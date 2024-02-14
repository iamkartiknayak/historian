import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'dart:io';
import 'dart:async';

import '../models/clipboard_item.dart';
import '../../../services/native_services.dart';

class ClipboardProvider extends ChangeNotifier with ClipboardListener {
  final List<ClipboardItem> _clipboard = [];
  List<ClipboardItem> get clipboard => _clipboard;

  final _scrollController = ItemScrollController();
  ItemScrollController get scrollController => _scrollController;

  final _positionsListener = ItemPositionsListener.create();
  ItemPositionsListener get positionsListener => _positionsListener;

  int _selectedItemIndex = 0;
  int get selectedItemIndex => _selectedItemIndex;

  late int _itemCount;
  bool _isInitialRun = false;

  bool _skipText = false;
  bool _skipImage = false;
  String _skippedItemValue = '';

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyPress);
    super.dispose();
  }

  @override
  void onClipboardChanged() {
    super.onClipboardChanged();
    copyTextToClipboard();
  }

  int _imageAutoDeleteIndex = 0;
  void stickToClipboardSize() {
    if (_clipboard.length > _itemCount) {
      for (int i = 0; i < _clipboard.length - 1; i++) {
        _clipboard[i] = _clipboard[i + 1];
      }

      _clipboard.removeLast();
      _imageAutoDeleteIndex += 1;
      NativeServices.runCommand('rm image$_imageAutoDeleteIndex.png');
    }
  }

  void copyTextToClipboard() async {
    final clipboarContent = await Clipboard.getData(Clipboard.kTextPlain);
    final content = clipboarContent?.text;

    final isValidString = content is String && content.trim().isNotEmpty;
    final isNewContent = clipboard.isEmpty || content != clipboard.last.content;

    if (_skipText) {
      final result = await Clipboard.getData(Clipboard.kTextPlain);
      _skippedItemValue = result?.text ?? '';
      _skipText = false;
    }

    final isSkippedItem = content == _skippedItemValue;
    if (!isValidString || !isNewContent || isSkippedItem) {
      return;
    }

    clipboard.add(
      ClipboardItem(
        id: const Uuid().v4(),
        content: content,
        isPinned: false,
      ),
    );
    stickToClipboardSize();
    scrollToTop();
  }

  void scrollToTop() {
    final clipboardLength = _clipboard.length;
    _selectedItemIndex = clipboard.length - 1;

    if (clipboardLength > 3) {
      scrollController.scrollTo(
        index: clipboard.length,
        duration: const Duration(seconds: 1),
      );
    }
    notifyListeners();
  }

  void loadAppSettings(int itemCount) {
    if (!_isInitialRun) {
      startListening();
      _isInitialRun = true;
    }

    _itemCount = itemCount;
    updateClipboardSize();
    scrollToTop();
  }

  late int _refreshTime;
  void setRefreshTime() => _refreshTime = NativeServices.isLinux ? 1 : 3;

  // called once during intial runtime
  void startListening() {
    RawKeyboard.instance.addListener(_handleKeyPress);
    NativeServices.initFileSystemVariables();
    setRefreshTime();

    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
    copyImageToClipboard();
  }

  int _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.isControlPressed) {
      final isFile = clipboard[selectedItemIndex].content is File;

      if (event.logicalKey == LogicalKeyboardKey.keyC) {
        copySelectedContent(_selectedItemIndex);
      }

      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        isFile ? deleteImage(selectedItemIndex) : deleteText(selectedItemIndex);
        _selectedItemIndex -= selectedItemIndex != 0 ? 1 : 0;
      }

      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        isFile
            ? saveImageFile(clipboard[selectedItemIndex].content.path)
            : null;
      }
      return selectedItemIndex;
    }

    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      if (selectedItemIndex + 1 < _clipboard.length) {
        _selectedItemIndex += 1;
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      if (_selectedItemIndex - 1 > -1) {
        _selectedItemIndex -= 1;
      }
    }

    _scrollController.scrollTo(
      index: _selectedItemIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    notifyListeners();
    return selectedItemIndex;
  }

  int _imageCount = 0;
  late ProcessResult lastSum;
  String latestImageHash = '';

  void addToClipboard(File file) {
    _clipboard.add(
      ClipboardItem(
        id: const Uuid().v4(),
        content: file,
        isPinned: false,
      ),
    );

    stickToClipboardSize();
    scrollToTop();
    return;
  }

  void copyImageToClipboard() {
    Timer.periodic(Duration(seconds: _refreshTime), (timer) async {
      try {
        final clipboardImageStat = await NativeServices.getClipboardImageStat();
        final tempImageHash = clipboardImageStat.$1;
        final imageExist = clipboardImageStat.$2;

        if (_imageCount == 0 && imageExist) {
          _imageCount += 1;
          await NativeServices.saveTempImageFile(_imageCount);
          addToClipboard(File('image$_imageCount.png'));
          latestImageHash = tempImageHash;
        }

        if (_skipImage) {
          final result = await NativeServices.getClipboardImageStat();
          _skippedItemValue = result.$1;
          _skipImage = false;
        }

        final isNewImage = latestImageHash != tempImageHash;
        final isNotSkippedItem = tempImageHash != _skippedItemValue;
        if (isNewImage && imageExist && !_skipImage && isNotSkippedItem) {
          _imageCount += 1;
          await NativeServices.saveTempImageFile(_imageCount);
          addToClipboard(File('image$_imageCount.png'));
          latestImageHash = tempImageHash;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void updateClipboardSize() {
    final clipboardLength = _clipboard.length;
    if (clipboardLength > _itemCount) {
      for (int i = clipboardLength - _itemCount - 1; i >= 0; i--) {
        clipboard.removeAt(i);
        NativeServices.runCommand('rm image$i.png');
      }
    }
  }

  Future<bool> saveImageFile(String imagePath) async {
    final saveInitDir = path.join(
      NativeServices.getHomeDirPath,
      'Downloads',
    );

    final tempFileName = '${const Uuid().v4()}.png';

    final String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Your File to desired location',
      initialDirectory: saveInitDir,
      lockParentWindow: true,
      fileName: tempFileName,
      type: FileType.image,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'heic'],
    );

    if (filePath == null) {
      return false;
    }

    final finalPath = path.join(
      NativeServices.getHomeDirPath,
      NativeServices.getTempDirPath,
      imagePath.split('/').last,
    );

    NativeServices.runCommand('cp $finalPath $filePath');
    return true;
  }

  // Copied item related functions
  // TODO: Fix altered order issue
  final Map<String, int> _pinnedItems = {};

  void pinItem(int index) {
    final item = _clipboard[index];

    deleteText(index);
    _clipboard.add(item.copyWith(isPinned: true));
    _pinnedItems[item.id] = index;

    for (var item in clipboard) {
      if (item.isPinned) {
        clipboard.insert(clipboard.length, item);
        clipboard.remove(item);
      }
    }

    debugPrint('PINNED : $_pinnedItems');
    notifyListeners();
  }

  void unpinItem(int index) {
    final item = _clipboard[index];
    final originalIndex = _pinnedItems[item.id];
    final updatedItem = item.copyWith(isPinned: false);

    deleteText(index);
    _clipboard.insert(originalIndex!, updatedItem);
    _pinnedItems.remove(item.id);

    // arrange items to separate pinned and unpinned
    for (var item in clipboard) {
      if (item.isPinned) {
        clipboard.insert(clipboard.length, item);
        clipboard.remove(item);
      }
    }

    debugPrint('PINNED : $_pinnedItems');
    notifyListeners();
  }

  void clearClipboard() {
    _imageCount = 0;
    _clipboard.clear();
    _imageAutoDeleteIndex = 0;
    PaintingBinding.instance.imageCache.clear();

    final homeDirPath = NativeServices.getHomeDirPath;
    final tempDirPath = NativeServices.getTempDirPath;
    final tempDirFinalPath = path.join(homeDirPath, tempDirPath);

    NativeServices.runCommand(
        'xclip -selection clipboard -t image/png -i /dev/null');
    NativeServices.runCommand('rm -r $tempDirFinalPath/*');
    Clipboard.setData(const ClipboardData(text: ''));
    notifyListeners();
  }

  void deleteText(int index) {
    Clipboard.setData(const ClipboardData(text: ''));
    _clipboard.removeAt(index);
    _imageCount -= 1;
    notifyListeners();
  }

  // void deleteImage(int index, File file) {
  void deleteImage(int index) {
    final image = clipboard[index].content;
    Clipboard.setData(const ClipboardData(text: ''));
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    image.delete();
    _clipboard.removeAt(index);
    _imageCount -= 1;
    notifyListeners();
  }

  void copySelectedContent(int index) {
    _selectedItemIndex = index;
    final content = clipboard[_selectedItemIndex].content;
    final isFile = content is File;

    isFile
        ? NativeServices.copySelectionToClipboard(content.path)
        : Clipboard.setData(ClipboardData(text: content));

    isFile ? _skipImage = true : _skipText = true;
    notifyListeners();
  }
}

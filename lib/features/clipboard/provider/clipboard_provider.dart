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

  void _handleKeyPress(RawKeyEvent event) {
    NativeServices.handleKeyPress(
      event,
      _selectedItemIndex,
      _clipboard.length,
      _scrollController,
    );
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

    if (!isValidString || !isNewContent) {
      return;
    }

    debugPrint('Copied String $content');
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
    _itemCount = itemCount;
    updateClipboardSize();
    scrollToTop();
    if (!_isInitialRun) {
      startListening();
      _isInitialRun = true;
    }
  }

  int _imageCount = 0;
  late ProcessResult lastSum;
  String latestImageHash = '';
  static const nullSha1Value = 'da39a3ee5e6b4b0d3255bfef95601890afd80709';

  Future copyImageToClipboard() async {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final imageExist = await NativeServices.doesImageExistInClipboard();
        final tempSum = await NativeServices.getClipboardImageShaValue();
        final tempImageHash = tempSum.stdout.split(' ').first;

        if (_imageCount == 0 && imageExist && tempImageHash != nullSha1Value) {
          _imageCount += 1;
          await NativeServices.saveTempImageFile(_imageCount);
          lastSum =
              await NativeServices.runCommand('sha1sum image$_imageCount.png');
          latestImageHash = lastSum.stdout.toString().split(' ').first;
          final file = File('image$_imageCount.png');
          clipboard.add(
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

        if (latestImageHash != tempImageHash &&
            imageExist &&
            tempImageHash != nullSha1Value) {
          _imageCount += 1;
          await NativeServices.saveTempImageFile(_imageCount);

          lastSum = await Process.run('sha1sum', ['image$_imageCount.png']);
          latestImageHash = lastSum.stdout.toString().split(' ').first;
          final file = File('image$_imageCount.png');
          clipboard.add(
            ClipboardItem(
              id: const Uuid().v4(),
              content: file,
              isPinned: false,
            ),
          );
          stickToClipboardSize();
          scrollToTop();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void startListening() {
    RawKeyboard.instance.addListener(_handleKeyPress);

    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
    copyImageToClipboard();
    NativeServices.createTempFolder();
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
    final String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Your File to desired location',
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

    deleteItem(index);
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

    deleteItem(index);
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

  void deleteItem(int index) {
    Clipboard.setData(const ClipboardData(text: ''));
    _clipboard.removeAt(index);
    _imageCount -= 1;
    notifyListeners();
  }

  void deleteImage(int index, File file) {
    Clipboard.setData(const ClipboardData(text: ''));
    PaintingBinding.instance.imageCache.clear();

    file.delete();
    _clipboard.removeAt(index);
    _imageCount -= 1;
    notifyListeners();
  }

  void copySelectedContent(dynamic content, bool isFile, int index) {
    _selectedItemIndex = index;

    isFile
        ? NativeServices.runCommand(
            'xclip -selection clipboard -t image/png -i ${content.path}')
        : Clipboard.setData(ClipboardData(text: content));

    notifyListeners();
  }
}

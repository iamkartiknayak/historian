import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/extensions/string_extensions.dart';
import '../../../services/snackbar_service.dart';
import '../models/image_item.dart';
import '../models/text_item.dart';
import '../utils/clipboard_utils.dart';

class ClipboardProvider extends ChangeNotifier {
  // getters
  List<dynamic> get clipboard => _clipboard;
  int get activeItemIndex => _activeItemIndex;
  ScrollController get scrollController => _scrollController;
  int get clipboardSize => _clipboardSize;

  // private var
  late final List<dynamic> _clipboard;
  late int _activeItemIndex;
  late final ScrollController _scrollController;
  late final List<dynamic> _deletedItems;
  late final BuildContext _context;
  late StreamSubscription<String> _clipboardSubscription;
  late final Box<dynamic> settingsConfig;

  static const previewCharLimit = 280;
  static const _clipboardMinSize = 5;
  static const _clipboardMaxSize = 30;

  String _previousClipboardText = '';
  String _previousImageHash = '';
  bool _isInitialized = false;
  bool _skipItem = false;
  bool _pauseClipboard = false;
  late int _clipboardSize;
  Timer? _timer;

// public methods
  void initControllers(BuildContext context) async {
    if (_isInitialized) return;

    debugPrint('ClipboardProvider initControllers is called');
    settingsConfig = Hive.box('settingsConfig');
    _clipboardSize = settingsConfig.get('clipboardSize', defaultValue: 30);
    _context = context;
    _clipboard = [];
    _deletedItems = [];
    _activeItemIndex = 0;
    _scrollController = ScrollController();
    _startListening();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _clipboardSubscription.cancel();
    super.dispose();
  }

  void clearClipboard() {
    try {
      for (var item in _clipboard) {
        if (!item.isPinned) {
          if (item.id.startsWith('image:')) {
            File('${item.id}.jpg').deleteSync();
          } else if (item.textFilePath.isNotEmpty) {
            File(item.textFilePath).deleteSync();
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong');
    }

    Clipboard.setData(const ClipboardData(text: ''));
    _clipboard.removeWhere((item) => !item.isPinned);
    SnackBarService.showSnackBar(
      context: _context,
      message: 'All unpinned items are cleared',
      time: 1000,
    );
    notifyListeners();
  }

  void copyItem(int index, {bool showSnackbar = true}) async {
    _skipItem = true;
    _activeItemIndex = index;

    String itemType = _clipboard[index].id.split(":")[0].toString();
    itemType = itemType.capitalize();
    itemType == 'Text' ? _copyTextItem(index) : _copyImageItem(index);

    if (showSnackbar) {
      SnackBarService.showSnackBar(
        message: '$itemType copied to clipboard',
        context: _context,
      );
    }
    notifyListeners();
  }

  void handleItemPin(int index) {
    final item = _clipboard[index];
    _clipboard[index] = item.copyWith(isPinned: !item.isPinned);
    notifyListeners();
  }

  void deleteItem(int index, {showSnackbar = true}) {
    if (!showSnackbar) {
      _clipboard.removeAt(index);
      return;
    }

    final deletedItem = _clipboard[index];
    _deletedItems.add(deletedItem);
    _clipboard.removeAt(index);
    _activeItemIndex = activeItemIndex == 0 ? 0 : activeItemIndex - 1;

    SnackBarService.showSnackBar(
      context: _context,
      message: 'Item deleted',
      showUndo: true,
    );
    notifyListeners();
  }

  void startModifyingClipboardSize(bool isIncremented) {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if ((isIncremented && _clipboardSize == _clipboardMaxSize) ||
          (!isIncremented && _clipboardSize == _clipboardMinSize)) {
        timer.cancel();
      }
      updateClipboardSize(isIncremented);
    });
  }

  void stopModifyingClipboardSize() => _timer?.cancel();

  void updateClipboardSize(bool isIncremented) {
    if (isIncremented && _clipboardSize == _clipboardMaxSize) return;
    if (!isIncremented && _clipboardSize == _clipboardMinSize) return;

    _clipboardSize += isIncremented ? 1 : -1;
    settingsConfig.put('clipboardSize', _clipboardSize);

    if (!isIncremented && _clipboard.length > _clipboardSize) {
      deleteItem(_clipboard.length - 1, showSnackbar: false);
    }

    notifyListeners();
  }

  void undoDeleteItem() {
    if (_deletedItems.isEmpty) return;

    final deletedItem = _deletedItems.first;

    if (_clipboard.length == _clipboardSize) {
      deleteItem(_clipboard.length - 1, showSnackbar: false);
    }

    _clipboard.insert(0, deletedItem);
    _deletedItems.removeAt(0);
    _activeItemIndex = 0;

    notifyListeners();
  }

  void deleteItemPermanently() {
    final item = _deletedItems[0];
    final isText = item.id.startsWith('text:');

    if (isText && item.textFilePath.isNotEmpty) {
      File(item.textFilePath).deleteSync();
    }

    _deletedItems.removeAt(0);
    notifyListeners();
  }

  void keyboardNavScroll(bool descending) {
    final currentOffset = _scrollController.offset;
    final minScroll = _scrollController.position.minScrollExtent;
    final maxScroll = _scrollController.position.maxScrollExtent;

    if ((descending && currentOffset >= maxScroll - 28) ||
        (!descending && currentOffset <= minScroll + 28)) {
      return;
    }

    final offset = currentOffset + (descending ? 125 : -125);
    _scrollController.jumpTo(offset);
  }

  void setActiveItemIndex(int index) {
    _activeItemIndex += index;
    notifyListeners();
  }

  void toggleClipboardListener() {
    _pauseClipboard = !_pauseClipboard;
    final clipboardStatus = _pauseClipboard ? 'paused' : 'resumed';

    SnackBarService.showSnackBar(
      context: _context,
      message: 'Clipboard has been $clipboardStatus',
      time: 1000,
    );
    notifyListeners();
  }

  Stream<String> _startListening() {
    final controller = StreamController<String>();
    Timer? timer;

    void checkClipboard() async {
      if (_pauseClipboard) return;

      try {
        final mimeResult = await Process.run('wl-paste', ['--list-types']);
        if (mimeResult.exitCode != 0) return;

        final mimeTypes = mimeResult.stdout
            .toString()
            .split('\n')
            .map((line) => line.trim())
            .where((e) => e.isNotEmpty)
            .toSet();

        if (mimeTypes.isEmpty) return;

        if (mimeTypes.contains('text/plain')) {
          final textResult = await Process.run('wl-paste', []);
          if (textResult.exitCode == 0) {
            final text = textResult.stdout.toString().trim();
            if (text.isNotEmpty && text != _previousClipboardText) {
              _getClipboardText(text);
            }
          }
          return;
        }

        if (mimeTypes.contains('image/png') ||
            mimeTypes.contains('image/jpeg')) {
          final extension = mimeTypes.contains('image/jpeg') ? 'jpeg' : 'png';
          _processImage(extension, (newHash) {
            _previousImageHash = newHash;
          });
        }
      } catch (e) {
        debugPrint('Error checking clipboard: $e');
      }
    }

    timer = Timer.periodic(
      const Duration(milliseconds: 700),
      (_) => checkClipboard(),
    );

    controller.onCancel = () {
      timer?.cancel();
      timer = null;
    };

    return controller.stream;
  }

  // TODO: Add prog-lang recognition for syntax highlight
  String _getTextCategory(String content) {
    String link = content.trim();
    return ClipboardUtils.isValidWebLink(link) ? 'url' : 'text';
  }

  Future<void> _processImage(
      String extension, Function(String) updateHash) async {
    try {
      final result = await Process.run(
        'wl-paste',
        ['--no-newline', '--type', 'image/$extension'],
        stdoutEncoding: Encoding.getByName('latin1'),
      );

      if (result.exitCode != 0 || result.stdout == null) return;

      final imageBytes = (result.stdout as String).codeUnits;
      final imageHash = crypto.sha256.convert(imageBytes).toString();

      if (_skipItem) {
        _previousImageHash = imageHash;
        _skipItem = false;
        return;
      }

      if (imageHash != _previousImageHash) {
        _previousImageHash = imageHash;
        updateHash(imageHash);

        final id = DateTime.now().toIso8601String();
        final filePath = '$id.$extension';
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);

        _getClipboardImage(file, extension);
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    }
  }

  Future<void> _getClipboardImage(File tempFile, String extension) async {
    try {
      final id = DateTime.now().toIso8601String();
      final newPath = '$id.$extension';

      await tempFile.rename(newPath);

      if (_clipboard.length == _clipboardSize) {
        deleteItem(_clipboard.length - 1, showSnackbar: false);
      }

      _clipboard.insert(
        0,
        ImageItem(
          id: 'image:$id',
          imageFilePath: newPath,
          isPinned: false,
          alt: '',
        ),
      );

      _activeItemIndex = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving clipboard image: $e');
    }
  }

  Future<void> _getClipboardText(String content) async {
    if (content == _previousClipboardText || content.isEmpty) return;

    if (_skipItem) {
      _previousClipboardText = content;
      _skipItem = false;
      return;
    }

    final previewLength =
        content.length <= previewCharLimit ? content.length : previewCharLimit;
    final textPreview = content.substring(0, previewLength);
    final id = DateTime.now().toIso8601String();
    late final String textFilePath;

    if (content.length > previewCharLimit) {
      textFilePath = '$id.txt';
      final file = File(textFilePath);

      try {
        await file.writeAsString(content);
      } catch (e) {
        debugPrint('Error writing to file: $e');
      }
    } else {
      textFilePath = '';
    }

    final textCategory = _getTextCategory(content);

    if (_clipboard.length == _clipboardSize) {
      deleteItem(_clipboard.length - 1, showSnackbar: false);
    }

    _clipboard.insert(
      0,
      TextItem(
        id: 'text:$id',
        textPreview: textPreview,
        textFilePath: textFilePath,
        textCategory: textCategory,
      ),
    );

    _previousClipboardText = content;
    _activeItemIndex = 0;
    notifyListeners();
  }

  void _copyTextItem(int index) async {
    final hasTextFile = clipboard[index].textFilePath.isNotEmpty;

    if (!hasTextFile) {
      Clipboard.setData(ClipboardData(text: clipboard[index].textPreview));
      return;
    }

    final fileName = clipboard[index].textFilePath;
    final file = File(fileName);

    try {
      final content = await file.readAsString();
      Clipboard.setData(ClipboardData(text: content));
    } catch (e) {
      debugPrint('Error reading the file: $e');
    }
  }

  void _copyImageItem(int index) async {
    final fileName = clipboard[index].imageFilePath;

    try {
      await Process.run('sh', ['-c', 'wl-copy < $fileName']);
    } catch (e) {
      debugPrint('Error copying image to clipboard: $e');
    }
  }
}

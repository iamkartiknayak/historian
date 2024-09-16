import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../services/snackbar_service.dart';
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
  late BuildContext _context;

  late final String _homeDirPath;
  final now = DateTime.now();
  static const previewCharLimit = 280;
  static const _clipboardMinSize = 5;
  static const _clipboardMaxSize = 30;

  String _previousClipboardText = '';
  bool _isInitialized = false;
  bool _skipItem = false;
  int _clipboardSize = 30;
  Timer? _timer;

// public methods
  void initControllers(BuildContext context) async {
    if (_isInitialized) return;

    debugPrint('ClipboardProvider initControllers is called');
    _context = context;
    _clipboard = [];
    _deletedItems = [];
    _activeItemIndex = 0;
    _homeDirPath = Platform.environment['HOME']!;
    _scrollController = ScrollController();
    _createAppFolder();
    _startListening();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    notifyListeners();
  }

  void copyItem(int index) async {
    _skipItem = true;
    _activeItemIndex = index;

    _copyTextItem(index);
    if (_context.mounted) {
      SnackBarService.showSnackBar(
        message: 'Text copied to clipboard',
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

  void deleteItem(int index) {
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

    if (!isIncremented && _clipboard.length > _clipboardSize) {
      deleteItem(_clipboard.length - 1);
    }

    notifyListeners();
  }

  void undoDeleteItem() {
    if (_deletedItems.isEmpty) return;

    final deletedItem = _deletedItems.first;

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

  // private methods
  void _createAppFolder() {
    final tempImagesDirPath = '$_homeDirPath/.historian/images';

    Directory(tempImagesDirPath).createSync(recursive: true);
    Directory.current = tempImagesDirPath;
    _deleteAllTempFiles();
  }

  void _deleteAllTempFiles() async {
    final directory = Directory.current;
    final List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      await entity.delete();
      debugPrint('File deleted: ${entity.path}');
    }
  }

  void _startListening() async {
    Timer.periodic(const Duration(milliseconds: 100), (_) async {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);

      final content = data?.text;
      if (content != null && content != _previousClipboardText) {
        _getClipboardText(content);
      }
    });
  }

  // TODO: Add prog-lang recognition for syntax highlight
  String _getTextCategory(String content) {
    String link = content.trim();
    return ClipboardUtils.isValidWebLink(link) ? 'url' : 'text';
  }

  Future<void> _getClipboardText(String content) async {
    if (content.trim().isEmpty) return;
    if (content == _previousClipboardText) return;

    if (_skipItem) {
      _previousClipboardText = content;
      _skipItem = false;
      return;
    }

    if (_clipboard.length == _clipboardSize) deleteItem(_clipboard.length - 1);

    final previewLength =
        content.length <= previewCharLimit ? content.length : previewCharLimit;
    final textPreview = content.substring(0, previewLength);
    final id = now.toIso8601String();
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
}

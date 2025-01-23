import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  late final BuildContext _context;
  late final Box<dynamic> settingsConfig;

  // late final String _homeDirPath;
  final now = DateTime.now();
  static const previewCharLimit = 280;
  static const _clipboardMinSize = 5;
  static const _clipboardMaxSize = 30;

  String _previousClipboardText = '';
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

    _copyTextItem(index);
    if (showSnackbar) {
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

  void _startListening() {
    final Duration checkInterval = const Duration(milliseconds: 300);

    Future<void> checkClipboard() async {
      if (_pauseClipboard) return;

      try {
        final process = await Process.start('wl-paste', []);

        process.stdout.transform(utf8.decoder).listen((content) {
          content = content.trim();
          if (content.isNotEmpty && content != _previousClipboardText) {
            _getClipboardText(content);
          }
        }, onError: (e) {
          debugPrint('Error reading stdout: $e');
        });
      } catch (e) {
        debugPrint('Error running wl-paste: $e');
      }
    }

    Timer.periodic(checkInterval, (_) => checkClipboard());
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

    if (_clipboard.length == _clipboardSize) {
      deleteItem(_clipboard.length - 1, showSnackbar: false);
    }

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

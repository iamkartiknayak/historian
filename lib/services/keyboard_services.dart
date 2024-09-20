import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './snackbar_service.dart';
import '../features/clipboard/providers/clipboard_provider.dart';
import '../features/emoji/providers/emoji_provider.dart';
import '../features/emoticon/providers/emoticon_provider.dart';
import '../features/home/pages/home_page.dart';
import '../features/home/providers/home_provider.dart';

class KeyboardService {
  static late BuildContext _context;
  static final Set<LogicalKeyboardKey> _pressedKeys = {};
  static bool _isKeyboardInitialized = false;

  static void initKeyboardListener(BuildContext context) {
    _context = context;
    if (_isKeyboardInitialized) return;

    debugPrint('KeyboardListener is initialized');
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
    _isKeyboardInitialized = true;
  }

  static void dispose() =>
      HardwareKeyboard.instance.removeHandler(_handleKeyPress);

  static bool _handleKeyPress(KeyEvent event) {
    final homePageState = homePageKey.currentState;
    final tabIndex = homePageState?.homeTabIndex;

    final homeProvider = _context.read<HomeProvider>();
    final clipboardProvider = _context.read<ClipboardProvider>();
    final emojiProvider = _context.read<EmojiProvider>();
    final emoticonProvider = _context.read<EmoticonProvider>();

    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);

      if (_pressedKeys.contains(LogicalKeyboardKey.controlLeft)) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.digit1:
            homeProvider.updateTabIndex(0);
            return false;

          case LogicalKeyboardKey.digit2:
            homeProvider.updateTabIndex(1);
            return false;

          case LogicalKeyboardKey.digit3:
            homeProvider.updateTabIndex(2);
            return false;
        }
      }

      switch (tabIndex) {
        case 0:
          _handleClipboardPage(event, clipboardProvider);
          return false;

        case 1:
          _handleEmojiPage(emojiProvider);
          break;

        case 2:
          _handleEmoticonPage(emoticonProvider);
          break;
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
    return false;
  }

  static void _handleClipboardPage(KeyEvent event, ClipboardProvider provider) {
    final activeItemIndex = provider.activeItemIndex;
    final clipboardNotEmpty = provider.clipboard.isNotEmpty;

    if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      if (!clipboardNotEmpty) return;
      final isLowerBound = activeItemIndex <= 0;
      provider.setActiveItemIndex(isLowerBound ? 0 : -1);
      provider.keyboardNavScroll(false);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      if (!clipboardNotEmpty) return;
      final isUpperBound = activeItemIndex >= provider.clipboard.length - 1;
      provider.setActiveItemIndex(isUpperBound ? 0 : 1);
      provider.keyboardNavScroll(true);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.controlLeft)) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyS:
          debugPrint('Save if image: Index $activeItemIndex');
          break;

        case LogicalKeyboardKey.keyD:
          if (!clipboardNotEmpty) return;
          provider.deleteItem(provider.activeItemIndex);
          break;

        case LogicalKeyboardKey.keyC:
          if (!clipboardNotEmpty) return;
          provider.copyItem(provider.activeItemIndex);
          break;

        case LogicalKeyboardKey.keyP:
          if (!clipboardNotEmpty) return;
          provider.handleItemPin(provider.activeItemIndex);
          break;

        case LogicalKeyboardKey.keyU:
          provider.undoDeleteItem();
          SnackBarService.scaffoldKey.currentState?.hideCurrentSnackBar();
          break;

        case LogicalKeyboardKey.keyL:
          if (!clipboardNotEmpty) return;
          provider.clearClipboard();
          break;
      }
    }
  }

  static void _handleEmojiPage(EmojiProvider provider) {
    if (_pressedKeys.contains(LogicalKeyboardKey.controlLeft) &&
        _pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      provider.toggleSearchBar();
    }
  }

  static void _handleEmoticonPage(EmoticonProvider provider) {
    if (_pressedKeys.contains(LogicalKeyboardKey.controlLeft) &&
        _pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      provider.toggleSearchBar();
    }
  }
}

import 'package:flutter/cupertino.dart';

enum ModificationType {
  increment,
  decrement,
}

class SettingsPageProvider extends ChangeNotifier {
  int _clipboardSize = 15;
  int get clipboardSize => _clipboardSize;

  void setClipboardSize(ModificationType type) {
    switch (type) {
      case ModificationType.increment:
        _clipboardSize += (_clipboardSize < 30) ? 1 : 0;
        break;

      case ModificationType.decrement:
        _clipboardSize -= (_clipboardSize > 1) ? 1 : 0;
        break;
    }
    notifyListeners();
  }
}

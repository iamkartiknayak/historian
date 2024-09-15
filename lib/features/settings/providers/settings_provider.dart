import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  // getters
  List<Color> get accentColors => _accentColors;
  int get accentColorLength => _accentColors.length;
  int get accentColorIndex => _accentColorIndex;
  double get categoryOneRadius => _categoryOneRadius;
  double get categoryTwoRadius => _categoryTwoRadius;
  int get selectedBorderRadiusConfig => _selectedBorderRadiusConfig;
  Color get accentColor => _accentColors[_accentColorIndex];
  bool get isClipboardListening => _isClipboardListening;
  Animation<double> get animation => _animation;

  // private var
  late List<Color> _accentColors;
  late AnimationController _animationController;
  late Animation<double> _animation;

  double _categoryOneRadius = 8.0; // more rounded => switch, color palette
  double _categoryTwoRadius = 8.0; // more curved => clipboard item, buttons
  int _selectedBorderRadiusConfig = 1;
  int _accentColorIndex = 0;
  bool _isClipboardListening = true;

  final List<Color> _lightAccentColors = [
    const Color(0xFF62d0df), // 1
    const Color(0xFFa0bfeb), // 2
    const Color(0xFFe89cff), // 3
    const Color(0xFFff9cb1), // 4
    const Color(0xFFffad01), // 5
    const Color(0xFFf8e062), // 6
    const Color(0xFF93cf9c), // 7
    const Color(0xFFccb9b5), // 8
  ];

  bool _isInitialized = false;

  // public methods
  void initControllers(TickerProvider vsync) {
    if (_isInitialized) return;

    debugPrint('SettingsProvider initControllers is called');
    _accentColors = _lightAccentColors;
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _toggleSwitch();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setAccentColor(int index) {
    _accentColorIndex = index;
    notifyListeners();
  }

  void setBorderRadiusConfig(int radius) {
    switch (radius) {
      case 0:
        _categoryOneRadius = 20.0;
        _categoryTwoRadius = 6.0;
        _selectedBorderRadiusConfig = 0;
        break;

      case 1:
        _categoryOneRadius = 6.0;
        _categoryTwoRadius = 4.0;
        _selectedBorderRadiusConfig = 1;
        break;

      case 2:
        _categoryOneRadius = 0.0;
        _categoryTwoRadius = 0.0;
        _selectedBorderRadiusConfig = 2;
        break;
    }

    notifyListeners();
  }

  void toggleClipboardListener() {
    _isClipboardListening = !_isClipboardListening;
    _toggleSwitch();
  }

  // private methods
  void _toggleSwitch() => _isClipboardListening
      ? _animationController.forward()
      : _animationController.reverse();
}

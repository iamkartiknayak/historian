import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../../services/snackbar_service.dart';
import '../../clipboard/providers/clipboard_provider.dart';
import '../../emoji/providers/emoji_provider.dart';
import '../../emoticon/providers/emoticon_provider.dart';

class SettingsProvider extends ChangeNotifier {
  // getters
  List<Color> get accentColors => _accentColors;
  int get accentColorIndex => _accentColorIndex;
  int get fitzpatrickScaleIndex => _fitzpatrickScaleIndex;
  double get categoryOneRadius => _categoryOneRadius;
  double get categoryTwoRadius => _categoryTwoRadius;
  int get selectedBorderRadiusConfig => _selectedBorderRadiusConfig;
  Color get accentColor => _accentColors[_accentColorIndex];
  bool get isClipboardListening => _isClipboardListening;
  Animation<double> get animation => _animation;
  fitzpatrick get skinTone => _skinTone;

  // private var
  late List<Color> _accentColors;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final BuildContext _context;
  late final Box<dynamic> settingsConfig;

  double _categoryOneRadius = 8.0; // more rounded => switch, color palette
  double _categoryTwoRadius = 8.0; // more curved => clipboard item, buttons
  int _selectedBorderRadiusConfig = 1;
  int _accentColorIndex = 0;
  int _fitzpatrickScaleIndex = 0;
  fitzpatrick _skinTone = fitzpatrick.None;
  bool _isClipboardListening = true;

  final List<Color> _darkAccentColors = [
    const Color(0xFF62d0df), // 1
    const Color(0xFFa0bfeb), // 2
    const Color(0xFFe89cff), // 3
    const Color(0xFFff9cb1), // 4
    const Color(0xFFffad01), // 5
    const Color(0xFFf8e062), // 6
    const Color(0xFF93cf9c), // 7
    const Color(0xFFccb9b5), // 8
  ];

  final List<Color> _lightAccentColors = [
    const Color(0xFF4ea6b2), //1
    const Color(0xFF8099bc), //2
    const Color(0xFFba7dcc), //3
    const Color(0xFFcc7d8e), //4
    const Color(0xFFcc8a01), //5
    const Color(0xFFc6b34e), //6
    const Color(0xFF76a67d), //7
    const Color(0xFFa39491), //8
  ];

  final List<Color> fitzpatrickScaleColors = [
    const Color(0xFFFFCC22),
    const Color(0xFFFFCCB0),
    const Color(0xFFE0B387),
    const Color(0xFFD18B61),
    const Color(0xFFA86943),
    const Color(0xFF5A463A),
  ];

  bool _isInitialized = false;

  // public methods
  void initControllers(TickerProvider vsync, BuildContext context) {
    if (_isInitialized) return;

    debugPrint('SettingsProvider initControllers is called');
    settingsConfig = Hive.box('settingsConfig');
    Future(() => _getSettingsConfigFromDb());
    _context = context;
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
    settingsConfig.put('accentColorIndex', _accentColorIndex);
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
    settingsConfig.put('borderRadiusConfig', _selectedBorderRadiusConfig);
    settingsConfig.put('categoryOneRadius', _categoryOneRadius);
    settingsConfig.put('categoryTwoRadius', _categoryTwoRadius);
    notifyListeners();
  }

  void toggleClipboardListener() {
    _isClipboardListening = !_isClipboardListening;
    _context.read<ClipboardProvider>().toggleClipboardListener();
    _toggleSwitch();
  }

  void setAccentPallete(bool isLightTheme) {
    _accentColors = isLightTheme ? _lightAccentColors : _darkAccentColors;
    setAccentColor(_accentColorIndex);
  }

  void setFitzpatrickScaleColor(int index) {
    _fitzpatrickScaleIndex = index;
    _skinTone = _getSkinTone(_fitzpatrickScaleIndex);
    settingsConfig.put('fitzpatrickScaleIndex', _fitzpatrickScaleIndex);
    notifyListeners();
  }

  void clearRecents() {
    _context.read<EmojiProvider>().clearRecentEmojis();
    _context.read<EmoticonProvider>().clearRecentEmoticons();
    SnackBarService.showSnackBar(
      context: _context,
      message: 'All recents are cleared',
      time: 1000,
    );
  }

  // private methods
  void _toggleSwitch() => _isClipboardListening
      ? _animationController.forward()
      : _animationController.reverse();

  void _getSettingsConfigFromDb() {
    _accentColorIndex = settingsConfig.get('accentColorIndex', defaultValue: 2);
    _categoryOneRadius = settingsConfig.get(
      'categoryOneRadius',
      defaultValue: 8.0,
    );
    _categoryTwoRadius = settingsConfig.get(
      'categoryTwoRadius',
      defaultValue: 8.0,
    );
    _selectedBorderRadiusConfig = settingsConfig.get(
      'borderRadiusConfig',
      defaultValue: 1,
    );
    _fitzpatrickScaleIndex = settingsConfig.get(
      'fitzpatrickScaleIndex',
      defaultValue: 0,
    );
    _skinTone = _getSkinTone(_fitzpatrickScaleIndex);
    notifyListeners();
  }

  fitzpatrick _getSkinTone(int index) {
    switch (index) {
      case 0:
        return fitzpatrick.None;
      case 1:
        return fitzpatrick.light;
      case 2:
        return fitzpatrick.mediumLight;
      case 3:
        return fitzpatrick.medium;
      case 4:
        return fitzpatrick.mediumDark;
      case 5:
        return fitzpatrick.dark;
      default:
        return fitzpatrick.None;
    }
  }
}

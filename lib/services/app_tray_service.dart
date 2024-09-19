import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../features/settings/providers/settings_provider.dart';

class AppTrayService {
  AppTrayService._privateConstructor();
  static final AppTrayService _instance = AppTrayService._privateConstructor();
  factory AppTrayService() => _instance;

  // getters
  static String get exitFlag => _instance._exitFlag;

  // private var
  final AppWindow _appWindow = AppWindow();
  final SystemTray _systemTray = SystemTray();
  final Menu _menuMain = Menu();
  late final BuildContext _context;

  String _iconBrightness = 'dark';
  String _exitFlag = "keep";
  bool _isWindowVisible = true;
  bool _isListening = true;
  bool _isInitialized = false;

  // public methods
  static Future<void> initAppTray(BuildContext context) async {
    if (_instance._isInitialized) return;
    _instance._context = context;
    debugPrint('AppTray initControllers called');
    await _instance._systemTray.initSystemTray(
      iconPath: 'assets/tray_icons/logo_dark_active.png',
      toolTip: 'Historian',
    );
    _instance._systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        _instance._systemTray.popUpContextMenu();
      }
    });
    if (context.mounted) {
      await _buildTrayMenu();
    }
    _instance._isInitialized = true;
  }

  static void toggleClipboardListener() {
    _instance._isListening = !_instance._isListening;
    _updateTrayIcon();
  }

  static void rebuildAppTray(bool isVisible) async {
    _instance._isWindowVisible = isVisible;
    await _buildTrayMenu();
  }

  static void setTrayIconBrightness(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    _instance._iconBrightness = isLightTheme ? 'light' : 'dark';
    _updateTrayIcon();
  }

  // private methods
  static void _updateTrayIcon() async {
    final imagePath = _instance._isListening
        ? 'assets/tray_icons/logo_${_instance._iconBrightness}_active.png'
        : 'assets/tray_icons/logo_${_instance._iconBrightness}_inactive.png';
    _instance._systemTray.setImage(imagePath);
    rebuildAppTray(_instance._isWindowVisible);
  }

  static Future<void> _buildTrayMenu() async {
    final provider = _instance._context.read<SettingsProvider>();

    await _instance._menuMain.buildFrom(
      [
        !_instance._isWindowVisible
            ? MenuItemLabel(
                label: 'Show',
                onClicked: (menuItem) async {
                  _instance._isWindowVisible = true;
                  _instance._appWindow.show();
                  WindowManager.instance.setAlwaysOnTop(true);
                  rebuildAppTray(true);
                },
              )
            : MenuItemLabel(
                label: 'Hide',
                onClicked: (menuItem) async {
                  _instance._isWindowVisible = false;
                  _instance._appWindow.hide();
                  rebuildAppTray(false);
                },
              ),
        MenuSeparator(),
        _instance._isListening
            ? MenuItemLabel(
                label: 'Pause',
                onClicked: (menuItem) => provider.toggleClipboardListener(),
              )
            : MenuItemLabel(
                label: 'Resume',
                onClicked: (menuItem) => provider.toggleClipboardListener(),
              ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Exit',
          onClicked: (menuItem) {
            _instance._exitFlag = "terminate";
            _instance._appWindow.close();
          },
        ),
      ],
    );
    _instance._systemTray.setContextMenu(_instance._menuMain);
  }
}

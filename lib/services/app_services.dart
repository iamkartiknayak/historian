import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './snackbar_service.dart';

class AppServices {
  AppServices._privateConstructor();
  static final AppServices _instance = AppServices._privateConstructor();
  factory AppServices() => _instance;

  // getters
  String get hiveDbSavedirPath => _hiveDbSavedirPath;

  // private var
  late final String _homeDirPath;
  late final String _hiveDbSavedirPath;
  late final BuildContext _context;
  bool _isInitialized = false;

  // public methods
  Future<void> initData() async {
    debugPrint('App Services init is called');
    _homeDirPath = Platform.environment['HOME']!;
    await _createAppFolder();
    await Hive.initFlutter(AppServices().hiveDbSavedirPath);
    await Hive.openBox('settingsConfig');
    await Hive.openBox('recents');
  }

  void setContext(BuildContext context) {
    if (_isInitialized) return;

    _context = context;
    _isInitialized = true;
  }

  void launchUrl(String url) {
    Process.run('xdg-open', [url]);
    SnackBarService.showSnackBar(
      context: _context,
      message: 'Launching ${Uri.parse(url).host}',
      time: 1000,
    );
  }

  Future<void> saveImage(String filePath) async {
    final fileName = filePath.split('/').last;
    final extension = fileName.split('.').last;

    final result = await Process.run(
      'zenity',
      [
        '--file-selection',
        '--save',
        '--confirm-overwrite',
        '--title=Save Image As',
        '--filename=$_homeDirPath/$fileName',
        '--file-filter=*.$extension'
      ],
    );

    if (result.exitCode != 0) return;

    final newPath = result.stdout.toString().trim();
    final saveResult = await Process.run('cp', [filePath, newPath]);

    if (_context.mounted && saveResult.exitCode == 0) {
      SnackBarService.showSnackBar(
        context: _context,
        message: 'Image has been saved successfully',
        time: 1000,
      );
    }
  }

  // private methods
  Future<void> _createAppFolder() async {
    final tempSaveDirPath = '$_homeDirPath/.historian/tempData';
    _hiveDbSavedirPath = '$_homeDirPath/.historian/hive';

    Directory(tempSaveDirPath).createSync(recursive: true);
    Directory(_hiveDbSavedirPath).createSync(recursive: true);
    Directory.current = tempSaveDirPath;
    await _deleteAllTempFiles();
  }

  Future<void> _deleteAllTempFiles() async {
    final directory = Directory.current;
    final List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      await entity.delete();
      debugPrint('File deleted: ${entity.path}');
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

class AppServices {
  AppServices._privateConstructor();
  static final AppServices _instance = AppServices._privateConstructor();
  factory AppServices() => _instance;

  // getters
  String get hiveDbSavedirPath => _hiveDbSavedirPath;

  // private var
  late final String _homeDirPath;
  late final String _hiveDbSavedirPath;

  // public methods
  Future<void> initData() async {
    debugPrint('App Services init is called');
    _homeDirPath = Platform.environment['HOME']!;
    await _createAppFolder();
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

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'dart:io';
import 'package:flutter/services.dart';

class NativeServices {
  static const _tempDirPath = '.historian/temp';
  static String get getTempDirPath => _tempDirPath;

  static final _homeDirPath = Platform.environment['HOME']!;
  static String get getHomeDirPath => _homeDirPath;

  // create temp  directory to save copied images temporarily
  static void createTempFolder() {
    final folderPath = path.join(_homeDirPath, _tempDirPath);

    Directory(folderPath).createSync(recursive: true);
    Directory.current = folderPath;
    runCommand('rm -r $folderPath/*');
  }

  // run linux commands
  static Future<ProcessResult> runCommand(String command) async =>
      await Process.run('/bin/bash', ['-c', command]);

  // handles various keypress events
  static int handleKeyPress(
    RawKeyEvent event,
    int selectedItemIndex,
    int clipboardLength,
    ItemScrollController scrollController,
  ) {
    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      if (selectedItemIndex + 1 < clipboardLength) {
        selectedItemIndex += 1;
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      if (selectedItemIndex - 1 > -1) {
        selectedItemIndex -= 1;
      }
    }

    scrollController.scrollTo(
      index: selectedItemIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // notifyListeners();
    return selectedItemIndex;
  }

  // returns result of calculating sha1value of the image in clipboard
  static Future<ProcessResult> getClipboardImageShaValue() async =>
      await runCommand('xclip -selection clipboard -t image/png -o | sha1sum');

  // checks if image exist in clipboard
  static Future<bool> doesImageExistInClipboard() async {
    final tempSum = await getClipboardImageShaValue();
    return tempSum.stderr.toString().isEmpty;
  }

  // save copied images to temp folder
  static Future<void> saveTempImageFile(int imageCount) async {
    await runCommand(
        'xclip -selection clipboard -t image/png -o > image$imageCount.png');
  }
}

import 'package:path/path.dart' as path;

import 'dart:io';

import './native_scripts.dart';

enum PlatformType {
  linux,
  windows,
}

class NativeServices {
  static late String _tempDirPath;
  static String get getTempDirPath => _tempDirPath;

  static late String _homeDirPath;
  static String get getHomeDirPath => _homeDirPath;

  static late PlatformType _platformType;

  static final isLinux = _platformType == PlatformType.linux;

  static const nullSha1Value = 'da39a3ee5e6b4b0d3255bfef95601890afd80709';

  // execute functions in order to setup storage access
  static void initFileSystemVariables() {
    setPlatformValues(); // sets isLinux
    setHomeDirPath(); // gets path according to system
    createTempFolder(); // create temp dir in acquired path
  }

  // fetch and set isLinux var to help execute tasks in other function accordingly
  static void setPlatformValues() {
    final platform = Platform.operatingSystem;
    switch (platform) {
      case 'linux':
        _platformType = PlatformType.linux;
        break;

      case 'windows':
        _platformType = PlatformType.windows;
        break;
    }
  }

  // get system specific home dir path
  static void setHomeDirPath() {
    _homeDirPath = isLinux
        ? Platform.environment['HOME']!
        : Platform.environment['USERPROFILE']!;

    _tempDirPath = isLinux ? '.historian/temp' : r'.historian\temp';
  }

  // create temp  directory to save copied images temporarily
  static void createTempFolder() {
    final folderPath = path.join(_homeDirPath, _tempDirPath);

    Directory(folderPath).createSync(recursive: true);
    Directory.current = folderPath;
    runCommand('rm -r $folderPath/*');
  }

  // run system commands
  static Future<ProcessResult> runCommand(String command) async {
    final executor = isLinux ? '/bin/bash' : 'powershell';
    return await Process.run(executor, ['-c', command]);
  }

  // validates string for sha1
  static bool isValidSHA1(String inputString) {
    if (isLinux && inputString == nullSha1Value) {
      return false;
    }

    if (!isLinux && inputString == 'clipboard.') {
      return false;
    }

    RegExp sha1Regex = RegExp(r'^[0-9a-fA-F]{40}$');
    return sha1Regex.hasMatch(inputString);
  }

  // returns sha1value of the image in clipboard if exist
  // returns if error is empty to validate clip-image existance
  static Future<(String, bool)> getClipboardImageStat() async {
    final cmd = isLinux
        ? NativeScripts.linuxClipImageShaCmd
        : NativeScripts.windowsClipImageShaCmd;

    final result = await runCommand(cmd);
    final sha1Sum = isLinux
        ? result.stdout.toString().trim().split(' ').first
        : result.stdout.toString().trim().split(' ').last;
    final imageExist = isValidSHA1(sha1Sum);

    return (sha1Sum, imageExist);
  }

  // returns sha1Value of a image saved in file-system
  static Future<String> getFSImageStat(int imageCount) async {
    final cmd = isLinux
        ? NativeScripts.getLinuxFSImageShaCmd(imageCount)
        : NativeScripts.getWindowsFSImageShaCmd(imageCount);

    final result = await runCommand(cmd);
    final sha1Sum = isLinux
        ? result.stdout.toString().trim().split(' ').first
        : result.stdout.toString().trim().split(' ').last;

    return sha1Sum;
  }

  // save copied images to temp folder
  static Future<void> saveTempImageFile(int imageCount) async =>
      await runCommand(
        isLinux
            ? NativeScripts.getLinuxClipImageSaveCmd(imageCount)
            : NativeScripts.getWindowsClipImageSaveCmd(imageCount),
      );

  // copies selected non-text content to clipboard
  static Future<void> copySelectionToClipboard(String imagePath) async =>
      await runCommand(
        isLinux
            ? NativeScripts.getLinuxSelectionToClipCmd(imagePath)
            : NativeScripts.getWindowsSelectionToClipCmd(imagePath),
      );
}

import 'package:flutter/material.dart';

@immutable
sealed class NativeScripts {
  static const linuxClipImageShaCmd =
      'xclip -selection clipboard -t image/png -o | sha1sum';

  static const windowsClipImageShaCmd = '''
          Add-Type -AssemblyName System.Windows.Forms
          \$image = [System.Windows.Forms.Clipboard]::GetImage()

          if (\$image -ne \$null) {
              \$imageStream = New-Object System.IO.MemoryStream
              \$image.Save(\$imageStream, [System.Drawing.Imaging.ImageFormat]::Png)

              \$sha1 = [System.Security.Cryptography.SHA1]::Create().ComputeHash(\$imageStream.ToArray())
              \$sha1Hex = [System.BitConverter]::ToString(\$sha1) -replace "-"

              Write-Output "SHA-1 Hash: \$sha1Hex"
          } else {
              Write-Output "No image data found in the clipboard."
          }
          ''';

  static String getLinuxClipImageSaveCmd(int imageCount) =>
      'xclip -selection clipboard -t image/png -o > image$imageCount.png';

  static String getWindowsClipImageSaveCmd(int imageCount) => '''
          Add-Type -AssemblyName System.Windows.Forms
          \$image = [System.Windows.Forms.Clipboard]::GetImage()
          if (\$image -ne \$null) {
          \$image.Save("image$imageCount.png", [System.Drawing.Imaging.ImageFormat]::Png)
          Write-Host "Image saved to image_from_clipboard.png"
          } else {
          Write-Host "No image data found in the clipboard."
          }
        ''';

  static String getLinuxFSImageShaCmd(int imageCount) =>
      'sha1sum image$imageCount.png';

  static String getWindowsFSImageShaCmd(int imageCount) => '''
          \$filePath = "image$imageCount.png"
          \$sha1Hash = Get-FileHash -Path \$filePath -Algorithm SHA1
          Write-Host "SHA-1 Hash: \$(\$sha1Hash.Hash)"
          ''';

  static String getLinuxSelectionToClipCmd(String imagePath) =>
      'xclip -selection clipboard -t image/png -i $imagePath';

  static String getWindowsSelectionToClipCmd(String imagePath) => '''
              Add-Type -AssemblyName System.Windows.Forms
              \$imagePath = '$imagePath'
              [System.Windows.Forms.Clipboard]::SetImage([System.Drawing.Image]::FromFile(\$imagePath))
              Write-Output "Image copied to clipboard successfully."
                    ''';
}

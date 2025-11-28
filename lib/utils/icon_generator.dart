import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  // Create directories
  await _createDirectories();

  // Copy icon to Android directories
  await _copyIcons();

  print('Icons have been set up successfully!');
}

Future<void> _createDirectories() async {
  final directories = [
    'android/app/src/main/res/mipmap-mdpi',
    'android/app/src/main/res/mipmap-hdpi',
    'android/app/src/main/res/mipmap-xhdpi',
    'android/app/src/main/res/mipmap-xxhdpi',
    'android/app/src/main/res/mipmap-xxxhdpi',
  ];

  for (var dir in directories) {
    await Directory(dir).create(recursive: true);
  }
}

Future<void> _copyIcons() async {
  // Copy the app_logo.png to all Android directories
  final sourceFile = File('assets/app_logo.png');

  if (!await sourceFile.exists()) {
    print('Error: app_logo.png not found in assets folder');
    return;
  }

  // Copy to Android directories
  await _copyToAndroid(sourceFile, 'mipmap-mdpi', 48);
  await _copyToAndroid(sourceFile, 'mipmap-hdpi', 72);
  await _copyToAndroid(sourceFile, 'mipmap-xhdpi', 96);
  await _copyToAndroid(sourceFile, 'mipmap-xxhdpi', 144);
  await _copyToAndroid(sourceFile, 'mipmap-xxxhdpi', 192);
}

Future<void> _copyToAndroid(File source, String folder, int size) async {
  final destPath = 'android/app/src/main/res/$folder/ic_launcher.png';

  // Resize and save the image
  final result = await FlutterImageCompress.compressAndGetFile(
    source.path,
    destPath,
    minWidth: size,
    minHeight: size,
    quality: 100,
  );

  if (result != null) {
    print('Created: $destPath');
  } else {
    print('Failed to create: $destPath');
  }
}
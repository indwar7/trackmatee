import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

void main() async {
  print("🔧 Generating app icons...");

  final String source = "assets/app_logo.png";

  if (!File(source).existsSync()) {
    print("❌ ERROR: assets/app_logo.png not found");
    exit(1);
  }

  await _makeIcon(source, "mipmap-mdpi", 48);
  await _makeIcon(source, "mipmap-hdpi", 72);
  await _makeIcon(source, "mipmap-xhdpi", 96);
  await _makeIcon(source, "mipmap-xxhdpi", 144);
  await _makeIcon(source, "mipmap-xxxhdpi", 192);

  print("✔ All icons ready!");
}

Future<void> _makeIcon(String src, String folder, int size) async {
  final dir = "android/app/src/main/res/$folder";
  await Directory(dir).create(recursive: true);

  final dest = "$dir/ic_launcher.png";
  final result = await FlutterImageCompress.compressAndGetFile(
    src,
    dest,
    minWidth: size,
    minHeight: size,
    quality: 95,
  );

  print(result != null
      ? "✔ Generated → $dest"
      : "❌ Failed → $dest");
}

#!/bin/bash

# Create directories if they don't exist
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

# Convert the logo to different sizes
convert assets/app_logo.png -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
convert assets/app_logo.png -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
convert assets/app_logo.png -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
convert assets/app_logo.png -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
convert assets/app_logo.png -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# For adaptive icons (Android 8.0+)
convert -size 108x108 xc:black -fill white -draw 'circle 54,54 54,0' android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png
convert -size 108x108 xc:transparent -fill "#000000" -draw 'circle 54,54 54,0' android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_background.png

# For iOS (you'll need to set these in Xcode)
convert assets/app_logo.png -resize 1024x1024 ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcon-1024x1024.png

# For web
convert assets/app_logo.png -resize 512x512 web/favicon.png

echo "Icons have been generated successfully!"

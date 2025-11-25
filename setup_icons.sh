#!/bin/bash

# Create directories if they don't exist
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first:"
    echo "  brew install imagemagick"
    exit 1
fi

# Copy and resize the app icon for different densities
if [ -f "assets/app_logo.png" ]; then
    # Android icons
    convert assets/app_logo.png -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    convert assets/app_logo.png -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    convert assets/app_logo.png -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    convert assets/app_logo.png -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    convert assets/app_logo.png -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
    
    # For iOS (you'll need to set this up in Xcode)
    mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset
    cp assets/app_logo.png ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcon-1024x1024.png
    
    # For web
    cp assets/app_logo.png web/favicon.png
    
    echo "Icons have been set up successfully!"
    echo "Please open Xcode and set up the iOS app icon manually:"
    echo "1. Open ios/Runner.xcworkspace in Xcode"
    echo "2. Select Runner in the project navigator"
    echo "3. Go to the 'Runner' target"
    echo "4. In the 'General' tab, set the App Icons Source"
    
    # Open Xcode
    open -a Xcode ios/Runner.xcworkspace
else
    echo "Error: app_logo.png not found in the assets folder"
    exit 1
fi

#!/bin/bash
set -e

echo "Setting up Flutter environment..."

# Install Flutter if not present
if [ ! -d "flutter" ]; then
    echo "Downloading Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Set Flutter to not warn about root
export FLUTTER_ROOT="$PWD/flutter"

echo "Flutter version:"
flutter --version --suppress-analytics

echo "Configuring Flutter for web..."
flutter config --enable-web --no-analytics --suppress-analytics

echo "Getting dependencies..."
cd frontend
flutter pub get --suppress-analytics

echo "Building web app..."
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=false

echo "Build complete!"

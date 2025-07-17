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

echo "Flutter version:"
flutter --version

echo "Configuring Flutter for web..."
flutter config --enable-web --no-analytics

echo "Getting dependencies..."
cd frontend
flutter pub get

echo "Building web app..."
flutter build web --release --web-renderer html

echo "Build complete!"

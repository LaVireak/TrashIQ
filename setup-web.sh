#!/bin/bash
set -e

echo "Setting up web deployment..."

# Check if build directory exists, if not, build it
if [ ! -d "frontend/build/web" ]; then
    echo "Build directory not found. Building Flutter web app..."
    
    # Install Flutter if not present
    if [ ! -d "flutter" ]; then
        echo "Downloading Flutter..."
        git clone https://github.com/flutter/flutter.git -b stable --depth 1
    fi

    # Add Flutter to PATH and set environment
    export PATH="$PWD/flutter/bin:$PATH"
    export FLUTTER_ROOT="$PWD/flutter"

    echo "Flutter version:"
    flutter --version --suppress-analytics

    echo "Configuring Flutter for web..."
    flutter config --enable-web --no-analytics --suppress-analytics

    echo "Getting dependencies..."
    cd frontend
    flutter pub get --suppress-analytics

    echo "Building web app..."
    flutter build web --release

    echo "Build complete!"
    cd ..
else
    echo "Build directory found, using existing build..."
fi

echo "Copying web build files to root..."
# Copy the web build to a 'web' directory at root level
cp -r frontend/build/web ./web

echo "Web files copied successfully!"
echo "Contents of web directory:"
ls -la web/

echo "Deployment setup complete!"

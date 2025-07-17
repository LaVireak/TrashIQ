#!/bin/bash
set -e

echo "Setting up web deployment..."

# Check if build directory exists
if [ ! -d "frontend/build/web" ]; then
    echo "Error: frontend/build/web directory not found!"
    echo "Please run 'flutter build web' first."
    exit 1
fi

echo "Copying web build files to root..."
# Copy the web build to a 'web' directory at root level
cp -r frontend/build/web ./web

echo "Web files copied successfully!"
echo "Contents of web directory:"
ls -la web/

echo "Deployment setup complete!"

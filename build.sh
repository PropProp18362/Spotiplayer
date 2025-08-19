#!/bin/bash

# Exit on error
set -e

echo "Starting Flutter web build process..."

# Install Flutter
echo "Cloning Flutter repository..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
echo "Flutter cloned successfully."

# Add Flutter to PATH
echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"
echo "Current PATH: $PATH"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version

# Enable web
echo "Enabling Flutter web..."
flutter config --enable-web

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build web
echo "Building Flutter web app..."
flutter build web --release

# Output success message
echo "Flutter web build completed successfully!"
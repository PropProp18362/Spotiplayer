#!/bin/bash

# Exit on error
set -e

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build web
flutter build web --release

# Output success message
echo "Flutter web build completed successfully!"
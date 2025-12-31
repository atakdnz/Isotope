#!/bin/bash

# Isotope DMG Build Script
# Run from project root directory

set -e

APP_NAME="Isotope"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
BUILD_DIR="build"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"

echo "🔨 Building ${APP_NAME}..."

# Clean and build release
xcodebuild -project ${APP_NAME}.xcodeproj \
    -scheme ${APP_NAME} \
    -configuration Release \
    -derivedDataPath ${BUILD_DIR} \
    clean build

# Find the built app
BUILT_APP=$(find ${BUILD_DIR} -name "${APP_NAME}.app" -type d | head -1)

if [ -z "$BUILT_APP" ]; then
    echo "❌ Error: Could not find ${APP_NAME}.app"
    exit 1
fi

echo "📦 Found app at: ${BUILT_APP}"

# Copy to build directory
cp -R "${BUILT_APP}" "${APP_PATH}"

# Create temporary DMG directory
DMG_TEMP="dmg_temp"
rm -rf "${DMG_TEMP}"
mkdir -p "${DMG_TEMP}"

# Copy app to DMG temp folder
cp -R "${APP_PATH}" "${DMG_TEMP}/"

# Create symlink to Applications folder
ln -s /Applications "${DMG_TEMP}/Applications"

echo "💿 Creating DMG..."

# Create DMG
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_TEMP}" \
    -ov -format UDZO \
    "${DMG_NAME}"

# Cleanup
rm -rf "${DMG_TEMP}"

echo "✅ Done! Created: ${DMG_NAME}"
echo ""
echo "To install: Open the DMG and drag ${APP_NAME} to Applications"

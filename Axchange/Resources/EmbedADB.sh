#!/bin/bash

set -euo pipefail

# Source path of the (now signed) adb binary, from the project's Axchange/Resources directory
SIGNED_ADB_IN_PROJECT_RESOURCES_PATH="$PROJECT_DIR/Axchange/Resources/adb"

# Destination path within the app bundle's MacOS directory
# $TARGET_BUILD_DIR: Root directory for product of the target (e.g., .../Build/Products/Debug)
# $EXECUTABLE_FOLDER_PATH: Path to the folder containing the main executable (e.g., YourApp.app/Contents/MacOS)
DESTINATION_DIR_IN_BUNDLE="$TARGET_BUILD_DIR/$EXECUTABLE_FOLDER_PATH"
DESTINATION_ADB_PATH_IN_BUNDLE="$DESTINATION_DIR_IN_BUNDLE/adb"

echo "Source (signed) ADB Path: $SIGNED_ADB_IN_PROJECT_RESOURCES_PATH"
echo "Destination ADB Path (in App Bundle): $DESTINATION_ADB_PATH_IN_BUNDLE"

if [ ! -f "$SIGNED_ADB_IN_PROJECT_RESOURCES_PATH" ]; then
    echo "Error: Signed ADB executable not found at '$SIGNED_ADB_IN_PROJECT_RESOURCES_PATH'."
    echo "Ensure 'SignADB.sh' runs successfully before this script, and that 'adb' was originally in 'Axchange/Resources/'."
    exit 1
fi

# Ensure the destination directory in the bundle exists
mkdir -p "$DESTINATION_DIR_IN_BUNDLE"

# Copy the signed adb binary to the app bundle
echo "Copying signed ADB from '$SIGNED_ADB_IN_PROJECT_RESOURCES_PATH' to '$DESTINATION_ADB_PATH_IN_BUNDLE'..."
cp "$SIGNED_ADB_IN_PROJECT_RESOURCES_PATH" "$DESTINATION_ADB_PATH_IN_BUNDLE"

# The `cp` command should preserve execute permissions if the source has them.
# If you want to be absolutely sure it's executable in the bundle:
chmod +x "$DESTINATION_ADB_PATH_IN_BUNDLE"

echo "Signed ADB embedded successfully into app bundle at '$DESTINATION_ADB_PATH_IN_BUNDLE'."

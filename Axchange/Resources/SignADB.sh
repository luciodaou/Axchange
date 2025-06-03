#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Pipestatus: a pipeline's return status is the value of the last command to exit with a non-zero status,
# or zero if all commands in the pipeline exit successfully.
set -euo pipefail

# Path to the adb binary within the project's Axchange/Resources directory
# $PROJECT_DIR is an Xcode environment variable.
ADB_IN_PROJECT_RESOURCES_PATH="$PROJECT_DIR/Axchange/Resources/adb"

# Xcode build settings for code signing
CODE_SIGN_IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY}"
OTHER_CODE_SIGN_FLAGS_STRING="${OTHER_CODE_SIGN_FLAGS:-}" # Default to empty if not set
ENTITLEMENTS_PATH="${CODE_SIGN_ENTITLEMENTS:-}" # Path to .entitlements file

echo "Attempting to sign ADB binary at project path: $ADB_IN_PROJECT_RESOURCES_PATH"
echo "Using identity: $CODE_SIGN_IDENTITY"

if [ ! -f "$ADB_IN_PROJECT_RESOURCES_PATH" ]; then
    echo "Error: ADB binary not found at '$ADB_IN_PROJECT_RESOURCES_PATH'."
    echo "Please ensure 'adb' is present in your project's 'Axchange/Resources/' directory."
    exit 1
fi

if [ -z "$CODE_SIGN_IDENTITY" ] || [ "$CODE_SIGN_IDENTITY" == "-" ]; then
    echo "Warning: Code signing identity is not set or is ad-hoc ('$CODE_SIGN_IDENTITY')."
    echo "Skipping signing of ADB at '$ADB_IN_PROJECT_RESOURCES_PATH'."
    echo "For App Store distribution or notarization, a valid Developer ID signing identity is required."
    exit 0 # Exit successfully as this might be an intentional ad-hoc/local build scenario
fi

# Prepare entitlements argument if an entitlements file is specified
ENTITLEMENTS_ARG=()
if [ -n "$ENTITLEMENTS_PATH" ]; then
    if [ -f "$ENTITLEMENTS_PATH" ]; then
        echo "Using entitlements: $ENTITLEMENTS_PATH"
        ENTITLEMENTS_ARG=(--entitlements "$ENTITLEMENTS_PATH")
    else
        echo "Warning: Entitlements file specified but not found at '$ENTITLEMENTS_PATH'. Signing without custom entitlements."
    fi
fi

# Prepare other code signing flags (e.g., --timestamp)
IFS=' ' read -r -a OTHER_CODE_SIGN_FLAGS_ARRAY <<< "$OTHER_CODE_SIGN_FLAGS_STRING"
echo "Other code sign flags: ${OTHER_CODE_SIGN_FLAGS_ARRAY[@]}"

# Sign the binary in place
# --force: Overwrites any existing signature.
# --options runtime: Enables hardened runtime (recommended for macOS).
echo "Executing: codesign --sign \"$CODE_SIGN_IDENTITY\" --force \"${ENTITLEMENTS_ARG[@]}\" --options runtime \"${OTHER_CODE_SIGN_FLAGS_ARRAY[@]}\" \"$ADB_IN_PROJECT_RESOURCES_PATH\""

codesign --sign "$CODE_SIGN_IDENTITY" \
         --force \
         "${ENTITLEMENTS_ARG[@]}" \
         --options runtime \
         "${OTHER_CODE_SIGN_FLAGS_ARRAY[@]}" \
         "$ADB_IN_PROJECT_RESOURCES_PATH"

echo "ADB binary at '$ADB_IN_PROJECT_RESOURCES_PATH' signed successfully."
echo "Note: This script modified '$ADB_IN_PROJECT_RESOURCES_PATH' in your project source tree."

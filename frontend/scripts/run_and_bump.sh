#!/usr/bin/env bash
# Bumps the build number in pubspec.yaml, then runs `flutter run`.
# Use this instead of `flutter run` directly to get an auto-incrementing
# build number on every launch (e.g. `./scripts/run_and_bump.sh -d <device>`).
set -euo pipefail # Exit if any command fails

cd "$(dirname "${BASH_SOURCE[0]}")/.." # Move to 'frontend' dir
PUBSPEC="pubspec.yaml"

CURRENT_LINE=$(grep -E '^version:' "$PUBSPEC")
VERSION_NAME=$(echo "$CURRENT_LINE" | sed -E 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)[[:space:]]*$/\1/')
BUILD_NUMBER=$(echo "$CURRENT_LINE" | sed -E 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)[[:space:]]*$/\2/')

if [[ -z "$VERSION_NAME" || -z "$BUILD_NUMBER" ]]; then
  echo "run_and_bump.sh: could not parse version from: $CURRENT_LINE" >&2
  exit 1
fi

NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_LINE="version: ${VERSION_NAME}+${NEW_BUILD_NUMBER}"

sed -E "s/^version:.*/${NEW_LINE}/" "$PUBSPEC" > "${PUBSPEC}.tmp" && mv "${PUBSPEC}.tmp" "$PUBSPEC" # Rewrite
echo "run_and_bump.sh: ${CURRENT_LINE} -> ${NEW_LINE}"

exec flutter run "$@"

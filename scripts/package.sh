#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$REPO_ROOT/build"

APP_NAME="VisiCore_App_for_AI_Observability"

# Get version from app.conf
version=$(grep -m1 '^version' "$REPO_ROOT/default/app.conf" | awk -F' = ' '{print $2}')

# Clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Package only known Splunk app content (allowlist, not a blacklist) so a
# stray top-level file/dir (.github, a worktree, a scratch dir) can never
# leak into the tarball just because nobody thought to exclude it by name.
app_entries=()
for entry in default metadata bin static app.manifest; do
    [ -e "$REPO_ROOT/$entry" ] && app_entries+=("$entry")
done

# Create tarball with proper root directory name
echo "Packaging $APP_NAME v${version}..."
tar -czf "$BUILD_DIR/${APP_NAME}-${version}.tar.gz" \
    --transform "s,^,$APP_NAME/," \
    -C "$REPO_ROOT" \
    --exclude='.DS_Store' \
    --exclude='*.swp' \
    --exclude='*.swo' \
    --exclude='*~' \
    "${app_entries[@]}"

echo "  -> ${APP_NAME}-${version}.tar.gz"
echo ""
echo "Build artifact:"
ls -lh "$BUILD_DIR"/*.tar.gz

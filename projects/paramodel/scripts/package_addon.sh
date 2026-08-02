#!/usr/bin/env bash
# Package ParaModel Blender addon as installable zip.
# Usage: from repo root or this dir:
#   bash projects/paramodel/scripts/package_addon.sh
# Output: projects/paramodel/dist/paramodel_addon_vX.Y.Z.zip

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ADDON_SRC="$ROOT/addon"
DIST="$ROOT/dist"
VERSION="0.3.0"

if [[ ! -f "$ADDON_SRC/__init__.py" ]]; then
  echo "ERROR: addon not found at $ADDON_SRC"
  exit 1
fi

mkdir -p "$DIST"
STAGE="$(mktemp -d)"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

# Blender expects a folder named like the module inside the zip
mkdir -p "$STAGE/paramodel"
cp -R "$ADDON_SRC/"* "$STAGE/paramodel/"

OUT="$DIST/paramodel_addon_v${VERSION}.zip"
rm -f "$OUT"

(
  cd "$STAGE"
  zip -r "$OUT" paramodel -x "*.pyc" -x "*__pycache__*" -x "*.git*"
)

echo "Created: $OUT"
echo "Install in Blender: Edit > Preferences > Add-ons > Install > select this zip"

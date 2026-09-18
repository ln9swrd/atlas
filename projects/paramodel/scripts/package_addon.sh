#!/usr/bin/env bash
# Package ParaModel Blender addon as installable zip.
# Usage:
#   bash projects/paramodel/scripts/package_addon.sh
# Output:
#   projects/paramodel/dist/paramodel_addon_vX.Y.Z.zip
#
# Requires: bash + python3 (no system 'zip' binary required)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ADDON_SRC="$ROOT/addon"
SCHEMA_SRC="$ROOT/schema"
DIST="$ROOT/dist"
VERSION="0.7.4"

if [[ ! -f "$ADDON_SRC/__init__.py" ]]; then
  echo "ERROR: addon not found at $ADDON_SRC"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required to build the zip"
  exit 1
fi

mkdir -p "$DIST"
OUT="$DIST/paramodel_addon_v${VERSION}.zip"
rm -f "$OUT"

python3 - "$ADDON_SRC" "$SCHEMA_SRC" "$OUT" <<'PY'
import os
import sys
import zipfile

addon_src, schema_src, out = sys.argv[1], sys.argv[2], sys.argv[3]
skip_parts = {"__pycache__", ".git"}

def add_tree(zf, src, arc_prefix):
    if not os.path.isdir(src):
        return
    for root, dirs, files in os.walk(src):
        dirs[:] = [d for d in dirs if d not in skip_parts and not d.startswith(".")]
        for name in files:
            if name.endswith(".pyc") or name.startswith("."):
                continue
            full = os.path.join(root, name)
            rel = os.path.relpath(full, src)
            arc = os.path.join(arc_prefix, rel).replace(os.sep, "/")
            zf.write(full, arcname=arc)

with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    # addon modules → paramodel/
    add_tree(zf, addon_src, "paramodel")
    # schema (slots + templates) → paramodel/schema/
    add_tree(zf, schema_src, "paramodel/schema")

print(f"Created: {out}")
print("Install: Blender > Preferences > Add-ons > Install > select this zip")
PY

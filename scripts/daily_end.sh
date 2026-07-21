#!/usr/bin/env bash
# Daily end script for Atlas
set -euo pipefail
cd "$(dirname "$(dirname "$0")")"
echo "Finishing Atlas daily run (finish)..."
python3 tools/atlas_runner.py finish
echo "Done."

#!/usr/bin/env bash
# Daily start script for Atlas
set -euo pipefail
cd "$(dirname "$(dirname "$0")")"
echo "Starting Atlas daily run (start-report)..."
python3 tools/atlas_runner.py start-report
echo "Done."

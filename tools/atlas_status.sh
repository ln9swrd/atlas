#!/bin/bash
# Atlas session start helper (P2-4 DAILY_LOOP)
# Usage: bash tools/atlas_status.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== Atlas session status ==="
echo "cwd: $ROOT"
echo "branch: $(git branch --show-current 2>/dev/null || echo '?')"
echo ""

echo "-- git --"
git status --short || true
echo "recent:"
git log --oneline -5 2>/dev/null || true
echo ""

echo "-- CURRENT_STATE (ACTIVE_TARGET / Next) --"
if [[ -f state/CURRENT_STATE.md ]]; then
  # Print ACTIVE_TARGET line and Next section (first ~20 lines of body after Next)
  grep -E '^(ACTIVE_TARGET|# CURRENT|## Next|## Do not)' -A 6 state/CURRENT_STATE.md | head -40
else
  echo "(missing state/CURRENT_STATE.md)"
fi
echo ""

echo "-- domain_policy smoke --"
if command -v python3 >/dev/null 2>&1; then
  python3 tools/check_domain_policy.py || {
    echo "FAIL: domain_policy smoke"
    exit 1
  }
else
  echo "(python3 not found; skip smoke)"
fi

echo ""
echo "=== status OK — read TASK_MAP then one Next item ==="

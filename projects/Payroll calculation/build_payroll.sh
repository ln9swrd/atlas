#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
python -m pip install -r requirements-payroll.txt
python -m PyInstaller --noconfirm --clean --onefile --windowed --name PayrollStatement payroll_app.py
printf 'Built: %s\n' "$PWD/dist/PayrollStatement"

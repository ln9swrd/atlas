#!/usr/bin/env python3
"""Enrich backlog.json files with default metadata where missing.

Usage: python3 scripts/enrich_backlog.py [--apply]
If --apply is provided, files are modified in-place and a summary is printed.
Without --apply, the script will only report proposed changes.
"""
import json
import os
import sys
from pathlib import Path

DEFAULT_EST = 60
DEFAULT_GAIN = 1.0


def enrich_file(path: Path, apply_changes: bool = False):
    try:
        data = json.loads(path.read_text(encoding='utf-8'))
    except Exception as e:
        return False, f"Failed to read {path}: {e}"

    changed = False
    for item in data:
        if 'est_time' not in item or item.get('est_time') in (None, 0, ''):
            item['est_time'] = item.get('estimate') or DEFAULT_EST
            changed = True
        if 'projected_gain' not in item or item.get('projected_gain') in (None, ''):
            item['projected_gain'] = item.get('projected_gain') or DEFAULT_GAIN
            changed = True

    if changed and apply_changes:
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding='utf-8')

    return changed, data


def main():
    base = Path(__file__).resolve().parents[1]
    projects_dir = base / 'projects'
    if not projects_dir.exists():
        print('No projects directory found.')
        return 1

    apply_changes = '--apply' in sys.argv
    summary = []

    for proj in sorted(projects_dir.iterdir()):
        backlog = proj / 'backlog.json'
        if backlog.exists():
            changed, data_or_msg = enrich_file(backlog, apply_changes=apply_changes)
            if changed:
                summary.append(str(backlog))

    if summary:
        print('Files that would be/ were enriched:')
        for p in summary:
            print(' -', p)
    else:
        print('No backlog files required enrichment.')

    return 0


if __name__ == '__main__':
    sys.exit(main())

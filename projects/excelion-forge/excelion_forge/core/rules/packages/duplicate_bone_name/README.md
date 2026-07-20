# Duplicate Bone Name Rule Package

This package provides a rule and autofix helpers for duplicate bone names.

## Contents

- `validator.py` — `DuplicateBoneNameRule` implementation
- `autofix.py` — `apply_duplicate_bone_name_fixes` helper
- `tests/` — rule-specific regression tests
- `samples/` — Blender samples for valid/invalid cases (TODO)

## Rule contract

- `EF101` is the bone-name duplicate rule id
- Category is `Bone`
- Severity is `Error`
- Autofix preserves existing valid names
- Autofix generates unique names using `make_unique_name`

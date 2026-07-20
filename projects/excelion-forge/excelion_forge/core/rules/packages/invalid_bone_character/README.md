# Invalid Bone Character Rule

This rule detects invalid characters in bone names and offers an auto-fix that sanitizes those names.

## Rule behavior
- Detect invalid characters: `<>:\"/\|?*`
- Fix by replacing invalid characters with `_`

## Package layout
- `metadata.py`
- `validator.py`
- `autofix.py`
- `tests/`
- `samples/`

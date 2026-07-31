# CURRENT_STATE

ACTIVE_TARGET: **platform P3**  
D28 S0–S3: **Done**  
S4-A excelion import: **Done** (working tree clean / remote already matched)  
S4-B forge diff: **Evidence recorded** (sync choices pending Master)

## S4-B diff (Master local)

| Side | Paths |
|------|--------|
| Only standalone | `.agents`, `.codex`, `.github`, `.gitignore`, `.importlinter` |
| Differ | `README.md` |
| Only atlas mono | `shin_getter_robo11.blend` (root), `state/` |

**Default recommendation:** standalone = code canonical; copy mono `state/` into standalone if newer; root blend → LFS/policy or drop if duplicate of `blender/assets/`.

## Next (one thing)

Master pick S4-B:
1. `state/` mono → standalone copy?  
2. root `.blend` keep / LFS / ignore?  
3. then S5 (pointer in atlas, no delete required immediately)

## Do not

- force-push forge  
- delete mono paths without S5 confirm

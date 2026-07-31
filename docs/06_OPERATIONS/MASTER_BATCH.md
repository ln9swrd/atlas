# 마스터 배치 커맨드

**Status: SUPERSEDED for extension track (D22, 2026-07-31)**

`atlas-extension` / L-8…L-10 / PR #3 are **abandoned**.

`scripts/master_l8_l10.sh` remains in repo for history only — **do not run for active work**.

Optional hygiene on `main` (not feature work):

```bash
# only if 마스터 wants index cleanup on main
git checkout main
git pull github main
git rm -r --cached projects/atlas-extension/node_modules 2>/dev/null || true
git rm --cached projects/atlas-extension/*.vsix 2>/dev/null || true
# commit only if something was removed from index
```

Active work: G6 approval or excelion-forge T-1 — see `state/CURRENT_STATE.md`.

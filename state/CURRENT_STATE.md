# CURRENT_STATE

ACTIVE_TARGET: 마스터 **L-8…L-9 batch**  
ACTIVE_BRANCH: `main` · `impl/atlas-extension`  
STATUS: G6 drafts saved (승인 대기). CA-1 both. L-8…L-10 Pending.  
MASTER_BATCH: `scripts/master_l8_l10.sh` · `docs/06_OPERATIONS/MASTER_BATCH.md`  
G6_DRAFTS: `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md`  
ROLES: 마스터 = 쉘 배치 가능 (D21)

## Next (마스터)

```bash
bash scripts/master_l8_l10.sh status
bash scripts/master_l8_l10.sh l8-l9
# optional: bash scripts/master_l8_l10.sh l10-npm
# then F5 manual → PR #3 merge
```

Evidence → `state/TASK_MAP.md`  
G6 승인 → `docs/DECISIONS.md`

## Do not

- SERA as project
- Done without Evidence
- Commit node_modules / vsix

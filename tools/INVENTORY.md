# tools/ Inventory (M6)

Date: 2026-07-31  
Scope: Atlas min only

## Listing (마스터 `ls tools/`)

| Path | Role | Min-scope? | Smoke |
|------|------|------------|-------|
| `atlas_status.sh` | git branch/status/log | **Yes** | `bash tools/atlas_status.sh` |
| `atlas_runner.py` | start/next/end/finish/audit … | Partial — needs `core/` | conflict fixed 2026-07-31; full smoke later |
| `atlas_runner_backup.py` | backup of runner | No — ignore | — |
| `atlas_qwen_orchestrator.py` | Ollama tool loop | Optional (Cline primary D15) | needs Ollama |
| `README.md` | policy | Yes (read) | — |
| `__pycache__/` | bytecode | ignore | — |

## Recommended Evidence (M6)

```bash
cd /path/to/atlas   # repo root
bash tools/atlas_status.sh
```

Pass = prints branch, short status, last 5 commits (exit 0).

## Notes

- `atlas_runner.py` had unresolved `<<<<<<<` markers; removed in same change set as this inventory.
- Runner still depends on legacy `core/` — not required for M6 pass.
- Product projects remain on hold (`ATLAS_MIN_SCOPE.md`).

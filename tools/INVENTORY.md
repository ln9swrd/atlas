# tools/ Inventory (M6)

Date: 2026-07-31  
Status: **M6 Done**

## Listing

| Path | Role | Min-scope? | Smoke |
|------|------|------------|-------|
| `atlas_status.sh` | git status | **Yes** | `bash tools/atlas_status.sh` — **PASS** |
| `atlas_runner.py` | start/next/end… | Partial (`core/`) | conflict removed `8edcc4f` |
| `atlas_qwen_orchestrator.py` | Ollama loop | Optional | needs Ollama |
| `README.md` | policy | Yes | — |

## Evidence (2026-07-31)

```
bash tools/atlas_status.sh
# branch: main
# recent: 2949ac3 … then push 8edcc4f fix(tools): remove merge conflict markers
```

Product projects remain on hold.

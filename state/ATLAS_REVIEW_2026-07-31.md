# Atlas Review — 2026-07-31

## Done this session

- `git mv projects/forge` → `archive/projects-forge-legacy`
- push `main` (`feecd25..ab5057b` then docs sync commit)
- state/docs path alignment (R1)

## Problems

| # | Issue |
|---|--------|
| 1 | Docs lagged physical paths (forge still listed under projects/) |
| 2 | Platform charter (IDE extension, perception) mostly Spec; runtime incomplete |
| 3 | Legacy duplication: `core/`/`src` snapshot, `templates` vs `_template`, nested excelion forge stub, deprecated extension still in tree |
| 4 | Monorepo mixes DevOS + large product trees |
| 5 | Binary asset policy vs history (blend/audio) unclear |
| 6 | P0 products on hold while ACTIVE_TARGET = platform idle |
| 7 | Multi-level state files; easy to desync after moves |

## Improvements (priority)

| ID | Action | Status |
|----|--------|--------|
| R1 | Sync PROJECT_MAP / CURRENT_STATE / projects/README / CONTEXT_INDEX | **Done** |
| R2 | `projects/templates` → archive or drop | Open |
| R3 | Nested excelion forge stub cleanup | Open |
| R4 | `atlas-extension` → archive (D22) | Open |
| R5 | Master decides ACTIVE_TARGET: product vs platform | Open |
| — | Binary → LFS or external store (medium) | Open |
| — | Long-term: split platform vs product repos | Open |

## Keep

Evidence-First, domain blacklist, no auto-load of archive/obsidian.

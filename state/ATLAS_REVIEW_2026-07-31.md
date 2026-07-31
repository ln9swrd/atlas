# Atlas Review — 2026-07-31

## Done this session

- forge → `archive/projects-forge-legacy` + R1 docs
- templates → `archive/projects-templates-legacy` (R2, cb4999e)
- nested stub → `archive/excelion-exelion_forge-stub` (R3, dceb51a)

## Problems

| # | Issue |
|---|--------|
| 1 | Docs lagged physical paths |
| 2 | Platform charter mostly Spec; runtime incomplete |
| 3 | Legacy duplication (core/src, templates, nested stub, extension) |
| 4 | Monorepo mixes DevOS + large product trees |
| 5 | Binary asset policy vs history unclear |
| 6 | P0 products on hold while ACTIVE_TARGET = platform idle |
| 7 | Multi-level state files; easy to desync |

## Improvements (priority)

| ID | Action | Status |
|----|--------|--------|
| R1 | state/docs path sync | **Done** |
| R2 | templates → archive | **Done** |
| R3 | nested excelion forge stub → archive | **Done** |
| R4 | `atlas-extension` → archive (D22) | Open |
| R5 | ACTIVE_TARGET product vs platform | Open |
| — | Binary → LFS or external store | Open |
| — | Long-term: split platform vs product repos | Open |

## Keep

Evidence-First, domain blacklist, no auto-load of archive/obsidian.

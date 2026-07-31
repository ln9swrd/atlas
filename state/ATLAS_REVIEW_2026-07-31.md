# Atlas Review — 2026-07-31

## Done this session

- forge → `archive/projects-forge-legacy` + R1 docs
- templates → `archive/projects-templates-legacy` (R2)
- nested stub → `archive/excelion-exelion_forge-stub` (R3)
- atlas-extension → `archive/projects-atlas-extension-legacy` (R4 / D22, 49eb16b)
- R5 ACTIVE_TARGET = **platform 유지** (Master 2026-07-31)

## Problems

| # | Issue | Status |
|---|--------|--------|
| 1 | Docs lagged physical paths | **Done** (R1) |
| 2 | Platform charter mostly Spec; runtime incomplete | Open (P3) |
| 3 | Legacy duplication (partially cleaned R2–R4) | **Mostly Done** |
| 4 | Monorepo mixes DevOS + large product trees | Open (long-term) |
| 5 | Binary asset policy vs history unclear | Open → R6 |
| 6 | P0 products on hold while ACTIVE_TARGET = platform | **Accepted** (R5 platform) |
| 7 | Multi-level state files; easy to desync | Open → R7 |

## Improvements (priority)

| ID | Action | Status |
|----|--------|--------|
| R1 | state/docs path sync | **Done** |
| R2 | templates → archive | **Done** |
| R3 | nested excelion forge stub → archive | **Done** |
| R4 | atlas-extension → archive (D22) | **Done** |
| R5 | ACTIVE_TARGET product vs platform | **Done** (platform 유지) |
| R6 | Binary → LFS or external store policy | Open |
| R7 | State single SoR discipline | Open |
| — | Long-term: split platform vs product repos | Open |

## Keep

Evidence-First, domain blacklist, no auto-load of archive/obsidian.

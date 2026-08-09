# Tech Debt — 2026-08

## Active issues

| Issue | Title | Priority | Est. effort | Status |
|-------|-------|----------|-------------|--------|
| #31 | consolidate test execution strategy | **P1** | M (move ~13 files, CI verify, policy fix) | Decision: 안 B · code gated |
| #32 | Introduce pyproject.toml and dependency management | **P2** | S–M (add pyproject, keep requirements-dev) | Draft only · not applied |
| #33 | Redesign VisualPerception architecture | **P2** | S under R1 (remove stub) | Decision: R1 · code gated |

## Completed recently

- CI dev deps (#26)
- Optional / experimental vision guards (#25, #27)
- Forge legacy test removal (#24)
- Archive node_modules cleanup (#28)
- Testing policy (#29)

## Implementation start matrix

| Work | Start now? |
|------|------------|
| Merge docs PR #35–#38 | **Yes** (recommended) |
| #31 code migration | No — after master approve |
| #32 apply pyproject.toml | No — draft review only |
| #33 remove VisualPerceptionEngine | No — after master approve |

## Excelion / HOLD

- Excelion: ACTIVE (no change this phase)
- Forge / UE / Visualization: HOLD
- Allowed: Novel, Worldbuilding, Design, Documentation

# Tech Debt — 2026-08

## Active issues

| Issue | Title | Priority | Est. effort | Status |
|-------|-------|----------|-------------|--------|
| #32 | Introduce pyproject.toml and dependency management | **P2** | S–M (add pyproject, keep requirements-dev) | **HOLD** · draft only |
| #33 | Redesign VisualPerception architecture | **P2** | S under R1 (remove stub) | Decision: R1 · **next** |

## Completed

| Issue | Title | Evidence |
|-------|-------|----------|
| #31 | consolidate test execution strategy | PR #42 MERGED · Merge SHA `9033d68971bb44f5dd8d6433869bd2f08d1a8d2b` · CI 31301608837 success |

## Completed recently (prior)

- CI dev deps (#26)
- Optional / experimental vision guards (#25, #27)
- Forge legacy test removal (#24)
- Archive node_modules cleanup (#28)
- Testing policy (#29)

## Implementation start matrix

| Work | Start now? |
|------|------------|
| #31 code migration | **DONE** (PR #42) |
| #33 remove VisualPerceptionEngine | **Yes** — after #31 record |
| #32 apply pyproject.toml | **No** — HOLD |

## Excelion / HOLD

- Excelion: HOLD (no change this phase)
- Forge / UE / Visualization: HOLD
- Allowed: Novel, Worldbuilding, Design, Documentation

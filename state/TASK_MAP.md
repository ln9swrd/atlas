# TASK_MAP

> Documentation rebuild track is closed except optional local tag. Implementation work uses issue + branch.

## Docs rebuild (RB-*)

| ID | Task | Status |
|----|------|--------|
| RB-A | Tag / branch for rebuild | Done |
| RB-B | Isolate summary under `archive/` | **Done** (`archive/summary/` 000–086) |
| RB-C | `docs/00`–`07` skeleton + specs | Done |
| RB-D | `state/` CURRENT / CONTEXT / TASK / PROJECT | Done |
| RB-E | README charter for 3 requirements | Done |
| RB-F | Merge to `main` | **Done** (PR #1) |
| RB-F2 | Tag `atlas-docs-rebuild-v1` | Pending (**local** `git tag` + push; no API) |
| RB-G | Bulk path move summary → `archive/summary/` | **Done** |
| RB-H | Clean root / ignore tracked junk | **Done** on policy (`.gitignore` strengthened 2026-07-30); `git rm --cached node_modules` still local |

## Implementation

| ID | Task | Status |
|----|------|--------|
| IMP-1 | VS Code extension formal track | **Open** — [issue #2](https://github.com/ln9swrd/atlas/issues/2) + branch `impl/atlas-extension` |
| — | Camera / vision pipeline code | **Out of scope** |
| — | AI Runtime / Plugin Host / Knowledge services | **Out of scope** until separate issues |

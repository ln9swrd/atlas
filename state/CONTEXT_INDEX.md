# CONTEXT_INDEX

> What to open before work. Prefer these over long chat history.

## Always

| Path | Why |
|------|-----|
| `state/CURRENT_STATE.md` | Where we are now |
| `state/TASK_MAP.md` | Open work — G-*, L-*, CA-*, IMP-* |
| `docs/07_ROADMAP/ATLAS_GIT_REBUILD_PLAN.md` | Rebuild plan |
| `docs/07_ROADMAP/CLOUD_AI_VSCODE_EXEC_PLAN.md` | Cloud AI + VS Code 실행계획 |
| `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md` | L-8…L-10 로컬 체크리스트 + PR 리뷰 포인트 |
| `README.md` | Entry map |
| `docs/DECISIONS.md` | Living decision log |
| `docs/GLOSSARY.md` | Concept glossary |
| `docs/process/PROJECT_STATE_SCHEMA.md` | Atlas vs project state; 3 AI modes |

## By task type

### Owner local (Cline / Ollama) — L-8…L-10

- `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md` — **실행 체크리스트**
- `state/TASK_MAP.md` — L-8…L-10 Pending
- `docs/04_IDE_EXTENSION/PACKAGING.md` (on `impl/atlas-extension`)
- `docs/04_IDE_EXTENSION/F5_CHECKLIST.md` (on `impl/atlas-extension`)
- `docs/04_IDE_EXTENSION/BOUNDARY.md` (on `impl/atlas-extension`)
- `AGENTS.md`

### Cloud AI / both mode

- `docs/07_ROADMAP/CLOUD_AI_VSCODE_EXEC_PLAN.md`
- `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md`
- `docs/process/PROJECT_STATE_SCHEMA.md` — ACTIVE_MODE
- `docs/05_AGENTS/README.md` — role split
- project `state/CURRENT_STATE.md` → TASK_MAP → CONTEXT_INDEX only

### Domain project work

- `docs/process/PROJECT_STATE_SCHEMA.md`
- `projects/_template/state/` (after G3)
- `projects/<name>/state/CURRENT_STATE.md` → TASK_MAP → CONTEXT_INDEX only

### Docs / rebuild

- `docs/02_CONTEXT_STATE/SCHEMA.md`
- `docs/03_PERCEPTION/SCOPE.md`
- `docs/04_IDE_EXTENSION/SPEC.md`
- `archive/README.md`
- `docs/process/DUPLICATE_POLICY.md`
- `docs/process/CORE_INDEX.md`

### Core philosophy

- `docs/00_VISION/README.md`
- `docs/01_CORE/README.md`
- `docs/adr/README.md`
- `docs/DECISIONS.md`
- `docs/GLOSSARY.md`

### Agents / roles

- `docs/05_AGENTS/README.md`

### Historical detail (archive)

- `archive/summary/` — numbered summaries 000–086 (canonical)
- `obsidian/Archive/` — raw dumps (not operational context)
- `obsidian/Archive/Original Conversations/ANALYSIS_REPORT.md` — source analysis
- `docs/process/CORE_INDEX.md` — when intentionally reviewing Core conversations

## Token discipline

Load only rows needed for the current task. Do not dump entire summary 000–086 into context.

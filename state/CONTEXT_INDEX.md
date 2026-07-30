# CONTEXT_INDEX

> What to open before work. Prefer these over long chat history.

## Always

| Path | Why |
|------|-----|
| `state/CURRENT_STATE.md` | Where we are now |
| `state/TASK_MAP.md` | What is open — **Owner local TODO (L-1…L-10)** |
| `docs/07_ROADMAP/ATLAS_GIT_REBUILD_PLAN.md` | Rebuild plan |
| `README.md` | Entry map |
| `docs/DECISIONS.md` | Living decision log (from conversation analysis) |
| `docs/GLOSSARY.md` | Concept glossary |

## By task type

### Owner local (Cline / Ollama)

- `state/TASK_MAP.md` — L-1…L-10 checklist
- `state/CURRENT_STATE.md` — decision: Cline primary
- `AGENTS.md` — paste-related rules into Cline instructions
- `docs/04_IDE_EXTENSION/BOUNDARY.md` — if using custom extension too (on `impl/atlas-extension`)

### Docs / rebuild

- `docs/02_CONTEXT_STATE/SCHEMA.md`
- `docs/03_PERCEPTION/SCOPE.md`
- `docs/04_IDE_EXTENSION/SPEC.md`
- `archive/README.md`
- `docs/process/DUPLICATE_POLICY.md` — Original Conversations duplicate rules

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

## Token discipline

Load only rows needed for the current task. Do not dump entire summary 000–086 into context.

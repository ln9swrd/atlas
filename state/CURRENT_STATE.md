# CURRENT_STATE

ACTIVE_TARGET: Owner local setup — **Cline + Ollama** as primary Atlas work surface  
ACTIVE_BRANCH: `impl/atlas-extension` (repo work) · daily coding on **local Cline**  
ACTIVE_PHASE: Stabilize local agent (not more custom extension features)  
STATUS: Docs/meta track largely closed; **your machine** must finish L-1…L-10 in `state/TASK_MAP.md`

## Decision (2026-07-30)

| Choice | Rationale |
|--------|-----------|
| Primary agent = **Cline** (fallback **Roo**) | Matches agent + tools need; better fit than Continue for Atlas |
| Continue = optional only | Chat/autocomplete; upstream maintenance weak for main agent role |
| Do **not** fork Cline/Continue | Fix via num_ctx, settings, Atlas rules |
| Custom extension | Secondary; packaging/docs on issue #2 / PR #3 — not the long-term full agent |

## Scope agreement

| Area | Status |
|------|--------|
| Domain Isolation (orchestrator blacklist) | Done |
| Docs rebuild RB-* | Done except RB-F2 tag + local untrack |
| Owner local Cline/Ollama path | **Pending** — see TASK_MAP L-1…L-5 |
| Extension packaging on `impl/atlas-extension` | Open — L-6…L-8, PR #3 |
| Camera / vision | Out of scope |
| `core/`, `src/`, `atlas-runtime/` | No modify without issue |

## Next one thing (owner)

1. **L-1** Create Ollama model with `num_ctx` ≥ 32768  
2. **L-2…L-4** Point Cline at it + harden + paste Atlas rules  
3. **L-5** Smoke test (no loop)  
4. Then L-6…L-10 (git untrack, merge, tag, PR)

Full checklist: `state/TASK_MAP.md` → **Owner local TODO**

## Verified milestones (repo)

- Ollama host used in project: `http://192.168.219.254:11434`
- `archive/summary/` 000–086 canonical
- Issue #2, branch `impl/atlas-extension`, draft PR #3
- Orchestrator: workspace root from `ATLAS_ROOT` or cwd (not hardcoded `/mnt/d/Atlas`) on impl branch

## Fixed requirements (charter)

1. VS Code + **local LLM** (Cline/Roo + Ollama preferred over cloud-only)
2. **Git** as source of state (`state/`)
3. Code + screen + images; **camera = 0**

## Blockers

- None blocking L-1 start
- L-5 failure → try Roo with same rules before any fork

## Do not

- Auto-approve all Cline terminal/file tools on local models
- Dump `archive/` or `obsidian/` into agent context
- Land extension features on `main` without PR from `impl/atlas-extension`
- Expand Runtime/Plugin/Knowledge without new issues

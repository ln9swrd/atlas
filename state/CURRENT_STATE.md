# CURRENT_STATE

ACTIVE_TARGET: `state/` + docs rebuild closeout (primary); `projects/atlas-extension` verification only
ACTIVE_PHASE: Domain Isolation & Access Control Enforcer — **Completed & Verified**
STATUS: Docs track residual (tag RB-F2, RB-H/gitignore); extension **implementation** remains out of scope until issue + branch

## Scope agreement (aligned with TASK_MAP)

| Area | Status |
|------|--------|
| Domain Isolation Enforcer (blacklist `archive/`, `obsidian/` from auto LLM injection) | Done |
| Smart Context Router / streaming webview (verified) | Done as verification |
| Full VS Code extension feature implementation | **Out of scope** until GitHub issue + dedicated branch |
| Camera / vision pipeline code | **Out of scope** |
| Application code under `core/`, `src/`, `atlas-runtime/` | Do not modify without explicit implementation issue |

## Primary Target Scope (allowed now)

- `state/`, `docs/`, `archive/` metadata
- `.gitignore` / tracked-junk cleanup (chore)
- Optional: F5 Extension Host **smoke test only** (no new feature work on main)

## Verified Milestones

- Local `qwen3:14b` connected via Ollama (`http://192.168.219.254:11434`).
- Domain Isolation Enforcer: `archive/`, `obsidian/` blacklisted from automated LLM injection.
- Smart Context Router: Reduced simple query overhead to ~150 tokens (0.2s latency).
- Real-time token streaming (`stream: true`) integrated into VS Code Webview panel.
- Numbered summaries 000–086 canonical at `archive/summary/` (RB-B/G closed 2026-07-30).

## Fixed requirements (charter)

1. VS Code + **local LLM** extension (`projects/atlas-extension/`)
2. **Git** as source of state and context (`state/`)
3. Recognize **code + screen + images**; **camera = 0** (`docs/03_PERCEPTION/`)

## Blockers

- None for docs/chore track
- Extension feature work blocked on: open issue + branch (per TASK_MAP)

## Next one thing

1. Create tag `atlas-docs-rebuild-v1` (RB-F2) when ready
2. Strengthen `.gitignore` and list tracked `node_modules` / `__pycache__` for `git rm --cached`
3. (Optional) F5 smoke test only — no implementation on `main`

## Evidence

- `tools/atlas_qwen_orchestrator.py` standalone module
- `projects/atlas-extension/out/extension.js`, `sidebarProvider.js` compiled
- Ollama endpoint `http://192.168.219.254:11434` ping & 420ms response verified
- Commits: `a70eb9fc` (archive README), `9272dbe9` (TASK_MAP RB-B/G)

## Do not

- Modify `core/`, `src/`, `atlas-runtime/` without an explicit implementation issue
- Treat extension verification as a license to expand features on `main`

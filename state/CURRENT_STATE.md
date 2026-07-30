# CURRENT_STATE

ACTIVE_TARGET: [issue #2](https://github.com/ln9swrd/atlas/issues/2) — Atlas VS Code extension formal implementation  
ACTIVE_BRANCH: `impl/atlas-extension`  
ACTIVE_PHASE: Extension packaging + boundary hardening (not domain isolation — that is Done)  
STATUS: Docs rebuild closed except optional local tag / `git rm --cached`; **impl gate is open**

## Scope agreement

| Area | Status |
|------|--------|
| Domain Isolation Enforcer | Done |
| Docs rebuild RB-B/G/H policy | Done (tag RB-F2 optional local) |
| Extension **feature work** | Allowed **only** on `impl/atlas-extension` per issue #2 |
| Camera / vision pipeline | Out of scope |
| `core/`, `src/`, `atlas-runtime/` | No modify without dedicated issue |

## Primary Target Scope (allowed now)

- Branch `impl/atlas-extension`: packaging hygiene, orchestrator boundary, F5 checklist docs
- `main`: state/docs chore only; no extension feature commits

## Verified Milestones

- Ollama `qwen3:14b` @ `http://192.168.219.254:11434`
- Domain Isolation: `archive/`, `obsidian/` blacklisted from auto LLM injection
- Smart Context Router + streaming webview path verified
- `archive/summary/` 000–086 canonical
- Issue #2 + branch `impl/atlas-extension` created 2026-07-30

## Fixed requirements (charter)

1. VS Code + **local LLM** extension (`projects/atlas-extension/`)
2. **Git** as source of state and context (`state/`)
3. Recognize **code + screen + images**; **camera = 0**

## Blockers

- None for starting IMP-1 on `impl/atlas-extension`
- Tag `atlas-docs-rebuild-v1` still needs local `git tag` (optional)

## Next one thing

1. On `impl/atlas-extension`: `git rm --cached` node_modules/vsix + commit  
2. Document F5 regression checklist under `docs/04_IDE_EXTENSION/`  
3. (Optional on any clone) tag `atlas-docs-rebuild-v1`

## Evidence

- Issue: https://github.com/ln9swrd/atlas/issues/2
- Branch ref: `impl/atlas-extension`
- Orchestrator: `tools/atlas_qwen_orchestrator.py`
- Extension out: `projects/atlas-extension/out/`

## Do not

- Land extension feature commits on `main` without PR from `impl/atlas-extension`
- Expand into Runtime/Plugin/Knowledge without new issues

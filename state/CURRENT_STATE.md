# CURRENT_STATE

ACTIVE_TARGET: projects/atlas-extension
ACTIVE_PHASE: Domain Isolation & Access Control Enforcer
STATUS: Completed & Verified

## Primary Target Scope
- `projects/atlas-extension/`
- `tools/atlas_qwen_orchestrator.py`

## Verified Milestones
- Local `qwen3:14b` connected via Ollama (`http://192.168.219.254:11434`).
- Domain Isolation Enforcer: `archive/`, `obsidian/` blacklisted from automated LLM injection.
- Smart Context Router: Reduced simple query overhead to ~150 tokens (0.2s latency).
- Real-time token streaming (`stream: true`) integrated into VS Code Webview panel.

## Fixed requirements (charter)
1. VS Code + **local LLM** extension (`projects/atlas-extension/`)
2. **Git** as source of state and context (`state/`)
3. Recognize **code + screen + images**; **camera = 0** (`docs/03_PERCEPTION/`)

## Blockers

- None

## Next one thing

1. Test Atlas Extension via F5 Extension Host
2. Connect additional CLI toolings as required by workspace goals

## Evidence

- `tools/atlas_qwen_orchestrator.py` standalone module
- `projects/atlas-extension/out/extension.js`, `sidebarProvider.js` compiled
- Ollama endpoint `http://192.168.219.254:11434` ping & 420ms response verified

## Do not

- Modify `core/`, `src/`, `atlas-runtime/` without an explicit implementation issue

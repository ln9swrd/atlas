# F5 Extension Host — regression checklist

Track: [issue #2](https://github.com/ln9swrd/atlas/issues/2) · branch `impl/atlas-extension`

Run from a clean clone after `npm install` (do **not** commit `node_modules`).

## Setup

1. Ollama reachable at settings `atlas.ollamaHost` (default `http://192.168.219.254:11434`)
2. Model `atlas.model` available (`qwen3:14b` or configured name)
3. Workspace root = Atlas repo (so `state/`, `AGENTS.md` resolve)

```bash
cd projects/atlas-extension
npm install
npm run compile
# VS Code: open this folder or repo root → F5 (Extension Development Host)
```

## Smoke checks

| # | Check | Pass? |
|---|--------|-------|
| 1 | Activity bar shows Atlas container / sidebar webview | |
| 2 | Command `Atlas: Open Agent Panel` opens UI | |
| 3 | Simple prompt returns streamed tokens (not hang) | |
| 4 | Domain isolation: prompts do **not** auto-inject full `archive/` or `obsidian/` dumps | |
| 5 | Context prefers `state/CURRENT_STATE.md` + `state/TASK_MAP.md` when loaded explicitly | |
| 6 | No camera / mic permission prompts (camera = 0) | |
| 7 | Settings change for host/model takes effect after reload | |

## Fail → do

- Connection errors: verify Ollama `curl $HOST/api/tags`
- Empty UI: check `out/extension.js` compiled; Developer Tools console in Extension Host
- Context bloat: confirm router / blacklist still active in orchestrator path

## Sign-off

- Date:
- Host / model:
- Result: Pass / Fail
- Notes:

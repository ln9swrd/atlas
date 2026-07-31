# Domain blacklist ↔ tools (M7)

Date: 2026-07-31  
Policy source: `AGENTS.md` §1 + D17

## Canonical BLACK (no auto LLM context)

| Path | AGENTS | .clineignore | orchestrator | atlas_runner |
|------|--------|--------------|--------------|--------------|
| `archive/` | BLACK | yes | FORBIDDEN | none |
| `obsidian/` | BLACK | yes | FORBIDDEN | none |
| `node_modules/` | BLACK | yes | FORBIDDEN | none |
| `.git/` | BLACK | yes | FORBIDDEN | none |
| `scratch/` | User sandbox (no auto-load) | no | FORBIDDEN (stricter) | none |

## Findings (fixed / open)

| Item | Status |
|------|--------|
| `.clineignore` had `textarchive/` typo | **Fixed** → `archive/` |
| orchestrator `WORKSPACE_ROOT=/mnt/d/Atlas` hardcode | **Fixed** → `ATLAS_ROOT` or repo parent of `tools/` |
| orchestrator FORBIDDEN list | Align archive/obsidian/node_modules/.git; scratch kept deny-on-tool |
| `atlas_runner.py` has no path guard | **Open** — min scope: document only; Cline+.clineignore primary |
| CLI substring deny is coarse | **Open** — false positives possible; acceptable for M7 |
| D23 VERIFY full sandbox | **Open** — follow-up beyond M7 |

## Primary enforcement (D15)

**Cline** uses `.clineignore` + `AGENTS.md`.  
Orchestrator is optional secondary when Ollama CLI path is used.

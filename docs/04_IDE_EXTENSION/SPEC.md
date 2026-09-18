# VS Code Extension + Local LLM — Spec (no implementation)

## Role

Provide a **work surface** in VS Code that:

1. Connects to a **local LLM** (e.g. Ollama)
2. Loads context from **Git-tracked** Atlas files (`state/`, selected `docs/`)
3. Applies shared agent rules (`AGENTS.md`)

## Must

- Prefer local inference endpoint configuration
- Read `state/CONTEXT_INDEX.md` to choose files to attach
- Support explicit “load CURRENT_STATE + TASK_MAP” actions (spec-level)

## Must not (this phase)

- Ship extension code in the rebuild branch
- Force cloud-only models
- Replace Git as system of record
- Enable camera capture

## Context loading

See `CONTEXT_LOADING.md`.

## Non-goals

See `NON_GOALS.md`.

## Archive refs

003, 018, 039, 040, 079

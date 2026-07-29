# AGENTS.md — Atlas DevOS Core Rules

## 1. Domain Separation
- **System Domain:** `AGENTS.md`, `state/`, `tools/` (Agent operational intelligence & CLI runner)
- **Project Domain:** `projects/<active-project>/` (Active target development scope)
- **User Sandbox:** `scratch/` (User personal free notes & temporary files, bypassed by LLM)
- **Forbidden Domain (BLACK):** `archive/`, `obsidian/`, `node_modules/`, `.git/` (STRICTLY BLOCKED from automatic LLM context injection)

## 2. Evidence-First Rule
- Do not report DONE without verified CLI execution evidence.
- Claims != Implementation.

## 3. Strict Boundary Control
- Never traverse or auto-load files outside the active project target defined in `state/CURRENT_STATE.md`.
- Keep context slim (< 500 tokens total).


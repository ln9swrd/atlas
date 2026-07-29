# CURRENT_STATE

> Git-tracked operational state. Update at end of each work session.

## Date

2026-07-29

## Phase

<<<<<<< HEAD
**Docs rebuild structure is on `main`** (PR #1 squash-merged)

- Program development / modification: still **out of scope** until a dedicated implementation branch
- Focus remains knowledge, state, specs

## Active goal

Atlas Git 지식·상태·스펙 골격을 유지하고, 다음으로 archive summary 정리 또는 첫 구현 이슈 정의.

## Fixed requirements (charter)

1. VS Code + **local LLM** extension — **spec only** (`docs/04_IDE_EXTENSION/`)
2. **Git** as source of state and context (`state/`)
3. Recognize **code + screen + images**; **camera = 0** (`docs/03_PERCEPTION/`)

## Blockers

- None for using `main` as documentation entry
- Bulk move `obsidian/Archive/summary` → `archive/summary` still pending

## Next one thing

1. (Optional) Tag `atlas-docs-rebuild-v1` on current `main`
2. Bulk archive isolation of summary 000–086 **or**
3. Define first **implementation** issue (separate branch; Done when + evidence)

## Evidence

- PR #1 merged: squash commit on `main`
- `state/`, `docs/00`–`07`, `AGENTS.md`, charter README present on `main`

## Do not

- Modify `core/`, `src/`, `atlas-runtime/` without an explicit implementation issue
=======
**Docs rebuild in progress** (`docs/rebuild-structure`)

- Program development / modification: **forbidden** in this phase
- Focus: knowledge, state, specs only

## Active goal

Atlas를 Git 위의 기억·상태·컨텍스트 OS로 재배치한다.

## Fixed requirements (charter)

1. VS Code + **local LLM** extension — **spec only** (no implementation in this phase)
2. **Git** as source of state and context (progress, decisions)
3. Recognize **code + screen + images**; **camera = 0** (out of scope)

## Blockers

- None for documentation structure
- Bulk move of `obsidian/Archive/summary` → `archive/summary` may be incremental

## Next one thing

1. Review this branch and merge when structure is accepted
2. Complete archive isolation of summary 000–086
3. Keep `state/` updated before any future implementation branch

## Do not

- Modify `core/`, `src/`, `atlas-runtime/`, or add extension code on this track
>>>>>>> origin/docs/rebuild-structure

# CURRENT_STATE

> Git-tracked operational state. Update at end of each work session.

## Date

2026-07-29

## Phase

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

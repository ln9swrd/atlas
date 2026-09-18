# AGENTS.md — Atlas DevOS Core Rules

## 1. Domain Separation

* **System Domain:** `AGENTS.md`, `state/`, `tools/` (Agent operational intelligence & CLI runner)
* **Project Domain:** `projects/<active-project>/` (Active target development scope)
* **User Sandbox:** `scratch/` (User personal free notes & temporary files, bypassed by LLM)
* **Forbidden Domain (BLACK):** `archive/`, `obsidian/`, `node_modules/`, `.git/` (STRICTLY BLOCKED from automatic LLM context injection)

## 2. Evidence-First Rule

* Do not report DONE without appropriate verification evidence.
* For executable changes, require verified CLI/build/test evidence when applicable.
* Claims != Implementation.
* Do not claim EDITOR or PIE verification unless actually performed.

## 3. Strict Boundary Control

* Never traverse or auto-load files outside the active project target defined in `state/CURRENT_STATE.md`.
* Keep AGENTS.md concise. Load additional project context only when required by the active task.
* Do not expand the task scope automatically.

## 4. AI Edit Permission (필수 사전 확인)

작업 시작 전:

1. `state/CURRENT_STATE.md` (플랫폼 라우팅) 확인
2. 활성 제품이면 `projects/<name>/state/CURRENT_STATE.md` 확인
3. Excelion이면 `projects/excelion/state/SOT_MAP.md` 확인
4. 대상 파일의 수정 권한(LOCK / EDITABLE) 확인
5. 작업 범위·변경 대상이 지시서와 일치하는지 확인
6. `git status` 및 현재 변경사항 확인

**LOCK 의미:** 절대 수정 금지가 아니라, **명시적 작업 범위와 승인 없이 AI가 임의 수정하지 않는다.**

명시적 지시 없이 수정하지 않는 영역:

* CANON · Novel 정본 본문
* `*_FINAL_SPEC` · OFFICIAL_SETTING
* Unreal 프로젝트 (`game/` 등)
* `archive/` · 과거 audit 본문
* SOT_MAP에서 LOCK으로 지정된 경로

## 5. Change Safety

* Modify only files required by the current task.
* Do not delete, rename, move, or overwrite files/assets without explicit approval.
* Before modification, inspect the relevant existing files/assets.
* After modification, inspect `git diff`.
* If unexpected changes are detected, stop and report HOLD.
* Never revert pre-existing user changes.

## 6. Multi-Agent Coordination

* Cline, Copilot, and Codex must operate within the same declared task scope.
* Do not overwrite or undo another Agent's changes without explicit instruction.
* If unrelated or pre-existing changes are encountered, preserve them and report them.
* Agents must not automatically continue into subsequent development stages.

## 7. Git Safety

* AI may inspect `git status`, `git log`, and `git diff`.
* Commit and Push require explicit Master approval.
* Do not execute `git reset`, `git clean`, or destructive history operations without explicit approval.
* Never treat an existing commit as proof that the implementation is functionally verified.

## 8. Handoff (중단/재개)

작업 종료 시 제품 `CURRENT_STATE`에 최소 기록:

* 작업명 · 현재 상태 · 완료/미완료 · 변경 파일 · 관련 commit · 다음 작업 · 재개 조건

재개 순서:
`CURRENT_STATE → SOT_MAP(해당 시) → 최근 commit → 작업 범위`

## 9. Stop Conditions

Immediately stop and report **HOLD** when:

* Required information is missing.
* The task requires access outside the declared project boundary.
* An external source is required but not approved.
* Existing changes may be affected.
* Unexpected modifications are detected.
* Verification results contradict the expected result.
* The requested scope begins expanding beyond the original task.
* The task cannot be completed without entering a subsequent development stage.

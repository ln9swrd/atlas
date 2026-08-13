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

## 4. AI Edit Permission (필수 사전 확인)

작업 시작 전:

1. `state/CURRENT_STATE.md` (플랫폼 라우팅) 확인
2. 활성 제품이면 `projects/<name>/state/CURRENT_STATE.md` 확인
3. Excelion이면 `projects/excelion/state/SOT_MAP.md` 확인
4. 대상 파일의 수정 권한(LOCK / EDITABLE) 확인
5. 작업 범위·변경 대상이 지시서와 일치하는지 확인

**LOCK 의미:** 절대 수정 금지가 아니라, **명시적 작업 범위와 승인 없이 AI가 임의 수정하지 않는다.**

명시적 지시 없이 수정하지 않는 영역:
- CANON · Novel 정본 본문
- `*_FINAL_SPEC` · OFFICIAL_SETTING
- Unreal 프로젝트 (`game/` 등)
- `archive/` · 과거 audit 본문
- SOT_MAP에서 LOCK으로 지정된 경로

## 5. Handoff (중단/재개)

작업 종료 시 제품 `CURRENT_STATE`에 최소 기록:
- 작업명 · 현재 상태 · 완료/미완료 · 변경 파일 · 관련 commit · 다음 작업 · 재개 조건

재개 순서: **CURRENT_STATE → SOT_MAP(해당 시) → 최근 commit → 작업 범위**

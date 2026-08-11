# Documentation Source of Record Review — 2026-08-11

조사일: 2026-08-11  
시작 SHA: `74663e015040d9ba41abb91eba1a949fce46e27a`  
대상: `docs/` · `docs/process/`  
역할: **조사만** (삭제·이동·통합 **0**)

---

## 1. SoR 결론 (한 줄)

**경우 A + 부분 역할 분리:**  
**운영·설계 SoR = `docs/` (특히 `docs/06_OPERATIONS/`, `docs/DECISIONS.md`, `docs/00_VISION`–`07_ROADMAP`, `docs/adr/`) + `state/` + `AGENTS.md`.**  
**`docs/process/` = 과거 process 작업 산출물·스텁·위생 보고서 영역 (운영 SoR 아님).**

---

## 2. 구조 요약

| 영역 | 파일 수(대략) | 역할 |
|------|---------------|------|
| `docs/` 루트 md | 21 | 설계·런타임·로드맵·릴리스 요약 |
| `docs/00_VISION` … `07_ROADMAP` | 번호 체계 설계 | README “Live design docs” |
| `docs/06_OPERATIONS/` | 8 | **세션 루프·Decision·state 규율** |
| `docs/adr/` | 11 | ADR 인덱스 |
| `docs/maintenance/` | 15+ | 저장소 정리 감사 (메타) |
| `docs/process/` | **35** | process 실험·감사·스텁·포인터 |
| `docs/atlas/`, `PLAYBOOKS/`, `agents/`, `roadmap/` | 다수 | 부가 설계·요약 |

`state/CONTEXT_INDEX.md` **Always** 표에 포함된 문서 경로:

- `docs/06_OPERATIONS/{DAILY_LOOP,DECISION_PROCESS,STATE_DISCIPLINE,BINARY_ASSET_POLICY}.md`
- `docs/DECISIONS.md`
- `docs/05_AGENTS/ROLE_SPLIT.md`
- `docs/GLOSSARY.md`

**`docs/process/`는 CONTEXT_INDEX Always/Optional에 없음.**

---

## 3. 참조 분석

| 검사 | 결과 |
|------|------|
| `README.md` / `AGENTS.md` → `docs/process` | **0** |
| `state/` → `docs/process` | **0** |
| `tools/` · `scripts/` · `.github/` · `config/` · `core/` → `docs/process` | **0** |
| CI 워크플로가 process md 로드 | **0** |
| `docs/atlas/*` → `ATLAS_REVIEW_CONTEXT.md` | **있음** (검토 렌즈 링크 4건) |
| process 내부 상호 링크 | 다수 (CORE_INDEX ↔ DUPLICATE_POLICY, STATUS→AUDIT 등) |

운영 자동화·에이전트 컨텍스트의 **공식 문서 그래프는 `docs/` + `state/`**.  
`docs/process/` 참조는 주로 **같은 디렉터리 내부** 또는 **docs/atlas 역사 요약**에 한정.

---

## 4. 이름 충돌 (동일 역할 후보)

| 파일 | `docs/` | `docs/process/` | 관계 |
|------|---------|-----------------|------|
| `DESIGN_PRINCIPLES.md` | 8 lines 실문 | **1 line 제목만** | process = **스텁 / LEGACY** |
| `EXECUTION_MODEL.md` | 23 lines 실문 | **1 line 제목만** | process = **스텁 / LEGACY** |
| Architecture | `ARCHITECTURE.md` 199 lines | `ATLAS_ARCHITECTURE.md` **1 line** | process = **스텁** |
| Release notes | `RELEASE_NOTES_v1.2.md` | `RELEASE_NOTES.md` (v1.0 foundation) | process = **구버전 / Historical** |
| Vision | `00_VISION/` | `VISION.md` (Sera 제거 등) | process = **구 전략 메모 / Historical** |

---

## 5. Git 이력 (요약)

- process 다수 스텁·FOUNDATION: **2026-07-25** Runtime V2 묶음 커밋.
- 위생/정리 보고서: **2026-07-20 ~ 07-30**.
- Alpha/Beta 본문: R9에서 path 제거 · 포인터만 **2026-08-11**.
- `PROJECT_REGISTRY.md`: **2026-08-11** TASK_MAP 동기화 (최근이나 SoR는 `state/PROJECT_MAP.md`).
- 루트 `docs/` 번호 체계·OPERATIONS·DECISIONS: CONTEXT_INDEX와 함께 **현재 운영 기준**.

---

## 6. `docs/process/` 문서별 분류

범례: AR=ARCHIVE CANDIDATE · RM=REMOVE CANDIDATE · K=KEEP(포인터/유용) · L=LEGACY · H=Historical · M=MERGE · I=INVESTIGATE

| 문서 | 역할 | 참조 | 최신성 | 분류 | 근거 |
|------|------|------|--------|------|------|
| README_ARCHIVED_ALPHA_BETA.md | 이동 포인터 | 내부 | 2026-08-11 | **KEEP** | archive 안내 |
| README_ARCHIVED_ROOT_TEMP.md | 이동 포인터 | 내부 | 2026-08-11 | **KEEP** | archive 안내 |
| DESIGN_PRINCIPLES.md | 스텁 | 무 | 07-25 | **REMOVE CANDIDATE** | 1줄 · SoR는 `docs/DESIGN_PRINCIPLES.md` |
| EXECUTION_MODEL.md | 스텁 | 무 | 07-25 | **REMOVE CANDIDATE** | 1줄 · SoR는 `docs/EXECUTION_MODEL.md` |
| ATLAS_ARCHITECTURE.md | 스텁 | 무 | 07-25 | **REMOVE CANDIDATE** | 1줄 · SoR는 `docs/ARCHITECTURE.md` |
| ATLAS_FOUNDATION.md | 스텁 | 무 | 07-25 | **REMOVE CANDIDATE** | 1줄 |
| SYSTEM_MANIFEST.md | 스텁 | 무 | 07-25 | **REMOVE CANDIDATE** | 1줄 |
| todo.md | 구 todo | 무 | 07-20 | **ARCHIVE CANDIDATE** | 루트 이관 잔여 |
| RELEASE_NOTES.md | v1.0 notes | 무 | 07-20 | **ARCHIVE CANDIDATE** | v1.2가 docs 루트에 존재 |
| CONTRIBUTING.md | process 기여 | 무 | 07-20 | **ARCHIVE CANDIDATE** | 운영 SoR 아님 |
| PROJECT_LIFECYCLE.md | 수명주기 | 무 | 07-20 | **ARCHIVE CANDIDATE** | |
| VISION.md | 구 비전 | 무 | 07-30 | **ARCHIVE CANDIDATE** | 00_VISION이 live |
| ROOT_DOCUMENT_RELOCATION.md | 이관 기록 | 자기 | 07-21 | **ARCHIVE CANDIDATE** | 역사 H2 |
| ATLAS_MARKDOWN_INDEX.md | md 인덱스 | 자기 | 07-21 | **ARCHIVE CANDIDATE** | 구 인덱스 |
| DUPLICATE_POLICY.md | 중복 정책 | CORE_INDEX | 07-30 | **ARCHIVE CANDIDATE** | process-local |
| CORE_INDEX.md | process 인덱스 | DUPLICATE | 07- | **ARCHIVE CANDIDATE** | |
| ENVIRONMENTS.md | 환경 | 무 | 07-30 | **ARCHIVE CANDIDATE** | |
| PROJECT_STATE_SCHEMA.md | 스키마 초안 | REGISTRY | 07- | **ARCHIVE / INVESTIGATE** | state 스키마와 관계 확인 후 |
| PROJECT_REGISTRY.md | 레지스트리 | 최근 sync | 08-11 | **INVESTIGATE** | `state/PROJECT_MAP.md`와 중복 가능 |
| ATLAS_PRIORITY_ENGINE_POST_ALPHA_PLAN.md | PE 개선안 | 무 | 07-26 | **ARCHIVE CANDIDATE** | post-alpha 계획 |
| ATLAS_IMPLEMENTATION_AUDIT.md | 구현 감사 | STATUS | 07-25 | **ARCHIVE CANDIDATE** | H2 |
| ATLAS_STATUS_REPORT.md | 상태 보고 | AUDIT | 07- | **ARCHIVE CANDIDATE** | |
| ATLAS_DEVOS_PRINCIPLES.md | DevOS 원칙 | 무 | 07-25 | **ARCHIVE / MERGE?** | DESIGN_PRINCIPLES·00_VISION과 겹칠 수 있음 |
| FORGE_* | forge 우선 | 무 | 07-25 | **ARCHIVE CANDIDATE** | forge HOLD |
| ATLAS_REVIEW_CONTEXT.md | 검토 렌즈 | docs/atlas 4링크 | 07- | **KEEP or ARCHIVE** | 외부 링크 있음 → **삭제 금지** · 이동 시 링크 갱신 필요 |
| ATLAS_RUNTIME_BOUNDARY_ANALYSIS.md | 경계 분석 | 무 | 07- | **ARCHIVE CANDIDATE** | `docs/ATLAS_RUNTIME_BOUNDARY.md`와 역할 유사 가능 |
| ATLAS_CONTRACT_ARCHITECTURE.md | 계약 | 무 | 07- | **ARCHIVE CANDIDATE** | |
| ATLAS_DECISION_CONTRACT_SPEC.md | Decision 계약 | 무 | 07- | **ARCHIVE / MERGE** | DECISIONS·DECISION_PROCESS와 관계 확인 |
| DECISION_ENGINE_PLAN.md | DE 계획 | 무 | 07- | **ARCHIVE CANDIDATE** | |
| ATLAS_BUSINESS_AGENT_REGISTRY_REVIEW.md | 에이전트 레지스트리 | 무 | 07- | **ARCHIVE CANDIDATE** | Beta 계열 잔여 |
| ATLAS_REPOSITORY_* (3) | 저장소 위생 보고 | 상호 | 07- | **ARCHIVE CANDIDATE** | maintenance 계열과 역할 중복 |
| ATLAS_MARKDOWN_CLEANUP_ANALYSIS.md | md 정리 분석 | 무 | 07- | **ARCHIVE CANDIDATE** | |

---

## 7. `docs/` (운영·설계) — KEEP / SoR

| 경로 | 분류 |
|------|------|
| `docs/06_OPERATIONS/*` | **SOR** (CONTEXT_INDEX Always) |
| `docs/DECISIONS.md` | **SOR** |
| `docs/05_AGENTS/*`, `docs/GLOSSARY.md` | **SOR** |
| `docs/00_VISION` … `04_*`, `07_ROADMAP` (live design) | **KEEP / design SoR** |
| `docs/adr/*` | **KEEP** |
| `docs/ARCHITECTURE.md`, `DESIGN_PRINCIPLES.md`, `EXECUTION_MODEL.md` | **KEEP** (process 스텁의 상위 원본) |
| `docs/maintenance/*` | **KEEP** (감사 메타 · 운영 코드 아님) |
| `docs/ROADMAP.md` | **KEEP** (historical banner · CONTEXT optional) |
| `docs/atlas/*` | **KEEP / Historical** (process REVIEW_CONTEXT 링크 유지) |

---

## 8. 후속 후보 (실행 금지 — 문서만)

### REMOVE CANDIDATE (스텁 · 정보 손실 없음)

- `docs/process/DESIGN_PRINCIPLES.md`
- `docs/process/EXECUTION_MODEL.md`
- `docs/process/ATLAS_ARCHITECTURE.md`
- `docs/process/ATLAS_FOUNDATION.md`
- `docs/process/SYSTEM_MANIFEST.md`

### ARCHIVE CANDIDATE

권장 경로 예: `archive/docs-process-legacy/` (Master 승인 후)

- 위생·감사 보고서 3종, IMPLEMENTATION/STATUS, MARKDOWN_*, ROOT_DOCUMENT_RELOCATION
- RELEASE_NOTES, CONTRIBUTING, PROJECT_LIFECYCLE, VISION, todo, ENVIRONMENTS
- FORGE_*, PRIORITY_ENGINE_POST_ALPHA_PLAN, CONTRACT/DECISION plan 계열
- DUPLICATE_POLICY, CORE_INDEX
- BUSINESS_AGENT_REGISTRY_REVIEW

### MERGE CANDIDATE (보류 · 내용 대조 후)

- `ATLAS_DEVOS_PRINCIPLES` ↔ `docs/DESIGN_PRINCIPLES` / `00_VISION`
- `ATLAS_RUNTIME_BOUNDARY_ANALYSIS` ↔ `docs/ATLAS_RUNTIME_BOUNDARY.md`
- `ATLAS_DECISION_CONTRACT_SPEC` ↔ `docs/DECISIONS` / `06_OPERATIONS/DECISION_PROCESS`
- `PROJECT_REGISTRY` ↔ `state/PROJECT_MAP.md`

### INVESTIGATE

- `PROJECT_REGISTRY.md` / `PROJECT_STATE_SCHEMA.md` — state SoR와 관계
- `ATLAS_REVIEW_CONTEXT.md` — 링크 4건 · 이동 시 일괄 갱신 필요

### KEEP in process (당장)

- `README_ARCHIVED_*` 포인터 2개
- (선택) `ATLAS_REVIEW_CONTEXT.md` until link migration

---

## 9. 가설 검증

| 가설 | 결과 |
|------|------|
| `docs/` = 공식 SoR, `docs/process/` = legacy | **채택 (경우 A)** |
| `docs/process/` = 개발 프로세스 SoR | **기각** — CONTEXT_INDEX/CI/AGENTS 미참조 |
| 역할 완전 분리 (둘 다 현재 필요) | **부분만** — process는 역사·스텁 위주 |

---

## 10. 이번 작업

삭제·이동·통합: **0**  
본 문서만 추가.

## 11. 다음 에이전트

Master 승인 후:

1. REMOVE 스텁 5개  
2. ARCHIVE 일괄 (경로 확정)  
3. MERGE는 파일별 diff 승인 후  
4. `ATLAS_REVIEW_CONTEXT` 링크 정책 결정  

Excelion / Unreal / 코드 / state SoR 본문 변경 금지.

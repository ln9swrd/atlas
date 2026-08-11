# Documentation Source of Record Review — 2026-08-11

조사일: 2026-08-11  
시작 SHA: `74663e015040d9ba41abb91eba1a949fce46e27a`  
대상: `docs/` · `docs/process/`  
역할: **조사만** (삭제·이동·통합 **0**) — 이후 Execution 절에서 스텁 5개 삭제 기록

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
| `docs/process/` | **35→30** (스텁 5 제거 후) | process 실험·감사·스텁·포인터 |
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
| `DESIGN_PRINCIPLES.md` | 8 lines 실문 | **REMOVED stub** | SoR = docs/ |
| `EXECUTION_MODEL.md` | 23 lines 실문 | **REMOVED stub** | SoR = docs/ |
| Architecture | `ARCHITECTURE.md` 199 lines | **REMOVED** ATLAS_ARCHITECTURE stub | SoR = docs/ |
| Release notes | `RELEASE_NOTES_v1.2.md` | `RELEASE_NOTES.md` (v1.0 foundation) | process = **구버전 / Historical** |
| Vision | `00_VISION/` | `VISION.md` (Sera 제거 등) | process = **구 전략 메모 / Historical** |

---

## 5. Git 이력 (요약)

- process 다수 스텁·FOUNDATION: **2026-07-25** Runtime V2 묶음 커밋.
- 위생/정리 보고서: **2026-07-20 ~ 07-30**.
- Alpha/Beta 본문: R9에서 path 제거 · 포인터만 **2026-08-11**.
- 스텁 5개 삭제: **2026-08-11** Execution.
- 루트 `docs/` 번호 체계·OPERATIONS·DECISIONS: CONTEXT_INDEX와 함께 **현재 운영 기준**.

---

## 8. 후속 후보 (스텁 제거 후 남은 것)

### REMOVE CANDIDATE

- **완료** (스텁 5개)

### ARCHIVE CANDIDATE

권장 경로 예: `archive/docs-process-legacy/` (Master 승인 후)

- 위생·감사 보고서, IMPLEMENTATION/STATUS, MARKDOWN_*, ROOT_DOCUMENT_RELOCATION
- RELEASE_NOTES, CONTRIBUTING, PROJECT_LIFECYCLE, VISION, todo, ENVIRONMENTS
- FORGE_*, PRIORITY_ENGINE_POST_ALPHA_PLAN, CONTRACT/DECISION plan 계열
- DUPLICATE_POLICY, CORE_INDEX
- BUSINESS_AGENT_REGISTRY_REVIEW

### MERGE CANDIDATE (보류)

- `ATLAS_DEVOS_PRINCIPLES` ↔ `docs/DESIGN_PRINCIPLES` / `00_VISION`
- `ATLAS_RUNTIME_BOUNDARY_ANALYSIS` ↔ `docs/ATLAS_RUNTIME_BOUNDARY.md`
- `ATLAS_DECISION_CONTRACT_SPEC` ↔ `docs/DECISIONS` / `06_OPERATIONS/DECISION_PROCESS`
- `PROJECT_REGISTRY` ↔ `state/PROJECT_MAP.md`

### INVESTIGATE

- `PROJECT_REGISTRY.md` / `PROJECT_STATE_SCHEMA.md`
- `ATLAS_REVIEW_CONTEXT.md` — 링크 4건 · 이동 시 일괄 갱신 필요

### KEEP in process

- `README_ARCHIVED_*` 포인터 2개
- `ATLAS_REVIEW_CONTEXT.md` until link migration

---

## Execution — stub removal (2026-08-11)

시작 SHA: `21c5e09673a124220dab886b95502d534570393d`

### 삭제 (5)

| Path | 이유 |
|------|------|
| `docs/process/DESIGN_PRINCIPLES.md` | 1-line stub · SoR = `docs/DESIGN_PRINCIPLES.md` |
| `docs/process/EXECUTION_MODEL.md` | 1-line stub · SoR = `docs/EXECUTION_MODEL.md` |
| `docs/process/ATLAS_ARCHITECTURE.md` | 1-line stub · SoR = `docs/ARCHITECTURE.md` |
| `docs/process/ATLAS_FOUNDATION.md` | 1-line stub |
| `docs/process/SYSTEM_MANIFEST.md` | 1-line stub |

### 보존

- `docs/` SoR · `state/` · `AGENTS.md` · `docs/maintenance/`
- `ATLAS_REVIEW_CONTEXT.md` 및 나머지 `docs/process/` legacy
- process archive 일괄 이동 **미수행**

### 재검증

- tools/tests/CI/state 의 `docs/process/<stub>` 경로 참조: **0**
- 역사·maintenance 문서의 과거 경로 언급: 보존

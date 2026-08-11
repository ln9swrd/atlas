# Documentation Source of Record Review — 2026-08-11

조사일: 2026-08-11  
시작 SHA: `74663e015040d9ba41abb91eba1a949fce46e27a`  
대상: `docs/` · `docs/process/`  
역할: 조사 + 후속 기록 (스텁 제거 실행 · Registry/State 관계 조사)

---

## 1. SoR 결론 (한 줄)

**경우 A:** 운영·설계 SoR = `docs/` (특히 `06_OPERATIONS/`, `DECISIONS.md`, 번호 체계, `adr/`) + `state/` + `AGENTS.md`.  
**`docs/process/` = legacy / historical process 영역 (운영 SoR 아님).**

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

---

## Project Registry / State SoR — 2026-08-11

시작 SHA: `ae07310ae54133c51866da6e20db28714ac006c2`  
역할: **조사만** (state/ · process/ · projects/ **미변경**)

### 실제 경로

| 항목 | 경로 |
|------|------|
| PROJECT_REGISTRY | `docs/process/PROJECT_REGISTRY.md` |
| PROJECT_STATE_SCHEMA | `docs/process/PROJECT_STATE_SCHEMA.md` |
| PROJECT_MAP | `state/PROJECT_MAP.md` |

### 내용·역할

| 항목 | 역할 | 계층 |
|------|------|------|
| **PROJECT_MAP** | 디스크상 프로젝트 경로·등록 상태의 **현재 목록** | **Current State / Path SoR** |
| **PROJECT_REGISTRY** | 도메인 프로젝트 표·의도·온보딩 안내. 본문이 **`state/PROJECT_MAP.md`를 path truth로 명시** | **Definition / catalog** (MAP에 종속) |
| **PROJECT_STATE_SCHEMA** | `projects/<name>/state/` 파일 형식·Atlas root state와 분리 규칙 | **Schema SoR** (도메인 state) |

세 문서는 **동일 복사본이 아님.**

- MAP = 무엇이 어디에 있는가 (지금)
- REGISTRY = 무엇을 제품으로 다루는가 + 설명 (MAP 참조)
- SCHEMA = 프로젝트 state 파일을 어떻게 쓸 것인가

### 실제 참조

| 참조자 | 대상 | 비고 |
|--------|------|------|
| `PROJECT_REGISTRY.md` | → `state/PROJECT_MAP.md`, → `PROJECT_STATE_SCHEMA` | 자체 선언 |
| `projects/README.md` | → `state/PROJECT_MAP.md` | 경로 SoR |
| `projects/_template/**` | → `PROJECT_STATE_SCHEMA.md` | 온보딩 스키마 |
| tools / scripts / .github / core | **0** | runtime 미로드 |
| AGENTS.md | **0** 직접 파일명 | 도메인 분리만 |

### Git 이력

- SCHEMA: G2 도입 (07-30) · D30 모드 갱신
- REGISTRY: 레지스트리 정렬 · R4/R5 sync (08-11) · path truth를 MAP으로 명시
- MAP: 제품 SoR 경로·CLOSED·R5 archive 반영 등 **state 운영 이력**

### 판단 표

| 항목 | 역할 | 실제 참조 | SoR | 중복 | 판단 |
|------|------|-----------|-----|------|------|
| PROJECT_REGISTRY | Definition/catalog | template 외·MAP 가리킴 | **아니오** (path는 MAP) | MAP과 **목록 겹침 가능** · 역할은 다름 | **KEEP** (삭제 금지) · 장기 MERGE→README/MAP 가능 |
| PROJECT_STATE_SCHEMA | Schema | `_template` **활성** | **Schema SoR** | MAP과 **비중복** | **KEEP** |
| PROJECT_MAP | Current path state | projects/README, REGISTRY | **Path / listing SoR** | — | **KEEP / SoR** |

### 결론 (경우 **B** 변형)

| 질문 | 답 |
|------|-----|
| Project Definition / catalog | `PROJECT_REGISTRY` (보조) + `projects/README` |
| Schema SoR | **`docs/process/PROJECT_STATE_SCHEMA.md`** |
| Current State / Path SoR | **`state/PROJECT_MAP.md`** |
| Legacy | **없음** (셋 다 역할 있음) |
| REMOVE | **0** |
| ARCHIVE | REGISTRY만 **장기** 후보 (지금 아님) |
| Next action | MAP↔REGISTRY 목록 정합만 유지 · SCHEMA는 `_template`와 함께 유지 · **삭제/통합 금지 until Master** |

**잘못 합치면:** 스키마와 현재 목록이 섞이거나, path truth가 process로 옮겨져 CONTEXT/state 규율과 충돌할 수 있음.

# Documentation Source of Record Review — 2026-08-11

조사일: 2026-08-11  
시작 SHA: `74663e015040d9ba41abb91eba1a949fce46e27a`  
대상: `docs/` · `docs/process/`

## 1. SoR 결론

**운영·설계 SoR = `docs/` + `state/` + `AGENTS.md`.**  
**`docs/process/` = process 영역 (일부 runtime KEEP · 다수 legacy).**

## Execution — stub removal

스텁 5개 삭제 완료 (DESIGN_PRINCIPLES, EXECUTION_MODEL, ATLAS_ARCHITECTURE, ATLAS_FOUNDATION, SYSTEM_MANIFEST).

## Project Registry / State SoR

| 항목 | SoR |
|------|-----|
| Path / listing | `state/PROJECT_MAP.md` |
| Schema | `docs/process/PROJECT_STATE_SCHEMA.md` |
| Catalog | `docs/process/PROJECT_REGISTRY.md` (KEEP) |

---

## Process Legacy Archive Classification — 2026-08-11

시작 SHA: `3475215b4ae0ff783fe3a289da7a1c828a7627ba`  
`docs/process/` 잔여 **30** 파일 · **삭제/이동 0**

### Archive 위치

`archive/docs-process-legacy/` — **사용 가능 (YES)**  
- 기존: `process-alpha-beta-snapshots/`, `process-root-temp/` 와 병행 가능  
- `archive/README.md` 정책: archive ≠ live SoR · 충돌 없음

### 보호 (KEEP — archive 금지)

| 문서 | 근거 |
|------|------|
| `PROJECT_STATE_SCHEMA.md` | Schema SoR · `_template` 참조 |
| `PROJECT_REGISTRY.md` | Catalog · MAP 종속 · KEEP |
| `ENVIRONMENTS.md` | **runtime 로드** (`core/execution/*`, `tools/atlas_runner.py` fallback) |
| `ATLAS_IMPLEMENTATION_AUDIT.md` | **`tools/atlas_runner.py` 경로 로드** |
| `ATLAS_REVIEW_CONTEXT.md` | `docs/atlas/*` 링크 4건 |
| `README_ARCHIVED_ALPHA_BETA.md` | archive 포인터 |
| `README_ARCHIVED_ROOT_TEMP.md` | archive 포인터 |

### 전체 분류 표

| 문서 | 현재 역할 | 참조 | SoR | 역사 가치 | 최종 분류 |
|------|-----------|------|-----|-----------|-----------|
| PROJECT_STATE_SCHEMA.md | Schema | `_template` 활성 | YES | — | **KEEP** |
| PROJECT_REGISTRY.md | Catalog | README/self | path는 MAP | — | **KEEP** |
| ENVIRONMENTS.md | 환경 레지스트리 | **core/tools/tests** | runtime | — | **KEEP** |
| ATLAS_IMPLEMENTATION_AUDIT.md | 구현 감사 | **atlas_runner** | runtime read | H2 | **KEEP** |
| ATLAS_REVIEW_CONTEXT.md | 검토 렌즈 | docs/atlas | 문서 참조 | H2 | **KEEP** |
| README_ARCHIVED_* (2) | 이동 포인터 | — | — | — | **KEEP** |
| ATLAS_STATUS_REPORT.md | 구 상태보고 | process 내부 | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_CONTRACT_ARCHITECTURE.md | 계약 설계 | archive only | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_DECISION_CONTRACT_SPEC.md | Decision 계약 | archive only | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_DEVOS_PRINCIPLES.md | DevOS 원칙 | archive only | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_MARKDOWN_CLEANUP_ANALYSIS.md | md 정리 분석 | 무 | NO | H3 | **ARCHIVE CANDIDATE** |
| ATLAS_MARKDOWN_INDEX.md | 구 인덱스 | 무 | NO | H3 | **ARCHIVE CANDIDATE** |
| ATLAS_PRIORITY_ENGINE_POST_ALPHA_PLAN.md | PE 계획 | 무 | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_REPOSITORY_ARTIFACT_CLEANUP_REPORT.md | 위생 보고 | hygiene phase2 | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_REPOSITORY_HYGIENE_PHASE2_REVIEW.md | 위생 보고 | artifact | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_REPOSITORY_HYGIENE_REVIEW.md | 위생 보고 | 무 | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_RUNTIME_BOUNDARY_ANALYSIS.md | 경계 분석 | 무 | NO | H2 | **ARCHIVE CANDIDATE** |
| ATLAS_BUSINESS_AGENT_REGISTRY_REVIEW.md | 에이전트 리뷰 | 무 | NO | H2 | **ARCHIVE CANDIDATE** |
| DECISION_ENGINE_PLAN.md | DE 계획 | archive | NO | H2 | **ARCHIVE CANDIDATE** |
| CORE_INDEX.md | process 인덱스 | archive README, DUPLICATE | NO | H3 | **ARCHIVE CANDIDATE** |
| DUPLICATE_POLICY.md | 중복 정책 | archive README, CORE | NO | H3 | **ARCHIVE CANDIDATE** |
| CONTRIBUTING.md | 기여 안내 | archive | NO | H3 | **ARCHIVE CANDIDATE** |
| PROJECT_LIFECYCLE.md | 수명주기 | archive | NO | H3 | **ARCHIVE CANDIDATE** |
| RELEASE_NOTES.md | v1.0 notes | archive | NO | H3 | **ARCHIVE CANDIDATE** |
| ROOT_DOCUMENT_RELOCATION.md | 이관 기록 | archive, todo | NO | H2 | **ARCHIVE CANDIDATE** |
| VISION.md | 구 비전 | archive, PROJECT_STATUS | NO | H2 | **ARCHIVE CANDIDATE** |
| FORGE_FIRST_MISSION.md | forge 미션 | archive | NO | H3 | **ARCHIVE CANDIDATE** |
| FORGE_RUNTIME_PRIORITY.md | forge 우선 | archive | NO | H3 | **ARCHIVE CANDIDATE** |
| todo.md | 구 todo | archive, ROOT_RELOC | NO | H3 | **ARCHIVE CANDIDATE** |

### 통계

| 분류 | 수 |
|------|---:|
| docs/process total | **30** |
| KEEP | **7** |
| ARCHIVE CANDIDATE | **23** |
| REMOVE CANDIDATE | **0** |
| INVESTIGATE | **0** |

### 주의

- **ENVIRONMENTS.md / IMPLEMENTATION_AUDIT.md** 는 코드 경로 참조 → archive 시 **runner/core 수정 필요** → **KEEP**
- CORE_INDEX / DUPLICATE_POLICY 이동 시 `archive/README.md` 링크 갱신 필요

### Next (Master 승인 후)

1. ARCHIVE 23 → `archive/docs-process-legacy/` (+ archive/README 한 줄)
2. KEEP 7 유지
3. REMOVE 추가 없음

# Repository Cleanup Investigation — 2026-08-11

## 작업 시작 HEAD

- SHA: `58b37d0cb0d9c50feb367a72c112857ab65d66dd`
- Message: `feat(excelion): restore Unreal 5.3.2 project skeleton (AXION prototype base)`
- Branch: `main`
- Working tree: clean (no prior uncommitted changes)

## 조사한 경로

| 경로 | 파일 수 | 용량 | 마지막 관련 커밋 |
|------|---------|------|------------------|
| `archive/projects-forge-legacy/` | 11 | 56K | 97de831 (2026-08-04, untrack pycache) |
| `archive/projects-templates-legacy/` | 3 | 20K | cb4999e (2026-07-31, R2 archive) |
| `archive/projects-atlas-extension-legacy/` | 14 | 108K | c11b9ce (2026-08-09, remove node_modules) |
| `archive/excelion-exelion_forge-stub/` | 9 | 64K | dceb51a (2026-07-31, R3 archive) |
| `archive/legacy_files/` | 12 | 92K | 5e01bde (2026-07-31, pointer) |

`archive/summary/`, `archive/recovered/`, `archive/README.md` 는 지시대로 이번 작업 범위에서 임의 삭제하지 않음.

## 참조 검색 결과

### projects-forge-legacy
- `docs/atlas/APPLICATION_DISCOVERY.md` — 역사 이동 기록
- `projects/excelion/state/FORGE_REMOVAL_SCOPE_2026-08-09.md` — **명시적 KEEP** ("역사 기록 | 보존")
- `state/ATLAS_REVIEW_2026-07-31.md` — R1 archive 기록

### projects-templates-legacy
- `state/ATLAS_REVIEW_2026-07-31.md` — R2 archive 기록

### projects-atlas-extension-legacy
- `state/ATLAS_REVIEW_2026-07-31.md` — R4 / D22 기록
- 자체 `REBUILD.md` 내부 경로
- D22: atlas-extension 폐기 (do not revive)

### excelion-exelion_forge-stub
- `state/ATLAS_REVIEW_2026-07-31.md` — R3 archive 기록

### legacy_files
- `archive/README.md` — 내용 목록에 포함

**projects/, docs/, state/, scripts/, .github/, README.md 영역에서 런타임/빌드 import 또는 실행 경로 참조 없음.**

`core/forge/` 는 별도 활성 코어 모듈 (test skipped HOLD). `projects/_template/` 가 현재 템플릿.

## 분류표 (1차)

| 경로 | 용량 | 참조 여부 | 현재 사용 | 판단 | 근거 |
|------|------|-----------|-----------|------|------|
| Forge legacy (`archive/projects-forge-legacy/`) | 56K | 문서 역사 참조 + **명시 KEEP** | 아니오 (운영 코드 0) | **KEEP** | FORGE_REMOVAL_SCOPE 2026-08-09 명시 보존. 역사 기록. |
| Templates legacy (`archive/projects-templates-legacy/`) | 20K | 리뷰 문서만 | 아니오 (현재 `_template` 존재) | **KEEP** (1차) → 2차 DELETE | 1차 보류 후 2차에서 삭제 확정 |
| Atlas Extension legacy (`archive/projects-atlas-extension-legacy/`) | 108K | D22/리뷰 문서 | 아니오 (폐기됨) | **KEEP** (1차) → 2차 DELETE | 1차 보류 후 2차에서 삭제 확정 |
| Excelion Forge stub (`archive/excelion-exelion_forge-stub/`) | 64K | 리뷰 문서만 | 아니오 (빈 stub README) | **KEEP** (1차) → 2차 DELETE | 1차 보류 후 2차에서 삭제 확정 |
| legacy_files (`archive/legacy_files/`) | 92K | archive README | 아니오 | **KEEP** | archive README 목록. 복구/역사 스냅샷 성격. |

## 삭제한 경로 (1차)

없음.

---

## 2차 정리 (2026-08-11) — Archive 후보 실제 삭제

### 시작 HEAD
`c143a2b191677331c0bb374e5ae25207f7a01128` (1차 조사 커밋)

### 후보별 최종 판단

| 후보 | 운영 참조 | 문서 의존성 | 역사적 가치 | 최종 |
|------|-----------|-------------|-------------|------|
| `archive/projects-templates-legacy/` | 없음 (`projects/_template` 사용) | ATLAS_REVIEW 과거 기록 + 본 문서만 | 낮음 (구 템플릿, 현재와 상이) | **DELETE** |
| `archive/projects-atlas-extension-legacy/` | 없음 (프로젝트 디렉터리 없음, CI 미사용, script는 DEPRECATION exit) | ATLAS_REVIEW / D22 기록 (과거 시제) | 폐기된 extension 소스 아카이브 | **DELETE** |
| `archive/excelion-exelion_forge-stub/` | 없음 | ATLAS_REVIEW 과거 기록 | 빈 stub (README만, 실제 소스 없음) | **DELETE** |

### 검색 결과 요약
- `git grep projects-templates-legacy` → 본 maintenance 문서 + `state/ATLAS_REVIEW_2026-07-31.md` (R2 이동 기록)만
- `git grep projects-atlas-extension-legacy` → 동일 + archive 내부 REBUILD.md
- `git grep excelion-exelion_forge-stub` → 동일
- 운영 영역(projects/ docs/ state/ scripts/ .github/ README)에서 경로를 **실행/빌드/링크**하는 참조 없음
- `atlas-extension` 문자열은 다수 존재하나 D22 폐기 기록·과거 브랜치 이야기이며 archive 경로를 가리키지 않음

### 삭제 실행
26 files deleted across the three trees (~192K).
Remote applied via sequential file deletes (API constraint).

### 문서 링크 수정
- 없음. 역사 문서(`state/ATLAS_REVIEW_2026-07-31.md`)의 과거 시제 기록은 그대로 보존.
- 본 문서에 2차 결과 추가.

### 검증
- 삭제 후 세 경로 디렉터리 없음 확인
- 운영 영역 파일 변경: 없음
- `archive/` 잔존: README.md, legacy_files/, projects-forge-legacy/, recovered/, summary/
- 금지 경로 삭제 없음

### 남은 후보
- `archive/projects-forge-legacy/` — FORGE_REMOVAL_SCOPE 명시 KEEP → 계속 보존
- `archive/legacy_files/`, `archive/summary/`, `archive/recovered/`, `archive/README.md` — 금지 목록

### 다음 작업
- 추가 archive 정리 불필요 (금지 항목만 남음)
- Master가 forge-legacy KEEP 정책을 변경할 경우에만 재검토

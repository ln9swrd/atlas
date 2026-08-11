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

## 분류표

| 경로 | 용량 | 참조 여부 | 현재 사용 | 판단 | 근거 |
|------|------|-----------|-----------|------|------|
| Forge legacy (`archive/projects-forge-legacy/`) | 56K | 문서 역사 참조 + **명시 KEEP** | 아니오 (운영 코드 0) | **KEEP** | FORGE_REMOVAL_SCOPE 2026-08-09 명시 보존. 역사 기록. |
| Templates legacy (`archive/projects-templates-legacy/`) | 20K | 리뷰 문서만 | 아니오 (현재 `_template` 존재) | **KEEP** (이번 패스) | 삭제 영향 검증 불충분. 문서 갱신 없이 경로 깨짐 가능. 작은 용량. |
| Atlas Extension legacy (`archive/projects-atlas-extension-legacy/`) | 108K | D22/리뷰 문서 | 아니오 (폐기됨) | **KEEP** (이번 패스) | D22 폐기이나 archive 의도적 보존. 임의 삭제 금지 원칙. |
| Excelion Forge stub (`archive/excelion-exelion_forge-stub/`) | 64K | 리뷰 문서만 | 아니오 (빈 stub README) | **KEEP** (이번 패스) | 동일. 향후 Master 확인 후 후보. |
| legacy_files (`archive/legacy_files/`) | 92K | archive README | 아니오 | **KEEP** | archive README 목록. 복구/역사 스냅샷 성격. |

## 삭제한 경로

없음.

## 보존한 경로

- 위 표 전체 + `archive/summary/`, `archive/recovered/`, `archive/README.md`

## 실행한 검증

- `git status` / `git branch` / `git log` / `git fetch` / HEAD 기록: 완료
- 디렉터리별 파일 수·용량·마지막 커밋: 완료
- `git grep` 경로명 및 주요 키워드: 완료 (운영 영역 무참조)
- `ls` / `find projects -maxdepth 2`: 정상
- 테스트: N/A (코드 변경·삭제 없음)
- 삭제 후 grep: N/A

## 삭제 후 저장소 상태

변경 없음. Working tree clean. HEAD 동일.

## 남은 정리 후보

다음을 **Master 확인 후** 삭제 가능 후보로 남김:

1. `archive/projects-templates-legacy/` — 현재 `projects/_template` 로 대체됨
2. `archive/projects-atlas-extension-legacy/` — D22 폐기, VSCode extension 과거본
3. `archive/excelion-exelion_forge-stub/` — 빈 stub (실제 소스는 외부 `ln9swrd/excelion-forge`)
4. (조건부) `archive/projects-forge-legacy/` — FORGE_REMOVAL_SCOPE KEEP 해제 시에만

삭제 시 관련 리뷰/결정 문서의 경로 언급을 함께 갱신하는 것이 권장됨.

## 다음 에이전트가 해야 할 작업

1. Master에게 위 후보 삭제 승인 여부 확인
2. 승인 시 `git rm -r` 후 문서 경로 정리 + 단일 chore 커밋
3. `archive/summary/` / `recovered/` 는 계속 보존
4. Excelion / docs / state / Unreal 구조는 이번 범위 밖 — 건드리지 말 것

## 절대 금지 준수

- reset --hard / clean -fd / force push: 미사용
- 기존 변경 덮어쓰기: 없음
- projects/excelion 개발자료·docs/state 운영문서 삭제: 없음
- 코드 기능 변경: 없음

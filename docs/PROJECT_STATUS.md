# Project Status

## 1. 현재 상태

- Repo: Atlas DevOS
- 현재 브랜치: `main`
- 원격과 동기화됨
- 주요 문서 추가 완료: `PROJECT_OVERVIEW.md`, `PROJECT_EXECUTION_PLAN.md`
- Exelion 프로젝트는 `EX-GOAL-001` 및 `Sprint-001` 단계에 있으며, 초기 백로그가 정리된 상태
- `projects/exelion/backlog.json`에 4개 작업이 있으며, 첫 번째 작업은 `EX-BRAVE-001`

## 2. 주요 문서

- `README.md` — 리포지토리 전체 개요 및 구조
- `SYSTEM_MANIFEST.md` — 시스템 목표, 아키텍처, 현재 상태 요약
- `VISION.md` — 전략과 방향
- `PROJECT_OVERVIEW.md` — 현재 프로젝트 이해용 요약 문서
- `PROJECT_EXECUTION_PLAN.md` — 실행 계획 및 단계별 진행 계획
- `docs/PROJECT_STATUS.md` — 현재 상태 및 단기 실행 체크리스트
- `docs/OPERATIONS.md` — 일일 운영 절차
- `docs/ARCHITECTURE.md` — 아키텍처 계층 및 흐름
- `projects/exelion/sprints/Sprint-001.md` — 현재 스프린트 정의
- `projects/exelion/sprints/Sprint-001-tasklist.md` — 스프린트 작업 리스트
- `projects/exelion/sprints/Sprint-001-report.md` — 스프린트 보고서

## 3. 즉시 실행 항목

1. `projects/exelion/backlog.json`에서 `EX-BRAVE-001`을 오늘의 첫 작업으로 설정
2. `projects/exelion/sprints/Sprint-001-tasklist.md`에 상태(예: Pending, In Progress)를 추가
3. `projects/exelion/sprints/Sprint-001-report.md`에 진행 상황/리스크/잠재 블로커 기록
4. `PROJECT_OVERVIEW.md`와 `PROJECT_EXECUTION_PLAN.md`를 검토 후 필요한 내용을 보강

### 현재 작업

| ID | Description | Target Stage | Estimated Time | Environment | Status |
| --- | --- | --- | --- | --- | --- |
| EX-BRAVE-001 | Brave 기본 프레임 제작 (Dummy Frame, 관절 구조, 공용 조인트) | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-002 | Brave 기본 프레임 UV 매핑 및 Export | Blender - UV 매핑 | 120 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-003 | Brave 외장 장갑 1개 제작 (Material Instance 적용, Naming Rule 검증) | Blender - Export 준비 | 150 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-004 | Brave Unreal Engine 임포트 및 셋업 (Import, Animation, Collision, Blueprint) | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |

## 4. 다음 단계

- **현재 작업**: `EX-BRAVE-001` 모델링 준비 및 작업 시작
- **다음 검토**: `EX-BRAVE-002` UV 매핑 준비
- **통합 준비**: `EX-BRAVE-004` Unreal 임포트 대비 환경 점검
- **문서 자동화**: 이후 문서 갱신을 위한 스크립트 설계

## 5. 리스크 및 이슈

- 현재 `excelion-forge/`, `projects/coin-s/`, `projects/exelion-forge/`가 언트랙 상태이므로, 이 파일들이 실제 작업과 관련 없는 경우 정리 필요
- `DEV_WORK`와 `DEV_HOME` 환경 구분이 명확하며, Unreal 관련 작업은 Home PC에서만 수행해야 함
- 실제 작업이 시작되기 전에 `Sprint-001-report.md`를 반드시 상태 업데이트해야 함

## 6. 권장 일정

- 오늘: `PROJECT_OVERVIEW.md`/`PROJECT_EXECUTION_PLAN.md` 검토, `Sprint-001` 단기 계획 확정
- 내일: `EX-BRAVE-001` 실행 및 진행 기록, `Sprint-001-report.md` 업데이트
- 이후: `EX-BRAVE-002`~`EX-BRAVE-004` 순차 진행 및 `docs/PROJECT_STATUS.md` 유지

# Atlas DevOS

> Atlas는 AI 기반으로 프로젝트 개발 환경을 자동화하고, 지식과 실행 흐름을 지속적으로 보존하며 개선하는 개발 운영 플랫폼입니다.

## AI Context Entry Point

이 README.md는 Atlas DevOS 작업을 시작하는 AI Agent와 개발자를 위한 첫 번째 컨텍스트 진입점입니다.

작업 시작 시 다음 순서로 현재 상태를 확인합니다.

1. `README.md`
   - 시스템 목적 및 전체 구조 확인

2. `docs/PROJECT_STATUS.md`
   - 현재 진행 상태와 우선 작업 확인

3. `PROJECT_OVERVIEW.md`
   - 전체 프로젝트 목표와 범위 확인

4. `ATLAS_STATE.json`
   - 현재 런타임 상태 확인

5. 프로젝트별 문서
   - `projects/{project}/` 이하 상세 내용 확인


## Source of Truth 정책

Atlas의 현재 상태 판단은 다음 우선순위를 따릅니다.

1. Runtime State
   - `ATLAS_STATE.json`

2. Project Status
   - `docs/PROJECT_STATUS.md`

3. Project Overview
   - `PROJECT_OVERVIEW.md`

4. Architecture Documents
   - `docs/`
   - `projects/{project}/`

5. Historical Records
   - 변경 기록 및 과거 문서

과거 문서와 현재 상태가 충돌하는 경우 최신 상태 문서를 기준으로 판단합니다.


## 현재 루트 핵심 문서

루트에는 프로젝트 진입과 전체 방향 확인에 필요한 최소 문서만 유지합니다.

- `README.md`
  - 저장소 소개
  - AI Context Entry Point
  - 문서 탐색 기준

- `PROJECT_OVERVIEW.md`
  - 프로젝트 전반 목표
  - 주요 구성 요소
  - 장기 방향


## 요약

이 저장소는 단순한 코드 저장소가 아니라,

- AI 기반 실행 흐름
- 문서 중심 상태 관리
- 프로젝트 검증 루프

를 함께 제공하는 개발 운영 플랫폼입니다.

Atlas의 모든 작업은 상태와 문서를 기준으로 진행하며,
AI Agent는 README.md를 시작점으로 현재 프로젝트 상태를 확인한 뒤 작업을 수행합니다.
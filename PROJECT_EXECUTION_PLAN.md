# Atlas Execution Plan

## 1. 현재 상태 요약

- Atlas는 `v1.2 RC` 아키텍처가 문서화된 상태이며, `SYSTEM_MANIFEST.md`, `docs/ARCHITECTURE.md`, `docs/OPERATIONS.md`, `docs/ROADMAP.md` 등이 주요 기준 문서입니다.
- 주력 프로젝트는 `projects/exelion`이며, 현재 `EX-GOAL-001`을 중심으로 `Sprint-001`까지 계획이 정리되어 있습니다.
- `projects/exelion/backlog.json`에는 `EX-BRAVE-001` ~ `EX-BRAVE-004` 네 개의 초기 작업 항목이 등록되어 있습니다.
- `projects/exelion/ENVIRONMENT_PLAN.md`에 따라 회사 PC와 홈 PC 역할이 분리되어 있습니다.
- 현재 로컬 `main` 브랜치는 `origin/main`과 동일하며, `excelion-forge/`, `projects/coin-s/`, `projects/exelion-forge/`가 언트랙된 상태입니다.

## 2. 목표

1. Exelion 초기 프로토타입 작업을 명확한 실행 단계로 정리
2. 문서 기반으로 AI/협업자가 빠르게 이해하고 이어갈 수 있는 상태로 만들기
3. 단계별로 검증 가능한 결과와 상태 업데이트를 유지
4. 문서 자동화/커밋 프로세스를 장기적으로 도입할 수 있는 기반 마련

## 3. 우선 순위 작업

### 3.1 바로 할 일
1. `PROJECT_IMPLEMENTATION_PLAN.md`에 따라 Atlas 코어 플랫폼 5대 고도화 영역 구현 (Platform Rule Engine, Review Engine, sys.path 주입, Doc Sync 등)
2. `projects/exelion/backlog.json`의 4개 작업을 `Sprint-001`에 맞게 우선 순위와 실행 상태로 정리
3. `PROJECT_OVERVIEW.md`를 현재 상태 요약 문서로 끝까지 다듬기
4. `SYSTEM_MANIFEST.md`와 `docs/OPERATIONS.md`를 기준으로 ‘오늘 할 일’ 프로세스를 구체화

### 3.2 다음 할 일
1. Exelion 진행 중인 작업을 실제로 수행할 수 있도록 `Sprint-001` 보고서 형식 채우기
2. `todo.md`에 실무 우선순위와 차기 검토 항목 추가
3. 문서 자동화 초안 설계: 주요 문서를 갱신하는 스크립트 또는 명령어 정의

### 3.3 장기 목표
1. `docs/PROJECT_STATUS.md` 또는 `docs/PROJECT_EXECUTION.md`를 만들어 상태 추적 체계화
2. `docs/DECISIONS.md` 스타일로 현재 결정과 미결정 항목 기록
3. `git` 커밋 후 문서 자동 추출·커밋 파이프라인 구성

## 4. 구체적 단계

### 단계 1: 핵심 문서 고정
- `README.md`, `SYSTEM_MANIFEST.md`, `PROJECT_OVERVIEW.md`, `docs/OPERATIONS.md`가 현재 상태를 가장 잘 보여주도록 검토
- `PROJECT_OVERVIEW.md`에 현재 작업 현황과 다음 단계가 명확히 보이도록 유지

### 단계 2: Exelion 실행 흐름 정리
- `projects/exelion/PROJECT_CHARTER.md`와 `EX-GOAL-001.md`에서 목표/산출물/완료 기준을 다시 확인
- `projects/exelion/backlog.json`을 `Sprint-001` 우선순위 기준으로 정리
- `projects/exelion/sprints/Sprint-001-tasklist.md`에 작업 구분(Company PC vs Home PC)과 상태 표시 추가

### 단계 3: 문서형 진행 기록 추가
- `projects/exelion/sprints/Sprint-001-report.md`를 열어 현재 진행 중인 내용, 블로커, 다음 작업을 기록
- `todo.md`에 오늘 할 일과 검토 항목을 추가
- 필요한 경우 `projects/exelion/sprints/Sprint-001-report.md`를 업데이트하여 현재 상태를 문서화

### 단계 4: git/문서 프로세스 정리
- 언트랙된 디렉토리는 현재 작업과 무관하면 `.gitignore`로 관리하거나 추후에 별도 커밋 대상인지 검토
- 문서 변경 및 실행 계획은 `git add` -> `git commit -m "Update project execution plan"` 방식으로 관리
- 장기적으로 `scripts/update_docs.py` 또는 `tools/atlas_runner.py`에 문서 갱신 루틴을 추가

## 5. 추천 진행 순서

1. `PROJECT_OVERVIEW.md` 검토 및 현재 상태 보강
2. `projects/exelion/backlog.json`과 `Sprint-001-tasklist.md` 정리
3. `Sprint-001-report.md`에 현재 상태/진척/리스크 기록
4. `todo.md`에 당일 작업과 검토 항목 적기
5. 문서 변경을 git 커밋으로 정리

## 6. 현재 바로 실행할 수 있는 액션

- `cat projects/exelion/backlog.json | python -m json.tool`로 백로그 항목 확인
- `head -n 100 projects/exelion/sprints/Sprint-001-tasklist.md`로 우선 작업 확인
- `git status`로 현재 파악 중인 변경을 정리
- 문서화된 상태를 기준으로 우선순위 태스크를 선택

## 7. 문서 자동화 제안

### 7.1 최소 자동화
- `PROJECT_OVERVIEW.md`를 기준으로 현재 상태를 손쉽게 갱신할 수 있는 템플릿화
- `todo.md`를 일일 작업 기록으로 사용

### 7.2 중간 자동화
- `scripts/generate_project_overview.py` 또는 `tools/update_docs.py`를 만들어 주요 문서 요약 자동 생성
- 문서 변경 시 `git add PROJECT_OVERVIEW.md todo.md` 후 커밋하는 단순 스크립트

### 7.3 완전 자동화
- `tools/atlas_runner.py`에 현재 상태 요약/문서 업데이트 명령 추가
- `git` 커밋 메시지도 자동화

## 8. 제안된 우선 작업

- `projects/exelion/backlog.json`의 작업들을 `Sprint-001` 중 우선순위별로 상태 표시
- `todo.md`에 다음 3개 작업을 바로 적기
- `PROJECT_OVERVIEW.md`에 현재 진행 중인 작업을 한 줄씩 추가
- `Sprint-001-report.md`를 열어 현재까지 진행 상황을 기록

---

## 요약

지금은 `문서화 + Exelion backlog 정리 + git 상태 정리`가 핵심입니다. 이 세 가지를 먼저 끝내면, 어떤 AI가 와도 프로젝트를 빠르게 파악하고 이어갈 수 있는 기반이 마련됩니다.

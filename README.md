# Atlas DevOS

> Atlas는 AI 기반으로 프로젝트 개발 환경을 자동화하고, 지식과 실행 흐름을 지속적으로 보존하며 개선하는 개발 운영 플랫폼입니다.

## 1. 개요

이 저장소는 Atlas DevOS 플랫폼의 실행 엔진, 에이전트 협업 구조, 그리고 첫 번째 검증 프로젝트인 Exelion을 포함합니다.

- `core/`: Atlas의 런타임, 룰 엔진, 리뷰 엔진, 실행 흐름을 담고 있는 핵심 모듈
- `agents/`: AI 에이전트별 역할과 전문성을 정의한 폴더
- `projects/`: 실제 프로젝트 인스턴스와 백로그, 스프린트, 아키텍처 기록
- `tools/atlas_runner.py`: 일일 시작·마감·검증을 수행하는 실행기
- `docs/`: 아키텍처, 운영, 플레이북, 의사결정 기록 등 문서 자료

## 2. 현재 루트 핵심 문서

루트에는 다음 세 파일만 유지하도록 구성되어 있습니다.

- `README.md` — 저장소 소개 및 빠른 시작
- `PROJECT_OVERVIEW.md` — 프로젝트 전반 요약
- `PROJECT_EXECUTION_PLAN.md` — 실행 계획과 우선순위

## 3. 주요 문서 위치

상세 문서는 루트가 아닌 아래 위치에 정리되어 있습니다.

- `docs/PROJECT_STATUS.md` — 현재 상태 및 단기 실행 항목
- `docs/process/ROOT_DOCUMENT_RELOCATION.md` — 루트 문서 이동 기록
- `docs/process/CONTRIBUTING.md` — 기여 가이드
- `docs/process/ENVIRONMENTS.md` — 개발/배포 환경 정책
- `docs/process/PROJECT_LIFECYCLE.md` — 프로젝트 수명주기
- `docs/process/PROJECT_REGISTRY.md` — 프로젝트 목록 및 상태
- `docs/process/RELEASE_NOTES.md` — 릴리스 노트
- `docs/process/SYSTEM_MANIFEST.md` — 시스템 구성 및 운영 원칙
- `docs/process/VISION.md` — 전략 및 비전

- `docs/atlas/` — Atlas 자체 관련 문서, 결정 기록, 로그, 규칙
- `projects/exelion/` — Exelion 프로젝트 관련 기획, 백로그, 스프린트

## 3.1 AI 자동화 진입점

AI가 `README.md`를 읽고 자동으로 다음 단계를 진행하려면, 이 문서가 시작점이라는 사실을 이용하세요.

- 현재 실행 상태와 작업 우선순위는 `docs/PROJECT_STATUS.md`에서 확인합니다.
- 전체 프로젝트 맥락은 `PROJECT_OVERVIEW.md`와 `PROJECT_EXECUTION_PLAN.md`에서 확인합니다.
- 실행기 진입점은 `tools/atlas_runner.py`입니다.
- 현재 상태 저장소는 `ATLAS_STATE.json`입니다.
- 목표 관리/진행 기록은 `GOAL_REGISTRY.json`과 `projects/exelion/backlog.json`입니다.

`README.md`는 전체 구조와 진입점을 안내하는 역할을 하며, 상세한 판단과 수정은 위의 문서들에서 수행해야 합니다.

## 4. 실행 요약

### 4.1 하루 시작
```
python tools/atlas_runner.py start
```
- 오늘의 추천 작업을 계산하고 상태를 초기화합니다.

### 4.2 하루 마감
```
python tools/atlas_runner.py finish
```
- 룰 엔진과 리뷰 엔진을 실행하여 작업 결과를 검증하고 품질 보고서를 생성합니다.

## 5. 이 저장소에서 확인할 수 있는 것

- `core/execution/` — 실행 컨텍스트, 우선순위 규칙, 런타임 모델
- `core/review/` — 품질 점수화 및 리뷰 결과
- `projects/exelion/backlog.json` — 현재 Exelion 백로그
- `projects/exelion/sprints/` — 스프린트 작업 목록 및 보고서
- `ATLAS_STATE.json` — 현재 런타임 상태 저장소
- `GOAL_REGISTRY.json` — 목표 관리 레지스트리

## 6. 권장 흐름

1. `docs/PROJECT_STATUS.md`를 통해 현재 상태 확인
2. `PROJECT_OVERVIEW.md`로 전체 구조와 우선순위 파악
3. `PROJECT_EXECUTION_PLAN.md`로 실행 계획 확인
4. `tools/atlas_runner.py`로 하루 시작(`start`) 또는 마감(`finish`) 수행

## 7. 요약

이 저장소는 단순한 코드 저장소가 아니라,
- AI 기반 실행 흐름
- 문서 중심 상태 관리
- 프로젝트 검증 루프
를 함께 제공하는 개발 운영 플랫폼입니다.

루트에는 핵심 가이드만 두고, 자세한 문서는 `docs/`와 각 프로젝트 폴더에 분리되어 있습니다.
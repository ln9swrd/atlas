# Atlas DevOS

> Atlas는 AI 기반으로 프로젝트 개발 환경을 자동화하고, 지식과 실행 흐름을 지속적으로 보존하며 개선하는 개발 운영 플랫폼입니다.

## 1. 개요

이 저장소는 Atlas DevOS 플랫폼의 실행 엔진, 에이전트 협업 구조, 그리고 첫 번째 검증 프로젝트인 Exelion을 포함합니다.

- `core/`: Atlas의 런타임, 룰 엔진, 리뷰 엔진, 실행 흐름을 담고 있는 핵심 모듈
- `core/decision/`: Decision Engine, Registry, Strategy Descriptor, 그리고 Decision Memory를 포함한 실행 가능한 의사결정 계층
- `agents/`: AI 에이전트별 역할과 전문성을 정의한 폴더
- `projects/`: 실제 프로젝트 인스턴스와 백로그, 스프린트, 아키텍처 기록
- `tools/atlas_runner.py`: 일일 시작·마감·검증을 수행하는 실행기
- `docs/`: 아키텍처, 운영, 플레이북, 의사결정 기록 등 문서 자료
- `AI_DEVELOPMENT_RULES.md`: AI 에이전트용 프로젝트 헌법으로, 환경 변경 및 외부 DCC 애플리케이션 사용 규칙을 정의합니다.
- `PROJECT_ENVIRONMENT.md`: 호스트 OS, WSL, Ollama, Blender, Unreal, Atlas 런타임 위치를 정리한 환경 문서입니다.
- `docs/atlas/RUNTIME_V2_SPEC.md`: Knowledge Layer, AI Runtime 정책, Knowledge Curator, Storage Roadmap, Hardware Independence 전략이 정리된 Runtime V2 설계 문서
- `core/event_bus.py`: publish/subscribe 기반 Event Bus MVP
- `core/plugin_host.py`: 애플리케이션 등록 및 라이프사이클 실행을 담당하는 Plugin Host MVP
- `core/connectors/`: Blender와 Unreal과 연결되는 MCP 스타일 connector 구현
- `docs/process/ATLAS_DECISION_CONTRACT_SPEC.md`: Decision Layer의 핵심 계약(DecisionContext, DecisionRequest, DecisionResult, DecisionEvidence, DecisionAction)을 정의한 사양서
- `docs/process/ATLAS_CONTRACT_ARCHITECTURE.md`: Atlas 전체 Contract System, Registry, Versioning, Lifecycle, 구현 순서를 정의한 아키텍처 문서
- `docs/atlas/RUNTIME_V2_SPEC.md`의 Decision 계층은 현재 RuntimeContext와 Priority Engine을 기반으로 한 초기 의사결정 흐름을 설명하며, 앞으로 Decision Engine이 AI Runtime과 Knowledge System을 연결하는 핵심 계층이 될 예정입니다.

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
- 장기 비전은 `docs/atlas/RUNTIME_V2_SPEC.md`에 정리된 AI Operating System 방향을 따릅니다.

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
- Knowledge Layer 기반의 장기 지식 축적
- Decision Engine을 통한 상황 기반 판단 흐름
- Event Bus와 Plugin Host를 통한 실행 중심 기능 확장
- Layered Memory 구조를 통한 Session / Decision / Project / Persistent 메모리 분리
- Forge를 위한 실사용 미션 실행 플랫폼
를 함께 제공하는 개발 운영 플랫폼입니다.

## 8. Forge-First 운영 원칙

Atlas의 개발 방향은 이제 더 이상 "기능을 먼저 추가하는 방식"이 아닙니다.

다음 순서로 진행합니다.

1. Forge에서 요구사항이 발생한다.
2. Atlas가 그 요구를 지원하는 기능을 추가한다.
3. 테스트와 워크플로우로 검증한다.
4. Forge가 실제로 사용해 본다.
5. Atlas를 개선한다.

이 원칙은 [docs/process/FORGE_FIRST_MISSION.md](docs/process/FORGE_FIRST_MISSION.md) 에 정리되어 있습니다.

Atlas의 역할은 이제 "기능을 많이 만드는 프레임워크"가 아니라, "Forge Mission을 실행하는 DevOS 플랫폼"입니다. 자세한 운영 원칙은 [docs/process/ATLAS_DEVOS_PRINCIPLES.md](docs/process/ATLAS_DEVOS_PRINCIPLES.md) 에 정리되어 있습니다.

현재 우선순위는 실제 3D 모델 제작이 아니라, Forge 런타임과 Atlas 연동을 구현하고 검증하는 것입니다. placeholder 또는 mock asset을 사용해도 되며, 실사용 자산은 이후 단계에서 통합합니다. 자세한 내용은 [docs/process/FORGE_RUNTIME_PRIORITY.md](docs/process/FORGE_RUNTIME_PRIORITY.md) 에 정리되어 있습니다.

루트에는 핵심 가이드만 두고, 자세한 문서는 `docs/`와 각 프로젝트 폴더에 분리되어 있습니다.
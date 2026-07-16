# Atlas DevOS v1.0.0

> Build the system that builds the game.
>
> Atlas is the operating platform for AI-assisted solo game development. It exists to reduce development friction, preserve knowledge, and continuously improve through real project feedback.

**Atlas**는 프로젝트 빌드가 아닌, **프로젝트를 만드는 개발 환경을 자동화하고 관리하는 AI 중심 DevOS 플랫폼**입니다.
개발 엔진(Core), 에이전트 협업 체계(Agents), 그리고 제작 대상 프로젝트(Projects)의 경계를 구분하여 독립적으로 작동하도록 설계되었습니다.

---

## 📂 디렉토리 구조 (Directory Structure)

```text
Atlas/
│
├── core/                    # Atlas 자체 엔진 및 시스템
│   ├── workflow/            # 병목 분석 및 상태 관리
│   ├── rules/               # 룰 엔진 및 규칙 정의
│   ├── review/              # 품질 리뷰 평가 엔진
│   ├── execution/           # 일일 추천 데시보드 및 백로그 관리
│   ├── checklists/          # 분야별 휴먼 에러 방지 체크리스트
│   ├── tools/               # Blender/UE 파이프라인 자동화 스크립트
│   └── config/              # 시스템 설정 (에이전트 레지스트리 등)
│
├── agents/                  # AI 전문가 계층
│   ├── mari/                # 시스템 아키텍트 및 리뷰어
│   ├── antigravity/         # 코드 및 자동화 구현 엔진
│   ├── sera/                # 기획 및 아트 스타일 디렉터
│   └── forge/               # 3D 모델링 및 리깅 전문가
│
├── projects/                # 프로젝트 인스턴스 (제작 대상물)
│   ├── exelion/             # 1차 검증 프로젝트: Exelion
│   │   ├── design/
│   │   ├── models/
│   │   ├── unreal/
│   │   ├── backlog.json     # 프로젝트 백로그
│   │   ├── memory.md        # 의사결정 이력 (ADR)
│   │   └── ADR/             # 상세 아키텍처 의사결정 기록
│   │
│   └── templates/           # 신규 프로젝트 생성 템플릿
│
└── tools/                   # 공용 실행 환경 제어 도구 (Runner)
    └── atlas_runner.py
```

---

## 🧭 Atlas Constitution

For a concise milestone summary, see [RELEASE_NOTES.md](RELEASE_NOTES.md).

**Atlas DevOS v1.0 Foundation Complete**

Atlas now has a stable operating model centered on constitution, vision, registries, runtime state, event logging, and execution flow. The next phase of development will be driven by real project usage in Exelion rather than by unvalidated feature expansion.


Atlas now exposes a shared operating model through three core documents:

- [VISION.md](VISION.md) — the strategic mission and long-term goals
- [PROJECT_REGISTRY.md](PROJECT_REGISTRY.md) — the known projects and their lifecycle states
- [AGENT_REGISTRY.md](AGENT_REGISTRY.md) — the roles and responsibilities of Atlas agents
- [ATLAS_CONSTITUTION.md](ATLAS_CONSTITUTION.md) — the enduring operating principles for Atlas
- [ATLAS_STATE.json](ATLAS_STATE.json) — the runtime state store managed by Atlas runner for current mode, phase, and lifecycle events
- [projects/exelion/PROJECT_CHARTER.md](projects/exelion/PROJECT_CHARTER.md) — the charter for the first Atlas validation project
- [projects/exelion/goals/EX-GOAL-001.md](projects/exelion/goals/EX-GOAL-001.md) — the first Exelion operational goal and work order
- [GOAL_REGISTRY.json](GOAL_REGISTRY.json) — the live registry of active, completed, and next goals for Atlas-driven execution
- [projects/exelion/sprints/Sprint-001.md](projects/exelion/sprints/Sprint-001.md) — the first sprint derived from the active goal
- [projects/exelion/ENVIRONMENT_PLAN.md](projects/exelion/ENVIRONMENT_PLAN.md) — the Company PC / Home PC execution split for Exelion work
- [ENVIRONMENTS.md](ENVIRONMENTS.md) — the generalized environment registry for Atlas-driven planning
- [core/execution/environment_resolver.py](core/execution/environment_resolver.py) — the runtime-context resolver that turns environment definitions into executable context
- [core/execution/context_resolver.py](core/execution/context_resolver.py) — the higher-level context resolver that assembles environment, time, project, and runtime signals into a single context object
- [core/execution/runtime_context.py](core/execution/runtime_context.py) — the immutable RuntimeContext data model used as the official execution interface
- [core/execution/priority_rules.py](core/execution/priority_rules.py) — the rule layer that the priority engine consults rather than embedding logic directly in the engine
- [PROJECT_LIFECYCLE.md](PROJECT_LIFECYCLE.md) — the shared lifecycle stages for projects managed by Atlas
- [docs/PLAYBOOKS/README.md](docs/PLAYBOOKS/README.md) — the practical knowledge base for recurring execution workflows
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — the layered architecture and dependency model of Atlas
- [docs/EXECUTION_MODEL.md](docs/EXECUTION_MODEL.md) — the runtime loop and execution responsibilities
- [docs/DESIGN_PRINCIPLES.md](docs/DESIGN_PRINCIPLES.md) — the non-negotiable design principles for Atlas evolution
- [docs/adr](docs/adr) — architecture decision records that preserve key Atlas design choices
- [docs/ROADMAP.md](docs/ROADMAP.md) — the architecture-focused roadmap for Atlas releases
- [docs/RELEASE_NOTES_v1.2.md](docs/RELEASE_NOTES_v1.2.md) — the release candidate summary for Atlas v1.2
- [SYSTEM_MANIFEST.md](SYSTEM_MANIFEST.md) — the repository entry point for Atlas architecture, current status, and operating principles
- [docs/OPERATIONS.md](docs/OPERATIONS.md) — the daily operating procedure for using Atlas as a DevOS
- [CONTRIBUTING.md](CONTRIBUTING.md) — contributor guidance for new resolvers, ADRs, and architecture tests
- [tests/test_architecture.py](tests/test_architecture.py) — structural regression tests for the Atlas layer model
- [.github/workflows/ci.yml](.github/workflows/ci.yml) — the basic CI workflow for automated test execution
- [docs/DoD_v1.2.md](docs/DoD_v1.2.md) — the completion checklist for declaring Atlas v1.2 ready

These documents form the shared context layer for future automation and planning.

## ⚙️ 실행 방법 (Usage)

일일 태스크 관리 및 검증 파이프라인은 `tools/atlas_runner.py`를 통해 일괄 수행됩니다.

### 1. 하루 시작 (Start Day)
오늘의 개발 가능 예산(Time Budget) 내에서 백로그 항목들의 ROI 점수(병목 점수 × 예상 기여도 ÷ 예상 소요시간)를 계산해 최적의 추천 태스크 목록을 구성합니다.
```bash
python tools/atlas_runner.py start
```
* 결과: `core/execution/README.md`의 **Today's Recommended Tasks** 업데이트

### 2. 하루 마감 (Finish Day)
작업이 끝난 후, 규칙 검사(Rule Engine)와 품질 채점(Review Engine)을 자동으로 수행하고 태스크 완료 상태를 일괄 기록합니다.
```bash
python tools/atlas_runner.py finish
```
* 결과: 사전 규칙 위반 검증, 품질 평가 보고서(`core/review/scorecard_*.md`) 생성, 대시보드 진행률 업데이트 및 실행 로그 저장

---

## 🤖 에이전트 및 역량 매핑 (Agent & Capabilities)

Atlas는 에이전트 레지스트리(`core/config/agent_registry.json`)를 통해 작업 영역에 매칭되는 적절한 에이전트를 선별합니다.

| AI Agent | Role | Capabilities |
| :--- | :--- | :--- |
| **Marie** | System Architect | `architecture`, `review`, `planning` |
| **Antigravity** | Implementation Engine | `python`, `cpp`, `automation`, `implementation`, `code` |
| **Sarah** | Design Director | `character`, `mecha`, `visual_design`, `concept`, `art_rules` |
| **Forge** | 3D Specialist | `blender`, `rigging`, `3d_print`, `modeling`, `uv_mapping`, `materials` |

---

## 🚀 새로운 프로젝트 시작하기 (Creating a New Project)

신규 프로젝트 생성 시 `projects/templates/project_template`를 복사하여 독립적인 백로그와 기획 메모리를 구성하십시오.

```bash
# 예시: 프로젝트 폴더 복사
xcopy /E /I projects\templates\project_template projects\new_project_name
```

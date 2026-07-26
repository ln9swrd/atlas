# ATLAS Agent Architecture v0.1

## 1. Current AI Development Analysis
**EXIST**  
- 기존 흐름: User → Cline → LLM → Repository  
**VERIFIED**  
- 문제점:  
  - Context 지속성 부족 (IMPLEMENTED: `atlas-runtime/memory.py`에서 30% 지원)  
  - 작업 범위 제어 미비 (MISSING: 현재 구현 없음)  
  - 검증 결과 보존 없음 (PROPOSED: `core/state/atlas_state.py` 수정 필요)

## 2. Cline Role Analysis
**IMPLEMENTED**  
- 기능:  
  - 파일 접근 (VERIFIED: `core/tools/README.md` 기반)  
  - CLI 명령 실행 (EXIST: `atlas-runner` 프로세스)  
**PROPOSED**  
- 재구성 필요:  
  - Planning → Context Injection → Execution → Verification → Memory Update 흐름 도입

## 3. Atlas Agent Layer Necessity
**EXIST**  
- 관리 대상:  
  - AI 선택 기준 (PROPOSED: `core/registry/environment_registry.py` 확장)  
  - 작업 유형별 라우팅 (MISSING: 현재 구현 없음)  
  - 결과 검증 책임 (VERIFIED: `core/review/review_engine.py` 기반)

## 4. Context Storage Structure
**EXIST**  
- 저장 구조:  
  ```bash
  context/
  ├── project_state       # EXIST (atlas-runtime/decision.py)
  ├── task_history        # PROPOSED (core/state/atlas_state.py)
  ├── decisions           # IMPLEMENTED (core/decision/decision_memory.py)
  ├── audit_records       # EXIST (logs/decision_history.jsonl)
  └── constraints         # PROPOSED (core/config/project_lifecycle.json)
  ```

## 5. AI Provider Strategy
**IMPLEMENTED**  
- 역할 분리:  
  | AI     | 역할               | 상태       |
  | ------ | ---------------- | -------- |
  | Kraken | Local 실행 및 코드 조사 | EXIST (atlas-runtime/kernel.py) |
  | SERA   | 고급 분석 및 설계 검토    | PROPOSED (core/review/scorecard_*.md) |
  | 기타 모델  | 필요 시 확장          | UNKNOWN |

## 6. Role Definitions

### 1. atlas_runner (Orchestration)
- **Responsibilities**:
  - Runtime initialization and task grouping
  - System entry point for command dispatch
  - **No domain logic ownership** - Coordinates task execution without implementing business rules
  - **Alpha Compliance**: Maintains strict separation from domain-specific logic as per Alpha Freeze requirements

### 2. TaskBroker (Lifecycle Owner)
- **Responsibilities**:
  - **Exclusive task lifecycle management** (create → start → complete/fail → cancel)
  - Task state validation and transition control
  - History persistence to JSONL files
  - Integration with AtlasEventBus for state propagation

### 3. DecisionEngine (Decision Generation)
- **Responsibilities**:
  - Rule-based prioritization and decision generation
  - Strategy-based extension architecture (e.g., `RuleDecisionStrategy`)
  - **No ownership of task lifecycle** - Provides recommendation outputs only

### 4. AtlasEventBus (State Transition)
- **New role**:
  - Central communication channel for state transitions
  - Propagates task lifecycle events between components
  - Synchronizes DecisionEngine outputs with audit systems

### 5. SDK Interface
- **Responsibilities**:
  - External system integration
  - Standardized API for agent interactions
  - Maintains compatibility with third-party tools

## 7. Future Implementation Steps
**PROPOSED**  
1. `core/context/runtime_context.py` 확장 (70% 완료)  
2. `core/execution/priority_engine.py` 수정 (50% 진행)  
3. `docs/ADR-011.md` 문서화 (0% 진행)
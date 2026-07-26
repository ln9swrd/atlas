# ATLAS Runtime Boundary Analysis

## 1. Current Architecture
현재 ATLAS 시스템은 다음과 같은 주요 구성 요소로 이루어져 있습니다:

- **atlas_runner.py**:
  - 실행 환경 설정 및 초기화
  - Decision Engine 호출
  - Task Broker와의 상호작용
  - 상태 관리 및 로깅 기능

- **core/decision/**:
  - DecisionRegistry를 통해 전략(예: RuleDecisionStrategy) 관리
  - DecisionEngine이 실행 중인 규칙 기반 의사결정 처리

- **core/taskbroker/**:
  - TaskBroker가 Task Lifecycle Management 담당
  - Task History 로깅

- **EventBus**:
  - 상태 전환 이벤트 전파 역할

## 2. Responsibility Mapping
| 구성 요소 | 책임 |
|---------|------|
| **atlas_runner.py** | 실행 환경 설정, Decision Engine 호출, Task Broker와의 상호작업, 상태 관리, 로깅 |
| **DecisionRegistry** | 전략(예: RuleDecisionStrategy) 등록 및 관리 |
| **DecisionEngine** | 규칙 기반 의사결정 실행 |
| **TaskBroker** | Task Lifecycle Management, Task History 로깅 |
| **EventBus** | 상태 전환 이벤트 전파 |

## 3. Coupling Analysis
- **atlas_runner.py**는 **DecisionEngine**과 **TaskBroker**에 강하게 의존하고 있습니다.
- **DecisionRegistry**는 **RuleDecisionStrategy**에 의존하며, 이는 현재 **core/decision/** 디렉토리에 위치해 있습니다.
- **TaskBroker**는 **task_history.jsonl** 파일에 의존하며, 이는 로깅 메커니즘과 관련이 있습니다.

## 4. Refactoring Candidates
- **Task-related logic**은 **TaskBroker**로 이전되어야 합니다.
- **Decision logic**은 **DecisionEngine**으로 분리되어야 합니다.
- **State management**는 별도의 모듈로 분리되어야 합니다.

## 5. Risk Assessment
- **Refactoring** 과정에서 기존 의존성에 문제가 발생할 수 있습니다.
- **EventBus**와의 상호작용을 분리할 경우, 상태 전환 이벤트 전파에 문제가 발생할 수 있습니다.

## 6. Recommended Migration Plan
1. **Dependency Analysis**:
   - 현재 시스템의 의존성을 분석하여, 각 구성 요소의 역할을 명확히 합니다.

2. **Incremental Refactoring**:
   - **TaskBroker**로 Task-related logic 이전
   - **DecisionEngine**으로 Decision logic 분리
   - **State management** 모듈 분리

3. **Testing**:
   - 각 단계별로 테스트를 수행하여, 기존 기능에 영향을 최소화합니다.

4. **Documentation**:
   - 변경 사항을 문서화하여, 팀 내 공유 및 유지보수를 용이하게 합니다.

## 7. Future Refactoring Candidates
- **DecisionStrategy 추상화 계획**:
  - 현재 Alpha Freeze 단계에서는 코드 수정 없이 추상화 계획만 기록
  - 향후 Alpha Stabilization 이후에 `DecisionStrategy` 인터페이스 도입 예정
  - 기존 `RuleDecisionStrategy`를 추상 클래스로 분리하여 확장성 향상
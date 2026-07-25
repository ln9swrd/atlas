# Decision Engine Plan

## 목적

Atlas의 현재 흐름은 Context -> Priority Engine -> Execution으로 이어지지만, 중간의 Decision Layer가 아직 명시적인 구현체로 분리되어 있지 않습니다.

이 문서는 Atlas를 단순한 자동화 런타임이 아니라, 상황에 따라 판단하는 AI Operating System으로 확장하기 위한 다음 단계 설계안을 정리합니다.

## 핵심 목표

1. Context, Knowledge, AI inference, Rule/Review 결과를 종합해 하나의 Decision을 생성한다.
2. Workflow 선택, task prioritization, risk 판단, exception handling을 Decision Engine이 담당한다.
3. Plugin, AI Runtime, Knowledge System이 모두 Decision Engine을 통해 연결되도록 구조를 맞춘다.

## 제안 아키텍처

```text
Context
  -> Knowledge Retrieval
  -> AI Reasoning
  -> Rule/Review Evaluation
  -> Decision Engine
  -> Workflow Selection
  -> Execution
```

## 최소 구현 범위

### 1. Decision Engine 인터페이스
- decide(context, knowledge, constraints) -> DecisionResult
- select_workflow(context, options) -> WorkflowChoice
- explain(decision) -> rationale

### 2. DecisionResult 구조
- decision_id
- chosen_action
- confidence
- reasoning
- evidence_ids
- next_steps

### 3. Integration 포인트
- RuntimeContext를 입력으로 받는다.
- Knowledge Service를 조회한다.
- AI Runtime을 호출할 수 있다.
- Rule/Review Engine 결과를 반영한다.

## 우선순위

1. AI Runtime
2. Knowledge System
3. Decision Engine
4. Plugin Framework
5. Connector Framework

## 기대 효과

Decision Engine이 생기면 Atlas는 다음과 같이 진화할 수 있습니다.
- 단순 추천 도구에서 상황 판단형 운영체제로 전환
- Forge, Mission Editor, Music Studio 같은 애플리케이션이 Atlas의 판단을 공유받음
- 앱들은 실행에만 집중하고, 판단은 Atlas가 담당

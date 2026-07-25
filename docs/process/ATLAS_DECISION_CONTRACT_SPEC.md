# Atlas Decision Contract Specification

## 목적

Atlas의 Decision Layer는 AI, Rule, Priority, Hybrid 전략을 모두 수용할 수 있는 공통 계약을 갖도록 설계합니다.

이 사양서는 다음을 정의합니다.
- DecisionContext: 판단에 필요한 입력
- DecisionRequest: 판단 요청의 명시적 형식
- DecisionResult: 판단 결과의 표준 형식
- DecisionEvidence: 판단 근거의 표준 형식
- DecisionAction: 실행 가능한 행동의 표준 형식

## 1. DecisionContext

DecisionContext는 의사결정에 필요한 핵심 입력을 담습니다.

```json
{
  "environment": "DEV_HOME",
  "project": "Exelion",
  "goals": ["complete backlog", "preserve quality"],
  "constraints": ["no_unreal"],
  "capabilities": ["blender", "gpu"],
  "resources": {"available_minutes": 180},
  "time": {"work_hours": true},
  "context": {}
}
```

## 2. DecisionRequest

DecisionRequest는 의사결정 요청의 명시적인 형태입니다.

```json
{
  "request_id": "req-001",
  "context": {"environment": "DEV_HOME"},
  "goals": ["complete backlog"],
  "knowledge": ["follow naming rules"],
  "constraints": ["no_unreal"],
  "strategies": ["rule", "priority", "ai"],
  "preferred_strategy": "hybrid"
}
```

## 3. DecisionResult

DecisionResult는 최종 의사결정 결과를 표준화합니다.

```json
{
  "decision_id": "dec-001",
  "status": "accepted",
  "priority": 0.92,
  "reason": "High-value backlog item fits current constraints",
  "confidence": 0.88,
  "evidence": [],
  "actions": []
}
```

## 4. DecisionEvidence

DecisionEvidence는 판단 근거를 설명합니다.

```json
{
  "source": "priority_engine",
  "kind": "rule",
  "summary": "Task matches active bottleneck and fits available time",
  "score": 0.91
}
```

## 5. DecisionAction

DecisionAction은 실행 가능한 행동 단위입니다.

```json
{
  "action_id": "act-001",
  "type": "workflow_select",
  "target": "EX-BRAVE-001",
  "reason": "Best next task based on priority and constraints"
}
```

## 6. Recommended Strategy Model

Decision Engine은 다음 전략을 가질 수 있습니다.

- RuleDecisionStrategy
- PriorityDecisionStrategy
- AIDecisionStrategy
- HybridDecisionStrategy

## 7. Contract Principle

Decision Layer는 AI에 종속되지 않아야 합니다.

즉,
- Rule만으로 결정할 수 있어야 하고
- Priority만으로 결정할 수 있어야 하고
- AI만으로 결정할 수 있어야 하며
- 필요 시 Hybrid로 결합할 수 있어야 합니다.

## 8. Expected Integration

이 계약은 이후 다음 요소와 연결됩니다.
- AI Runtime
- Knowledge System
- Workflow Engine
- Plugin Framework

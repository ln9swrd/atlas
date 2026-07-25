from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


@dataclass(frozen=True)
class DecisionContext:
    environment: str
    project: str
    goals: List[str] = field(default_factory=list)
    constraints: List[str] = field(default_factory=list)
    capabilities: List[str] = field(default_factory=list)
    resources: Dict[str, Any] = field(default_factory=dict)
    time: Dict[str, Any] = field(default_factory=dict)
    context: Dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class DecisionRequest:
    request_id: str
    context: DecisionContext
    goals: List[str] = field(default_factory=list)
    constraints: List[str] = field(default_factory=list)
    knowledge: List[str] = field(default_factory=list)
    strategies: List[str] = field(default_factory=list)
    preferred_strategy: str = "rule"


@dataclass(frozen=True)
class DecisionEvidence:
    source: str
    kind: str
    summary: str
    score: float


@dataclass(frozen=True)
class DecisionAction:
    action_id: str
    type: str
    target: str
    reason: str


@dataclass(frozen=True)
class DecisionResult:
    decision_id: str
    status: str
    priority: float
    reason: str
    confidence: float
    evidence: List[DecisionEvidence]
    actions: List[DecisionAction]


class RuleDecisionStrategy:
    def decide(self, request: DecisionRequest) -> DecisionResult:
        constraints = set(request.constraints or [])
        if "no_unreal" in constraints:
            reason = "No Unreal constraint present; proceed with safe workflow selection."
            priority = 0.82
        else:
            reason = "Default rule-based decision for available workflow."
            priority = 0.65

        evidence = [
            DecisionEvidence(
                source="rule_strategy",
                kind="rule",
                summary="Rule strategy accepted the request based on constraints and goals.",
                score=priority,
            )
        ]
        actions = [
            DecisionAction(
                action_id="act-rule-001",
                type="workflow_select",
                target="EX-BRAVE-001",
                reason="Rule-based workflow selection for the next task.",
            )
        ]
        return DecisionResult(
            decision_id=f"dec-{request.request_id}",
            status="approved",
            priority=priority,
            reason=reason,
            confidence=0.83,
            evidence=evidence,
            actions=actions,
        )


class DecisionEngine:
    def __init__(self, strategy: Optional[RuleDecisionStrategy] = None):
        self.strategy = strategy or RuleDecisionStrategy()

    def make_decision(self, request: DecisionRequest) -> DecisionResult:
        return self.strategy.decide(request)

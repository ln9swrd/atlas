from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional
from core.tools.visual_perception import VisualPerceptionEngine, Dict


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
    visual_data: Dict[str, Any] = field(default_factory=dict)  # Add visual data field


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
        visual_data = request.context.visual_data  # Access visual data from context
        
        # Example: Adjust priority based on visual data
        if "no_unreal" in constraints:
            reason = "No Unreal constraint present; proceed with safe workflow selection."
            priority = 0.82
        else:
            reason = "Default rule-based decision for available workflow."
            priority = 0.65
            
            # Modify priority if visual data indicates urgency (example logic)
            if visual_data.get("urgent_objects_detected", False):
                priority += 0.15  # Increase priority by 15%
                reason += " Visual urgency detected; priority increased."

        evidence = [
            DecisionEvidence(
                source="rule_strategy",
                kind="rule",
                summary=f"Rule strategy accepted the request based on constraints, goals, and visual data: {visual_data.get('summary', 'none')}",
                score=priority,
            )
        ]
        actions = [
            DecisionAction(
                action_id="act-rule-001",
                type="workflow_select",
                target="EX-BRAVE-001",
                reason=f"Rule-based workflow selection for the next task. Visual data: {visual_data.get('summary', 'none')}",
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

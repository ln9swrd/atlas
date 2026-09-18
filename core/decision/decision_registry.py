from dataclasses import dataclass, field
from typing import Dict, List, Optional


@dataclass(frozen=True)
class DecisionStrategyDefinition:
    name: str
    kind: str
    description: str


class DecisionRegistry:
    def __init__(self):
        self._strategies: Dict[str, DecisionStrategyDefinition] = {}
        self.register("rule", "rule", "Rule-based strategy for simple deterministic decisions")

    def register(self, name: str, kind: str, description: str) -> None:
        self._strategies[name] = DecisionStrategyDefinition(name=name, kind=kind, description=description)

    def get(self, name: str) -> Optional[DecisionStrategyDefinition]:
        return self._strategies.get(name)

    def list(self) -> List[DecisionStrategyDefinition]:
        return list(self._strategies.values())

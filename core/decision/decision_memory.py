from dataclasses import dataclass, field
from typing import Any, Dict


@dataclass
class DecisionMemory:
    current_project: str = ""
    current_goal: str = ""
    current_sprint: str = ""
    state: Dict[str, Any] = field(default_factory=dict)

from dataclasses import dataclass, field
from typing import Any, Dict, List


@dataclass(frozen=True)
class RuntimeContext:
    environment: str
    project: str
    time: Dict[str, Any] = field(default_factory=dict)
    capabilities: List[str] = field(default_factory=list)
    constraints: List[str] = field(default_factory=list)
    resources: Dict[str, Any] = field(default_factory=dict)
    user: Dict[str, Any] = field(default_factory=dict)

from dataclasses import dataclass, field
from typing import Dict, List, Optional


@dataclass(frozen=True)
class StrategyDescriptor:
    strategy_id: str
    name: str
    version: str = "1.0"
    author: str = "Atlas"
    description: str = ""
    priority: int = 100
    supports_ai: bool = False
    requires_knowledge: bool = False
    tags: List[str] = field(default_factory=list)
    metadata: Dict[str, object] = field(default_factory=dict)

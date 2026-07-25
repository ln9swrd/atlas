from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, Optional


@dataclass
class SessionMemory:
    data: Dict[str, Any] = field(default_factory=dict)

    def set(self, key: str, value: Any) -> None:
        self.data[key] = value

    def get(self, key: str, default: Any = None) -> Any:
        return self.data.get(key, default)


@dataclass
class DecisionMemory:
    current_project: str = ""
    current_goal: str = ""
    current_sprint: str = ""
    state: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ProjectMemory:
    data: Dict[str, Any] = field(default_factory=dict)

    def set(self, key: str, value: Any) -> None:
        self.data[key] = value

    def get(self, key: str, default: Any = None) -> Any:
        return self.data.get(key, default)


@dataclass
class PersistentMemory:
    data: Dict[str, Any] = field(default_factory=dict)

    def set(self, key: str, value: Any) -> None:
        self.data[key] = value

    def get(self, key: str, default: Any = None) -> Any:
        return self.data.get(key, default)


@dataclass
class AtlasMemoryLayers:
    session: SessionMemory = field(default_factory=SessionMemory)
    decision: DecisionMemory = field(default_factory=DecisionMemory)
    project: ProjectMemory = field(default_factory=ProjectMemory)
    persistent: PersistentMemory = field(default_factory=PersistentMemory)


class AtlasMemory:
    def __init__(self) -> None:
        self.memory_layers = AtlasMemoryLayers()
        self.session = self.memory_layers.session
        self.decision = self.memory_layers.decision
        self.project = self.memory_layers.project
        self.persistent = self.memory_layers.persistent

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Tuple


@dataclass(frozen=True)
class BoneModel:
    name: str
    head: Tuple[float, float, float]
    tail: Tuple[float, float, float]

    parent: Optional[str] = None
    index: Optional[int] = None

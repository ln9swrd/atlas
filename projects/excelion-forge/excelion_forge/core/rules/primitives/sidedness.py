"""Reusable bone sidedness helpers for heuristic rules."""

from __future__ import annotations

import re
from enum import Enum

SIDE_SUFFIX_RE = re.compile(r"(?:[._]|\b)([lr])$", re.IGNORECASE)
TOKEN_SPLIT_RE = re.compile(r"[._\-\s]+")
CAMEL_CASE_RE = re.compile(r"[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)")
LEFT_ALIASES = {"left", "l"}
RIGHT_ALIASES = {"right", "r"}
CENTER_ALIASES = {"center", "centre", "root", "pelvis", "spine"}

LATERAL_TOKENS = {
    "arm",
    "forearm",
    "hand",
    "leg",
    "thigh",
    "calf",
    "foot",
    "shoulder",
    "elbow",
    "wrist",
    "thumb",
    "index",
    "middle",
    "ring",
    "pinky",
    "hip",
    "knee",
    "eye",
    "ear",
}


class BoneSide(str, Enum):
    LEFT = "LEFT"
    RIGHT = "RIGHT"
    CENTER = "CENTER"
    UNKNOWN = "UNKNOWN"


def split_camel_case(token: str) -> list[str]:
    return [part.lower() for part in CAMEL_CASE_RE.findall(token) if part]


def tokenize_name(name: str) -> list[str]:
    normalized = name.strip()
    if not normalized:
        return []

    parts: list[str] = []
    for token in TOKEN_SPLIT_RE.split(normalized):
        parts.extend(split_camel_case(token))

    return [token for token in parts if token]


def detect_side(name: str) -> BoneSide:
    tokens = tokenize_name(name)
    if not tokens:
        return BoneSide.UNKNOWN

    if SIDE_SUFFIX_RE.search(name):
        suffix = SIDE_SUFFIX_RE.search(name).group(1)
        return BoneSide.LEFT if suffix.lower() == "l" else BoneSide.RIGHT

    has_left = any(token in LEFT_ALIASES for token in tokens)
    has_right = any(token in RIGHT_ALIASES for token in tokens)
    has_center = any(token in CENTER_ALIASES for token in tokens)

    if has_center and (has_left or has_right):
        return BoneSide.UNKNOWN

    if has_left:
        return BoneSide.LEFT

    if has_right:
        return BoneSide.RIGHT

    if has_center:
        return BoneSide.CENTER

    return BoneSide.UNKNOWN


def contains_lateral_keyword(name: str) -> bool:
    tokens = tokenize_name(name)
    return any(token in LATERAL_TOKENS for token in tokens)


def is_lateral_candidate(name: str) -> bool:
    return detect_side(name) == BoneSide.UNKNOWN and contains_lateral_keyword(name)


def strip_side_suffix(name: str) -> str:
    return SIDE_SUFFIX_RE.sub("", name)


def get_side_suffix(name: str) -> str | None:
    match = SIDE_SUFFIX_RE.search(name)
    return match.group(1).upper() if match else None


def is_lateral_bone(name: str) -> bool:
    """Return True when the bone name contains a left/right side suffix."""
    return get_side_suffix(name) is not None


__all__ = [
    "BoneSide",
    "detect_side",
    "get_side_suffix",
    "is_lateral_bone",
    "is_lateral_candidate",
    "strip_side_suffix",
]

"""Atlas domain isolation policy (single source).

AGENTS.md §1 BLACK + D17. Used by optional orchestrator; Cline uses .clineignore.
"""
from __future__ import annotations

from pathlib import Path
from typing import Iterable

# Directory segment names (lowercase) — never auto-load / tool-deny
BLACK_DIR_NAMES: tuple[str, ...] = (
    "archive",
    "obsidian",
    "node_modules",
    ".git",
    "scratch",  # user sandbox: no auto-load; tools deny by default
)


def repo_root_from_tools() -> Path:
    return Path(__file__).resolve().parent.parent


def resolve_workspace_root(env_atlas_root: str | None = None) -> Path:
    import os

    raw = env_atlas_root if env_atlas_root is not None else os.environ.get("ATLAS_ROOT")
    if raw:
        return Path(raw).resolve()
    return repo_root_from_tools()


def path_is_blacklisted(target_path: str, black: Iterable[str] = BLACK_DIR_NAMES) -> bool:
    """True if path should be denied for read/write tool access."""
    normalized = target_path.replace("\\", "/").lower()
    for name in black:
        n = name.lower()
        if f"/{n}/" in f"/{normalized}/" or normalized.startswith(f"{n}/"):
            return True
    return False


def command_mentions_black(command: str, black: Iterable[str] = BLACK_DIR_NAMES) -> bool:
    """Coarse CLI guard — substring match on forbidden segment names."""
    lower = command.lower()
    return any(name.lower() in lower for name in black)

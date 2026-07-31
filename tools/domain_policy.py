"""Atlas domain isolation policy (single source).

AGENTS.md §1 BLACK + D17 + D23 (path sandbox helpers).
Cline: .clineignore | Orchestrator/Runner: this module.
"""
from __future__ import annotations

from pathlib import Path
from typing import Iterable

BLACK_DIR_NAMES: tuple[str, ...] = (
    "archive",
    "obsidian",
    "node_modules",
    ".git",
    "scratch",
)


def repo_root_from_tools() -> Path:
    return Path(__file__).resolve().parent.parent


def resolve_workspace_root(env_atlas_root: str | None = None) -> Path:
    import os

    raw = env_atlas_root if env_atlas_root is not None else os.environ.get("ATLAS_ROOT")
    if raw:
        return Path(raw).resolve()
    return repo_root_from_tools()


def path_is_blacklisted(
    target_path: str,
    black: Iterable[str] = BLACK_DIR_NAMES,
    workspace: Path | None = None,
) -> bool:
    """True if path should be denied.

    Checks string segments and, when workspace is set, resolved path parts
    (blocks ../archive style escapes outside or into BLACK).
    """
    normalized = target_path.replace("\\", "/").lower().lstrip("./")
    for name in black:
        n = name.lower()
        if f"/{n}/" in f"/{normalized}/" or normalized.startswith(f"{n}/") or normalized == n:
            return True

    if workspace is not None:
        ws = workspace.resolve()
        try:
            # Absolute targets: still resolve
            candidate = Path(target_path)
            full = candidate.resolve() if candidate.is_absolute() else (ws / target_path).resolve()
        except (OSError, RuntimeError):
            return True
        try:
            rel = full.relative_to(ws)
        except ValueError:
            # Outside workspace → deny (D23 sandbox)
            return True
        parts_lower = {p.lower() for p in rel.parts}
        for name in black:
            if name.lower() in parts_lower:
                return True
    return False


def command_mentions_black(command: str, black: Iterable[str] = BLACK_DIR_NAMES) -> bool:
    lower = command.lower()
    return any(name.lower() in lower for name in black)


def assert_path_allowed(target_path: str, workspace: Path | None = None) -> None:
    """Raise PermissionError if blacklisted or outside workspace."""
    ws = workspace or resolve_workspace_root()
    if path_is_blacklisted(target_path, workspace=ws):
        raise PermissionError(f"domain_policy: denied path '{target_path}'")

"""Atlas domain isolation policy (single source).

AGENTS.md §1 BLACK + D17 + D23 (path sandbox helpers).
Cline: .clineignore | Orchestrator/Runner: this module.

Phase A: path_is_allowed + get_active_domain
Phase B: runner wire via assert_path_allowed
Phase C: command_is_allowed + orchestrator allowlist
"""
from __future__ import annotations

import re
from pathlib import Path
from typing import Iterable

BLACK_DIR_NAMES: tuple[str, ...] = (
    "archive",
    "obsidian",
    "node_modules",
    ".git",
    "scratch",
)

# Relative prefixes always allowed when not BLACK (D23 system paths)
SYSTEM_ALLOW_PREFIXES: tuple[str, ...] = (
    "state/",
    "tools/",
    "docs/",
    "core/",
    "atlas-runtime/",
    "tests/",
    "logs/",
    "config/",
    "scripts/",
)

SYSTEM_ALLOW_FILES: tuple[str, ...] = (
    "agents.md",
    "readme.md",
    ".clineignore",
    "requirements-dev.txt",
    ".gitignore",
)

# Product ids recognized in ACTIVE_TARGET text
KNOWN_PRODUCT_IDS: tuple[str, ...] = (
    "excelion-forge",
    "excelion",
    "printguard",
    "coin-s",
    "atlas-extension",
)

# Rough path-like tokens inside CLI strings (Phase C)
_PATH_TOKEN_RE = re.compile(
    r"(?:^|[\s\"'=])("
    r"(?:(?:\.\./)+|\./)?(?:[A-Za-z0-9_.-]+/)+[A-Za-z0-9_.-]*"
    r"|/[A-Za-z0-9_./-]+"
    r"|(?:projects|state|tools|docs|core|archive|obsidian|logs|tests)/[A-Za-z0-9_./-]*)"
)


def repo_root_from_tools() -> Path:
    return Path(__file__).resolve().parent.parent


def resolve_workspace_root(env_atlas_root: str | None = None) -> Path:
    import os

    raw = env_atlas_root if env_atlas_root is not None else os.environ.get("ATLAS_ROOT")
    if raw:
        return Path(raw).resolve()
    return repo_root_from_tools()


def _normalize_rel(target_path: str) -> str:
    return target_path.replace("\\", "/").lstrip("./").strip()


def path_is_blacklisted(
    target_path: str,
    black: Iterable[str] = BLACK_DIR_NAMES,
    workspace: Path | None = None,
) -> bool:
    """True if path should be denied.

    Checks string segments and, when workspace is set, resolved path parts
    (blocks ../archive style escapes outside or into BLACK).
    """
    normalized = _normalize_rel(target_path).lower()
    for name in black:
        n = name.lower()
        if f"/{n}/" in f"/{normalized}/" or normalized.startswith(f"{n}/") or normalized == n:
            return True

    if workspace is not None:
        ws = workspace.resolve()
        try:
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


def get_active_domain(
    workspace: Path | None = None,
    state_text: str | None = None,
) -> str | None:
    """Return active product domain name or None for platform mode.

    Reads ACTIVE_TARGET from state/CURRENT_STATE.md unless state_text given.
    """
    text = state_text
    if text is None:
        ws = workspace or resolve_workspace_root()
        state_path = ws / "state" / "CURRENT_STATE.md"
        if not state_path.is_file():
            return None
        try:
            text = state_path.read_text(encoding="utf-8")
        except OSError:
            return None

    active_line = ""
    for line in text.splitlines():
        if line.upper().startswith("ACTIVE_TARGET"):
            active_line = line
            break
    if not active_line:
        return None

    lower = active_line.lower()

    # Explicit projects/<name>
    m = re.search(r"projects/([a-z0-9_-]+)", lower)
    if m:
        return m.group(1)

    # Known product id token
    for pid in KNOWN_PRODUCT_IDS:
        if re.search(rf"\b{re.escape(pid)}\b", lower):
            return pid

    # platform / idle / F3 / min → no product domain
    return None


def _under_prefix(normalized: str, prefix: str) -> bool:
    n = normalized.lower()
    p = prefix.lower()
    return n == p.rstrip("/") or n.startswith(p)


def path_is_allowed(
    target_path: str,
    workspace: Path | None = None,
    active: str | None | object = ...,
) -> bool:
    """True if path is allowed under D23 allowlist.

    Order: BLACK/outside deny → system allow → active project allow → deny.
    active=... means load from CURRENT_STATE; pass str or None to override.
    """
    ws = workspace or resolve_workspace_root()
    if path_is_blacklisted(target_path, workspace=ws):
        return False

    # Resolve to workspace-relative for allow checks
    try:
        candidate = Path(target_path)
        full = candidate.resolve() if candidate.is_absolute() else (ws / target_path).resolve()
        rel = full.relative_to(ws.resolve())
        normalized = rel.as_posix()
    except (OSError, RuntimeError, ValueError):
        return False

    if not normalized or normalized == ".":
        return True

    norm_lower = normalized.lower()

    if norm_lower in SYSTEM_ALLOW_FILES:
        return True
    for prefix in SYSTEM_ALLOW_PREFIXES:
        if _under_prefix(norm_lower, prefix):
            return True

    if active is ...:
        active = get_active_domain(workspace=ws)

    if active:
        proj_prefix = f"projects/{str(active).lower()}/"
        proj_exact = f"projects/{str(active).lower()}"
        if norm_lower == proj_exact or norm_lower.startswith(proj_prefix):
            return True

    return False


def assert_path_allowed(
    target_path: str,
    workspace: Path | None = None,
    active: str | None | object = ...,
) -> None:
    """Raise PermissionError if blacklisted, outside workspace, or outside allowlist."""
    ws = workspace or resolve_workspace_root()
    if not path_is_allowed(target_path, workspace=ws, active=active):
        raise PermissionError(f"domain_policy: denied path '{target_path}'")


def extract_path_tokens(command: str) -> list[str]:
    """Rough path-like tokens from a CLI command string (Phase C)."""
    tokens: list[str] = []
    for m in _PATH_TOKEN_RE.finditer(command):
        tok = m.group(1).strip().strip("'\"")
        if tok and tok not in tokens:
            tokens.append(tok)
    return tokens


def command_is_allowed(
    command: str,
    workspace: Path | None = None,
    active: str | None | object = ...,
) -> bool:
    """True if CLI command is allowed under D23.

    1. BLACK name mention → deny
    2. Any path-like token failing path_is_allowed → deny
    3. No path tokens → allow (e.g. pwd, git status)
    """
    if not command or not command.strip():
        return False
    if command_mentions_black(command):
        return False

    ws = workspace or resolve_workspace_root()
    if active is ...:
        active = get_active_domain(workspace=ws)

    for tok in extract_path_tokens(command):
        if not path_is_allowed(tok, workspace=ws, active=active):
            return False
    return True


def assert_command_allowed(
    command: str,
    workspace: Path | None = None,
    active: str | None | object = ...,
) -> None:
    """Raise PermissionError if command is outside allowlist."""
    ws = workspace or resolve_workspace_root()
    if not command_is_allowed(command, workspace=ws, active=active):
        raise PermissionError(f"domain_policy: denied command '{command}'")

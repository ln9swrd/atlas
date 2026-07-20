from __future__ import annotations

import ast
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Set


class DomainType(str, Enum):
    A_INVARIANT = "A"
    B_POLICY = "B"
    C_GENERATIVE = "C"


@dataclass(frozen=True)
class ConstraintNode:
    name: str
    domain: DomainType


@dataclass(frozen=True)
class ConstraintEdge:
    from_node: str
    to_node: str
    rule: str


ALLOWED_EDGES: Dict[str, Set[str]] = {
    "core": set(),
    "adapters": {"core"},
    "runtime": {"adapters", "core_interfaces"},
    "plugins": {"runtime", "adapters"},
}

DOMAIN_ROOTS: Dict[str, str] = {
    "core": "excelion_forge.core",
    "adapters": "excelion_forge.adapters",
    "runtime": "excelion_forge.runtime",
    "plugins": "excelion_forge.plugins",
}


def build_constraint_graph() -> Dict[str, DomainType]:
    return {
        "core": DomainType.A_INVARIANT,
        "adapters": DomainType.B_POLICY,
        "runtime": DomainType.C_GENERATIVE,
        "plugins": DomainType.C_GENERATIVE,
    }


def get_domain_for_module(module_name: str) -> Optional[str]:
    for domain, root in DOMAIN_ROOTS.items():
        if module_name == root or module_name.startswith(f"{root}."):
            return domain
    return None


def validate_import(source_domain: str, target_domain: str) -> bool:
    allowed = ALLOWED_EDGES.get(source_domain, set())
    return target_domain in allowed


def collect_imported_modules(path: Path) -> List[str]:
    text = path.read_text(encoding="utf-8")
    tree = ast.parse(text, filename=str(path))
    imported: List[str] = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imported.append(alias.name)
        elif isinstance(node, ast.ImportFrom):
            module = node.module or ""
            if node.level:
                module = "." * node.level + module
            imported.append(module)
    return imported


def resolve_relative_import(module_name: str, current_module: str) -> Optional[str]:
    if not module_name.startswith("."):
        return module_name
    level = len(module_name) - len(module_name.lstrip("."))
    module_suffix = module_name.lstrip(".")
    current_parts = current_module.split(".")
    base_parts = current_parts[:-level]
    if module_suffix:
        base_parts.append(module_suffix)
    return ".".join(base_parts)


def collect_module_import_domains(path: Path, module_name: str) -> List[tuple[str, Optional[str]]]:
    imported_modules = collect_imported_modules(path)
    result: List[tuple[str, Optional[str]]] = []
    for imported in imported_modules:
        resolved = resolve_relative_import(imported, module_name)
        domain = get_domain_for_module(resolved) if resolved else None
        result.append((resolved or imported, domain))
    return result

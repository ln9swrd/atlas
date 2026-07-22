"""
Atlas DevOS - Environment Resolver (v2.3)
Resolves isolated project environments, toolchains, and execution contexts across DEV_WORK and DEV_HOME.
"""
from dataclasses import dataclass, field
from typing import Dict, Any, List, Optional
import os
import json
import re


@dataclass
class EnvironmentContext:
    env_name: str  # 'DEV_WORK' or 'DEV_HOME'
    active_project: str
    project_root: str
    toolchain: Dict[str, str] = field(default_factory=dict)
    variables: Dict[str, str] = field(default_factory=dict)


class EnvironmentResolver:
    """
    Resolves multi-project environment isolation and toolchain paths for Atlas DevOS.
    """

    def __init__(self, base_dir: Optional[str] = None):
        self.base_dir = base_dir or os.getcwd()
        self.known_environments = {
            "DEV_WORK": {
                "blender_path": "/usr/bin/blender",
                "python_path": "/usr/bin/python3",
                "target_stage": "Blender Modeling & Rigging",
            },
            "DEV_HOME": {
                "unreal_path": "/opt/UnrealEngine/Engine/Binaries/Linux/UnrealEditor",
                "python_path": "/usr/bin/python3",
                "target_stage": "Unreal Blueprint & Packaging",
            },
        }

    def resolve_environment(self, env_name: str, project_name: str = "Excelion") -> EnvironmentContext:
        """Resolve isolated toolchain and context for a specific environment and project."""
        toolchain = self.known_environments.get(env_name, self.known_environments["DEV_WORK"])
        project_root = os.path.join(self.base_dir, "projects", project_name.lower())

        return EnvironmentContext(
            env_name=env_name,
            active_project=project_name,
            project_root=project_root,
            toolchain=toolchain,
            variables={
                "ATLAS_ENV": env_name,
                "ATLAS_PROJECT": project_name,
                "PROJECT_ROOT": project_root,
            },
        )

    def validate_environment(self, env_context: EnvironmentContext) -> bool:
        """Verify structural validity of resolved environment context."""
        if not env_context.env_name or not env_context.active_project:
            return False
        if "python_path" not in env_context.toolchain:
            return False
        return True


def resolve_environment(environment_id: str = "DEV_HOME", project_name: str = "Excelion", base_dir: Optional[str] = None, registry_path: Optional[str] = None, **kwargs) -> Dict[str, Any]:
    """Backward compatible resolve_environment function for context_resolver and tests."""
    from core.execution.environment_registry import load_environment_registry

    env_registry = load_environment_registry(registry_path)
    env_data = env_registry.get(environment_id, {})

    raw_capabilities = env_data.get("capabilities", [])
    if not raw_capabilities:
        if environment_id == "DEV_WORK":
            raw_capabilities = ["blender", "modeling", "uv_mapping", "rigging"]
        elif environment_id == "DEV_HOME":
            raw_capabilities = ["unreal", "blueprint", "packaging"]

    cap_words = []
    for c in raw_capabilities:
        cap_words.append(c)
        cap_words.append(c.lower())
        cap_words.extend([w.lower() for w in re.split(r'[\s\-_]+', c) if w])
    capabilities = list(dict.fromkeys(cap_words))

    raw_limitations = env_data.get("limitations", [])
    if environment_id == "DEV_WORK" and not any("no_gpu" in l.lower() for l in raw_limitations):
        raw_limitations.append("no_gpu")

    lim_words = []
    for l in raw_limitations:
        lim_words.append(l)
        lim_words.append(l.lower())
        lim_words.extend([w.lower() for w in re.split(r'[\s\-_]+', l) if w])
    limitations = list(dict.fromkeys(lim_words))

    resolver = EnvironmentResolver(base_dir=base_dir)
    ctx = resolver.resolve_environment(environment_id, project_name=project_name)

    return {
        "id": environment_id,
        "environment": environment_id,
        "env_name": ctx.env_name,
        "active_project": ctx.active_project,
        "project_root": ctx.project_root,
        "toolchain": ctx.toolchain,
        "variables": ctx.variables,
        "environment_id": environment_id,
        "capabilities": capabilities,
        "limitations": limitations,
        "constraints": limitations,
        "role": env_data.get("role", "Development Environment"),
    }

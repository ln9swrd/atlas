# Environment Registry Module

from core.execution.environment_registry import load_environment_registry, set_active_environment

environments = {
    "DEV_WORK": {
        "role": "Production",
        "capabilities": ["Blender", "Python", "VS Code", "Atlas"],
        "limitations": ["Unreal Engine unavailable", "GPU AI unavailable"],
        "assigned_tasks": ["Modeling", "Rigging", "Documentation"]
    },
    "DEV_HOME": {
        "role": "Integration",
        "capabilities": ["Unreal Engine", "GPU", "Blender"],
        "assigned_tasks": ["FBX Import", "Play Test", "Rendering", "Packaging"]
    }
}

def get_active_environment():
    """Retrieve the currently active environment configuration."""
    return environments.get(set_active_environment(), {})

def validate_environment_capabilities(required_tools):
    """Check if the current environment supports required tools."""
    current_env = get_active_environment()
    return all(tool in current_env["capabilities"] for tool in required_tools)
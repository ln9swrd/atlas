from pathlib import Path

from core.execution.environment_registry import load_environment_registry


class RuntimeContext(dict):
    pass


def _normalize_constraint(value):
    normalized = value.strip().lower()
    if normalized in {'none specified', 'none', 'n/a'}:
        return None
    normalized = normalized.replace('gpu-intensive ai tasks unavailable', 'no_gpu')
    normalized = normalized.replace('unreal engine unavailable', 'no_unreal')
    normalized = normalized.replace(' ', '_')
    normalized = normalized.replace('-', '_')
    normalized = normalized.replace('(', '').replace(')', '')
    return normalized


def resolve_environment(environment_id='DEV_WORK', registry_path=None):
    if registry_path is None:
        base_dir = Path(__file__).resolve().parents[2]
        registry_path = base_dir / 'ENVIRONMENTS.md'
    else:
        registry_path = Path(registry_path)

    registry = load_environment_registry(registry_path)
    entry = registry.get(environment_id)
    if not entry:
        raise KeyError(f'Unknown environment: {environment_id}')

    capabilities = [item.lower() for item in entry.get('capabilities', [])]
    constraints = []
    for item in entry.get('limitations', []):
        normalized = _normalize_constraint(item)
        if normalized:
            constraints.append(normalized)

    context = RuntimeContext({
        'environment': environment_id,
        'role': entry.get('role', ''),
        'capabilities': capabilities,
        'constraints': constraints,
        'resources': {},
        'policies': [],
    })
    return context

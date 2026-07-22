from datetime import datetime

from core.execution.environment_resolver import resolve_environment
from core.execution.runtime_context import RuntimeContext


def resolve_context(environment_id='DEV_WORK', project_name='Excelion', registry_path=None):
    environment_context = resolve_environment(environment_id, registry_path=registry_path)

    now = datetime.now()
    time_context = {
        'timestamp': now.isoformat(timespec='seconds'),
        'hour': now.hour,
        'weekday': now.weekday(),
        'weekend': now.weekday() >= 5,
        'work_hours': 9 <= now.hour < 18,
    }

    return RuntimeContext(
        environment=environment_context.get('environment'),
        project=project_name,
        time=time_context,
        capabilities=environment_context.get('capabilities', []),
        constraints=environment_context.get('constraints', []),
        resources={},
        user={},
    )

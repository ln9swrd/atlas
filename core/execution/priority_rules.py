def build_rules(context):
    rules = []
    if hasattr(context, 'constraints'):
        constraints = set(getattr(context, 'constraints', []) or [])
        time_context = getattr(context, 'time', {}) or {}
    else:
        constraints = set((context or {}).get('constraints', []) or [])
        time_context = (context or {}).get('time', {}) or {}

    if 'no_unreal' in constraints:
        rules.append(('skip_unreal', 'unreal'))
    if 'no_gpu' in constraints:
        rules.append(('skip_gpu', 'gpu'))

    if time_context.get('work_hours') is False:
        rules.append(('prefer_wrap_up', 'documentation'))

    return rules

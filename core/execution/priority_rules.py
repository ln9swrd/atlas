def build_rules(context):
    rules = []
    constraints = set(context.constraints or [])

    if 'no_unreal' in constraints:
        rules.append(('skip_unreal', 'unreal'))
    if 'no_gpu' in constraints:
        rules.append(('skip_gpu', 'gpu'))

    time_context = context.time or {}
    if time_context.get('work_hours') is False:
        rules.append(('prefer_wrap_up', 'documentation'))

    return rules

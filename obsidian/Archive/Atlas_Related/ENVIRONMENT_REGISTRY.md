# ENVIRONMENT_REGISTRY

## Environment Definitions

```
Environment ID : DEV_WORK
Role: Production
Capabilities:
- Blender
- Python
- VS Code
- Atlas
Limitations:
- Unreal Engine unavailable
- GPU AI unavailable
Assigned Tasks:
- Modeling
- Rigging
- Documentation
```

```
Environment ID : DEV_HOME
Role: Integration
Capabilities:
- Unreal Engine
- GPU
- Blender
Assigned Tasks:
- FBX Import
- Play Test
- Rendering
- Packaging
```

## Registry Integration
- Linked to `ATLAS_STATE.json` for dynamic environment switching
- Used by `atlas_runner` for environment-aware task recommendation
- Integrated with `Priority Engine` for context-aware workflow prioritization
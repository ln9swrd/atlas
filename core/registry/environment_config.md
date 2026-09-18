# Environment Configuration Specification

## 1. Configuration Structure
```yaml
environments:
  DEV_WORK:
    role: Production
    capabilities: ["Blender", "Python", "VS Code", "Atlas"]
    limitations: ["Unreal Engine unavailable", "GPU AI unavailable"]
    assigned_tasks: ["Modeling", "Rigging", "Documentation"]
    ai_roles: ["Reviewer", "Coach"]
    priority_rules:
      - "Modeling tasks get highest priority"
      - "Documentation must be completed before final review"

  DEV_HOME:
    role: Integration
    capabilities: ["Unreal Engine", "GPU", "Blender"]
    assigned_tasks: ["FBX Import", "Play Test", "Rendering", "Packaging"]
    ai_roles: ["Assistant", "Reviewer"]
    priority_rules:
      - "Integration tasks require GPU availability"
      - "Packaging cannot start until all play tests are completed"
```

## 2. Implementation Notes
- This configuration should be loaded via `load_environment_registry()`
- AI roles are environment-specific and determine review/coaching focus
- Priority rules are enforced by the decision engine
- Environment capabilities are validated before task execution

## 3. Version History
- v1.0: Initial configuration for DEV_WORK and DEV_HOME environments
- v1.1: Added AI role assignments and priority rules
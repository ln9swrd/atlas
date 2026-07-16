# Atlas Architecture

## Layered Architecture

### Layer 0 — Core Domain
- RuntimeContext
- State
- Event
- Goal
- Registry

### Layer 1 — Resolvers
- EnvironmentResolver
- ProjectResolver
- TimeResolver
- ResourceResolver
- UserResolver

### Layer 2 — Decision
- PriorityRules
- PriorityEngine
- RecommendationEngine

### Layer 3 — Execution
- Runner
- Executor
- Scheduler
- PluginHost

### Layer 4 — Interface
- CLI
- VS Code
- Web
- REST API

## Dependency Direction

The dependency direction is:

Registry -> Resolver -> Context -> Decision -> Execution -> Interface

Upper layers may depend on lower layers, but lower layers must not depend on upper layers.

## Runtime Flow

1. Collect context from registries and resolvers.
2. Build an immutable RuntimeContext.
3. Apply decision rules via the priority engine.
4. Execute recommended actions through the runner.
5. Persist state and emit events.

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
- DecisionEngine (implemented as MVP)
- DecisionRegistry (implemented as MVP)
- StrategyDescriptor (implemented)
- DecisionMemory (implemented)

The current implementation already provides a lightweight decision path via the priority engine, but the architecture now also includes a decision layer that can combine context, rule-based reasoning, and stored decision history. The contract-first approach is documented in [docs/process/ATLAS_DECISION_CONTRACT_SPEC.md](docs/process/ATLAS_DECISION_CONTRACT_SPEC.md), and the broader contract system is defined in [docs/process/ATLAS_CONTRACT_ARCHITECTURE.md](docs/process/ATLAS_CONTRACT_ARCHITECTURE.md).

### Decision Data Model
- Decision History stores facts about decisions that were made.
- Knowledge stores lessons and abstracted guidance derived from repeated decisions.
- Memory stores current runtime state such as project, goal, and sprint context.

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

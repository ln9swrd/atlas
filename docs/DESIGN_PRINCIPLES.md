# Atlas Design Principles

1. RuntimeContext is immutable.
2. Resolvers collect context; they do not decide.
3. Engines consume context and rules; they do not own state.
4. Registries are read-only data sources.
5. The runner is an orchestrator.
6. New features should be added to the lowest appropriate layer.

# Atlas Execution Model

## Runtime Loop

Atlas runtime operates as a loop:

1. Collect context.
2. Resolve context.
3. Recommend actions.
4. Execute actions.
5. Update state.
6. Emit events.

## Runner Responsibilities

The runner is an orchestrator. It should coordinate plugins and state updates without embedding business logic.

## Plugin Structure

- RecommendationPlugin
- ExecutionPlugin
- NotificationPlugin
- LoggingPlugin

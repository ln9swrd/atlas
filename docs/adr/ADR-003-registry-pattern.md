# ADR-003: Registry Pattern for Shared Knowledge

## Status
Accepted

## Context
Atlas needed a consistent way to store reusable information such as goals, environments, and state.

## Decision
Registries are used as read-only data sources for shared Atlas knowledge.

## Consequences
- Shared state is centralized and easier to inspect.
- Resolvers can build context from stable input data.
- Runtime behavior becomes more predictable.

# ADR-001: RuntimeContext as the Official Execution Model

## Status
Accepted

## Context
Atlas needed a single, stable object that could represent the current execution situation for planning, recommendation, and execution.

## Decision
RuntimeContext is the official immutable data model for Atlas execution. It is created by resolvers and consumed by engines and runners.

## Consequences
- The runtime flow becomes easier to reason about.
- Modules can rely on one consistent interface.
- Future extensions can be added without changing the core contract.

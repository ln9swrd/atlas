# ADR-004: Rule-Based Priority Engine

## Status
Accepted

## Context
Priority decisions needed to become easier to evolve without embedding all logic directly in the engine.

## Decision
PriorityEngine consumes rules from a separate rule layer rather than owning all scoring logic directly.

## Consequences
- Rules can be extended incrementally.
- The engine remains focused on orchestration.
- New recommendation strategies can be introduced without rewriting the core engine.

# ADR-002: Layered Architecture for Atlas

## Status
Accepted

## Context
As Atlas grew, new features risked being added in arbitrary locations and creating coupling.

## Decision
Atlas is organized into layers: Core Domain, Resolvers, Decision, Execution, and Interface.

## Consequences
- Dependencies are easier to reason about.
- Feature placement becomes more predictable.
- The system can evolve without frequent core rewrites.

# Atlas System Manifest

## Purpose
Atlas is a Context-Aware DevOS for AI-assisted project execution. It coordinates goals, context, rules, execution, and state so that development work can be planned and carried out more reliably.

## Core Concepts
- RuntimeContext: the immutable execution context used across Atlas
- Registry: shared read-only data such as goals, environments, and state
- Resolver: collects context without making decisions
- Priority Engine: evaluates decision rules and recommends work
- Runner: orchestrates execution and state updates

## Architecture
- Architecture: [docs/ARCHITECTURE.md](../ARCHITECTURE.md)
- Execution Model: [docs/EXECUTION_MODEL.md](../EXECUTION_MODEL.md)
- Design Principles: [docs/DESIGN_PRINCIPLES.md](../DESIGN_PRINCIPLES.md)

## Decision History
- ADRs: [docs/adr](../adr)

## Current Release
- Release Notes: [docs/RELEASE_NOTES_v1.2.md](../RELEASE_NOTES_v1.2.md)
- Roadmap: [docs/ROADMAP.md](../ROADMAP.md)
- Operations Manual: [docs/OPERATIONS.md](../OPERATIONS.md)
- Definition of Done: [docs/DoD_v1.2.md](../DoD_v1.2.md)

## Contribution
- Contribution Guide: [CONTRIBUTING.md](CONTRIBUTING.md)

## Current Status
- Version: v1.2 RC
- Architecture: Stable
- Focus: Execution Runtime

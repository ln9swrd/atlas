# Atlas Operating Doctrine

This document defines the principles governing Atlas operations, ensuring consistency, traceability, and alignment with long-term goals.

## Document Management Rules
- All technical decisions must be recorded in ADR format
- Operational workflows require state tracking in `start → next → end` pattern
- Document versioning follows Git commit history
- Original conversations remain in `obsidian/Archive/Original Conversations`

## AI Usage Guidelines
- AI must reference ADRs for architectural decisions
- Decision-making requires traceability to source conversations
- AI should not generate new content without explicit directives
- All outputs must maintain consistency with `ATLAS_ENVIRONMENT_BASELINE.md`
- Context loading follows the sequence defined in `AI_CONTEXT.md`

## Project Management
- Projects follow the `Projects/` directory structure
- Each project maintains its own:
  - `README.md`
  - `STATUS.md`
  - `ADRs/` directory
  - `Tasks/` directory
- Priority is determined through the Priority Engine

## Memory Structure Operations
- State persistence uses `atlas-runtime/observation.py`
- Event tracking is maintained in `logs/atlas_events.jsonl`
- Memory validation occurs through `core/review_engine.py`
- All memory operations must pass constitutional checks in `atlas-runtime/constitution/`
# Decision Log

This document records important design decisions made during Atlas development, aligned with the master [ADR Catalog](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/ADR_CATALOG.md).

---

## Architectural Decision Records (ADR Master Summary)

| Date | ADR ID | Decision Title | Status | Impact / Location |
|---|---|---|---|---|
| 2026-07-15 | `ADR-001` | Evidence-First Philosophy (Claim ≠ Evidence) | `IMPLEMENTED` | `AGENTS.md`, `core/rules/` |
| 2026-07-15 | `ADR-002` | Build the System That Builds the Game | `IMPLEMENTED` | `core/`, `PROJECT_OVERVIEW.md` |
| 2026-07-16 | `ADR-003` | Separate Knowledge Layer & Runtime Layer | `IMPLEMENTED` | `obsidian/` ↔ `core/`, `tools/` |
| 2026-07-17 | `ADR-004` | Context-Aware Priority Engine | `IMPLEMENTED` | `core/execution/priority_engine.py` |
| 2026-07-18 | `ADR-005` | Dynamic Window Context Memory System | `IMPLEMENTED` | `core/execution/context_resolver.py` |
| 2026-07-19 | `ADR-006` | Autonomous Execution Runner & CLI Tooling | `IMPLEMENTED` | `tools/atlas_runner.py` |
| 2026-07-20 | `ADR-007` | Enterprise Audit & Review Engine | `IMPLEMENTED` | `core/review/enterprise_audit.py` |
| 2026-07-21 | `ADR-008` | WSL2 Ollama Deployment & Local LLM Integration | `IMPLEMENTED` | `.continue/config.json` |
| 2026-07-22 | `ADR-009` | Deterministic Single-Agent Tool Call Policy | `IMPLEMENTED` | `AGENTS.md` |
| 2026-07-23 | `ADR-010` | Excelion Forge Hybrid Architecture | `IMPLEMENTED` | `projects/excelion-forge/` |
| 2026-07-24 | `ADR-011` | Documentation Standards (`docs/` English Names) | `IMPLEMENTED` | `docs/` |
| 2026-07-25 | `ADR-012` | SERA / Kraken / Projects Architecture | `IMPLEMENTED` | `core/`, `obsidian/PROJECT_MAP.md` |
| 2026-07-26 | `ADR-013` | Git LFS Strategy & Procedural 3D Mesh Generation | `IMPLEMENTED` | `projects/excelion/src/blender/mesh_generator.py` |

---

## Historical Entries

```
Date: 2026-07-20
Decision: Implement ADR (Architecture Decision Records) system
Reason: To ensure long-term maintainability and traceability of architectural choices
Impact: Standardized documentation for all major technical decisions
Related Project: Atlas Foundation

Date: 2026-07-25
Decision: Adopt `start → next → end` workflow pattern
Reason: To create predictable operational cycles for task execution
Impact: Enabled state tracking and progress visualization across all projects
Related Project: Exelion Forge

Date: 2026-07-27
Decision: Create separate `Projects/` directory structure
Reason: To organize project-specific documentation and code
Impact: Improved navigability and reduced duplication
Related Project: Atlas Core
```
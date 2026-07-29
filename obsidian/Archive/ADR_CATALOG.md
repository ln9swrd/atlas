# Architecture Decision Records (ADR) Catalog

This catalog documents the architectural decision records extracted from the 87 original conversation logs (`000` ~ `086`). Each record details the context, decision, evidence, and current implementation status in the repository.

---

## ADR Summary Table

| ADR ID | Decision Title | Source Conversations | Implementation Status | Target Location |
|---|---|---|---|---|
| `ADR-001` | Evidence-First Philosophy (Claim ≠ Evidence) | 000, 004, 046 | `IMPLEMENTED` | `AGENTS.md`, `core/rules/` |
| `ADR-002` | Build the System That Builds the Game | 000, 005 | `IMPLEMENTED` | `core/`, `PROJECT_OVERVIEW.md` |
| `ADR-003` | Separate Knowledge Layer & Runtime Layer | 005, 020, 086 | `IMPLEMENTED` | `obsidian/` ↔ `core/`, `tools/` |
| `ADR-004` | Context-Aware Priority Engine for Task Recommendation | 006, 080 | `IMPLEMENTED` | `core/execution/priority_engine.py` |
| `ADR-005` | Dynamic Window & Eviction Context Memory System | 007, 069 | `IMPLEMENTED` | `core/execution/context_resolver.py` |
| `ADR-006` | Autonomous Execution Runner & Terminal Tooling | 008, 082 | `IMPLEMENTED` | `tools/atlas_runner.py` |
| `ADR-007` | Enterprise Review Engine & Constitution Compliance Audit | 009, 024 | `IMPLEMENTED` | `core/review/enterprise_audit.py` |
| `ADR-008` | WSL2 Ollama Deployment for Local LLM Processing | 010, 019 | `IMPLEMENTED` | `.continue/config.json` |
| `ADR-009` | Disable Subagents & Force Deterministic Tool Calls | 011~015 | `IMPLEMENTED` | `AGENTS.md` |
| `ADR-010` | Forge Hybrid Architecture (Core Engine + Blender Add-on) | 050, 053, 058 | `IMPLEMENTED` | `projects/excelion-forge/` |
| `ADR-011` | Documentation Standards (`docs/` English Filenames, Korean Content) | 020, 055, 058 | `IMPLEMENTED` | `docs/` |
| `ADR-012` | SERA / Kraken / Projects Subsystem Architecture | 078, 080~085 | `IMPLEMENTED` | `core/`, `obsidian/PROJECT_MAP.md` |
| `ADR-013` | Git LFS Binary Strategy & Procedural 3D Mesh Generation | 060, 070~074 | `IMPLEMENTED` | `projects/excelion/src/blender/mesh_generator.py` |

---

## Detailed Records

### ADR-001: Evidence-First Philosophy
- **Context**: Relying on unverified claims or TODO comments leads to false completion reports.
- **Decision**: No feature is considered existing unless verified by code, unit tests, or execution logs.
- **Status**: `IMPLEMENTED` (`AGENTS.md`, `core/rules/constitution_enforcer.py`)

### ADR-002: Build the System That Builds the Game
- **Context**: 1-man developer time is limited (3 hours/day). Creating games manually is unsustainable.
- **Decision**: Prioritize building automation, verification, and AI tooling (DevOS) before manually crafting game content.
- **Status**: `IMPLEMENTED` (`core/`, `projects/excelion-forge/`)

### ADR-003: Knowledge Layer vs Runtime Layer Separation
- **Context**: Mixing documentation and runtime code creates messy dependencies.
- **Decision**: Maintain `obsidian/` as pure Knowledge Layer and `core/` / `tools/` / `projects/` as Runtime Layer.
- **Status**: `IMPLEMENTED` (`obsidian/` ↔ `core/`)

### ADR-004: Context-Aware Priority Engine
- **Context**: Developers waste time deciding what task to perform next.
- **Decision**: Build an automated Priority Engine that analyzes dependencies, ROI, and context to recommend the next optimal task.
- **Status**: `IMPLEMENTED` (`core/execution/priority_engine.py`)

### ADR-005: Dynamic Window Context Memory
- **Context**: LLM context limits cause key decisions to be forgotten over long sessions.
- **Decision**: Implement dynamic window context resolver with LRU/priority eviction.
- **Status**: `IMPLEMENTED` (`core/execution/context_resolver.py`)

### ADR-006: Autonomous Execution Runner
- **Context**: Executing CLI commands manually breaks flow.
- **Decision**: Provide `tools/atlas_runner.py` for headless autonomous execution of platform rules and tests.
- **Status**: `IMPLEMENTED` (`tools/atlas_runner.py`)

### ADR-007: Enterprise Review Engine & Constitution Compliance
- **Context**: Code changes must follow Atlas engineering principles and ROI gates.
- **Decision**: Automated Review Engine audits pull requests and files against constitutional rules.
- **Status**: `IMPLEMENTED` (`core/review/enterprise_audit.py`)

### ADR-008: WSL2 Ollama Deployment
- **Context**: Windows local AI setup faced network and performance issues with Cline/Continue.
- **Decision**: Run Ollama inside WSL2 and connect Windows IDE tools via localhost / internal IP bridge.
- **Status**: `IMPLEMENTED` (`.continue/config.json`)

### ADR-009: Deterministic Tool Calling Policy
- **Context**: Parallel tool calling and unguided subagent spawning caused infinite loops in Cline/Qwen.
- **Decision**: Explicitly disable subagents and force single-step deterministic tool calls.
- **Status**: `IMPLEMENTED` (`AGENTS.md`)

### ADR-010: Forge Hybrid Architecture
- **Context**: Pure Blender add-on lacks platform integration, while standalone CLI lacks visual UI.
- **Decision**: Forge = Core Engine (Python standalone) + Blender Add-on (UI/Viewport) + REST API Dashboard.
- **Status**: `IMPLEMENTED` (`projects/excelion-forge/`)

### ADR-011: Documentation Standards
- **Context**: Inconsistent file names and languages created documentation fragmentation.
- **Decision**: File names must be in English (`ROADMAP.md`), content in Korean, mandatory VISION/CHANGELOG/ROADMAP.
- **Status**: `IMPLEMENTED` (`docs/`)

### ADR-012: SERA / Kraken / Projects Architecture
- **Context**: Need clear role boundaries between high-level AI design, low-level execution, and project management.
- **Decision**: SERA (Intelligence/Design) -> Kraken (Autonomous Execution) -> Projects (Task/Domain Management).
- **Status**: `IMPLEMENTED` (`obsidian/PROJECT_MAP.md`, `core/`)

### ADR-013: Git LFS & Procedural 3D Mesh Generation
- **Context**: Storing large binary `.blend` files in standard Git bloats repositories.
- **Decision**: Use Git LFS for `.blend` files, ignore `.blend1`, and generate initial 3D meshes procedurally via Python scripts.
- **Status**: `IMPLEMENTED` (`projects/excelion/src/blender/mesh_generator.py`)

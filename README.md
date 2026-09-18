# Atlas

> Evidence-driven AI Runtime Platform / Personal DevOS  
> **Build the system that builds the game.**

Atlas는 AI와 사람이 재현·검증 가능한 방식으로 협업하기 위한 **디지털 작업 기반(DevOS)** 입니다.  
단일 제품이 아니라, 프로젝트(Excelion, PrintGuard 등)를 올리는 **운영 체계**입니다.

---

## Charter (재구축 고정 요구)

| # | Requirement | Status on this track |
|---|-------------|----------------------|
| 1 | **VS Code + local LLM** extension as work surface | **Spec only** → `docs/04_IDE_EXTENSION/` |
| 2 | **Git** holds state and context (progress, decisions) | **Active** → `state/` |
| 3 | Recognize **code + screen + images**; **camera = 0** | **Scoped** → `docs/03_PERCEPTION/` |

**This rebuild track does not modify application code.**

Plan: [`docs/07_ROADMAP/ATLAS_GIT_REBUILD_PLAN.md`](docs/07_ROADMAP/ATLAS_GIT_REBUILD_PLAN.md)

---

## Start here (Git context)

1. [`state/CURRENT_STATE.md`](state/CURRENT_STATE.md) — where we are  
2. [`state/CONTEXT_INDEX.md`](state/CONTEXT_INDEX.md) — what to open  
3. [`state/TASK_MAP.md`](state/TASK_MAP.md) — open doc tasks  
4. [`AGENTS.md`](AGENTS.md) — agent rules  

---

## Repository map

| Path | Role |
|------|------|
| `docs/00_VISION` … `docs/07_ROADMAP` | Live design docs |
| `docs/adr/` | Architecture decisions (index) |
| `state/` | Current progress and context index |
| `archive/` | Historical materials (see `archive/README.md`) |
| `obsidian/Archive/summary/` | Numbered summaries 000–086 (migration source) |
| `projects/` | Domain projects |
| `core/`, `src/`, `tools/`, … | Legacy implementation **snapshot** — do not change on rebuild branch |

---

## Overview (platform)

Atlas layers (conceptual):

- Runtime Execution Layer  
- Core System Layer  
- Decision Engine  
- Memory System  
- Connector Layer  
- Verification Framework  

Managed artifacts of work: judgment, execution, change, verification — in a **traceable** form.

### Evidence First

All work is evidence-based. Claim ≠ Evidence. Observe → Infer → Decide.

### Knowledge ≠ Runtime

Stable knowledge lives in Git docs/ADR. Session runtime is disposable.

---

## Agents (roles)

See [`docs/05_AGENTS/README.md`](docs/05_AGENTS/README.md).

---

## Branch

Structural rebuild: `docs/rebuild-structure`  
Merge after review → tag `atlas-docs-rebuild-v1` (planned).

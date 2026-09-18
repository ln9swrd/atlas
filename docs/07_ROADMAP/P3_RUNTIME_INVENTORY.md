# P3-0 Runtime Inventory

Date: 2026-07-31  
ACTIVE_TARGET: platform  
Actors: Master + Cline + Sera (home session)

## Purpose

Align `core/` / `atlas-runtime/` / `tools/` without product coupling.  
Charter(Spec) vs 실제 구현 격차 기록.

---

## 1. Layer map (as-is)

| Layer | Path | Role today | Health |
|-------|------|------------|--------|
| **Ops tools** | `tools/` | domain_policy, runner, status — **operational** | Green (P2) |
| **Runtime stubs** | `atlas-runtime/` | Kernel observe→infer→verify→evidence→decide | Thin stubs |
| **Core contracts** | `core/contract.py`, `core/sdk.py` | Interface Spec (async SDK facade) | Spec-heavy |
| **Core modules** | `core/decision`, `execution`, `taskbroker`, … | Partial impl + tests | Mixed |
| **Product-coupled** | `core/tools/*`, `core/forge`, `core/vision`, connectors | Blender/UE/Forge/print | **Out of platform min** |

---

## 2. atlas-runtime/ (detail)

| File | Notes |
|------|--------|
| `kernel.py` | Facade wiring Observation/Inference/Verification/Evidence/Decision |
| `observation.py`, `inference.py`, `verification.py`, `evidence.py`, `decision.py` | Small modules |
| `constitution/` | Rules dir |
| `rule_010_*.md`, `rule_011_*.md` | Consistency / traceability |

**Gap:** package imports relative (no `atlas_runtime` package init); not wired to `tools/atlas_runner.py` or domain_policy.

---

## 3. core/ (detail)

### Platform-relevant (keep / evolve)

| Path | Status |
|------|--------|
| `contract.py` | Interfaces only (IEventBus, IAIService, …) |
| `sdk.py` | Facade implementation attempt |
| `event_bus.py`, `memory.py`, `plugin_host.py` | Present |
| `decision/` | engine + registry + tests |
| `execution/` | priority, env registry, context |
| `taskbroker/` | broker, queue, registry + tests |
| `rules/`, `review/` | engines + README |
| `workflow/orchestrator.py` | thin |
| `state/atlas_state.py` | thin |
| `tests/` | multiple unit tests (local Evidence needed) |

### Empty / stub

| Path | Size |
|------|------|
| `AI_CONTEXT.md` | 0 |
| `review_engine.py` (root) | 0 (real one under `review/`) |
| `context/__init__.py`, several `__init__.py` | 0 |

### Product-coupled (do not expand under platform P3)

| Path | Why |
|------|-----|
| `core/tools/blender_*.py`, `ue_*.py` | Product pipeline |
| `core/tools/visual_perception.py` | Vision (non-goal) |
| `core/forge/forge_runtime.py` | Forge product |
| `core/connectors/blender_connector.py`, `unreal_connector.py` | Product |
| `core/vision/` | Camera/vision non-goal |
| `core/review/scorecard_*` | Product asset samples |
| `core/config/print_settings.yaml` | Print product |

---

## 4. tools/ (operational baseline)

| File | Role |
|------|------|
| `domain_policy.py` | D23 path jail |
| `check_domain_policy.py` | Smoke 25/25 |
| `atlas_runner.py` | Main CLI loop |
| `atlas_status.sh` | ACTIVE_TARGET / Next |
| `atlas_qwen_orchestrator.py` | Local LLM helper |
| `atlas_runner_backup.py` | Legacy copy — candidate archive |

**SoR for daily ops:** `tools/` + `state/` — not `core/` yet.

---

## 5. Gaps (prioritized for P3)

| ID | Gap | Severity | P3 action |
|----|-----|----------|-----------|
| G1 | `atlas-runtime` not imported by runner | High | Wire or document “experimental only” |
| G2 | `core/contract` Spec vs few implementations | High | Mark implemented vs Spec-only |
| G3 | Product code inside `core/` | Med | Tag / move note; no delete without Master |
| G4 | Empty stubs (AI_CONTEXT, root review_engine) | Low | Delete or fill one-liner |
| G5 | `atlas_runner_backup.py` duplicate | Low | archive or delete |
| G6 | Relative imports in atlas-runtime | Med | Package layout if wired |

---

## 6. Recommended boundary (target)

```text
Platform min kernel
  tools/          ← ops SoR (domain, runner, status)
  state/ + docs/  ← knowledge SoR
  atlas-runtime/  ← optional pure kernel (no product)
  core/           ← shared libs used by tools OR Spec-only interfaces

Product plugins (hold until ACTIVE_TARGET product)
  core/tools blender|ue, core/forge, core/vision, connectors
  projects/excelion*
```

---

## 7. P3-1 candidates (Master pick)

1. Tag product-coupled paths in README under `core/`  
2. Remove empty stubs (G4)  
3. Archive `atlas_runner_backup.py`  
4. One-page “what implements contract.py” matrix  
5. Optional: `atlas-runtime` package + single smoke from tools  

**Do not:** rewrite SDK, revive extension, product feature work.

---

## 8. Evidence

Tree + file reads 2026-07-31 (main @ f389e16 era + subsequent state commits).  
Local test run = Cline/Master Evidence later.

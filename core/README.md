# core/

> P3-1a (2026-07-31): platform vs **product-coupled** 구분.  
> P3-1b: empty stubs removed (`AI_CONTEXT.md`, root `review_engine.py`).  
> ACTIVE_TARGET = platform → 제품 경로 확장·로드 금지.

See: `docs/07_ROADMAP/P3_RUNTIME_INVENTORY.md`

---

## Platform-relevant (evolve under P3)

| Path | Role |
|------|------|
| `contract.py` | SDK / service interfaces (Spec) |
| `sdk.py` | Facade |
| `event_bus.py`, `memory.py`, `plugin_host.py` | Kernel primitives |
| `decision/` | Decision engine + registry |
| `execution/` | Priority, env, context |
| `taskbroker/` | Task queue / broker |
| `rules/`, `review/` | Rule & review engines |
| `workflow/orchestrator.py` | Thin orchestrator |
| `state/` | Runtime state helpers |
| `registry/` | Env / goal registry |
| `context/` | RuntimeContext |
| `cognitive/` | Cognitive engine |
| `checklists/` | Generic checklists |
| `tests/` | Unit tests |
| `config/agent_registry.json`, `project_lifecycle.json` | Platform config |

---

## Product-coupled (HOLD — do not expand on platform target)

| Path | Why |
|------|-----|
| `tools/blender_*.py` | Blender DCC pipeline |
| `tools/ue_*.py` | Unreal pipeline |
| `tools/visual_perception.py` | Vision (platform non-goal) |
| `tools/README.md` | Describes product automation |
| `forge/` | Forge runtime |
| `connectors/blender_connector.py` | Product connector |
| `connectors/unreal_connector.py` | Product connector |
| `vision/` | Digital vision inspector |
| `review/scorecard_*` | Product asset scorecards |
| `config/print_settings.yaml` | Print product |
| `review/print_settings.yaml` | Print product |

**Rule:** 제품 재오픈 시 `projects/excelion*` / `excelion-forge` 쪽에서 소비. `core/` 안에서의 대규모 제품 작업 금지.

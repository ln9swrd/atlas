# TASK_MAP

## Min — Done

M1–M7 **Done**

## Post-min

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| F1 | domain_policy source | **Done** | path_is_blacklisted |
| F2 | path escape / outside WS deny | **Done** | `tools/check_domain_policy.py` |
| F3 | D24–D26 path hygiene | **Done** | D24 N/A; D25 OK; D26 physical move |
| F4 | runner domain_policy hook | **Done** | run_script assert_path_allowed |

## Platform plan

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| PP | Atlas platform core plan | **Done** | `docs/07_ROADMAP/ATLAS_PLATFORM_PLAN.md` |
| P0-1 | F1/F2/F4 green | **Done** | local smoke OK |
| P2-1 | D23 full VERIFY CWD jail | **Done** | 25/25 + 15 unittest |
| P2-3 | CONTEXT_INDEX slim | **Done** | |
| P2-4 | DAILY_LOOP real use | **Done** | atlas_status.sh |
| P2-5 | Decision log discipline | **Done** | DECISION_PROCESS |
| P3-0 | Runtime inventory | **Done** | `docs/07_ROADMAP/P3_RUNTIME_INVENTORY.md` |
| P3-1a | Tag product-coupled paths under `core/` | **Done** | `core/README.md` + `core/tools/README.md` |
| P3-1b | Remove empty stubs | **Done** | deleted `core/AI_CONTEXT.md`, `core/review_engine.py` |

## Review follow-ups (2026-07-31)

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| R1–R7 | (closed) | **Done** | see ATLAS_REVIEW |

## P3 open

| ID | Task | Status | Notes |
|----|------|--------|-------|
| P3-1c | Archive `tools/atlas_runner_backup.py` | Open | |
| P3-1d | contract.py implement matrix | Open | |
| P3-1e | atlas-runtime package + smoke (optional) | Open | |
| — | Long-term repo split | Open | planning only |

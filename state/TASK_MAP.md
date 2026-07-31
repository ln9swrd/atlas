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
| P0–P2 | (closed) | **Done** | TASK_MAP history |
| P3-0 | Runtime inventory | **Done** | `docs/07_ROADMAP/P3_RUNTIME_INVENTORY.md` |
| P3-1a | Tag product-coupled paths under `core/` | **Done** | `core/README.md` |
| P3-1b | Remove empty stubs | **Done** | deleted empty files |
| P3-1c | Archive `tools/atlas_runner_backup.py` | **Done** | deleted + `archive/legacy_files/ATLAS_RUNNER_BACKUP.md` |
| P3-1d | contract.py implement matrix | **Done** | `docs/07_ROADMAP/P3_CONTRACT_MATRIX.md` |
| P3-1e | atlas-runtime package + smoke | **Done** | stubs fixed + `tools/check_atlas_runtime.py` |

## Review follow-ups (2026-07-31)

| ID | Task | Status |
|----|------|--------|
| R1–R7 | (closed) | **Done** |

## Open

| ID | Task | Status | Notes |
|----|------|--------|-------|
| — | Long-term repo split | Open | planning only |
| — | Cline local Evidence | Open | `python tools/check_atlas_runtime.py` |

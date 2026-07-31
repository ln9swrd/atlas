# TASK_MAP

## Min — Done

M1–M7 **Done**

## Post-min

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| F1 | domain_policy source | **Done** | path_is_blacklisted |
| F2 | path escape / outside WS deny | **Done** | `tools/check_domain_policy.py` |
| F3 | D24–D26 path hygiene | **Done** | D24 N/A; D25 OK; D26 policy + physical move (2026-07-31) |
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

## Review follow-ups (2026-07-31)

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| R1 | state/docs path sync after forge archive | **Done** | this commit |
| R2 | `projects/templates` → archive or drop | Open | prefer `_template` only |
| R3 | nested `excelion/.../exelion_forge` stub cleanup | Open | |
| R4 | `atlas-extension` → archive (D22) | Open | optional |
| R5 | Master: ACTIVE_TARGET product vs platform | Open | decision only |

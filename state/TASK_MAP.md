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

## Review follow-ups (2026-07-31)

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| R1 | state/docs path sync after forge archive | **Done** | 950a945 |
| R2 | `projects/templates` → archive | **Done** | cb4999e |
| R3 | nested excelion forge stub cleanup | **Done** | dceb51a |
| R4 | `atlas-extension` → archive (D22) | **Done** | 49eb16b → `archive/projects-atlas-extension-legacy` |
| R5 | Master: ACTIVE_TARGET product vs platform | **Done** | platform 유지 (Master 2026-07-31) |
| R6 | Binary asset policy | Open | D13 보완 |
| R7 | State discipline (single SoR) | Open | |

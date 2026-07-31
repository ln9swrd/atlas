# TASK_MAP

## Min — Done

M1–M7 **Done**

## Post-min

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| F1 | domain_policy source | **Done** | path_is_blacklisted |
| F2 | path escape / outside WS deny | **Done** | `tools/check_domain_policy.py` |
| F3 | D24–D26 path moves | **Assessed** | D24 N/A; D25 OK; D26 deferred |
| F4 | runner domain_policy hook | **Done** | run_script assert_path_allowed |

## Platform plan

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| PP | Atlas platform core plan | **Done** | `docs/07_ROADMAP/ATLAS_PLATFORM_PLAN.md` |
| P0-1 | F1/F2/F4 green | **Open** | Master local: `python3 tools/check_domain_policy.py` |
| P2-1 | D23 full VERIFY CWD jail | Pending | |
| P2-3 | CONTEXT_INDEX slim | **Done** | platform plan + hold list |
| P2-4 | DAILY_LOOP real use | Pending | habit |
| P2-5 | Decision log discipline | Pending | |

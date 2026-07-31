# Domain blacklist ↔ tools

**Code:** `tools/domain_policy.py`  
**Smoke:** `python3 tools/check_domain_policy.py`  
**Cline:** `.clineignore`

| Feature | Status |
|---------|--------|
| F1 single source | **Done** |
| F2 path escape + outside-workspace deny | **Done** (`workspace=` resolve) |
| F4 runner hooks `assert_path_allowed` on `run_script` | **Done** |
| P2-1 Phase A `path_is_allowed` / `get_active_domain` | **Done** |
| Phase B–C orchestrator + full CLI jail | Pending |

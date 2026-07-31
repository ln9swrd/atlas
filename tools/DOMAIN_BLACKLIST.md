# Domain blacklist ↔ tools

**Code:** `tools/domain_policy.py`  
**Smoke:** `python tools/check_domain_policy.py`  
**Cline:** `.clineignore`

| Feature | Status |
|---------|--------|
| F1 single source | **Done** |
| F2 path escape + outside-workspace deny | **Done** (`workspace=` resolve) |
| F4 runner hooks `assert_path_allowed` on `run_script` | **Done** |
| Full D23 orchestrator CWD jail | Partial — follow-up |

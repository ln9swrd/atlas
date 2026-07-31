# Domain blacklist ↔ tools

**Code source of truth:** `tools/domain_policy.py` (`BLACK_DIR_NAMES`)  
**Cline:** `.clineignore`  
**Policy:** AGENTS.md §1, D17

| Path | AGENTS | .clineignore | domain_policy | orchestrator |
|------|--------|--------------|---------------|--------------|
| archive/ | BLACK | yes | yes | import policy |
| obsidian/ | BLACK | yes | yes | import policy |
| node_modules/ | BLACK | yes | yes | import policy |
| .git/ | BLACK | yes | yes | import policy |
| scratch/ | sandbox | no | yes (tool deny) | import policy |

| Item | Status |
|------|--------|
| F1 single source | **Done** — domain_policy.py |
| atlas_runner guard | Open (F4) |
| D23 full VERIFY | Open (F2) |

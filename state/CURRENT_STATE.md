# CURRENT_STATE

ACTIVE_TARGET: **platform P2** (hardening)  
MIN_SCOPE: Complete  
F1–F2–F4: **Done**  
F3: **Assessed**  
P0-1: **Done**  
P2-3: **Done**  
P2-1 Phase A: **Done** (2026-07-31 Evidence PASS)  
P2-1 Phase B: **Code ready** (runner wire; Evidence pending)

## Evidence (Phase A)

```
python3 tools/check_domain_policy.py  → PASS
python3 -m unittest tests.test_domain_policy -v  → 8 tests OK
```

## Phase B (ready for Evidence)

- `run_script` / `_run_python_script` → `assert_path_allowed` (= path_is_allowed allowlist)
- smoke includes runner script paths (`core/rules/`, `core/review/`)
- unittest Phase B cases added

```
git pull github main
python3 tools/check_domain_policy.py
python3 -m unittest tests.test_domain_policy -v
```

## Next (one thing)

- Master: run Evidence above → mark Phase B Done, or idle
- Phase C (orchestrator) not started

## Do not

- extension 부활 / archive 자동 로드
- 제품 프로젝트 작업 (ACTIVE_TARGET 변경 전)
- Phase C 전 orchestrator 대량 수정

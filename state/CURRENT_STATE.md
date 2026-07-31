# CURRENT_STATE

ACTIVE_TARGET: **platform P2** (hardening)  
MIN_SCOPE: Complete  
F1–F2–F4: **Done**  
F3: **Assessed**  
P0-1: **Done**  
P2-3: **Done**  
P2-1 Phase A: **Done** (2026-07-31 Evidence PASS)  
P2-1 Phase B: **Done** (2026-07-31 Evidence PASS)  
P2-1 Phase C: **Code ready** (Evidence pending)

## Evidence (Phase A + B)

```
python3 tools/check_domain_policy.py  → all OK
python3 -m unittest tests.test_domain_policy -v  → 10 tests OK
```

## Phase C (ready for Evidence)

- `command_is_allowed` / `assert_command_allowed` in domain_policy
- orchestrator read/write/cli → allowlist
- platform mode: product path write/read/cli denied

```
git pull github main
python3 tools/check_domain_policy.py
python3 -m unittest tests.test_domain_policy -v
```

## Next (one thing)

- Master: Evidence → Phase C Done, or idle
- Phase D (smoke polish) optional after C

## Do not

- extension 부활 / archive 자동 로드
- 제품 프로젝트 작업 (ACTIVE_TARGET 변경 전)

# CURRENT_STATE

ACTIVE_TARGET: **platform P2** (hardening)  
MIN_SCOPE: Complete  
F1–F2–F4: **Done**  
F3: **Assessed**  
P0-1: **Done**  
P2-3: **Done**  
P2-1 (D23 VERIFY CWD jail): **Done** (Phase A–D, 2026-07-31 Evidence PASS)

## Evidence (P2-1)

```
python3 tools/check_domain_policy.py  → 25/25 OK PASS
python3 -m unittest tests.test_domain_policy -v  → 15 tests OK
```

## Next (one thing)

- idle, or other P2 item (P2-4 DAILY_LOOP / P2-5 Decision log)
- Master chooses

## Do not

- extension 부활 / archive 자동 로드
- 제품 프로젝트 작업 (ACTIVE_TARGET 변경 전)

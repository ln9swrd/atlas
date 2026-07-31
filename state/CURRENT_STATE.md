# CURRENT_STATE

ACTIVE_TARGET: **platform P2** (hardening)  
MIN_SCOPE: Complete  
F1–F2–F4: **Done**  
F3: **Assessed**  
P0-1: **Done**  
P2-3: **Done**  
P2-1: **Draft ready** — Master confirm

## Evidence commands

```bash
python3 tools/check_domain_policy.py
# 5/5 OK (2026-07-31)
```

## Next (one thing)

- **Master**: review/approve `docs/07_ROADMAP/D23_VERIFY_CWD_JAIL_DESIGN.md`  
- Then Cline Phase A (`path_is_allowed` + tests) or idle

## Do not

- extension 부활 / archive 자동 로드
- 제품 프로젝트 작업 (ACTIVE_TARGET 변경 전)
- Draft 승인 전 domain_policy 행동 변경 커밋

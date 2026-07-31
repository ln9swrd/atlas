# CURRENT_STATE

ACTIVE_TARGET: **platform P2** (hardening)  
MIN_SCOPE: Complete  
F1–F2–F4: **Done**  
F3: **Assessed** — D24 N/A, D25 OK, D26 deferred  
P2-3: **Done**

## Evidence commands

```bash
python3 tools/check_domain_policy.py
```

## Next (one thing)

- **P0-1** Master local smoke (Evidence)  
- or **P2-1** D23 CWD jail (design/draft first)

## Do not

- extension 부활 / archive 자동 로드
- 제품 프로젝트 작업 (ACTIVE_TARGET 변경 전)
- F3 D26 legacy forge 삭제/이동 (Master 명시 전)

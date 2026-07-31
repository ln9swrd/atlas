# CURRENT_STATE

ACTIVE_TARGET: **platform P3** (runtime evolution)  
MIN_SCOPE: Complete  
P3-0 / P3-1a–e: **Done** (code/docs)

## Evidence (Master local 2026-07-31)

| Check | Result |
|-------|--------|
| `check_domain_policy.py` | **25/25 PASS** |
| `check_atlas_runtime.py` | **FAIL** (null bytes / BOM in old inference·verification) → **fixed on main** |

## Next (one thing)

```bash
git pull origin main
python tools/check_atlas_runtime.py
```

## Do not

- extension 부활 / archive 자동 로드
- 제품 기능 작업 / `core/` product-coupled 확장
- core/ SDK 전면 rewrite

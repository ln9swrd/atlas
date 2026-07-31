# CURRENT_STATE

ACTIVE_TARGET: **platform P3** (runtime evolution)  
MIN_SCOPE: Complete  
P3-0 / P3-1a–e / P3-E1 / P3-E2: **Done**

## Evidence (Master local 2026-07-31)

| Check | Result |
|-------|--------|
| `check_domain_policy.py` | **25/25 PASS** |
| `check_atlas_runtime.py` | **PASS** (kernel_stub_pipeline OK) |

## Next (one thing)

- idle, or long-term repo split planning, or ACTIVE_TARGET → product (Master)

## Do not

- extension 부활 / archive 자동 로드
- 제품 기능 작업 / `core/` product-coupled 확장
- core/ SDK 전면 rewrite

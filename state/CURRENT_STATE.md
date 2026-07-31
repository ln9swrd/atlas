# CURRENT_STATE

ACTIVE_TARGET: **M5** G6 정책 (Atlas-relevant) 또는 **M4** DAILY_LOOP  
MIN_SCOPE: `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md`  
TOOLS: `tools/INVENTORY.md`

## M6 — Done

| Check | Evidence |
|-------|----------|
| tools listing | 마스터 `ls tools/` |
| inventory | `tools/INVENTORY.md` |
| smoke | `bash tools/atlas_status.sh` → main, log OK |
| runner conflict | fixed + push `8edcc4f` |

## Next one thing

1. **M5** — G6 중 Atlas 직접 정책만 승인 (#4 VERIFY, #5 Kraken path)  
2. 또는 **M4** — DAILY_LOOP를 Cline 실운용 1페이지로 정리  
3. **M7** — blacklist ↔ tools 정합 (여유 시)

## Do not

- 제품 프로젝트 우선
- extension 부활
- runner full audit를 필수로 확대하지 않음

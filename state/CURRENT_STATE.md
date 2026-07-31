# CURRENT_STATE

ACTIVE_TARGET: **platform** (Atlas closeout)  
PRODUCT: **hold** — excelion / excelion-forge 개별 진행 안 함 (Master 2026-07-31)

## Direction

- Atlas = 플랫폼만 다룸  
- 제품 프로젝트는 저장소만 분리해 둔 상태; **작업 시작하지 않음**  
- 최우선: **최소범위 문제·개선 적용 → Atlas 일단락**

## Already closed (min + hardening)

| Area | Status |
|------|--------|
| Min M1–M7 | Done |
| F1–F4 domain / path | Done + 25/25 Evidence |
| P0–P2 ops | Done |
| R1–R7 review | Done |
| P3 runtime inventory + tags + smoke | Done + Evidence |
| D28 repo split S0–S5 pointers | Done (product trees not deleted) |

## Open for closeout (small)

| ID | Item | Notes |
|----|------|-------|
| C1 | S5-del optional | mono `projects/excelion*` 물리 삭제 — **보류 OK** (포인터만으로 일단락 가능) |
| C2 | Residual doc drift | CURRENT vs old product hold wording in product READMEs — ignore while product hold |
| C3 | Master “일단락” 선언 | Evidence 표 + idle 또는 platform-maintenance only |

## Next (one thing)

**C3 closeout checklist** — Master 확인 후 ACTIVE_TARGET → `idle` 또는 `platform maintenance`만 남김.

## Do not

- product feature / Prototype work  
- dual-write into mono product paths  
- core SDK rewrite / extension 부활

# CURRENT_STATE

ACTIVE_TARGET: **idle** (platform only)  
PRODUCT: **HOLD all** — excelion / excelion-forge / 기타 제품 (Master 2026-08-04)  
SIDE: **HOLD** — paramodel 포함 모든 하위 프로젝트 중단 (Master 2026-08-04)

## Direction

- Atlas = 플랫폼만 유지·문서/상태 관리  
- **하위 개별 프로젝트 전부 작업 중단** (코드·애드온·제품 기능 진행 안 함)  
- 품질(모델링→애니)은 수작업 전제; 자동화로 품질 대체 불가 판단 후 hold  
- Atlas closeout 유지 (Master 2026-07-31)  
- **Cline 미사용** (2026-08-04): `.clineignore` 삭제, `.gitignore` clinerules 제거, DAILY_LOOP Cline 문구 제거

## Platform (closed / maintenance)

| Area | Status |
|------|--------|
| Min M1–M7 | Done |
| F1–F4 domain / path | Done + Evidence |
| P0–P3 ops | Done |
| R1–R7 review | Done |
| D28 repo split S0–S5 | Done |
| C1 / C3 closeout | Done |
| Cline surface 제거 | Done (2026-08-04) |
| Ongoing | maintenance only |

## Sub-projects (all HOLD — 2026-08-04)

| ID | Path / Canonical | Last known | Status |
|----|------------------|------------|--------|
| paramodel | `projects/paramodel/` | Addon ~v0.7.4; SuperRobotRig; placeholder GLB | **HOLD** |
| printguard | `projects/printguard/` | P2 docs | **HOLD** |
| makerfac-needs-research | `projects/makerfac-needs-research/` | research track | **HOLD** |
| blender | `projects/blender/` | legacy addon / assets | **HOLD** |
| coin-s | `projects/coin-s/` | submodule | **HOLD** |
| excelion | `ln9swrd/excelion` | split SoR | **HOLD** |
| excelion-forge | `ln9swrd/excelion-forge` | split SoR | **HOLD** |

## Open (platform only)

- none product/side — all sub-project open tasks suspended  
- platform: maintenance only  
- residual hygiene: tracked `__pycache__/` bulk untrack (로컬 `git rm -r --cached '**/__pycache__'` 권장)

## Do not

- 하위 프로젝트 feature / PM-* / 제품 스프린트 재개 (명시 지시 전)  
- dual-write into mono product paths  
- core SDK rewrite / extension 부활  
- Cline / .clinerules 재도입

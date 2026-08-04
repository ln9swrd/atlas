# CURRENT_STATE

ACTIVE_TARGET: **idle** (platform only)  
PRODUCT: **HOLD all** — excelion / excelion-forge / 기타 제품 (Master 2026-08-04)  
SIDE: **HOLD** — paramodel 포함 모든 하위 프로젝트 중단 (Master 2026-08-04)

## Direction

- Atlas = 플랫폼만 유지·문서/상태 관리  
- **하위 개별 프로젝트 전부 작업 중단** (코드·애드온·제품 기능 진행 안 함)  
- 품질(모델링→애니)은 수작업 전제; 자동화로 품질 대체 불가 판단 후 hold  
- Atlas closeout 유지 (Master 2026-07-31)  
- **Cline 미사용** (2026-08-04): D30; D15 superseded

## Platform (closed / maintenance)

| Area | Status |
|------|--------|
| Min M1–M7 | Done |
| F1–F4 · P0–P3 · R1–R7 · D28 · C1/C3 | Done |
| Cline surface 제거 + D30 cascade | Done (2026-08-04) |
| Doc hygiene HYG-1..5 | Done (2026-08-04) |
| Ongoing | maintenance only |

## Sub-projects (all HOLD — 2026-08-04)

| ID | Path / Canonical | Status |
|----|------------------|--------|
| paramodel | `projects/paramodel/` | **HOLD** |
| printguard / makerfac / blender / coin-s | `projects/*` | **HOLD** |
| excelion / excelion-forge | GitHub canonical | **HOLD** |

## Open (platform only)

- none  
- historical Cline text in archive / old process docs: leave

## Recent hygiene (2026-08-04)

| ID | Change |
|----|--------|
| HYG-1..3 | pycache verify · D15→D30 · ROADMAP banner |
| HYG-4 | ROLE_SPLIT · GLOSSARY · 05_AGENTS · PROJECT_STATE_SCHEMA |
| HYG-5 | ATLAS_MIN_SCOPE · AGENT_REGISTRY · CONTEXT_INDEX |

## Do not

- 하위 프로젝트 feature 재개 (명시 지시 전)  
- dual-write product paths  
- core SDK rewrite / extension 부활  
- Cline / .clinerules 재도입

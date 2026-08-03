# CURRENT_STATE

ACTIVE_TARGET: **idle** (platform)  
PRODUCT: **hold** — excelion / excelion-forge 개별 진행 안 함 (Master 2026-07-31)  
SIDE: **paramodel** — `projects/paramodel/` Master-directed (2026-08-02)

## Direction

- Atlas = 플랫폼만 다룸  
- 제품 프로젝트는 저장소만 분리; **작업 시작하지 않음**  
- Atlas closeout 완료 (Master 2026-07-31)  
- ParaModel은 Atlas 내 side track (제품 hold와 별개)

## Platform (closed)

| Area | Status |
|------|--------|
| Min M1–M7 | Done |
| F1–F4 domain / path | Done + Evidence |
| P0–P3 ops | Done |
| R1–R7 review | Done |
| D28 repo split S0–S5 | Done |
| C1 / C3 closeout | Done |

## ParaModel (side track)

| Item | Status |
|------|--------|
| Path | `projects/paramodel/` |
| Addon | **v0.7.1** (GitHub main) |
| Design flow | Identity → Archetype → Size → Traits → Visual → Body |
| Size contract | sf = value / template.reference (humanoid ref 2.0) |
| Mesh import | v0.7.0 |
| Armature | SuperRobotRig procedural |
| Non-humanoid templates | planned |
| GLB assets | identical placeholder cubes |
| Local reinstall verify | **Open (PM-10)** — use v0.7.1 zip |

## Open

- PM-10: local pull → package v0.7.1 → Remove/Install → sf≈12.5 on brave-001
- Axis unify (slots vs bones) — open
- platform: maintenance only

## Do not

- excelion / forge product feature (hold)  
- dual-write into mono product paths  
- core SDK rewrite / extension 부활

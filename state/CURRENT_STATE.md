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
| Addon | **v0.5.0** (GitHub main) |
| PM-1..PM-8 | Done |
| PM-9 Basic armature | Superseded |
| PM-11 SuperRobotRig | **코드 반영 (v0.5.0)** — `para_model.blend` Append |
| Verified in Blender | Root + Slots + Parts OK |
| Armature in Outliner | **로컬 재설치 후 확인 필요** |

### Armature (2026-08-02)

- v0.5.0: 절차적 본 생성 제거 → `para_model.blend`의 `SuperRobotRig` Append
- 슬롯 id와 본 이름이 같으면 bone-parent 시도
- 조치: `git pull` → `package_addon.sh` → 애드온 Remove 후 재설치 → 패널 **v0.5.0 — SuperRobotRig** 확인

## Open

- paramodel SuperRobotRig 로컬 확인 (PM-10)
- platform: 없음 (maintenance only)

## Do not

- excelion / forge product feature (hold)  
- dual-write into mono product paths  
- core SDK rewrite / extension 부활

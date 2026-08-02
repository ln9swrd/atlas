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
| Addon | **v0.4.1** (GitHub main) |
| PM-1..PM-8 | Done |
| PM-9 Armature | **코드 반영됨 / 로컬 재현 실패 중** |
| Verified in Blender | Root + Slots + Parts OK |
| Armature in Outliner | **미확인** (사용자 보고 미생성) |

### Armature 이슈 (2026-08-02)

- 증상: Load 후 `ParaModel_Armature` / `armature_*` 없음  
- 가능 원인:  
  1. 로컬 `/mnt/d/Atlas`가 GitHub main보다 뒤처짐 → zip에 armature 코드 미포함  
  2. Blender에 구버전 애드온 잔존  
  3. `mode_set` 컨텍스트 실패 (v0.4.1에서 완화 시도)  
- 조치 권장: `git pull` → `package_addon.sh` → 애드온 Remove 후 재설치 → 패널 **v0.4.1** 확인

## Open

- paramodel armature 재현/수정 확인  
- platform: 없음 (maintenance only)

## Do not

- excelion / forge product feature (hold)  
- dual-write into mono product paths  
- core SDK rewrite / extension 부활

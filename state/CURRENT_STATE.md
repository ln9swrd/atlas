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
| Addon | **v0.7.0** (GitHub main) |
| PM-1..PM-8 | Done |
| PM-12 SuperRobotRig procedural | Done |
| Mesh import | **v0.7.0** via mesh_io (glb/gltf/obj/fbx/blend) |
| Armature | **SuperRobotRig procedural** (bone table, no blend dep) |
| blend 의존 | 없음 |
| Verified in Blender | Root + Slots + Parts OK (prior) |
| Armature / mesh in Outliner | **로컬 재설치 후 확인 필요 (PM-10)** |
| GLB assets | 전부 identical placeholder cube (24 verts 수준). 실제 mecha mesh 없음 |

### Mesh (2026-08-02 → v0.7.0)

- `mesh_io.py` + operators attach_parts mesh path 해결
- 규칙: `part.mesh` → `data/parts/meshes/{part_id}.glb` fallback
- 실패 시 placeholder cube
- brave-001: enabled 7 slots → 현재 7개 동일 cube 예상

### Armature (2026-08-02)

- SuperRobotRig 본 테이블 코드 하드코딩 → 직접 생성
- blend 파일 불필요

## Open

- paramodel 로컬 재설치 검증 (PM-10): pull → package_addon.sh → Remove/Install → v0.7.0 패널 + SuperRobotRig + mesh source 확인
- platform: 없음 (maintenance only)

## Do not

- excelion / forge product feature (hold)  
- dual-write into mono product paths  
- core SDK rewrite / extension 부활

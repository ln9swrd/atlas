# DEVELOPMENT_STATE_BASELINE — 2026-08-15

> Read-Only 조사 결과. Canon / Novel / Unreal Source / Asset / Blueprint 변경 없음.
> 목적: 현재 무엇이 실제로 되어 있고 앞으로 무엇을 해야 하는지 Git 기준선으로 남김.

---

## EXCELION CURRENT STATE

### Git

| 항목 | 값 | 상태 | 근거 | 검증 여부 |
|------|-----|------|------|----------|
| Branch | main (default) | — | GitHub default | — |
| HEAD | `eff9aa56e9ab18c520d57e3e80293eb76d6d8d66` | — | list_commits | — |
| Working Tree | clean (remote) | — | GitHub tree | — |
| Latest commit | fix: Excelion WASD input system (fallback axis + DefaultInput.ini) | IMPLEMENTED / UNVERIFIED | commit message: "Awaiting Windows compilation and PIE verification" | 미검증 |
| 직전 검증 커밋 | P5-4 Full Vertical Slice Integration | VERIFIED | CURRENT_STATE.md + proof scripts | 검증됨 (2026-08-15) |

**Input 관련 최근 변경 vs 이전 검증**
- U2-H Physical GUI Input: VERIFIED (W/S/A/D/Mouse/LMB/SpaceBar)
- 이후 커밋들 (1a806bbb ~ eff9aa56): Enhanced Input 분리 + fallback axis handlers
- 최신 변경은 **빌드/PIE 재검증 대기** 상태. 문서상 COMPLETE로 승격하지 않음.

---

### Unreal

| 항목 | 값 | 상태 | 근거 | 검증 여부 |
|------|-----|------|------|----------|
| Engine | UE 5.4 | LOCK | Excelion.uproject EngineAssociation "5.4" | — |
| Project | projects/excelion/game/Excelion/ | — | tree | — |
| Build | C++ 17 actions compile 성공 이력 있음 | VERIFIED (과거) | CURRENT_STATE 2026-08-14 | 과거 검증 |
| PIE | U1~P5-4 실기 통과 | VERIFIED | CURRENT_STATE + proof scripts | 검증됨 |
| Source 구조 | Character / Combat / AI / Boss / Game / UI / Data | IMPLEMENTED | Source/Excelion/* | 코드 존재 |
| Config | DefaultEngine / DefaultGame / DefaultInput | IMPLEMENTED | Config/ | 존재 |
| Character | AExcelionCharacter (Enhanced Input + fallback) | IMPLEMENTED / UNVERIFIED (최신 fallback) | ExcelionCharacter.h/cpp | 최신 fallback 미검증 |
| Input | IMC_Default, IA_Move/Look/Attack/Dash + AxisMappings | IMPLEMENTED / UNVERIFIED | Content/Input + DefaultInput.ini | 최신 변경 미검증 |
| Blueprint | BP_ExcelionCharacter, BP_ExcelionEnemy, BP_SethBoss, BP_ExcelionGameMode, WBP_ExcelionHUD 등 | IMPLEMENTED | Content/Blueprints | 존재 |
| Maps | NewMap, Untitled (OpenWorld 계열) | IMPLEMENTED | Content/Maps | 존재 |
| Content 추적 | Blueprints / Input / Data / Maps / Scripts 추적됨 | — | tree | — |

**주의**: 문서에 "구현됨"이라고 적혀 있어도 최신 Input fallback 변경은 별도 빌드+PIE 검증이 필요하다.

---

### Prototype

| 항목 | 상태 | 근거 | 검증 여부 |
|------|------|------|----------|
| Player Spawn | VERIFIED | P5-4 Scenario A/B | 검증됨 |
| Character Control | VERIFIED (U2-H) / 최신 fallback UNVERIFIED | U2-H + 이후 Input 커밋 | 혼합 |
| Input | VERIFIED (U2-H) → 이후 변경으로 IMPLEMENTED / UNVERIFIED | U2-H PASS 후 fallback 추가 | 재검증 필요 |
| Camera | IMPLEMENTED | SpringArm + FollowCamera | 코드 존재, 별도 PIE 항목 없음 |
| Movement | VERIFIED | U1 / U2-H | 검증됨 |
| Combat | VERIFIED | U2 Core Combat | 검증됨 |
| Enemy | VERIFIED | U3-2a Chase, U3-2b Hit/Death | 검증됨 |
| Damage | VERIFIED | U3-2b-1 Single Hit | 검증됨 |
| Death | VERIFIED | U3-2b-2 Lethal, U4-B-5 | 검증됨 |
| Restart / Retry | VERIFIED | P5-3 Retry Level Travel | 검증됨 |
| PIE | VERIFIED (P5-4까지) | 다수의 proof scripts | 검증됨 |
| Victory / Defeat | VERIFIED | P5-1 / P5-2 | 검증됨 |
| Full Vertical Slice Loop | VERIFIED | P5-4 8/8 | 검증됨 |

**HTML Prototype (v1~v4)**: 별도 존재. Unreal Prototype과 분리. v4 패턴 시스템 등 참고용.

---

### Story / Canon

| 항목 | 상태 | 근거 | 검증 여부 |
|------|------|------|----------|
| Canon | LOCK (다수 문서) | design/CANON_HIERARCHY, SUPER_ROBOT_DESIGN_LANGUAGE, OFFICIAL_SETTING 등 | 문서 기준 |
| Novel | EP01~EP24 본문 + 보조 문서 | novel/ | 존재 |
| Episode | EP1–24 매트릭스·씬 스크립트 | EPISODE_MATRIX, conti/, state/*_SCENE_SCRIPT | 존재 |
| Character | Official Setting 완료 (lia/kai/seth/yuna/rei + ORD) | design/character/*/OFFICIAL_SETTING.md | 문서 |
| Mecha | BRAVE/AXION, Seth, ORD, Nemesis 등 SPEC | design/mecha/, design/enemy/ | 문서 |
| Mission / Gameplay Mapping | 부분 존재, 체계적 Story→Gameplay Dependency Mapping 미완 | NOVEL_TO_GAMEPLAY_READINESS, VERTICAL_SLICE | 부분 |
| Canon Conflict | 조사 범위에서 신규 충돌 미발견 (기존 STORY_DESIGN_CONFLICTS 등 참고) | — | Master Decision 필요 시 보고 |

**Story → Gameplay Dependency Mapping 필요 여부**: YES (향후 PHASE 3 대상). 이번 작업에서는 신규 스토리 작성 없음.

---

### Production

| 항목 | 상태 | 근거 |
|------|------|------|
| Level | 최소 (NewMap/Untitled) | Content/Maps |
| Animation | NOT STARTED (placeholder) | assets/animations/.gitkeep |
| Mecha (3D) | NOT STARTED / HOLD | Meshy→Blender 파이프라인 문서만 |
| Environment | NOT STARTED | design/env 설명만 |
| VFX | NOT STARTED | assets/vfx/.gitkeep |
| Audio | NOT STARTED | assets/audio README |
| UI | Minimal HUD VERIFIED | WBP_ExcelionHUD |

---

## 개발 로드맵 (현재 상태 기준 제안)

기존 `docs/` 로드맵을 임의 수정하지 않음. 아래는 **조사 결과 기반 제안**.

```
PHASE 0  Current State Baseline          ← 본 문서 (Done)
    ↓
PHASE 1  Prototype Completion            ← Input fallback 재검증 + 잔여 안정화
    ↓
PHASE 2  Core Gameplay Lock              ← Combat/Enemy/Boss/GameLoop 이미 VERIFIED → Lock 선언 가능
    ↓
PHASE 3  Story → Gameplay Dependency Mapping
    ↓
PHASE 4  Vertical Slice (콘텐츠 확장)    ← EP1/6/8 또는 Seth VS 기준 콘텐츠 보강
    ↓
PHASE 5  Level Production Pipeline
    ↓
PHASE 6  Animation / Motion Pipeline     ← IK Rig + Pose Library + NLA 방향
    ↓
PHASE 7  Content Production
    ↓
PHASE 8  Visual Polish
    ↓
PHASE 9  QA / Optimization
```

### Existing vs Current

| Existing (문서) | Current Development State |
|-----------------|---------------------------|
| VERTICAL_SLICE: Seth + AXION, 5~10분 | P5-4까지 Game Loop VERIFIED. 콘텐츠/비주얼은 최소 |
| ORD-GRUNT HOLD | 유지 (DECISION C) |
| Meshy→Blender→UE 파이프라인 | 문서만, 구현 HOLD |
| Input VERIFIED (U2-H) | 이후 fallback 변경 → 재검증 필요 |

---

## 디자인 우선순위 원칙

```
Gameplay Requirement
        ↓
Required Design
        ↓
Minimum Production
        ↓
Validation
        ↓
Expansion
```

현재 단계에서는 최종 메카 디테일·대규모 환경·대량 애니메이션·최종 VFX·최종 폴리싱을 선행하지 않는다.  
**Vertical Slice에 필요한 디자인만** 로드맵에 포함.

---

## Vertical Slice 후보

| 후보 | 근거 | 필요한 시스템 | 필요한 레벨 | 필요한 메카 | 필요한 애니메이션 | 미확정 |
|------|------|---------------|-------------|-------------|-------------------|--------|
| Seth Boss Arena (현재 P5-4 기반) | P5-4 VERIFIED, VERTICAL_SLICE.md 정합 | Combat, Boss Phase, GameLoop (있음) | 1 arena (최소) | AXION + Seth (placeholder OK) | 최소 포즈/히트 | 맵 테마, S-Core 명칭 |
| EP1 / EP6 / EP8 연계 | state/VERTICAL_SLICE_EP1_6_8.md | 동일 + 스토리 훅 | 동일 | 동일 | 동일 | Story mapping |

후보가 명확하므로 억지 선정 없이 **Seth VS Arena**를 1차 후보로 유지.

---

## Unreal / Blender 생산 파이프라인 (기록)

### Blender
- Unique Asset, Mecha, Character, Rig, Animation, Pose, Modular Asset

### Unreal
- Level Assembly, Landscape, PCG, Lighting, Collision, Gameplay Volume, Spawn, AI, PIE

### Unreal MCP
- 가능한 범위 검토 대상: Editor inspection, Asset manipulation, Level assembly, Blueprint ops, Build/PIE verification
- **실제 MCP 기능 미확인 상태에서는 지원 확정하지 않음**

---

## Animation 방향 (기록만)

```
IK Rig + Pose Library + Action + NLA + Asset Browser
```

목표: 검증된 포즈/동작 재사용으로 모션 생산. 이번 작업에서 Blender Asset/Rig 수정 없음.

---

## 발견된 문제 / Master 결정 필요

1. **Input fallback 변경** — 코드 완료, Windows 빌드 + PIE 미검증 → COMPLETE 아님.
2. **ORD-GRUNT** — DECISION C = HOLD 유지. 후속 자율 착수 금지.
3. **Story → Gameplay Dependency Mapping** — 필요 상태. 체계적 작업은 PHASE 3.
4. **콘텐츠/프로덕션** — Gameplay 시스템은 VERIFIED 수준, 비주얼/애니/레벨은 최소.

변경하지 않은 것: Canon, Novel, Unreal 구현, Asset, Blueprint, C++ (조사만).

---

## NEXT

1. **Input fallback 재검증** (Windows Build + PIE) — 최우선
2. Core Gameplay Lock 선언 여부 Master 확인
3. Story→Gameplay Dependency Mapping 착수 시점 결정
4. Vertical Slice 콘텐츠 보강 범위 확정 (맵/비주얼 최소 요구)

선행 조건: Input 재검증 통과 또는 Master 지시.
검증 필요: 최신 Input 변경분 빌드/PIE.

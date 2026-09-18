# CORE_GAMEPLAY_IMPLEMENTATION_GAP_AUDIT — Excelion

> 2026-08-16 · READ-ONLY 조사 + 문서화 전용  
> Canon / Novel / Unreal / Blueprint / Asset / Input / ORD-GRUNT **변경 없음**  
> 목적: P5-4 Vertical Slice VERIFIED 이후 Core Gameplay에 **실제로 남은 작업**을 Git 기준으로 확정

**상태: Gap Audit 완료 · Core Gameplay Lock = 보류 (조건 미충족)**

---

## STATUS

### 완료
- Core Gameplay Matrix
- P5-4 VERIFIED 범위 정리
- P5-4 이후 변경사항
- 미완료 / Editor-required / 구현 필요 항목
- Core Gameplay Lock 가능 조건
- VS 완성까지 최소 작업

### 판정 규칙 (본 문서)

| 라벨 | 의미 |
|------|------|
| **VERIFIED** | 문서에 PIE/Build 실기 통과 기록이 있음 |
| **IMPLEMENTED / UNVERIFIED** | 코드·에셋 존재, 최신 변경 또는 재검증 없음 |
| **MISSING** | 코드/에셋/콘텐츠 없음 |
| **BLOCKED** | 선행 조건 또는 환경 때문에 진행 불가 |
| **NOT APPLICABLE** | 현재 VS 범위 밖 |

코드 존재만으로 VERIFIED 하지 않음.

### 변경하지 않은 것
- Canon · Novel · Unreal · Blueprint · Asset · Animation · VFX · Audio · Input · ORD-GRUNT · Design

---

## 1. Core Gameplay Matrix

### 1.1 Player

| 항목 | 상태 | 근거 |
|------|------|------|
| Character (AExcelionCharacter / BP) | VERIFIED (P5-4 시점) | U1 · P5-4 |
| Movement | VERIFIED | U1 / U2-H |
| Camera (SpringArm + Follow) | IMPLEMENTED / UNVERIFIED | 코드 존재 · 단독 PIE 항목 없음 |
| Possession | VERIFIED | P5-4 Scenario A/B |
| Spawn | VERIFIED | P5-4 |

### 1.2 Input

| 항목 | 상태 | 근거 |
|------|------|------|
| Enhanced Input (IMC / IA) | VERIFIED (U2-H 시점) | U2-H Physical GUI Input |
| Axis fallback (WASD / DefaultInput.ini) | **IMPLEMENTED / UNVERIFIED** | commit `eff9aa56` 이후 Build+PIE 대기 |
| 최신 Input 전체 회귀 | **IMPLEMENTED / UNVERIFIED** | P5-4 이후 Input 커밋 다수 |

### 1.3 Combat

| 항목 | 상태 | 근거 |
|------|------|------|
| Attack | VERIFIED | U2 Core Combat |
| Damage | VERIFIED | U3-2b-1 |
| Hit detection | VERIFIED | U2 / U3 |
| Cooldown | VERIFIED (시스템 존재·검증 범위 내) | U2 |
| Player ↔ Boss interaction | VERIFIED | U4-B · P5-4 |
| Dash invulnerability | VERIFIED | U4-B-4 |

### 1.4 Boss (SETH)

| 항목 | 상태 | 근거 |
|------|------|------|
| BP_SethBoss / ASethBoss | VERIFIED | U4-B-0~5 |
| Boss HP (480) | VERIFIED | U4-B-1 |
| Phase 1 / Phase 2 | VERIFIED | U4-B-1 · U4-B-2 |
| Pattern 01 / 02 | VERIFIED | U4-B-1 · U4-B-3 |
| Death | VERIFIED | U4-B-5 |
| Encounter flow (VS loop) | VERIFIED | P5-4 |
| Final mecha mesh / anim | **MISSING** | assets 없음 · Three-view만 APPROVED |

### 1.5 Game Loop

| 항목 | 상태 | 근거 |
|------|------|------|
| Start / Playing | VERIFIED | P5-0 · P5-4 |
| Combat loop | VERIFIED | P5-4 |
| Victory | VERIFIED | P5-1 · P5-4 A |
| Defeat | VERIFIED | P5-2 · P5-4 B |
| Restart / Retry | VERIFIED | P5-3 · P5-4 B |

### 1.6 HUD

| 항목 | 상태 | 근거 |
|------|------|------|
| Player HP | VERIFIED | P5 / U3 |
| Boss HP | VERIFIED | P5 / U4 |
| Game state UI | VERIFIED (최소) | WBP_ExcelionHUD · P5 |
| Result / Restart UI | VERIFIED (최소 흐름) | P5-1~3 |
| Polish UI | MISSING | 프로덕션 비주얼 아님 |

### 1.7 Level

| 항목 | 상태 | 근거 |
|------|------|------|
| GameDefaultMap (NewMap) | IMPLEMENTED | DefaultEngine.ini · Content/Maps |
| Spawn (기존 맵) | VERIFIED (P5-4 맵 기준) | P5-4 |
| Collision / Arena blockout | **IMPLEMENTED / UNVERIFIED** | T1 문서 · 맵 바이너리 미확인 |
| Lighting (최소) | UNKNOWN / UNVERIFIED | T1 |
| T1 Seth Arena Blockout | **IMPLEMENTED / UNVERIFIED** | T1_SETH_ARENA_BLOCKOUT_STATUS · Editor 필요 |
| 전용 Arena 맵 존재 여부 | UNKNOWN | 바이너리 내부 확인 불가 |

### 1.8 Story → Gameplay

| 항목 | 상태 | 근거 |
|------|------|------|
| Story→Gameplay Dependency Map | 문서 COMPLETE | STORY_GAMEPLAY_DEPENDENCY_MAP |
| VS A (Seth Arena) 채택 | APPROVED | 후보 리뷰 · Spec |
| VS에 구현된 스토리 연출 | **MISSING** / 최소 | P5-4는 시스템 루프 중심 |
| EP1/6/8 연계 구현 | NOT APPLICABLE (후보 B 보류) | — |

---

## 2. P5-4 VERIFIED 범위 (고정 기록)

`CURRENT_STATE.md` · proof scripts 기준 (2026-08-15):

```text
Scenario A: Spawn → Enemy Combat → Boss Combat → Victory
Scenario B: Spawn → Player Death → Defeat → Retry reset
8/8 PASS · P5-4 FULL VERTICAL SLICE INTEGRATION — VERIFIED
```

포함으로 간주되는 시스템:

- Player spawn / control (당시 Input)
- Enemy chase · hit · death
- Seth Phase 1/2 · patterns · death
- Damage · invuln dash
- GameMode state: Playing / Victory / Defeat / Retry
- Minimal HUD + delegates

**포함되지 않음:**

- 최종 메카 Mesh / Animation / VFX / Audio
- 전용 Arena 비주얼 블록아웃 (T1)
- Input fallback 이후 코드 (`eff9aa56` 계열)
- ORD-GRUNT
- Core Gameplay Lock 선언 자체

---

## 3. P5-4 이후 변경사항 (Git)

| 구분 | 내용 | 영향 |
|------|------|------|
| Input 커밋 연쇄 | Enhanced Input 분리 · Axis fallback · DefaultInput.ini | **회귀 검증 필요** |
| 최신 game 커밋 | `eff9aa56` — “Awaiting Windows compilation and PIE verification” | Input = IMPLEMENTED / UNVERIFIED |
| 문서 작업 | VS Spec · T1~T9 readiness · Reference · Mesh Plan 등 | 구현 코드 변경 아님 |
| T1 | 상태 문서만 · 맵 바이너리 미수정 | Level = UNVERIFIED |
| Mesh / Three-view | Reference APPROVED · Mesh 파일 없음 | 콘텐츠 MISSING |

**충돌:** P5-4 VERIFIED와 “Input COMPLETE”를 동일시하면 안 됨.  
P5-4 시점 Input(U2-H)은 VERIFIED · **이후 fallback 변경은 별도 UNVERIFIED**.

---

## 4. 현재 미완료 요약

### 시스템 (Core)

| 우선 | 항목 | 상태 |
|------|------|------|
| P0 | Input fallback 재검증 | IMPLEMENTED / UNVERIFIED · **EDITOR_REQUIRED** |
| P0 | T1 Arena blockout PIE | IMPLEMENTED / UNVERIFIED · **EDITOR_REQUIRED** |
| P1 | Core Gameplay Lock 선언 | 보류 |
| — | Combat / Boss / Loop / HUD 핵심 | **VERIFIED** (P5-4) |

### 콘텐츠 (VS 보강)

| 항목 | 상태 |
|------|------|
| AXION / SETH Mesh | NOT STARTED (Plan APPROVED · 로컬 도구) |
| Animation / Skeleton | BLOCKED (Mesh 후) |
| VFX / Audio | MISSING |
| Level 비주얼 | UNVERIFIED / 최소 |

### HOLD

| 항목 | 상태 |
|------|------|
| ORD-GRUNT | HOLD (DECISION C) |
| Input을 이유로 전 시스템 재작성 | 하지 않음 |

---

## 5. Editor-required 항목

| 작업 | 이유 |
|------|------|
| Input fallback Build + PIE | Windows + UE 5.4 |
| T1 Geometry / Spawn / Collision / PIE | `.umap` 바이너리 |
| P5-4 시나리오 재실행 (회귀) | 권장 |
| Mesh import 후 스폰 확인 | 이후 단계 |

에이전트 Git-only 세션에서는 위 항목 **실행 불가**.

---

## 6. 실제 구현이 필요한 항목 (코드 추가 관점)

현재 Core 루프 기준:

- **필수 신규 시스템 코드:** 거의 없음 (P5-4로 루프 VERIFIED)
- **필수 재검증:** Input fallback
- **필수 콘텐츠:** Mesh → (후) Skeleton/Anim · (선택) VFX/Audio · T1 공간
- **필수 아님 (지금):** ORD-GRUNT · EP1/6/8 전체 연출 · Core 구조 개편

---

## 7. Core Gameplay Lock 가능 조건

Lock = “핵심 전투·루프·입력 구조를 함부로 흔들지 않음” 선언.

**권고 선행 조건:**

1. Input fallback **Windows Build + PIE PASS** → Input VERIFIED 복귀  
2. (권장) P5-4 Scenario A/B **회귀 1회 PASS**  
3. Master가 Lock 범위 명시 (예: CombatComponent · GameMode state · Boss HP/Phase 수치 동결)

**Lock 전에도 가능한 것:**

- Mesh / Reference / 문서 작업 (이미 진행)
- T1 로컬 검증
- 콘텐츠 파이프라인

**Lock 전에 하지 말 것:**

- Combat/Boss/GameLoop 대규모 리팩터
- Input 추가 개편 (재검증 전)

---

## 8. Vertical Slice 완성까지 남은 최소 작업

시스템 VS(P5-4)는 **이미 VERIFIED**. “플레이 가능 데모 완성” 기준 최소:

```text
1. Input fallback 재검증          EDITOR
2. T1 Arena blockout VERIFIED    EDITOR
3. AXION P0 Mesh (+ 검수)        로컬 3D
4. SETH P0 Mesh (+ 검수)         로컬 3D
5. (선택) 최소 배치/스케일 확인   UE Import
6. P0 Animation                  Mesh 후
7. (선택) 최소 VFX/Audio         후순위
```

Skeleton/Animation/VFX는 **시스템 Gap이 아니라 콘텐츠 Gap**.

---

## 9. 선행 문서

| 문서 | 역할 |
|------|------|
| CURRENT_STATE.md | P5-4 VERIFIED 원장 |
| DEVELOPMENT_STATE_BASELINE_2026-08-15.md | Input UNVERIFIED 명시 |
| T1_SETH_ARENA_BLOCKOUT_STATUS.md | Level UNVERIFIED |
| SETH_BOSS_ARENA_* | VS 제작 분해 |
| AXION_SETH_MESH_PRODUCTION_PLAN.md | Mesh Plan APPROVED |

---

## NEXT

### 실제 남은 작업 우선순위 (권고)

| 순위 | 작업 | 환경 |
|------|------|------|
| 1 | Input fallback Build + PIE | Windows UE |
| 2 | T1 Arena PIE | Windows UE |
| 3 | Core Gameplay Lock 여부 Master 결정 | 문서 |
| 4 | AXION P0 Mesh | 로컬 Meshy/Blender |
| 5 | SETH P0 Mesh | 동상 |
| 6 | Mesh 후 Skeleton / P0 Anim | 3D + UE |

### Master 결정 필요

- Input 재검증 전 Lock 허용 여부 (권고: **비허용**)
- T1과 Input 중 로컬 우선순위
- Mesh와 UE 검증의 병행 여부

**본 문서는 조사만 수행한다. 구현·Lock 선언이 아니다.**

# VERTICAL_SLICE_COMPLETION_DEPENDENCY_PLAN — Excelion

> 2026-08-16 · READ-ONLY 조사 + 문서화 전용  
> Canon / Novel / Unreal / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT / Design **변경 없음**  
> 목적: Core Gameplay Gap Audit + Mecha Production Plan을 통합해 **VS 완성 dependency · 트랙 분리 · P0 우선순위**를 고정

**상태: Dependency Plan 완료 · 구현 착수 지시 아님**

---

## STATUS

### 완료
- dependency graph
- TRACK A / TRACK B 분리
- 병렬 · 순차 분류
- P0 / P1 / P2 분류
- 최소 Vertical Slice 조건
- Core Gameplay Lock 조건
- 지금 가능 / 도구 대기 분리

### 현재 기준선 (입력)

| 항목 | 상태 |
|------|------|
| P5-4 Core Gameplay | **VERIFIED** |
| Input fallback | IMPLEMENTED / UNVERIFIED |
| T1 Arena | IMPLEMENTED / UNVERIFIED |
| Core Gameplay Lock | **보류** |
| AXION / SETH Three-view | **APPROVED** |
| Mesh Production Plan | **MASTER APPROVED** |
| AXION P0 Mesh | NOT STARTED |
| SETH P0 Mesh | HOLD |
| Skeleton / Animation | BLOCKED |
| VFX / Audio / Story Presentation | MISSING |
| ORD-GRUNT | HOLD |

### 변경하지 않은 것
- Canon · Novel · Unreal · Blueprint · Asset · Design

---

## 1. Dependency Graph (요약)

```text
                    ┌─────────────────────────────┐
                    │  P5-4 Core Systems VERIFIED │
                    └──────────────┬──────────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
          ▼                        ▼                        ▼
   TRACK A                    (공유 없음)              TRACK B
 Gameplay Validation                               Content Production
          │                                              │
          ├─ Input fallback 재검증                        ├─ AXION P0 Mesh
          │     EDITOR                                    │     MESHY/BLENDER
          ├─ T1 Arena VERIFIED                            ├─ AXION Review
          │     EDITOR                                    ├─ SETH P0 Mesh
          ├─ P5-4 회귀 (권장)                              ├─ Skeleton
          │     EDITOR                                    ├─ P0 Animation
          └─ Core Gameplay Lock                           ├─ VFX / Audio (최소)
                Master                                    └─ VS Presentation
                                   │
                                   ▼
                    ┌──────────────────────────────┐
                    │  VS 통합 검증 (UE PIE)        │
                    │  systems + content on map    │
                    └──────────────────────────────┘
```

**핵심:** TRACK A와 TRACK B는 **서로 강하게 의존하지 않음**. 도구가 되는 쪽부터 진행 가능.

---

## 2. TRACK A — GAMEPLAY VALIDATION

| ID | 작업 | 선행조건 | 도구 | Editor | 3D | Master 승인 | 검증 | 완료 정의 | 우선 |
|----|------|----------|------|--------|-----|-------------|------|-----------|------|
| A1 | Input fallback 재검증 | 코드 `eff9aa56` 존재 | UE 5.4 Windows | **Y** | N | 범위만 (이미 지시됨) | Build + PIE WASD/Axis | Input → **VERIFIED** | **P0** |
| A2 | T1 Arena blockout PIE | T1 체크리스트 | UE 5.4 | **Y** | N | T1 범위 승인됨 | Spawn/이동/Seth 공간 | T1 → **VERIFIED** | **P0** |
| A3 | P5-4 회귀 (권장) | A1 권장 선행 | UE 5.4 | **Y** | N | 선택 | Scenario A/B 재PASS | 회귀 기록 | **P0** |
| A4 | Core Gameplay Lock | **A1 PASS 필수** · A3 권장 | 문서 | N | N | **필수** | Lock 문서 선언 | Lock 상태 | **P0** |

### TRACK A 순차 규칙

```text
A1 Input → (권장 A3 회귀) → A4 Lock
A2 T1 은 A1과 병렬 가능 (둘 다 Editor)
```

**권고 (고정):** Input fallback 실기 PASS 없이 Core Gameplay Lock **선언하지 않음**.

---

## 3. TRACK B — CONTENT PRODUCTION

| ID | 작업 | 선행조건 | 도구 | Editor | Meshy/Blender | Master 승인 | 검증 | 완료 정의 | 우선 |
|----|------|----------|------|--------|---------------|-------------|------|-----------|------|
| B1 | AXION P0 Mesh | Three-view APPROVED · Plan APPROVED | Meshy(선택)+Blender | N* | **Y** | 착수 승인됨 · 산출물 Review | 25m·피벗·F/S/R | Mesh 파일 + Review | **P0** |
| B2 | AXION Mesh Master Review | B1 | — | N | N | **필수** | 체크리스트 | APPROVED | **P0** |
| B3 | SETH P0 Mesh | B2 APPROVED | 동일 | N* | **Y** | 별도 착수 | ≈30m·손·민등 | Mesh + Review | **P0** |
| B4 | SETH Mesh Master Review | B3 | — | N | N | **필수** | 체크리스트 | APPROVED | **P0** |
| B5 | Skeleton (공통 humanoid) | B2 (최소) · 권장 B4 | Blender | N | **Y** | 계층 확정 | 본 계층·스케일 | Skeleton 존재 | **P0** |
| B6 | P0 Animation | B5 | Blender+UE | 일부 | **Y** | 범위 | Idle/Move/Attack/Hit | 클립 재생 | **P0** |
| B7 | 최소 VFX | 전투 루프 존재 | UE Niagara | **Y** | N | 범위 | 타격 가독 | 최소 이펙트 | **P1** |
| B8 | 최소 Audio | 동일 | UE | **Y** | N | 범위 | 타격/UI | 최소 사운드 | **P1** |
| B9 | VS Presentation | A2·B6 권장 | UE | **Y** | N | 범위 | 플레이 체감 | 데모 가능 | **P1** |

\* Mesh 후 UE Import 검증은 Editor 필요 (별도 게이트).

### TRACK B 순차 규칙

```text
B1 → B2 → B3 → B4 → B5 → B6
B7 / B8 는 B6 이후 또는 병렬(플레이스홀더 허용 시)
B9 는 A2 + B6 이후가 이상적
```

Meshy 출력 = 최종 Mesh **금지** (Plan 유지).

---

## 4. 병렬 vs 순차

### 병렬 가능

| 조합 | 조건 |
|------|------|
| A1 ↔ A2 | 둘 다 UE · 충돌 적음 |
| A1/A2 ↔ B1 | UE vs 3D 도구 분리 |
| B7 ↔ B8 | 콘텐츠 독립 |

### 반드시 순차

| 순서 | 이유 |
|------|------|
| A1 → A4 | Lock 전 Input VERIFIED |
| B1 → B2 → B3 | AXION 파이프라인 검증 후 SETH |
| B2/B4 → B5 | Skeleton은 Mesh 정합 후 |
| B5 → B6 | Animation은 Skeleton 후 |
| (권장) A2 + B6 → VS 통합 | 공간 + 모션 |

---

## 5. 최소 Vertical Slice 완성 조건

**시스템 VS (이미 충족):** P5-4 VERIFIED.

**데모 가능 VS (목표 최소):**

| # | 조건 | 트랙 |
|---|------|------|
| 1 | Input **VERIFIED** (fallback 포함) | A |
| 2 | T1 Arena **VERIFIED** (싸울 공간) | A |
| 3 | AXION P0 Mesh APPROVED (또는 placeholder 명시 허용 시 Master 예외) | B |
| 4 | SETH P0 Mesh APPROVED (동상) | B |
| 5 | 스폰·전투·Victory/Defeat/Retry 동작 (P5-4 회귀) | A |
| 6 | (권장) P0 Idle/Attack/Hit 가독 | B |

**최소에서 제외 (P1/P2):** 최종 텍스처 · 풀 애니 세트 · 스토리 컷신 · ORD-GRUNT · 고밀도 VFX.

Placeholder Mesh로 통합 검증을 허용할지는 **Master 예외 승인** 사항 (기본 Plan은 Three-view 후 실 Mesh).

---

## 6. Core Gameplay Lock 선행조건

| 조건 | 필수 |
|------|------|
| Input fallback Build + PIE **PASS** | **예** |
| P5-4 Scenario A/B 회귀 PASS | 권장 |
| Master가 Lock 범위 명시 (Combat/GameMode/Boss 수치 등) | **예** |
| T1 VERIFIED | 아니오 (Lock과 분리 가능) |
| Mesh APPROVED | 아니오 |

Lock 이후: 핵심 전투·루프·입력 **구조 변경 자제** · 콘텐츠(Mesh/Anim/VFX)는 계속 가능.

---

## 7. 지금 할 수 있는 것 vs 대기

### 도구 없이 가능한 것 (현재 에이전트/문서)

- 본 Plan · 상태 문서 유지
- Master 결정 대기 목록 정리
- (추가 조사 남발 금지 — **조사 단계 종료**)

### EDITOR_REQUIRED (Windows UE 5.4)

- A1 Input 재검증
- A2 T1 PIE
- A3 P5-4 회귀
- UE Import 후 스폰 확인
- B7/B8/B9 적용·검증

### BLENDER / MESHY_REQUIRED

- B1 AXION P0 Mesh
- B3 SETH P0 Mesh
- B5 Skeleton
- B6 P0 Animation (Blender 측)

### BLOCKED

- Skeleton / Animation ← Mesh APPROVED 전
- ORD-GRUNT ← HOLD
- SETH Mesh ← AXION Review 전

---

## 8. P0 / P1 / P2

| 등급 | 항목 |
|------|------|
| **P0** | A1 Input · A2 T1 · A3 회귀(권장) · A4 Lock · B1–B6 Mesh→Anim 최소 경로 |
| **P1** | B7 VFX · B8 Audio · B9 Presentation · UI polish |
| **P2** | 최종 텍스처 · 풀 모션 · 스토리 연출 · LOD · ORD |

---

## 9. 권고 실행 순서 (도구 허용 시)

**이상적 순차:**

```text
Input 검증 → T1 검증 → (회귀) → Core Gameplay Lock
→ AXION Mesh → SETH Mesh → Rig → P0 Anim
→ 최소 VFX/Audio → VS 통합
```

**병렬 현실안:**

```text
UE 가능 시:     A1 + A2
3D 가능 시:     B1 (AXION Mesh)
둘 다 가능 시:  A1 ∥ B1 동시
```

---

## 10. 선행 문서

| 문서 | 역할 |
|------|------|
| CORE_GAMEPLAY_IMPLEMENTATION_GAP_AUDIT | 시스템 Gap |
| AXION_SETH_MESH_PRODUCTION_PLAN | Mesh 계약 |
| AXION_P0_MESH_PRODUCTION_STATUS | Mesh NOT STARTED |
| T1_SETH_ARENA_BLOCKOUT_STATUS | T1 UNVERIFIED |
| CURRENT_STATE / DEVELOPMENT_STATE_BASELINE | P5-4 · Input |

---

## NEXT

### 현재 환경에서 가능한 P0
- **없음 (실행)** — UE · Blender/Meshy 없음 → 문서·결정만
- 조사 추가 양산 **중단**

### 도구 사용 가능 시 첫 작업
| 환경 | 첫 P0 |
|------|--------|
| Windows UE only | **A1 Input fallback 재검증** |
| Blender/Meshy only | **B1 AXION P0 Mesh** |
| Both | A1 ∥ B1 |

### Master 결정 필요
- Lock 범위 문구 (A1 통과 후)
- Placeholder Mesh로 통합 허용 여부 (기본: 비허용)
- A1 vs A2 로컬 우선순위

**본 문서로 “무엇을 조사할까” 단계는 종료한다. 이후는 승인된 P0 실행만.**

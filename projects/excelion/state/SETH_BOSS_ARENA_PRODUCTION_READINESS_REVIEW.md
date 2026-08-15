# SETH_BOSS_ARENA_PRODUCTION_READINESS_REVIEW — Excelion

> 2026-08-16 · READ-ONLY 조사 + 문서화 전용
> Canon / Novel / Unreal C++ / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT / Level **변경 없음**
> 목적: T1 IMPLEMENTED/UNVERIFIED 유지 상태에서 T2~T9의 선행조건·재사용·신규·UNKNOWN·EDITOR_REQUIRED·BLOCKED만 조사
> **T2~T9 실제 구현 수행하지 않음**

**상태: Readiness Review 완료 · T1 VERIFIED 대기 · T2 착수 승인 대기**

---

## STATUS

### 완료
- T2~T9 readiness 조사
- 재사용 가능 요소 조사 (P5-4 VERIFIED 기준)
- 신규 제작 요소 조사
- BLOCKED / EDITOR_REQUIRED 분류
- 문서 저장: 본 파일
- Commit

### 현재 기준 (고정)
| 항목 | 상태 |
|------|------|
| VS Candidate A: Seth Boss Arena | APPROVED |
| Minimum Production Spec | APPROVED |
| T1 Level Blockout | IMPLEMENTED / UNVERIFIED |
| T2 | HOLD |
| Input fallback | IMPLEMENTED / UNVERIFIED |
| ORD-GRUNT | HOLD |
| Core Gameplay Lock | 보류 |

### 미확인
- NewMap/Untitled 내부 Arena 공간·Collision·Lighting 상세 (바이너리)
- BP_SethBoss / BP_ExcelionCharacter 맵 배치 여부
- 실제 Animation / VFX / Audio 에셋 내용 (파일 없음)
- Input fallback 최신 회귀 (Windows Build + PIE)
- Camera polish / HitStop 체감

### BLOCKED
- T2~T9 구현 전체 (T1 VERIFIED 전)
- ORD-GRUNT 관련 항목 (HOLD)

### EDITOR_REQUIRED
- T1 실기 검증 (체크리스트)
- T2 배치 및 기존 Gameplay 연결 확인
- T3~T8 모든 검증 단계
- Animation / VFX / Audio 적용 및 PIE 확인

### Master 결정 필요
- T1 VERIFIED 여부 (로컬 UE 5.4 실기 후)
- T1 VERIFIED 후 T2 착수 승인 여부
- Placeholder 품질 세부 기준 (이미 Spec에 명시된 범위 내)
- Input fallback 재검증 시점

---

## 근거 문서 (읽기 전용)

- state/SETH_BOSS_ARENA_PRODUCTION_TASK_BREAKDOWN.md
- state/SETH_BOSS_ARENA_MINIMUM_PRODUCTION_SPEC.md
- state/T1_SETH_ARENA_BLOCKOUT_STATUS.md
- state/DEVELOPMENT_STATE_BASELINE_2026-08-15.md
- state/VERTICAL_SLICE_CANDIDATE_REVIEW.md
- state/CURRENT_STATE.md (P5-4 VERIFIED 기록)

---

## P5-4 VERIFIED 재사용 가능 요소 (Git 기준)

| 요소 | 분류 | 근거 |
|------|------|------|
| AExcelionCharacter + BP_ExcelionCharacter | EXISTING / REUSE | Source + Content/Blueprints |
| ASethBoss + BP_SethBoss | EXISTING / REUSE | Source/Boss + Content/Blueprints |
| Phase 1→2 / Pattern 01·02 / Death | EXISTING / REUSE | SethBoss.h/cpp · U4-B VERIFIED |
| Movement · Dash · Combat · Damage | EXISTING / REUSE | ExcelionCharacter · CombatComponent · U2/U4 |
| GameMode · Victory/Defeat/Retry | EXISTING / REUSE | ExcelionGameMode · P5-1~P5-3 |
| HUD (WBP_ExcelionHUD) | EXISTING / REUSE | Content/Blueprints · UI |
| DA_AXION_Stats / DA_SethBoss_Stats | EXISTING | Content/Data |
| Input (IMC + IA + Axis fallback) | EXISTING / UNVERIFIED | Content/Input + DefaultInput.ini |
| Maps (NewMap / Untitled) | EXISTING | Content/Maps · GameDefaultMap |

---

## AXION / SETH 관련 기존 Blueprint·Asset

| 경로 | 존재 | 비고 |
|------|------|------|
| Content/Blueprints/BP_ExcelionCharacter.uasset | EXISTING | 플레이어 |
| Content/Blueprints/BP_SethBoss.uasset | EXISTING | 보스 |
| Content/Blueprints/BP_ExcelionGameMode.uasset | EXISTING | |
| Content/Blueprints/WBP_ExcelionHUD.uasset | EXISTING | |
| Content/Data/DA_AXION_Stats.uasset | EXISTING | |
| Content/Data/DA_SethBoss_Stats.uasset | EXISTING | |
| Animation 실파일 | 없음 | NOT STARTED (assets/animations/.gitkeep 수준) |
| VFX 실파일 | 없음 | NOT STARTED |
| Audio 실파일 | 없음 | NOT STARTED |

맵 내부 배치 여부: **UNKNOWN** (바이너리, Editor 필요).

---

## Animation / VFX / Audio Git 존재 여부

| 카테고리 | Git 상태 | 분류 |
|----------|----------|------|
| Animation | 실에셋 없음 | NEW |
| VFX | 실에셋 없음 | NEW |
| Audio | 실에셋 없음 | NEW |

Placeholder 허용 범위는 Minimum Spec / Task Breakdown에 명시된 조건부 허용을 따름.

---

## ORD-GRUNT / Input 의존성

| 항목 | 의존 | 상태 |
|------|------|------|
| T2~T9 중 ORD-GRUNT 의존 | 없음 | HOLD 유지 · VS 범위 제외 |
| Input fallback 의존 | T2 이동/공격, T8 통합 검증 | IMPLEMENTED / UNVERIFIED · 수정 금지 |

---

## T2~T9 상세 분석

### T2 — AXION / SETH 배치 + 기존 Gameplay 재사용 확인

| # | 항목 | 내용 |
|---|------|------|
| 1 | 목적 | 기존 VERIFIED 시스템이 Arena에서 동작하는지 확인 |
| 2 | 선행조건 | T1 완료 (VERIFIED 권장) |
| 3 | 현재 Git 존재 | BP_ExcelionCharacter, BP_SethBoss, GameMode, Spawn/Combat/Damage/Death 로직 |
| 4 | 재사용 | EXISTING / REUSE (시스템 전부) |
| 5 | 신규 | 맵 내 배치 위치 확정 (NEW 가능) |
| 6 | 확인 불가 | 맵 배치 여부 · Collision 상호작용 (UNKNOWN) |
| 7 | UE Editor 필요 | 예 (EDITOR_REQUIRED) |
| 8 | T1 VERIFIED 필수 | 예 → **BLOCKED** (현재) |
| 9 | 위험 | 맵 공간 부족 시 배치 실패 · Input 미검증으로 이동 불가 착각 |
| 10 | 검증 방법 | PIE: Spawn → 이동 → 공격 → 피격 → Phase → Death/Victory 핵심 경로 |

**분류 요약**: REUSE (로직) · NEW/UNKNOWN (배치) · BLOCKED · EDITOR_REQUIRED

---

### T3 — Boss Arena 전투 흐름

| # | 항목 | 내용 |
|---|------|------|
| 1 | 목적 | P5-4 / U4-B 전투 루프를 Arena에 고정 |
| 2 | 선행조건 | T2 완료 |
| 3 | 현재 Git 존재 | SethBoss Phase/Pattern/Death 로직 (VERIFIED 이력) |
| 4 | 재사용 | EXISTING / REUSE |
| 5 | 신규 | 없음 (로직 변경 금지) |
| 6 | 확인 불가 | Arena 공간에서의 실제 패턴 범위·거리 (UNKNOWN) |
| 7 | UE Editor 필요 | 예 (EDITOR_REQUIRED) |
| 8 | T1 VERIFIED 필수 | 간접 (T2 경유) → **BLOCKED** |
| 9 | 위험 | 공간 크기로 Pattern Radius/Range 불일치 |
| 10 | 검증 방법 | U4-B / P5-4 시나리오 재현 체크리스트 |

**분류 요약**: REUSE · BLOCKED · EDITOR_REQUIRED

---

### T4 — 최소 Animation

| # | 항목 | 내용 |
|---|------|------|
| 1 | 목적 | 이동·공격·피격·사망 시각 구분 |
| 2 | 선행조건 | T3 완료 (로직 안정) |
| 3 | 현재 Git 존재 | 없음 (NOT STARTED) |
| 4 | 재사용 | 없음 |
| 5 | 신규 | AXION Idle/Locomotion/Attack/Dash/Hit/Death · SETH Phase/Attack/Hit/Death 최소 (NEW) |
| 6 | 확인 불가 | Placeholder 포즈 품질 기준 세부 (UNKNOWN) |
| 7 | UE Editor 필요 | 예 (EDITOR_REQUIRED) |
| 8 | T1 VERIFIED 필수 | 간접 → **BLOCKED** |
| 9 | 위험 | 과도한 애니 제작으로 범위 확대 · 핵심 외형 변경 시도 |
| 10 | 검증 방법 | 상태 전환 시 시각적 피드백 존재 여부 |

**분류 요약**: NEW · BLOCKED · EDITOR_REQUIRED · Placeholder 조건부 허용

---

### T5 — 최소 VFX

| # | 항목 | 내용 |
|---|------|------|
| 1 | 목적 | 타격·패턴·피격 식별 |
| 2 | 선행조건 | T4 진행 중 또는 완료 |
| 3 | 현재 Git 존재 | 없음 |
| 4 | 재사용 | 없음 |
| 5 | 신규 | 타격/피격 · 대시 · 씰/빔/블라스트 · 사망 최소 (NEW) |
| 6 | 확인 불가 | 실에셋 품질 (UNKNOWN) |
| 7 | UE Editor 필요 | 예 (EDITOR_REQUIRED) |
| 8 | T1 VERIFIED 필수 | 간접 → **BLOCKED** |
| 9 | 위험 | 폴리시 과다 · 환경 파괴 VFX 추가 |
| 10 | 검증 방법 | 공격·피격 시 이펙트 발동 |

**분류 요약**: NEW · BLOCKED · EDITOR_REQUIRED · Placeholder 허용

---

### T6 — 최소 Audio

| # | 항목 | 내용 |
|---|------|------|
| 1 | 목적 | 타격·패턴 피드백 최소 사운드 |
| 2 | 선행조건 | T5와 병행 가능 |
| 3 | 현재 Git 존재 | 없음 |
| 4 | 재사용 | 없음 |
| 5 | 신규 | 타격/피격/대시/Warning/사망 SFX (NEW) |
| 6 | 확인 불가 | 실파일 존재 여부 이미 확인됨 (없음) |
| 7 | UE Editor 필요 | 예 (EDITOR_REQUIRED) |
| 8 | T1 VERIFIED 필수 | 간접 → **BLOCKED** |
| 9 | 위험 | 풀 BGM·보이스 필수화 |
| 10 | 검증 방법 | 주요 액션 시 사운드 재생 또는 의도적 무음 placeholder 명시 |

**분류 요약**: NEW · BLOCKED · EDITOR_REQUIRED · Placeholder 허용

---

### T7 — Presentation / Camera / UI

| # | 항목 | 내용 |
|---|------|------|
| 1 | 목적 | Camera / HUD / Result UI Arena 안정 동작 |
| 2 | 선행조건 | T3 완료 |
| 3 | 현재 Git 존재 | SpringArm+FollowCamera · WBP_ExcelionHUD · Victory/Defeat/Retry 로직 |
| 4 | 재사용 | EXISTING / REUSE |
| 5 | 신규 | Arena 맞춤 Camera 조정 가능 (UNKNOWN/NEW) |
| 6 | 확인 불가 | HitStop 체감 · 맵 내 Camera 시야 (UNKNOWN) |
| 7 | UE Editor 필요 | 예 (EDITOR_REQUIRED) |
| 8 | T1 VERIFIED 필수 | 간접 → **BLOCKED** |
| 9 | 위험 | 신규 UI 시스템 도입 시도 |
| 10 | 검증 방법 | HUD 정상 · 결과 UI 전이 · Retry 후 재시작 |

**분류 요약**: REUSE · UNKNOWN (polish) · BLOCKED · EDITOR_REQUIRED

---

### T8 — 통합 PIE 검증

| # | 항목 | 내용 |
|---|------|------|
| 1 | 목적 | 전체 VS 루프 Arena 통과 확인 |
| 2 | 선행조건 | T1~T7 최소 완료 |
| 3 | 현재 Git 존재 | P5-4 proof scripts · 기존 검증 이력 |
| 4 | 재사용 | 시나리오 재사용 가능 |
| 5 | 신규 | Arena 콘텐츠 포함 검증 기록 (NEW) |
| 6 | 확인 불가 | Input fallback 회귀 결과 (UNKNOWN) |
| 7 | UE Editor 필요 | 예 (EDITOR_REQUIRED) |
| 8 | T1 VERIFIED 필수 | 예 → **BLOCKED** |
| 9 | 위험 | 검증 중 임의 코드/에셋 수정 |
| 10 | 검증 방법 | Spawn → Combat → Phase → Victory/Defeat → Retry 전 구간 |

**분류 요약**: REUSE (시나리오) · BLOCKED · EDITOR_REQUIRED

---

### T9 — 결과 보강 및 Vertical Slice 완료 판정

| # | 항목 | 내용 |
|---|------|------|
| 1 | 목적 | T8 FAIL 최소 결함만 수정 후 재검증 |
| 2 | 선행조건 | T8 FAIL 항목 존재 |
| 3 | 현재 Git 존재 | 해당 없음 (사후) |
| 4 | 재사용 | — |
| 5 | 신규 | FAIL 원인 최소 수정 (Master 승인 후) |
| 6 | 확인 불가 | 실제 FAIL 내용 |
| 7 | UE Editor 필요 | 예 (EDITOR_REQUIRED) |
| 8 | T1 VERIFIED 필수 | 예 → **BLOCKED** |
| 9 | 위험 | 범위 확대 · 신규 기능 추가 |
| 10 | 검증 방법 | 해당 FAIL 항목 PASS |

**분류 요약**: BLOCKED · EDITOR_REQUIRED · Master 승인 필수

---

## 종합 분류 매트릭스

| Task | EXISTING/REUSE | NEW | UNKNOWN | BLOCKED | EDITOR_REQUIRED |
|------|----------------|-----|---------|---------|-----------------|
| T2 | 시스템 로직 | 배치 | 맵 배치 | 예 (T1) | 예 |
| T3 | 전투 로직 | — | 공간 적합성 | 예 | 예 |
| T4 | — | Anim 세트 | 품질 기준 | 예 | 예 |
| T5 | — | VFX 세트 | — | 예 | 예 |
| T6 | — | SFX 세트 | — | 예 | 예 |
| T7 | Camera/HUD/UI | 조정 가능 | polish | 예 | 예 |
| T8 | 시나리오 | 기록 | Input 회귀 | 예 | 예 |
| T9 | — | 최소 수정 | FAIL 내용 | 예 | 예 |

---

## 변경하지 않은 것

- Canon
- Novel
- Unreal C++
- Blueprint
- Asset
- Animation
- VFX
- Audio
- Input
- ORD-GRUNT
- Level (맵 바이너리 포함)

---

## NEXT

다음 작업:
- T1 실기 검증 가능 시 T1 VERIFIED 여부 확인 (로컬 UE 5.4 체크리스트)
- 이후 T2 착수 승인 검토

선행 조건:
- T1 VERIFIED
- Master의 T2 명시적 착수 지시

**T1이 VERIFIED되지 않은 상태에서는 T2~T9 구현을 수행하지 않는다.**

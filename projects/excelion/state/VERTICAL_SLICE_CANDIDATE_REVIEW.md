# VERTICAL_SLICE_CANDIDATE_REVIEW — Excelion

> 2026-08-16 · 조사·분석 전용
> Canon / Novel / Unreal / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT **변경 없음**
> 목적: Master가 A/B 중 최종 후보를 선택할 수 있도록 사실 기반 비교 자료 제공
> 최종 선정은 하지 않음

**상태: 비교 완료 · Master 결정 대기**

---

## STATUS

### 조사 완료
- A (Seth Boss Arena) 조사
- B (EP1 / EP6 / EP8 연계) 조사
- 후보 비교표 작성
- 장단점·최소 작업·선행 조건 정리
- 문서 저장: 본 파일

### 미확인
- Input fallback 최신 변경분 Windows Build + PIE (IMPLEMENTED / UNVERIFIED 유지)
- 실제 Animation / VFX / Audio 에셋 (placeholder만 존재)
- Level 구체 레이아웃·테마 (NewMap/Untitled 최소)
- EP1↔EP6↔EP8 Transition 연출·로딩·스토리 훅 구현 상태
- ORD-GRUNT 최종 실루엣 (HOLD)

### Master 결정 필요
- Vertical Slice 최종 후보: **A** 또는 **B**
- 선정 후 최소 제작 범위 승인
- Input fallback 재검증 우선순위
- ORD-GRUNT HOLD 유지 여부

---

## 문서 우선순위 적용

```
CANON → IMPLEMENTATION → REVIEW → REFERENCE → ARCHIVE
```

근거 문서 (읽기 전용):
- state/STORY_GAMEPLAY_DEPENDENCY_MAP.md (PHASE 3)
- state/DEVELOPMENT_STATE_BASELINE_2026-08-15.md
- state/CURRENT_STATE.md (P5-4 VERIFIED)
- state/VERTICAL_SLICE_EP1_6_8.md
- novel/EPISODE_MATRIX.md 및 관련 Conti/Scene Script

문서에 존재한다는 이유만으로 구현/검증 완료로 판정하지 않음.

---

## Candidate A — Seth Boss Arena

**기준**: P5-4 Full Vertical Slice Integration 기반 · EP06 중심 1:1 보스 아레나

### 현재 구현 / VERIFIED
| 항목 | 상태 | 근거 |
|------|------|------|
| Player Spawn | VERIFIED | P5-4 Scenario A/B |
| Character Control / Movement | VERIFIED (U2-H 기준) · 최신 Input fallback은 UNVERIFIED | U2-H + 이후 fallback 커밋 |
| Combat Core | VERIFIED | U2 Core Combat |
| Enemy Spawn / Chase / Hit / Death | VERIFIED | U3-2a / U3-2b |
| Seth Boss Phase 1 / Transition / Pattern / Death | VERIFIED | U4-B-1~5 |
| Dash Invulnerability | VERIFIED | U4-B-4 |
| Victory / Defeat / Retry Flow | VERIFIED | P5-1 / P5-2 / P5-3 |
| Full Game Loop (Spawn→Combat→Boss→Victory/Defeat→Retry) | VERIFIED | P5-4 8/8 |
| HUD / Result UI | VERIFIED (최소) | WBP_ExcelionHUD 등 |
| BP_SethBoss / C++ ASethBoss | 존재 · VERIFIED | U4-B 전체 |

### REUSE / NEW / UNKNOWN
| 구분 | 내용 |
|------|------|
| **REUSE** | P5-4 Game Loop, Seth Boss Phase/Pattern/Death, CombatComponent, Dash, Damage, GameMode 상태전이, HUD, Retry |
| **NEW (콘텐츠)** | Arena Level 구체화 (현재 NewMap/Untitled 최소), Seth/ BRAVE 최소 Animation, Pattern VFX (씰·빔), Hit/Death VFX, 최소 Audio (타격·보스 연출·보이스 placeholder) |
| **UNKNOWN** | 맵 테마·라이팅·Collision 상세, 실에셋 품질, Input fallback 최신 회귀 |

### Level / Animation / VFX / Audio
- **Level**: 1 Arena (전선/보스 공간) — REQUIRED FOR VS · 현재 최소 맵만 존재
- **Animation**: BRAVE Idle/Locomotion/근접/대시/피격/필살 최소 + Seth Phase1 차단/씰 · Phase2 패턴 · Hit · Death — REQUIRED · 실에셋 없음
- **VFX**: 타격·피격·대시 잔상 · 씰·빔/블라스트 — REQUIRED · placeholder만
- **Audio**: 타격 SFX · 보스 연출 · 카이/세스 보이스 (placeholder 가능) — REQUIRED

### Technical Dependency
- 이미 VERIFIED된 Boss Phase / Pattern / Invulnerability / GameState 전이 재사용 가능
- Input fallback 최신 변경이 남아 있음 → 실기 재검증 시 회귀 확인 필요
- ORD-GRUNT는 A에서는 필수가 아님 (보스 1:1 중심)

### Risk / Verification / Scope
- **Risk**: LOW~MEDIUM (시스템 검증 완료, 콘텐츠만 보강)
- **Verification**: MEDIUM (기존 proof 스크립트 재사용 가능 + 콘텐츠 추가 후 PIE)
- **Scope**: 좁음 (1 Arena + 보스 전투 루프)

---

## Candidate B — EP1 / EP6 / EP8 연계

**기준**: state/VERTICAL_SLICE_EP1_6_8.md 설계 잠금 · 세 Episode 연결

### 현재 구현 / VERIFIED
| 항목 | 상태 | 근거 |
|------|------|------|
| 공통 Combat / Movement / Damage / Death / Retry | VERIFIED | P5-4 및 하위 단계 |
| Seth Boss (EP6) | VERIFIED | U4-B / P5-4 |
| EP1 전용 (GRUNT 무리 4–6, 첫 필살, 탈출) | 시스템 일부 존재 · 전용 Level/Wave/스토리 훅 미확인 | VERTICAL_SLICE_EP1_6_8 · STORY_GAMEPLAY_DEPENDENCY_MAP |
| EP8 전용 (방어 파도, 과부하 3초, Madness, 스토리 상실 분리) | Madness/Overload 시스템 일부 존재 · 스토리 훅·연출 미구현 | 동일 |
| Episode 간 Transition | UNKNOWN | 자료에 명시적 구현 없음 |

### REUSE / NEW / UNKNOWN
| 구분 | 내용 |
|------|------|
| **REUSE** | P5-4 루프, Seth Boss, Combat, Enemy 기본, HUD, Retry |
| **NEW** | EP1용 폐허/탈출 Level · ORD-GRUNT Wave (4–6) · 첫 필살 연출 · 카이 H1 통신 · EP8 거점 방어 Level · GRUNT/HEAVY Wave · 과부하 손 연출 · 시야 균열 VFX · 스토리 flag 분리 · 세 Episode 연결 로직/연출 |
| **UNKNOWN** | Transition 구현 여부, EP1/EP8 전용 Level 상세, 스토리 상실이 재도전 시 고정되는지 실제 코드 확인, Input 회귀 |

### Level / Animation / VFX / Audio
- **Level**: EP1 전투+탈출 · EP6 Arena · EP8 거점 방어 — 최소 3종 공간 필요 (현재 맵 최소)
- **Animation**: A 요구 + EP1 손 떨림 · EP8 과부하 손 멈춤→쥠 · 잔상 — REQUIRED · 실에셋 없음
- **VFX**: A 요구 + 먼지/연기 · 광기 시야 균열 — REQUIRED/OPTIONAL 혼합
- **Audio**: A 요구 + 카이 H1/H3 · 통신 끊김 · 정적 — REQUIRED (placeholder 가능)

### Technical Dependency
- Madness / Overload / Story flag 분리 필요 (설계 존재, 구현 완전성 미확인)
- Wave Spawn (GRUNT/HEAVY) 추가 필요
- Episode 전환 로직 신규
- ORD-GRUNT HOLD 상태 → placeholder 사용 가능하나 최종 실루엣 미정

### Risk / Verification / Scope
- **Risk**: MEDIUM~HIGH (범위 확대, Transition·스토리 훅·다중 Level)
- **Verification**: HIGH (세 Episode + 연결 + 연출 검증 필요)
- **Scope**: 넓음 (3 Episode + 연결)

---

## 비교표

```text
Vertical Slice Candidate Review

                    A: Seth Arena              B: EP1/6/8
Current State:      P5-4 VERIFIED 기반         시스템 일부 + 설계 LOCK
Reuse:              HIGH (GameLoop+Boss)       MEDIUM (공통 루프)
New Content:        LOW~MEDIUM (Arena+Anim/VFX) HIGH (3 Level+Wave+연출)
Level:              1 Arena                    3+ 공간 + Transition
Animation:          BRAVE+Seth 최소            + EP1/EP8 전용 포즈
VFX:                타격/씰/빔 최소            + 광기/먼지 등
Audio:              최소 + placeholder         + 보이스/통신
Technical Dependency: LOW (재사용 중심)        MEDIUM~HIGH (Wave/Madness/Transition)
Risk:               LOW~MEDIUM                 MEDIUM~HIGH
Verification:       MEDIUM                     HIGH
Scope:              좁음                       넓음
```

상대 평가 (근거 기반, 기간 추정 없음):
- A: Risk LOW~MEDIUM / Scope 좁음 / Reuse HIGH
- B: Risk MEDIUM~HIGH / Scope 넓음 / Reuse MEDIUM

---

## A를 선택할 경우

**장점**
- 이미 P5-4로 검증된 Game Loop + Seth Boss를 그대로 활용
- 범위가 1 Arena로 통제 가능
- 콘텐츠 보강량 상대적 적음
- 빠른 플레이 가능 Slice 확보 가능

**단점**
- Excelion 전체(스토리 아크·애착·상실)를 대표하기 어려울 수 있음
- EP1 씨앗 → EP8 상실 흐름이 빠짐

**필요한 최소 작업**
- Arena Level 최소 정리 (Collision / Spawn / Lighting)
- BRAVE + Seth 최소 Animation / VFX / Audio (placeholder 허용 범위 확정)
- Input fallback 재검증 (공통)
- 기존 P5-4 proof 재실행 + 콘텐츠 추가 후 PIE

---

## B를 선택할 경우

**장점**
- EP1→6→8로 스토리·게임플레이·감정 아크를 한 번에 보여줄 수 있음
- VERTICAL_SLICE_EP1_6_8 설계와 정합
- 데모로서의 대표성 높음

**단점**
- Level·Wave·연출·Transition 작업량 증가
- Madness/Overload/Story flag 완전성 미확인
- 검증 범위 확대

**필요한 최소 작업**
- EP1 / EP6 / EP8 각각 최소 Level
- ORD-GRUNT Wave + HEAVY (placeholder)
- 과부하·손 연출·시야 VFX·카이 보이스
- Episode 연결 로직 (최소)
- Input fallback 재검증 (공통)
- 다중 시나리오 PIE 검증

---

## 공통

### 반드시 선행되어야 하는 것
- Input fallback Windows Build + PIE 재검증 (현재 IMPLEMENTED / UNVERIFIED)
- Master의 후보 선정 + 최소 제작 범위 승인

### 현재 미확인 사항
- 실에셋(Animation/VFX/Audio) 전무
- Level 상세
- Input 최신 변경 회귀
- ORD-GRUNT 최종 형태 (HOLD)

### 선택 후 추가 조사 필요사항
- 선정된 후보의 정확한 에셋 리스트 (REUSE vs NEW)
- Placeholder 허용 범위
- 검증 스크립트 재사용/확장 계획

---

## 변경하지 않은 것
- Canon
- Novel
- Unreal C++ / Blueprint / Asset
- Animation / VFX / Audio
- Input
- ORD-GRUNT
- 기존 상태 문서 본문

---

## NEXT

다음 작업:
- Master의 VS 후보 선정 (A 또는 B)

선행 조건:
- 후보 선정 및 최소 제작 범위 승인

검증 필요:
- 선정된 VS의 실제 PIE 검증 (Input fallback 포함)

**본 문서는 선택을 대신하지 않는다. 사실 정리만 수행한다.**

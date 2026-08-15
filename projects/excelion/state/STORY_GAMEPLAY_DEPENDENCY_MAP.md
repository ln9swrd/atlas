# STORY_GAMEPLAY_DEPENDENCY_MAP — Excelion

> 2026-08-16 · PHASE 3 조사 결과
> Canon / Novel / Unreal / Asset / Blueprint / Animation / VFX / Audio **변경 없음**
> 목적: 존재하는 스토리 자료에서 게임 제작 요구사항을 추출하고 확정/미확정/부족을 Git에 기록

**상태: 조사 완료 · Master 승인 전 후보만 제시**

---

## STATUS

### 조사 완료
- Story / Canon 구조 조사 (novel/, design/, state/)
- Episode Matrix (EP01–24) 조사
- Scene / Conti / Scene Script 조사 (EP1·6·8 중심, 기타 Conti 존재 확인)
- Gameplay Dependency Mapping (Player Objective → Action → System → Content)
- Vertical Slice 후보 조사
- 필요한 콘텐츠 산출 (Level / Mecha / Animation / VFX / Audio / UI)
- 문서 저장: 본 파일

### 미확인
- EP02–05, EP07, EP09–24의 Scene Script 상세 플레이어블 판정 (Conti는 존재하나 전체 CUTSCENE/PLAYABLE 태깅 미완)
- 맵 테마·구체 레이아웃 (design/env DESCRIPTION만 존재)
- Animation / VFX / Audio 실제 에셋 (placeholder만)
- ORD-GRUNT 최종 실루엣 LOCK (HOLD)
- Input fallback 최신 변경분의 Windows Build + PIE (IMPLEMENTED / UNVERIFIED 유지)

### 충돌
- 신규 Canon conflict 미발견
- 기존 STORY_DESIGN_CONFLICTS 등 참고용 (Archive/Review 승격 없음)
- VS 보스 = 세스 (EP6) · EP5 몬투는 스토리 중보스 (VS 아님) — 의도적 분리, 충돌 아님

### Master 결정 필요
- Vertical Slice 최종 후보 선정 (본 문서는 후보만)
- Input fallback 재검증 우선순위
- ORD-GRUNT HOLD 유지 여부
- PHASE 3 이후 콘텐츠 보강 범위

---

## 문서 우선순위 적용

```
CANON → IMPLEMENTATION → REVIEW → REFERENCE → ARCHIVE
```

상위 문서 우선. Review/Archive를 Canon으로 승격하지 않음.

주요 근거 문서:
- novel/EPISODE_MATRIX.md
- state/VERTICAL_SLICE_EP1_6_8.md
- state/EP1_EP8_SCENE_SCRIPT.md
- design/conti/EP0x_CONTI.md
- design/gameplay/CORE_GAMEPLAY.md
- design/gameplay/COMBAT_SYSTEM.md
- docs/NOVEL_TO_GAMEPLAY_READINESS.md
- state/CURRENT_STATE.md / DEVELOPMENT_STATE_BASELINE_2026-08-15.md

---

## Episode별 Dependency Mapping (요약)

각 EP에 대해 자료에 명시된 것만 기록. 없으면 UNKNOWN.

### EP01 — 동기화

| 항목 | 내용 |
|------|------|
| Story | 지구 붕괴 직후 · 탈출 · 살아남기 · BRAVE 공명 · 카이 첫 연결 |
| Scene | 거리 폐허 · 조종석 · 첫 침입자 · 탈출 경로 |
| Player Objective | 탈출 / 첫 침입자 저지 |
| Gameplay | 이동 · 회피(대시) · 반격 1타 · 첫 필살(≥50) · Heat 도입 |
| Enemy | ORD-GRUNT (HP≈15 · 동시 4–6) |
| Level | 전투 공간 · 폐허 거리 · 탈출 경로 |
| Mecha | BRAVE(초기형 · ~25m) · ORD-GRUNT |
| Animation | 이동 · 대시 · 근접 1타 · 피격 · 손 떨림 포즈 |
| VFX | 타격 · 먼지/연기 · 필살 최소 |
| Audio | 통신 잡음 · 타격 · 바람/폭발 잔향 · 카이 보이스 H1「콜.」 |
| Technical | Spawn · Damage · S-Core · Input · Result UI |
| Playable 판정 | PLAYABLE (전투 루프 명시) · 오프닝/엔딩 HYBRID 가능 |
| 상태 | 설계 LOCK (VERTICAL_SLICE) · 실기 콘텐츠 최소 |
| 근거 | EPISODE_MATRIX · VERTICAL_SLICE_EP1_6_8 · EP1_EP8_SCENE_SCRIPT · EP01_CONTI |

**Player Action 체인**
```
OBJECTIVE: 적 포위/침입자 돌파 및 탈출
  ↓
PLAYER ACTION: 이동 · 대시 회피 · 근접 공격 · 필살
  ↓
GAME SYSTEM: CharacterMovement · Dash i-frame · CombatComponent · SCore · Damage
  ↓
REQUIRED CONTENT: Arena Level · ORD-GRUNT · BRAVE · 최소 Anim · Hit VFX · 통신 Audio
```

### EP02 — 잔향

| 항목 | 내용 |
|------|------|
| Story | 거점 사수 · GRUNT 파도 · 카이 이름·통신 · 유나 시선 |
| Scene | 거점 |
| Player Objective | 거점 사수 |
| Gameplay | 방어형 전투 · 무리 처리 |
| Enemy | ORD-GRUNT 파도 |
| Level | 거점 / 방어 공간 |
| Mecha | BRAVE · ORD |
| Animation / VFX / Audio | UNKNOWN (상세 Conti 존재하나 플레이 루프 수치 미상세) |
| Playable 판정 | PLAYABLE 추정 (전투 기믹 있음) · 상세 UNKNOWN |
| 상태 | Conti 존재 · Vertical Slice 후보 아님 |
| 근거 | EPISODE_MATRIX · EP02_CONTI |

### EP03 — 각성의 대가

| 항목 | 내용 |
|------|------|
| Story | 구출 · 광기 신호 1 · 살렸는데 꺼진 눈 |
| Player Objective | 구출 |
| Gameplay | 구출+압박 |
| Enemy | ORD |
| Level | 구출 구역 |
| Playable 판정 | UNKNOWN (전투 있음) |
| 근거 | EPISODE_MATRIX · EP03_CONTI |

### EP04 — 남겨진 것

| 항목 | 내용 |
|------|------|
| Story | 회수·정비 · 네메시스 이름만 · 전투 과다 금지 |
| Player Objective | 회수 · 내리지 않기 |
| Gameplay | 전투 최소화 |
| Playable 판정 | HYBRID / UNKNOWN |
| 근거 | EPISODE_MATRIX · EP04_CONTI |

### EP05 — 균열

| 항목 | 내용 |
|------|------|
| Story | MID 저지 · 레이 정점 · 카이 부상 |
| Player Objective | ORD-MID 저지 |
| Gameplay | MID 1:1성 |
| Enemy | ORD-MID (몬투 등 중보스 계열) |
| Level | 전선 |
| Playable 판정 | PLAYABLE (전투 기믹) · VS 아님 |
| 근거 | EPISODE_MATRIX · EP05_CONTI · NOVEL_TO_GAMEPLAY_READINESS |

### EP06 — 달의 그림자

| 항목 | 내용 |
|------|------|
| Story | 세스 격파 · 이겨도 전망 없음 · 네메시스 원경 1컷 |
| Scene | 전선 · 세스 1:1 · 네메시스 원경 |
| Player Objective | 세스 격파 |
| Gameplay | 1:1 보스 · Phase 1–2 · 차단/씰 · 집념 돌파 · 카운터 창 |
| Enemy | 세스 (HP 480 · Phase 2) |
| Level | 전선 / 보스 아레나 |
| Mecha | BRAVE · 세스기 (~30m · 차단·씰) |
| Animation | 보스 패턴 · 차단 · 씰 · 피격 · 사망 · BRAVE 전투 |
| VFX | 씰 · 빔/블라스트 · 피격 · 일시 빛 |
| Audio | 보스 연출 · 카이 H1 · 「…보고, 끝.」 |
| Technical | Boss Phase · Pattern · Invulnerability · Death · Victory |
| Playable 판정 | PLAYABLE (핵심 보스전) · 원경 컷 HYBRID |
| 상태 | 설계 LOCK · P5-4 / U4-B 시스템 VERIFIED · 콘텐츠 최소 |
| 근거 | EPISODE_MATRIX · VERTICAL_SLICE_EP1_6_8 · EP06_CONTI · BOSS 관련 |

**Player Action 체인**
```
OBJECTIVE: 세스 격파
  ↓
PLAYER ACTION: 접근 · 콤보 · 대시 회피 · 약점 창 공격 · 필살
  ↓
GAME SYSTEM: Boss Phase · Pattern Executor · Damage · Dash i-frame · S-Core
  ↓
REQUIRED CONTENT: Arena · SethBoss · BRAVE · Phase Anim · Pattern VFX · Result UI
```

### EP07 — 광기의 문턱

| 항목 | 내용 |
|------|------|
| Story | 네메시스 원격 일격 · 아누 · 생존 |
| Player Objective | 생존 |
| Gameplay | 아누 격파 가능 · 네메시스 원경 벽 |
| Enemy | 아누 · 네메시스(원경) |
| Playable 판정 | PLAYABLE 추정 · 상세 UNKNOWN |
| 근거 | EPISODE_MATRIX · EP07_CONTI |

### EP08 — 선택의 무게

| 항목 | 내용 |
|------|------|
| Story | 카이 지키기 실패 · 과부하 3초 · 카이 희생 · 부분 성공 |
| Scene | 거점 압박 · 과부하 · 상실 · 부분 클리어 |
| Player Objective | 거점 사수 (게임) · 상실 수용 (스토리) |
| Gameplay | 방어형 · GRUNT/HEAVY 파도 · 과부하 연출 · 스토리/게임 이중 층 |
| Enemy | ORD GRUNT/HEAVY 파도 (보스 아님) |
| Level | 거점 / 방어 공간 |
| Mecha | BRAVE · ORD |
| Animation | 과부하 손 멈춤→쥠 · 피격 · 잔상 |
| VFX | 시야 균열 · 광기 · 피격 |
| Audio | 카이 H3「끝나면 내려.」 · 통신 끊김 · 정적 |
| Technical | Madness · Overload · Story flag 분리 · Result UI |
| Playable 판정 | PLAYABLE (방어 루프) · 과부하/상실 구간 HYBRID |
| 상태 | 설계 LOCK · 시스템 일부 존재 · 스토리 훅 미구현 |
| 근거 | EPISODE_MATRIX · VERTICAL_SLICE_EP1_6_8 · EP1_EP8_SCENE_SCRIPT · EP08_CONTI |

**Player Action 체인**
```
OBJECTIVE: 거점 사수 (게임) + 상실 수용 (스토리)
  ↓
PLAYER ACTION: 방어 전투 · 무리 처리 · (과부하 시 조작 공백)
  ↓
GAME SYSTEM: Spawn wave · Damage · Madness/Overload · GameState · Story flag
  ↓
REQUIRED CONTENT: Defense Level · ORD wave · BRAVE · Overload Anim/VFX · Voice · UI
```

### EP09–24 (요약)

| EP | 주요 전투/목표 | Playable 추정 | 비고 |
|----|----------------|---------------|------|
| 09 | 네메시스 전면 · 생존/부분 | UNKNOWN | 카이 잔상 |
| 10 | 호르 · 통과 | UNKNOWN | |
| 11 | 호르 잔당 · 후퇴 유도 | UNKNOWN | 일시 엑셀리온 |
| 12 | 네메시스 심리 · 합류 | UNKNOWN | |
| 13 | 네메시스+게이트 · 시간 벌기 | UNKNOWN | |
| 14 | 토트 · 전선 유지 | UNKNOWN | |
| 15 | 세크 · 격파 | UNKNOWN | |
| 16 | 네크 · 맵 클리어 | UNKNOWN | |
| 17 | 경로·손 체감 · 해금 | UNKNOWN | |
| 18 | 데크레 · 통과 | UNKNOWN | |
| 19 | 시간 벌기 방어 · 돌입 결정 | UNKNOWN | |
| 20 | 소벡 · 다파 레이드 | UNKNOWN | |
| 21 | 와제 · 격파=문 열림 | UNKNOWN | |
| 22 | 암밋 · 통과 | UNKNOWN | |
| 23 | 네메시스 P1–2 · 한계 | UNKNOWN | |
| 24 | 네메시스 최종 · 선택 | UNKNOWN | |

상세 Player Objective / 필요 콘텐츠는 Conti·Scene Script 추가 조사 또는 Master 지시 후 확장.

---

## Cutscene / Gameplay 구분 (자료 기준)

| EP | Scene 유형 | 근거 |
|----|------------|------|
| EP01 오프닝/엔딩 | HYBRID | Conti P01–P04, P10 연출 중심 · 전투 P06–P08 PLAYABLE |
| EP01 전투 | PLAYABLE | 명시된 루프 |
| EP06 보스전 | PLAYABLE | Phase·패턴 명시 |
| EP06 네메시스 원경 | HYBRID / CUTSCENE | 말 없음 · 시선 1컷 |
| EP08 방어 | PLAYABLE | 파도·사수 |
| EP08 과부하·상실 | HYBRID | 3초 공백 · 스토리 고정 |
| 기타 EP | UNKNOWN | 전체 태깅 미완 |

임의로 PLAYABLE로 만들지 않음.

---

## 필요한 콘텐츠 산출 (현재 자료 기준)

### Level

| 용도 | 타입 | 필요 여부 | 현재 | 우선순위 |
|------|------|-----------|------|----------|
| EP1 전투 | 폐허 거리 · 탈출 경로 | REQUIRED FOR VERTICAL SLICE | NewMap/Untitled 최소 | REQUIRED FOR VS |
| EP6 보스 | 전선 / 아레나 | REQUIRED FOR VERTICAL SLICE | 동일 최소 | REQUIRED FOR VS |
| EP8 거점 | 방어 공간 | REQUIRED FOR VERTICAL SLICE | 동일 최소 | REQUIRED FOR VS |
| 기타 EP | 도시·시설·달·게이트 등 | OPTIONAL / 후속 | design/env DESCRIPTION만 | NOT CURRENTLY REQUIRED |

### Character / Mecha

| 대상 | 역할 | 필요 여부 | 현재 | 우선순위 |
|------|------|-----------|------|----------|
| BRAVE / AXION | 플레이어 기체 | REQUIRED FOR GAMEPLAY | BP + C++ · placeholder | REQUIRED FOR VS |
| ORD-GRUNT | 잡몹 | REQUIRED FOR GAMEPLAY | BP_ExcelionEnemy 등 · HOLD | REQUIRED FOR VS (placeholder OK) |
| 세스기 | VS 보스 | REQUIRED FOR VERTICAL SLICE | BP_SethBoss · C++ VERIFIED | REQUIRED FOR VS |
| 네메시스 | 후반 | OPTIONAL POLISH | 문서만 | NOT CURRENTLY REQUIRED |
| 기타 보스 (아누·호르·토트 등) | EP별 | OPTIONAL | 문서만 | NOT CURRENTLY REQUIRED |

### Animation

자료에서 **실제 요구되는 것만**:

| 대상 | 요구 | 우선순위 |
|------|------|----------|
| BRAVE | Idle · Locomotion · 근접 · 대시 · 피격 · 필살 최소 · 손 떨림/과부하 포즈 | REQUIRED FOR VS |
| ORD-GRUNT | Idle · Chase · Attack · Hit · Death | REQUIRED FOR VS |
| 세스 | Phase1 차단/씰 · Phase2 패턴 · Hit · Death | REQUIRED FOR VS |
| 기타 | UNKNOWN / 후속 | NOT CURRENTLY REQUIRED |

현재: assets/animations/.gitkeep 만. 실에셋 없음.

### VFX

| 요구 | 우선순위 |
|------|----------|
| 타격 · 피격 · 대시 잔상 | REQUIRED FOR VS |
| 필살 · 씰 · 빔/블라스트 | REQUIRED FOR VS |
| 광기 시야 · 먼지/연기 | OPTIONAL POLISH |
| 환경 파괴 | NOT CURRENTLY REQUIRED |

현재: assets/vfx/.gitkeep 만.

### Audio

| 요구 | 우선순위 |
|------|----------|
| 타격 SFX · 대시 · 피격 | REQUIRED FOR VS |
| 카이 보이스 (H1/H3) · 세스「보고, 끝」 | REQUIRED FOR VS (또는 placeholder) |
| BGM · 환경음 | OPTIONAL POLISH |

현재: assets/audio README만.

### UI

| 요구 | 현재 | 우선순위 |
|------|------|----------|
| HUD (HP/S-Core 등) | WBP_ExcelionHUD VERIFIED | REQUIRED FOR GAMEPLAY |
| Result / Victory / Defeat | 시스템 VERIFIED · 카피 일부 | REQUIRED FOR VS |
| 통신 UI | 최소 | OPTIONAL POLISH |

---

## Vertical Slice 후보

Master 승인 없이 최종 선정하지 않음. 후보만.

### Candidate A — Seth Boss Arena (현재 P5-4 기반)

- Episode: EP06 중심 (+ 공통 루프)
- Scene: 세스 1:1 보스전
- Narrative purpose: “이기고 싶다” · 안 흔들리는 벽 · 전망 없음
- Gameplay: Phase 1–2 · 차단/씰 · 집념 돌파 · Victory/Defeat/Retry
- Required Level: 1 arena (최소)
- Required Enemy: 세스
- Required Mecha: BRAVE + 세스기
- Required Animation: 보스 패턴 · 전투 최소
- Required VFX: 패턴 · 피격
- Required Audio: 보스 연출 · 최소 SFX
- Required UI: HUD · Result
- Current Assets: C++/BP/GameLoop VERIFIED · placeholder mecha · 최소 맵
- Missing Assets: 실 메쉬/애니/VFX/Audio · 맵 테마
- Technical Dependencies: 이미 VERIFIED (U4-B · P5-4)
- Risk: 콘텐츠 비주얼 공백 · 스토리 훅(네메시스 원경) 미연출
- 분류: **PARTIALLY READY**

### Candidate B — EP1 / EP6 / EP8 연계 (VERTICAL_SLICE_EP1_6_8)

- Episode: EP01 · EP06 · EP08
- Scene: 첫 전투 · 세스 · 거점+상실
- Narrative purpose: 첫 루프+애착 씨앗 · 보스 긴장 · 과부하·희생·부분 성공
- Gameplay: 학살/돌파 · 1:1 보스 · 방어+이중 층
- Required Level: 폐허 · 아레나 · 거점 (또는 재사용 1맵 섹션)
- Required Enemy: ORD-GRUNT · 세스
- Required Mecha: BRAVE · ORD · 세스
- Required Animation: EP1 손떨림 · EP6 패턴 · EP8 과부하
- Required VFX / Audio: 상기 + 카이 보이스
- Required UI: HUD · Result · (통신)
- Current Assets: 시스템 VERIFIED · 설계 LOCK
- Missing Assets: 레벨 테마 · 애니 · VFX · Audio · 스토리 플래그/연출
- Technical Dependencies: Madness/Overload · Story/Game 층 분리 (부분 존재)
- Risk: EP8 스토리 상실과 게임 클리어 분리 구현 · 애착 씨앗 전달
- 분류: **PARTIALLY READY**

### Candidate C — 기타 EP 단독

- 분류: **NOT READY** (상세 매핑·시스템·콘텐츠 부족)

---

## 디자인 우선순위 분류

| 콘텐츠 | 분류 |
|--------|------|
| BRAVE 전투 루프 · ORD 스폰 · 세스 Phase · GameLoop | REQUIRED FOR GAMEPLAY |
| EP1/6/8 목표·클리어 조건 · 최소 아레나 | REQUIRED FOR VERTICAL SLICE |
| 손 떨림/과부하 포즈 · 카이 보이스 · 네메시스 원경 1컷 | REQUIRED FOR VERTICAL SLICE (연출 최소) |
| 최종 메카 디테일 · 대규모 환경 · 풀 애니 세트 · 최종 VFX | OPTIONAL POLISH |
| EP9+ 전체 보스 · 오픈월드 | NOT CURRENTLY REQUIRED |

멋있어 보이기 위한 디자인 ≠ 플레이하기 위해 필요한 디자인. 후자는 위 REQUIRED만.

---

## Animation / Level 최소 생산 요구 (파이프라인용)

### Animation (스토리/게임플레이 실제 요구)

```
AXION / BRAVE
- Idle
- Locomotion (이동)
- Combat (근접 약/강)
- Dash
- Hit
- Death (플레이어)
- Special: 필살 최소 · 손 떨림 · 과부하 멈춤→쥠

ORD-GRUNT
- Idle · Chase · Attack · Hit · Death

SETH
- Phase1: 차단 · 씰 전개
- Phase2: 빔/프로세큐트
- Hit · Death
```

### Level

```
EP01 / 공통 Arena
- Level type: 폐허 거리 또는 추상 아레나
- Required playable area: 전투 가능 반경 (수치 TBD)
- Required modular assets: 최소 장애물 · 스폰 포인트
- Gameplay volumes: 조우 트리거 · 탈출/클리어 볼륨
- Spawn requirements: ORD 4–6 · 보스 1
- Destruction: 최소 또는 없음 (1차)
- Lighting: 가독성 우선

EP06 Arena: 동일 베이스 + 보스 전용 공간
EP08 Defense: 거점 중심 · 스폰 웨이브 포인트
```

---

## 구현 상태 요약 (시스템 vs 콘텐츠)

| 구분 | 상태 |
|------|------|
| Core Gameplay (이동·전투·피격·데미지) | VERIFIED (U1–U2) |
| Enemy Chase / Hit / Death | VERIFIED (U3) |
| Seth Boss Phase / Pattern / Death | VERIFIED (U4-B) |
| Victory / Defeat / Retry / Full Loop | VERIFIED (P5-4) |
| Input (최신 fallback) | IMPLEMENTED / UNVERIFIED |
| Level 콘텐츠 | 최소 맵만 |
| Animation / VFX / Audio / 실 메쉬 | NOT STARTED |
| Story 훅 (카이 통신·상실 플래그·원경) | 문서 LOCK · 런타임 미구현 또는 최소 |

---

## NEXT

다음 작업:
1. Master: Vertical Slice 후보 A/B 중 선정 또는 수정 지시
2. Input fallback Windows Build + PIE 재검증 (COMPLETE 승격 조건)
3. 선정 VS 기준 최소 콘텐츠 리스트 확정 (맵 섹션 · placeholder 유지 범위)
4. (선택) EP02–24 Playable/Cutscene 태깅 표 확장 — 본 PHASE 범위 외

선행 조건:
- Master 승인 없이 VS 최종 선정·구현 착수 금지
- ORD-GRUNT HOLD 유지
- Canon / Novel 수정 금지

검증 필요:
- Input fallback
- VS 선정 후 최소 아레나 PIE

---

## 변경하지 않은 것

- Canon
- Novel
- 세계관 / 캐릭터 설정 / 메카 설정
- Episode 원문 / Scene Script 원문
- Unreal C++ / Blueprint / Asset
- Animation / VFX / Audio / UI / Level
- 프로젝트 구조

본 문서는 조사·분석 결과만 기록한다.

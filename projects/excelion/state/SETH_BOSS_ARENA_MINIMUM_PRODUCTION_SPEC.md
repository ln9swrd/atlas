# SETH_BOSS_ARENA_MINIMUM_PRODUCTION_SPEC — Excelion

> 2026-08-16 · 조사·분석 전용
> Canon / Novel / Unreal 코드 / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT **변경 없음**
> 목적: A(Seth Boss Arena) Vertical Slice에 필요한 **최소 제작 사양**을 확정하고 EXISTING / REUSE / NEW / UNKNOWN으로 분류
> 구현·콘텐츠 제작은 하지 않음

**상태: 사양 정리 완료 · Master 최소 범위 승인 대기**

---

## STATUS

### 조사 완료
- Level 최소 구성 조사
- AXION (플레이어) 요구사항 조사
- SETH (보스) 요구사항 조사
- Presentation (Camera / UI / Audio / 연출) 조사
- EXISTING / REUSE / NEW / UNKNOWN 분류
- 문서 저장: 본 파일

### 미확인
- Input fallback 최신 변경 Windows Build + PIE (IMPLEMENTED / UNVERIFIED)
- 실제 Animation / VFX / Audio 에셋 (placeholder만)
- 맵 Collision / Lighting 상세
- Placeholder 허용 품질 기준

### Master 결정 필요
- 본 최소 사양 범위 승인
- Placeholder 허용 수준
- Input fallback 재검증 시점
- 실제 제작 착수 지시

---

## 기준

```text
Vertical Slice = A: Seth Boss Arena
Basis          = P5-4 VERIFIED
Scope          = Seth 1:1 보스 전투에 필요한 최소 콘텐츠만
금지           = 대규모 환경 / 스토리 연출 확장 / ORD-GRUNT 본제작 / Core Gameplay 변경
```

근거 문서 (읽기 전용):
- state/VERTICAL_SLICE_CANDIDATE_REVIEW.md
- state/STORY_GAMEPLAY_DEPENDENCY_MAP.md
- state/CURRENT_STATE.md (P5-4 / U4-B)
- state/DEVELOPMENT_STATE_BASELINE_2026-08-15.md
- state/VERTICAL_SLICE_EP1_6_8.md (EP06 부분)
- state/BOSS_STATS_SETH_NEMESIS.md / BOSS_WEAPON_SKILLS.md

---

## 1. Level

| 항목 | 분류 | 내용 | 근거 |
|------|------|------|------|
| 플레이 가능 공간 | NEW | 보스 아레나 1개 (전선/원형 또는 사각 최소 면적) | STORY_GAMEPLAY · Candidate A |
| Player Spawn Point | REUSE | 기존 Spawn 로직 재사용 | P5-4 VERIFIED |
| Boss Spawn Point | REUSE | BP_SethBoss 스폰 위치 | U4-B / P5-4 |
| Collision (바닥·벽) | NEW / UNKNOWN | 최소 Blocking Volume 또는 기본 지오메트리 | 현재 NewMap/Untitled 최소 |
| Lighting | NEW / UNKNOWN | 기본 Directional + 최소 포인트 (플레이 가시성만) | 상세 미존재 |
| 환경 Asset | UNKNOWN | 테마(전선/달 표면 등) 구체 레이아웃 없음 · 최소 평면/박스 허용 가능 | design/env DESCRIPTION만 |
| Gameplay Volume | REUSE | 기존 GameMode / 상태 전이 영역 | P5-4 |
| 파괴 가능 오브젝트 | NOT REQUIRED | VS 최소 범위에서 제외 | — |

**최소 합격 기준**
- 플레이어와 세스가 이동·전투 가능한 평면 공간
- Spawn / Collision으로 낙하·이탈 방지
- 라이팅으로 캐릭터·공격 이펙트 식별 가능

---

## 2. AXION (플레이어 기체 / BRAVE)

| 항목 | 분류 | 내용 | 근거 |
|------|------|------|------|
| Character / BP | EXISTING | BP_ExcelionCharacter + C++ | U1 / U2 VERIFIED |
| Movement | REUSE | CharacterMovement + Dash | U2-H / U4-B-4 |
| Combat (근접·필살) | REUSE | CombatComponent · S-Core | U2 Core Combat |
| Input | EXISTING / UNVERIFIED | Enhanced Input + fallback Axis | U2-H VERIFIED → fallback 재검증 필요 |
| Idle / Locomotion Anim | NEW | 최소 Idle + Walk/Run | 실에셋 없음 (assets/animations/.gitkeep) |
| Attack Anim | NEW | 근접 1~2타 최소 | 동일 |
| Dash Anim | NEW | 대시 포즈 또는 잔상 | 동일 |
| Hit / Death Anim | NEW | 피격 · 사망 최소 | 동일 |
| Special / 필살 Anim | NEW | 최소 1회용 | 동일 |
| Hit VFX | NEW | 타격·피격 이펙트 | assets/vfx/.gitkeep |
| Dash VFX | NEW | 잔상 또는 간단한 트레일 | 동일 |

**최소 합격 기준**
- 이동·대시·공격·피격이 시각적으로 구분됨
- Placeholder 메쉬/애니 허용 (Master 승인 시)

---

## 3. SETH (보스)

| 항목 | 분류 | 내용 | 근거 |
|------|------|------|------|
| Boss Logic / Phase | EXISTING | ASethBoss · Phase 1→2 · HP 480 · Pattern | U4-B-1~5 VERIFIED |
| Attack Pattern 01 (Area Blast) | REUSE | 데미지 55 · Warning | U4-B-1 |
| Attack Pattern 02 (Beam Charge) | REUSE | Phase 2 · 데미지 68.75 | U4-B-3 |
| Hit / Damage Reception | REUSE | 플레이어 공격 수신 | U4-B |
| Death | REUSE | IsDead · DisableMovement · Collision off | U4-B-5 |
| Invulnerability 연동 | REUSE | 플레이어 Dash 무적과 상호작용 | U4-B-4 |
| Idle / Phase Anim | NEW | Phase1 차단/씰 · Phase2 자세 | 실에셋 없음 |
| Attack Anim | NEW | Blast · Beam 텔레그래프 | 동일 |
| Hit / Death Anim | NEW | 피격 · 사망 | 동일 |
| Seal / Beam VFX | NEW | 씰 전개 · 빔/블라스트 | assets/vfx/.gitkeep |
| Hit / Death VFX | NEW | 피격 이펙트 · 사망 연출 최소 | 동일 |

**최소 합격 기준**
- Phase 전환과 패턴이 기존 검증된 로직대로 동작
- 공격·피격·사망이 시각적으로 식별 가능
- Placeholder 허용 (Master 승인 시)

---

## 4. Presentation

| 항목 | 분류 | 내용 | 근거 |
|------|------|------|------|
| Camera | REUSE | SpringArm + FollowCamera | 코드 존재 · 별도 검증 항목 제한적 |
| HUD | REUSE | WBP_ExcelionHUD (HP / S-Core 등) | VERIFIED |
| Result UI (Victory / Defeat) | REUSE | GameState 전이 + UI | P5-1 / P5-2 VERIFIED |
| Retry | REUSE | Level Travel | P5-3 VERIFIED |
| 최소 Audio (타격 SFX) | NEW | 타격·피격·대시 | assets/audio README만 |
| 보스 연출 Audio | NEW | Pattern Warning · 사망 등 (placeholder 가능) | 동일 |
| 보이스 (카이/세스) | NEW / OPTIONAL | 「…보고, 끝.」 등 placeholder | VERTICAL_SLICE_EP1_6_8 |
| 카메라 연출 (히트스톱 등) | UNKNOWN | U2-E Bridge 존재하나 최종 체감 미검증 | CURRENT_STATE |
| 스토리 컷 (네메시스 원경) | NOT REQUIRED | VS 최소 범위에서 제외 | Candidate A Scope |

**최소 합격 기준**
- HUD와 Result UI가 동작
- 기본 타격음 존재 (또는 무음 placeholder 허용)
- 카메라가 전투를 따라감

---

## 종합 분류 요약

```text
EXISTING / REUSE (시스템)
- Player / Boss Spawn
- Movement · Dash · Combat · Damage
- Seth Phase / Pattern / Death
- Game Loop (Victory / Defeat / Retry)
- HUD / Result UI

NEW (콘텐츠)
- Arena Level 최소 구성 (공간 · Collision · Lighting)
- AXION 최소 Animation set
- SETH 최소 Animation set
- Hit / Pattern / Death VFX
- 최소 SFX / Audio

UNKNOWN
- 맵 테마·상세 지오메트리
- 실에셋 품질 기준
- Input fallback 최신 회귀
- Camera polish / HitStop 체감

NOT REQUIRED (이번 VS)
- ORD-GRUNT 본제작
- 다중 Level / Transition
- EP1/EP8 스토리 훅
- 대규모 환경·파괴
- 최종 폴리시 비주얼
```

---

## 선행 조건

1. Input fallback Windows Build + PIE 재검증 (또는 Master가 보류 결정)
2. Master의 본 최소 사양 범위 승인
3. Placeholder 허용 수준 확정

---

## 변경하지 않은 것

- Canon
- Novel
- Unreal C++ / Blueprint / Asset
- Animation / VFX / Audio 실파일
- Input
- ORD-GRUNT
- Core Gameplay 구조

---

## NEXT

다음 작업:
- Master의 최소 사양 범위 승인
- 승인 후 작업 단위 분해 (Level → Anim → VFX 순서 등)

선행 조건:
- 본 문서 승인
- Input 재검증 또는 명시적 보류

검증 필요:
- 제작 착수 후 PIE (P5-4 시나리오 재실행 + 신규 콘텐츠)

**본 문서는 구현 지시가 아니다. 최소 제작 사양 확정용이다.**

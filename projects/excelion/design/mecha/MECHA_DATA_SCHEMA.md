# MECHA_DATA_SCHEMA — Excelion

> 2026-08-10  
> 원천: BRAVE_FINAL_SPEC · 06_MECHA · BOSS_STATS · UNREAL_ARCHITECTURE

**상태: 초안**

---

## 1. 저장 방식 결정

| 방식 | 용도 | 결정 |
|------|------|------|
| **Data Asset** | 메카·무기·패턴 개체 정의 (타입 안전 · 참조) | **주 경로** |
| **Data Table** | 밸런스 수치 일괄 · 스프레드시트 이관 | 보조 |

**이유:** 메카/패턴은 필드가 이질적이고 에셋 참조(애니·VFX·사운드)가 많다. Data Asset이 구조체 검증·에디터 편집에 적합. 대량 튜닝 수치는 Data Table로 뽑아 쓴다.

Gameplay Tags는 상태·속성 분류가 늘어날 때 도입 (1차 최소화).

---

## 2. 기본 스탯 (공통)

| 필드 | 타입 | 설명 |
|------|------|------|
| Id | Name/FString | brave-001 등 |
| DisplayName | FText | |
| Category | Enum | Player / Enemy / Boss |
| MaxHP | float | |
| Armor | float | 감쇠 또는 평탄 (단순화 가능) |
| MoveSpeed | float | |
| AttackPower | float | 기본 배율 |
| AttackSpeed | float | 또는 애니 길이로 대체 |
| StaggerResist | float | 경직 저항 |
| Scale | float | 스토리 m 기준 (BRAVE 25) |

---

## 3. Energy (플레이어 중심)

| 필드 | 설명 |
|------|------|
| MaxSCore | 기본 100 |
| SpecialCost | 필살 소모 |
| SuperCost | 초필 소모 |
| ChargeRateByStage | 단계별 배율 |
| MaxHeat | 100 |
| HeatPerCannon | +15 등 |
| OverheatDuration | |

---

## 4. 무기

| 필드 | 설명 |
|------|------|
| WeaponId | |
| Type | Melee / Ranged / Drone |
| Damage | |
| Range | |
| HeatCost | |
| Montage | Soft ref |
| VFX | Soft ref |
| Socket | |

무기 Data Asset을 메카가 배열/슬롯으로 참조.

---

## 5. 필살기

| 필드 | 설명 |
|------|------|
| SpecialId | |
| Cost | S-Core |
| Damage / Multiplier | |
| Duration | |
| IFrame | |
| Montage · Camera · VFX · Audio | Soft ref |

---

## 6. AI 설정 (적/보스)

| 필드 | 설명 |
|------|------|
| BehaviorTree | Soft ref |
| DetectRange | |
| AttackRange | |
| PatternSet | 보스: 패턴 Data Asset 목록 |
| PhaseTable | Phase 트리거 정의 |

---

## 7. 애니메이션 참조

| 필드 | 설명 |
|------|------|
| AnimBP | Soft ref |
| Idle / Move / Dash / Hit / Down | Soft ref 또는 테이블 |
| AttackMontages | 맵 또는 배열 |

---

## 8. VFX / 사운드 참조

| 필드 | 설명 |
|------|------|
| HitVFX · SpecialVFX · CoreVFX · MadnessVFX | Soft ref |
| HitSFX · SpecialSFX · WarnSFX | Soft ref |

---

## 9. 보스 전용 확장

- Phase 정의 (시간·행동 트리거 · 패턴 풀)
- 약점 창 · 씰 등 기믹 파라미터
- 기존 `BOSS_STATS` · `BOSS_WEAPON_SKILLS` · Pattern JSON 이관 대상

---

## 10. 명명·경로 (의도)

- Data Asset: `/Game/Excelion/Data/Mecha/DA_Mecha_Brave` 등
- 기존 문서 id (brave-001)와 동기화

---

## 11. TBD

- 최종 구조체 필드 타입 (float vs int)
- Attribute 시스템 사용 여부 (GAS 도입 여부 — 1차는 단순 컴포넌트 권장)
- 패턴 데이터 스키마 상세 (기존 PATTERN_EXECUTION_SPEC 정합)

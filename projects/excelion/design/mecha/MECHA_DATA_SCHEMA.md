# MECHA_DATA_SCHEMA — Excelion

> 2026-08-10  
> 원천: BRAVE_FINAL_SPEC · 06_MECHA · BOSS_STATS · UNREAL_ARCHITECTURE

**상태: SSOT (데이터 구조 기준 문서)**  
다른 Unreal/구현 문서는 본 스키마를 **참조**한다. 동일 필드를 별도 문서에서 재정의하지 않는다.

---

## 0. Static Configuration vs Runtime State

| 구분 | 저장 위치 | 내용 |
|------|-----------|------|
| **Static Configuration** | Data Asset / Data Table | 메카 기본 스탯 · 무기 설정 · 공격 파라미터 · 애니/VFX 참조 · Phase 정의 |
| **Runtime State** | C++ Component / Actor | 현재 HP · 현재 Energy/Heat · 현재 S-Core 게이지·상태 · 공격/피격 중 플래그 |

- 정적 설정은 에디터에서 편집·밸런스 이관.
- 런타임 상태는 게임 중 변경되며 세이브 대상이 될 수 있음.
- 동일 수치를 문서·코드·에셋에 이중 정의하지 않는다.

GAS는 **1차 미도입**. 단순 C++ Component + Data Asset.

---

## 1. 저장 방식 결정

| 방식 | 용도 | 결정 |
|------|------|------|
| **Data Asset** | 메카·무기·패턴 개체 정의 (타입 안전 · 참조) | **주 경로** |
| **Data Table** | 밸런스 수치 일괄 · 스프레드시트 이관 | 보조 |

**이유:** 메카/패턴은 필드가 이질적이고 에셋 참조(애니·VFX·사운드)가 많다. Data Asset이 구조체 검증·에디터 편집에 적합. 대량 튜닝 수치는 Data Table로 뽑아 쓴다.

Gameplay Tags는 상태·속성 분류가 늘어날 때 도입 (1차 최소화).

---

## 2. 기본 스탯 (공통 · Static)

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

런타임: `CurrentHP` 등은 Damage Component가 보유.

---

## 3. Energy / S-Core (플레이어 · Static 설정 + Runtime 상태)

| 필드 (Static) | 설명 |
|------|------|
| MaxSCore | 기본 100 |
| SpecialCost | 필살 소모 |
| SuperCost | 초필 소모 |
| ChargeRateByStage | 단계별 배율 |
| MaxHeat | 100 |
| HeatPerCannon | +15 등 |
| OverheatDuration | |

런타임: CurrentSCore · CurrentHeat · SCoreState (Idle/Charging/Ready/Active) → USCoreComponent / Energy Component.

---

## 4. 무기 (Static)

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

## 5. 필살기 (Static)

| 필드 | 설명 |
|------|------|
| SpecialId | |
| Cost | S-Core |
| Damage / Multiplier | |
| Duration | |
| IFrame | |
| Montage · Camera · VFX · Audio | Soft ref |

---

## 6. AI 설정 (적/보스 · Static)

| 필드 | 설명 |
|------|------|
| BehaviorTree | Soft ref |
| DetectRange | |
| AttackRange | |
| PatternSet | 보스: 패턴 Data Asset 목록 |
| PhaseTable | Phase 트리거 정의 |

---

## 7. 애니메이션 참조 (Static)

| 필드 | 설명 |
|------|------|
| AnimBP | Soft ref |
| Idle / Move / Dash / Hit / Down | Soft ref 또는 테이블 |
| AttackMontages | 맵 또는 배열 |

---

## 8. VFX / 사운드 참조 (Static)

| 필드 | 설명 |
|------|------|
| HitVFX · SpecialVFX · CoreVFX · MadnessVFX | Soft ref |
| HitSFX · SpecialSFX · WarnSFX | Soft ref |

---

## 9. 보스 전용 확장 (Static)

- Phase 정의 (시간·행동 트리거 · 패턴 풀)
- 약점 창 · 씰 등 기믹 파라미터
- 기존 `BOSS_STATS` · `BOSS_WEAPON_SKILLS` · Pattern JSON 이관 대상
- VS 1차 보스 = **세스** (P0 LOCK)

---

## 10. 명명·경로 (의도)

- Data Asset: `/Game/Excelion/Data/Mecha/DA_Mecha_Brave` 등
- 기존 문서 id (brave-001)와 동기화

---

## 11. 구현 시 원칙

1. 본 문서를 데이터 구조 SSOT로 사용한다.
2. UNREAL_ARCHITECTURE · Readiness 문서는 본 스키마를 가리킨다.
3. 런타임 필드를 Data Asset에 넣지 않는다.
4. 필드 타입(float/int) 최종 확정은 C++ 구조체 작성 시 한다.

---

## 12. TBD (프로토타입 후)

- 최종 구조체 필드 타입 (float vs int)
- 패턴 데이터 스키마 상세 (PATTERN_EXECUTION_SPEC 정합)
- Gameplay Tags 도입 시점

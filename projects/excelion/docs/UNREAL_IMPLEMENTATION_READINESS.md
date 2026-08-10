# Unreal Implementation Readiness — Excelion

> 2026-08-10 · Unreal 설치 전 최종 사전점검  
> 기준 Commit: `0807487` (PR #100 super robot visual language 반영)

**판정: READY WITH CONDITIONS**

현재 환경에는 Unreal Engine이 설치되어 있지 않음.  
실제 `.uproject` 생성·빌드·Editor 실행은 수행하지 않음. 문서 기반 검증만 수행.

---

## 기준 Commit

- 최신 main: `0807487`
- P0 LOCK: `aa69273` / `ff20ae5`
- PR #100: super robot visual language per-unit 반영

---

## 현재 Unreal 결정 (P0 LOCK)

| 항목 | 값 |
|------|-----|
| UE | **5.4.x** (개발 시작 시 구체 패치 선정·고정. 업그레이드는 별도 검토) |
| Platform | **PC Win64** |
| FPS | **60** |
| Root Motion | **In-place + CharacterMovement** |
| Animation | **30 fps** (판정 = 시간/Notify) |
| Bone | **PascalCase + L_/R_ + 공통 표준 계층** |
| GAS | **1차 제외** (C++ Component + Data Asset) |
| VS Boss | **세스** |

---

## 구현 아키텍처

### Class 구조 (최소)

```
AExcelionGameMode
ABaseMecha (C++)
  ├─ APlayerMecha (BRAVE)
  ├─ AEnemyMecha  (ORD-GRUNT 등)
  └─ ABossMecha   (세스 · 이후)
```

플레이어/적/보스는 **동일 Base**를 공유. 파생은 최소화.

### Component (1차)

| Component | 역할 | 1차 필수 |
|-----------|------|----------|
| CharacterMovement (또는 래퍼) | 이동·대시 | ✅ |
| UDamageComponent | HP · 피격 수신 · 데미지 적용 | ✅ |
| USCoreComponent | 게이지 · 충전/소비 · 발동 이벤트 | ✅ |
| UMechaCombatComponent | 공격 입력 처리 · 히트 박스 트리거 | 권장 |
| UTargetingComponent | 락온 | 2차 (선택) |
| UMechaEnergyComponent | Heat 등 | 2차 |

불필요한 추상화 금지. 1차는 Damage + S-Core + 이동만으로도 검증 가능.

### Data

- **Data Asset**: 메카 스탯 · 무기 · 패턴 정의 (타입 안전)
- **Data Table**: 대량 수치·밸런스 시트 이관용
- **Gameplay Tags**: 1차 최소화. 필요 시만 도입
- GAS 미사용. 일반 C++ + Data Asset 유지

정적 설정(스탯·무기 파라미터)과 런타임 상태(현재 HP·게이지)를 분리한다.

### Input

Enhanced Input 사용. 1차 최소 액션:

| Action | 용도 |
|--------|------|
| Move | 이동 |
| Look | 카메라 |
| Attack | 기본 공격 |
| Evade | 대시/회피 |
| SCore | S-Core 발동 (테스트용) |

Heavy / Ranged / Guard / LockOn / Ultimate는 설계에 존재하면 매핑만 준비, 1차 구현은 미포함.

처리 위치: PlayerController 또는 Mecha의 Enhanced Input 바인딩 → Component/메서드 호출.

### Combat (Hit / Damage)

```
Attack Trigger
  → Hit Detection (Overlap / Trace / 단순 Collision)
  → Damage Apply (UDamageComponent)
  → Reaction (경직·이벤트)
  → S-Core / Energy 영향 (이벤트)
```

- 판정: 시간/Notify 기준. 프레임 번호 하드코딩 금지.
- 중복 판정 방지: 공격 인스턴스 ID 또는 쿨다운.
- 애니 없음 전제: 타이머/키 입력으로 공격 윈도우를 열어 테스트 가능.
- Damage Receiver = UDamageComponent를 가진 Actor.

### S-Core

최소 Component로 시작:

- 상태 (Idle / Charging / Ready / Active)
- 게이지 값
- 충전 / 소비
- 발동 이벤트

필살기 연출·보스 연계는 범위 외.

---

## 최소 구현 골격

1차 범위 (LOCK):

1. 프로젝트 정상 실행
2. C++ GameMode
3. BRAVE 기본 Mecha (플레이스홀더 메시)
4. Enhanced Input
5. 기본 이동
6. 기본 카메라 (SpringArm + Camera)
7. Hit 판정 (최소)
8. Damage Component
9. S-Core Component
10. 최소 테스트 맵

필요 최소 클래스/컴포넌트:

- `AExcelionGameMode`
- `ABaseMecha` (Character 파생)
- `APlayerMecha` (또는 Base만 사용)
- `UDamageComponent`
- `USCoreComponent`
- Input Mapping Context + 기본 Actions
- 테스트용 빈 맵 1개

완성 모델·애니·보스 AI·UI·Niagara·풀 전투·스토리·세이브는 **제외**.

---

## Input 구조

- System: Enhanced Input
- Mapping Context: Default (패드 + KBM)
- 1차 Actions: Move, Look, Attack, Evade, SCore
- 처리: PlayerController → Mecha / Component

설계에 없는 입력은 임의 추가하지 않음.

---

## Hit / Damage 구조

- 방식: 단순 Overlap 또는 Line/Sphere Trace (1차)
- 전달: ApplyDamage 또는 Component 직접 호출
- Receiver: UDamageComponent
- 이벤트: OnDamaged / OnDeath
- 중복 방지: 공격 인스턴스 단위
- 확장: 무기별 히트박스·약점 배율은 Data Asset으로 이후 추가

애니 없이도 테스트 가능한 구조 선택.

---

## S-Core 구조

- Component: USCoreComponent
- 데이터: MaxGauge, Current, ChargeRate, Cost
- 이벤트: OnGaugeChanged, OnActivated
- 1차: 수동 충전/소비 + 발동 로그만으로 검증

과도한 서브시스템·연출 프레임워크 금지.

---

## Unreal Content 구조 (권장)

```
Source/
  Excelion/
    ... (C++ 모듈)

Content/
  Blueprints/
  Characters/
  Mecha/
  Combat/
  Input/
  Data/
  Animation/
  VFX/
  Audio/
  UI/
  Maps/
```

Git의 `projects/excelion/` 문서·에셋 구조와 Unreal Content는 **별개**. 혼동하지 말 것.

---

## Asset Pipeline

| 대상 | 상태 |
|------|------|
| BRAVE | 플레이스홀더로 시작 가능. 실메시·애니 TBD |
| Seth | VS 보스. 스펙 존재. 메시 TBD |
| ORD-Grunt | 양산 적. 스펙 존재. 메시 TBD |
| Skeleton / Bone | P0 LOCK 규칙 적용 |
| Material / Texture | 슈퍼로봇 디자인 언어 (PR #100) 준수 |
| Collision / LOD | 1차 단순 Capsule/Box. LOD는 이후 |

파이프라인(Meshy→Blender→FBX) 문서 계약만 존재. 실작업은 Unreal 골격 이후.

---

## Vertical Slice 구현 순서 (검증됨)

1. 프로젝트 생성 (UE 5.4.x · C++ · Win64)
2. GameMode
3. Input
4. BaseMecha
5. BRAVE (플레이스홀더)
6. Movement
7. Camera
8. Hit
9. Damage
10. S-Core
11. 테스트 적 (단순)
12. 기본 전투 루프
13. 세스 (Phase 최소)
14. UI
15. VFX
16. Audio
17. Playtest

이 순서는 현실적이다. 1~10까지가 현재 지시된 **최소 골격** 범위.

---

## P0 문제

**P0 문제 없음.**

구현 시작을 막는 문서 충돌·결정 미비는 없다.  
(VERTICAL_SLICE.md의 보스 TBD는 P0 LOCK으로 세스로 확정됨 → 문서 동기화는 P1)

---

## P1 문제

- UE 5.4 구체 패치 버전 미선정 (개발 PC에서 설치 시 기록 필요)
- VERTICAL_SLICE.md 등 일부 문서의 보스 TBD가 P0와 불일치 → 동기화 필요
- 카메라 Boom/각도/랙 수치 TBD
- FBX export scale 실측 미완료
- MECHA_DATA_SCHEMA 상세가 상태 문서에서 언급되나 단일 소스가 분산되어 있음 → 구현 시 Data Asset 스키마를 코드와 함께 확정

---

## P2 문제

- 동시 액터·Niagara 인스턴스 상한 측정
- 저사양 30 FPS 폴백 여부
- 최종 해상도 (1080p/1440p)
- 완성 메시·애니·LOD 정책
- 보스 Phase 머신 상세 데이터 구조

---

## 최종 판정

**READY WITH CONDITIONS**

조건:
1. UE 5.4.x 구체 패치를 개발 환경에서 선정·기록할 것
2. 최소 골격 범위(1~10)를 초과하지 말 것
3. P0 LOCK 결정(특히 GAS 제외·In-place·Bone 규칙)을 변경하지 말 것
4. 최신 main `0807487` 기준으로 작업할 것

---

## Unreal 설치 후 첫 작업 (5개)

1. UE 5.4.x 설치 및 사용 패치 버전을 `UNREAL_PRE_IMPLEMENTATION_DECISIONS.md` / 상태 문서에 기록
2. C++ · Win64 · 최소 플러그인으로 Excelion 프로젝트 생성
3. `AExcelionGameMode` + `ABaseMecha`(플레이스홀더) + Enhanced Input(Move/Look)으로 Editor 실행·이동 확인
4. `UDamageComponent` + `USCoreComponent` 추가 후 키 입력으로 데미지/게이지 변경 로그 확인
5. 최소 테스트 맵 1개에 스폰·이동·히트·S-Core 검증 후 Git commit + Build/Run 결과 보고

---

## 참고

- 이 문서는 설계 검증용이다. 실제 Unreal 코드는 UE 환경에서만 작성한다.
- 문제 발생 시 범위를 확장하지 말고 `state/UNREAL_PREPARATION_STATUS.md`에 기록 후 중단.

# UNREAL_ARCHITECTURE — Excelion

> 2026-08-10 · 실제 구현 가능성 기준  
> 원천: COMBAT_SYSTEM · IMPLEMENTATION_MAP · MESHY_BLENDER_PIPELINE_SPEC · BRAVE_FINAL_SPEC

**상태: 초안 · 과도한 추상화 금지**

---

## 1. Engine

| 항목 | 선택 | 사용처 |
|------|------|--------|
| Unreal Engine | **5.x** (버전 TBD) | 전체 |
| 렌더링 | Default (Lumen/Nanite 필요 시 검토) | 메카·환경 |
| 물리 | Chaos (기본) · 과도한 래그돌 지양 | 충돌·피격 |

버전은 `TECHNICAL_REQUIREMENTS` / 파이프라인 G2와 동기화.

---

## 2. Gameplay Framework

| 구분 | 기술 | Excelion 사용 |
|------|------|---------------|
| 핵심 로직 | **C++** | 이동·전투·데미지·S-Core·Phase 상태 머신 |
| 콘텐츠 조정 | **Blueprint** | 수치 튜닝 · 연출 · 에디터 유틸 · AI 동작 조정 |
| 역할 분리 | C++ = 안정·성능 · BP = 반복·연출 | 핵심 시스템은 C++ 우선 |

권장 구조 (최소):

```
AExcelionCharacter (C++)
  ├─ UMechaMovementComponent
  ├─ UMechaCombatComponent
  ├─ UMechaDamageComponent
  ├─ UMechaEnergyComponent (S-Core / Heat)
  └─ (필요 시) UMechaTargetingComponent
```

플레이어 / 적 / 보스는 동일 Base를 공유하거나 최소한의 파생만 둔다. 불필요한 컴포넌트 분리는 하지 않는다.

---

## 3. Input

| 항목 | 기술 | 사용 |
|------|------|------|
| 시스템 | **Enhanced Input** | 이동 · 대시 · 약/강공격 · 가드 · 필살 · 락온 |
| 매핑 | Input Action + Context | 패드 우선 (기존 Switch 패드 설계 반영) |

---

## 4. UI

| 항목 | 기술 | 사용 |
|------|------|------|
| 프레임워크 | **UMG** | HP · S-Core 게이지 · Heat · 보스 Phase · 결과 화면 · 최소 HUD |
| 위젯 | Widget Blueprint | 콘텐츠 배치 · 애니메이션 |

최소 HUD: 플레이어 HP, S-Core, Heat, 락온 마커, 위험 경고.

---

## 5. Animation

| 항목 | 기술 | 사용 |
|------|------|------|
| 상태 | **Animation Blueprint** | Idle / Move / Attack / Hit / Down |
| 단발 | **Montage** | 공격 · 필살 · 피격 · 다운 |
| 블렌드 | **Blend Space** | 이동 방향·속도 |
| IK | 필요 시만 | 발 접지 · 조준 (1차 최소) |

파이프라인: Blender → FBX → UE Skeletal Mesh + AnimSequence.  
Root motion: 1차 제안 = in-place + CharacterMovement (MESHY_BLENDER_PIPELINE_SPEC).

---

## 6. AI

| 항목 | 기술 | 사용 |
|------|------|------|
| 컨트롤러 | **AI Controller** | 적·보스 |
| 행동 | **Behavior Tree** | 추적 · 공격 · 패턴 선택 |
| 환경 쿼리 | **EQS** | 필요 여부 검토 (1차는 단순 거리·시야로 충분할 수 있음) |

보스: Phase 상태 머신(C++ 또는 BT 서비스) + 패턴 데이터 실행.  
양산 적: 단순 추적·근접/원거리 공격 루프.

---

## 7. VFX

| 항목 | 기술 | 사용 |
|------|------|------|
| 파티클 | **Niagara** | 히트 · 필살 · 코어 점등 · 광기 · 경고 |

슈퍼로봇 연출: 클린한 한 방 · accent 호박 계열 · 과한 그을음 지양 (BRAVE 스펙).

---

## 8. Audio

| 항목 | 기술 | 사용 |
|------|------|------|
| 시스템 | Unreal Audio + **MetaSounds** (필요 시) | 타격 · 회피 · 필살 · 경고 · BGM 훅 |

1차는 Sound Cue / MetaSound 최소 세트로 피드백 버스에 연결.

---

## 9. Data

| 항목 | 기술 | 사용 |
|------|------|------|
| 개체 정의 | **Data Asset** | 메카 스탯 · 무기 · 패턴 정의 (타입 안전·참조 용이) |
| 테이블 | **Data Table** | 수치 일괄 · 밸런스 시트 이관 |
| 태그 | **Gameplay Tags** | 상태·속성·패턴 분류 (필요 시 도입 · 1차는 최소화) |

권장: 메카/무기/패턴의 **구조체 + Data Asset** 우선. 대량 수치는 Data Table.

---

## 10. Save

| 항목 | 기술 | 사용 |
|------|------|------|
| 저장 | **SaveGame** | 진행도 · 옵션 · (필요 시) 숙련 플래그 |

Vertical Slice 단계에서는 최소(옵션·재도전)만. 스토리 플래그는 기존 TEXT-LOCK과 정합.

---

## 11. 모듈 의존 (개념)

```
GameMode / GameState
  └─ Level (전투 지역 1)
       ├─ Player (BRAVE)
       ├─ Enemies (ORD-GRUNT …)
       ├─ Boss (Phase Runner)
       ├─ UI (HUD / Result)
       └─ Feedback Bus (VFX / Audio / Camera shake)
```

패턴 실행·판정·피드백은 공통 버스로 모아 보스/잡몹이 공유할 수 있게 한다.

---

## 12. C++ / Blueprint 역할 정리

| C++ | Blueprint |
|-----|-----------|
| Character / Component 기본 클래스 | 파생 BP · 수치 오버라이드 |
| 데미지·게이지·Phase 로직 | 연출 타이밍 · 카메라 시퀀스 |
| 입력 바인딩 골격 | Input Mapping Context 조정 |
| Data Asset 타입 정의 | 에셋 인스턴스 생성·편집 |
| AI 컨트롤러 골격 | Behavior Tree / Task 조정 |

---

## 13. 비범위

- 네트워크 리플리케이션
- 완전 데이터 드리븐 퀘스트 시스템
- 실시간 프로시저럴 메카 생성
- 과도한 ECS/서브시스템 남발

단순하고 공유 가능한 메카 구조를 유지한다.

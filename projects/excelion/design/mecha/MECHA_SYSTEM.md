# MECHA_SYSTEM — Excelion

> 2026-08-10 · 슈퍼로봇 중심 · 공유 가능 구조  
> 원천: BRAVE_FINAL_SPEC · SUPER_ROBOT_DESIGN_LANGUAGE · UNREAL_ARCHITECTURE

**상태: 초안 · 불필요한 컴포넌트 분리 금지**

---

## 1. 공통 구조

```
BaseMecha
 ├─ PlayerMecha   (BRAVE / EXCELION)
 ├─ EnemyMecha    (ORD-*)
 └─ BossMecha     (세스 · 네메시스 · …)
```

Unreal에서는 `AExcelionCharacter` (C++)를 공통 베이스로 두고, 역할별 Blueprint 또는 얇은 파생 클래스로 확장한다.

---

## 2. 주요 책임 (논리적 모듈)

실제 구현 시 컴포넌트로 나눌지, Character에 모을지는 **필요 최소**로 결정한다.

| 모듈 | 역할 | 비고 |
|------|------|------|
| Movement | 이동 · 대시 · 회전 | CharacterMovement 연동 |
| Combat | 공격 입력 · 콤보 · 히트 요청 | |
| Weapon | 장착·발사·수납 | 소켓 · Data |
| Damage | HP · 피격 · 경직 · 다운 | |
| Armor | 감쇠 · (선택) 부위 | 1차 단순화 가능 |
| Energy | S-Core · Heat · 광기 레벨 | 플레이어 중심 |
| Targeting | 락온 · 조준 보조 | |
| Animation | AnimBP · Montage 트리거 | |
| AI | 적/보스 전용 | Player는 N/A |
| VFX | 히트·필살·코어·광기 | Niagara 훅 |
| Audio | 타격·경고·보이스 훅 | |

**원칙:** 여러 기체가 공유할 수 있는 것만 공통으로 둔다. 보스 전용 기믹은 Boss 쪽에서 확장.

---

## 3. PlayerMecha

- 입력 기반 Combat / Energy
- S-Core 단계 · 필살 · 초필
- 광기 연출 (실루엣 유지)
- 엑셀리온 규칙 (EP13+)은 동일 골격 + 상태/파츠 활성

---

## 4. EnemyMecha

- AI Controller + 단순 BT
- 공통 Damage/Movement
- 무기·패턴은 Data로 주입

---

## 5. BossMecha

- Phase 상태 머신
- Pattern Executor (데이터 기반)
- 기존 보스 스펙(세스·네메시스 등) 연동
- 소환·특수 기믹은 보스별 확장

---

## 6. 디자인 제약 (변경 금지)

- **SUPER ROBOT FIRST**
- 건담식 리얼로봇 · 과도한 패널 · 날씬 휴머노이드 축소 금지
- BRAVE: 여성적 비례 슈퍼로봇 · 3톤 · 여백 · EP1–12 동일 형태

---

## 7. 공유 Skeleton / 애셋

- 인간형 메카는 본 계층 공유 목표 (파이프라인 TBD 해소 후)
- 머티리얼 인스턴스 3톤 교체
- 애니메이션은 역할별 클립 + 공통 히트/다운 가능 시 재사용

---

## 8. 비범위

- 파츠 실시간 교체 시스템
- 완전 모듈러 로봇 조립
- 리얼 기체 정비·탄약 시스템

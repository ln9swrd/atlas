# Unreal Implementation Readiness — Excelion

> 2026-08-10 · Unreal 설치 전 최종 사전점검  
> 기준 Commit: `0807487` (PR #100) · SSOT 정리 후 갱신

**판정: READY WITH CONDITIONS**

현재 환경에는 Unreal Engine이 설치되어 있지 않음.  
실제 `.uproject` 생성·빌드·Editor 실행은 수행하지 않음. 문서 기반 검증만 수행.

---

## 기준 Commit

- P0 LOCK / PR #100 이후 SSOT 정리 반영
- Data SSOT: `design/mecha/MECHA_DATA_SCHEMA.md`
- VS 보스 SSOT: **세스** (P0 LOCK · Unreal/VS 문서 통일)

---

## 현재 Unreal 결정 (P0 LOCK)

| 항목 | 값 |
|------|-----|
| UE | **5.4.x** (개발 환경 설치 시 실제 사용 가능한 패치 버전을 확정하고 LOCK) |
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

### Component (1차)

| Component | 역할 | 1차 필수 |
|-----------|------|----------|
| CharacterMovement | 이동·대시 | ✅ |
| UDamageComponent | HP · 피격 · 데미지 | ✅ |
| USCoreComponent | 게이지 · 충전/소비 · 발동 | ✅ |
| UMechaCombatComponent | 공격·히트 트리거 | 권장 |
| UTargetingComponent | 락온 | 2차 |

### Data (SSOT)

- 기준 문서: `design/mecha/MECHA_DATA_SCHEMA.md`
- Static → Data Asset / Data Table
- Runtime → C++ Component / Actor
- GAS 미사용

### Input / Hit / S-Core

Readiness 최초 정의 유지. 최소 골격 범위 동일.

---

## 최소 구현 골격

1~10: 프로젝트 실행 · GameMode · BRAVE · Input · 이동 · 카메라 · Hit · Damage · S-Core · 테스트 맵

완성 모델·애니·보스 AI·UI·Niagara·풀 전투·스토리·세이브 제외.

---

## P0 문제

**없음**

---

## P1 문제

| 항목 | 상태 |
|------|------|
| 보스 SSOT (세스) | **정리 완료** (VERTICAL_SLICE · Charter · COMBAT_SYSTEM · PLAYABLE_SCOPE · IMPLEMENTATION_QUEUE) |
| Data Schema SSOT | **정리 완료** (MECHA_DATA_SCHEMA = Static/Runtime 구분 · SSOT 명시) |
| UE 5.4 구체 패치 | 개발 PC 설치 시 확정·LOCK |
| 카메라 수치 · FBX scale | 프로토타입 측정 (지금 확정 금지) |

스토리/EP5의 몬투는 **의도적 유지** (중보스). Unreal VS 1차만 세스.

---

## P2 문제

- 동시 액터·Niagara 상한 측정
- 저사양 폴백 · 최종 해상도
- 완성 메시·애니·LOD
- 보스 Phase 상세 데이터 구조

---

## 최종 판정

**READY WITH CONDITIONS**

조건:
1. UE 5.4.x 패치를 개발 환경에서 선정·기록
2. 최소 골격 범위 준수
3. P0 LOCK 변경 금지
4. 최신 main 기준 작업

---

## Unreal 설치 후 첫 작업

1. UE 5.4.x 설치 · 패치 버전 문서 기록
2. C++ · Win64 · 최소 플러그인 프로젝트 생성
3. GameMode + BaseMecha + Enhanced Input → 이동 확인
4. Damage + S-Core Component → 키 입력 검증
5. 테스트 맵 · Git commit · Build/Run 보고

---

## 참고

- 실제 Unreal 코드는 UE 환경에서만 작성
- 문제 시 범위 확장 금지 · 상태 문서 기록 후 중단

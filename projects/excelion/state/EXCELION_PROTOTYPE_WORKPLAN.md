# Excelion Prototype Work Plan

> 기록일: 2026-08-19  
> 위치: `projects/excelion/state/EXCELION_PROTOTYPE_WORKPLAN.md`  
> 상태: RECORDED  
> 갱신: 2026-08-19 — Player Mesh 역할 분리 (Manny=임시, AXION=최종 Canon)

## 목적

Unreal Editor와 Agent를 사용할 수 있을 때 Player/Enemy 기반 프로토타입을 단계적으로 구현한다.

## 핵심 원칙

```
READ-ONLY 조사
→ 결과 보고
→ Master 승인
→ 최소 수정
→ Diff 확인
→ Build
→ Master PIE 검증
→ Git 기록
```

## Phase A — 기준선

### A1. Git 기준선
- HEAD
- Branch
- Working Tree
- 변경 파일

### A2. Unreal 프로젝트 상태
- 프로젝트 Load
- Map Load
- Compile/Editor 오류
- Blueprint 오류
- C++ Module 상태

## Phase B — 런타임 구조

### B1. GameMode → PlayerController → Pawn
확인:
- 실제 PIE GameMode
- PlayerController
- Default Pawn
- 실제 Spawn Character
- C++ ↔ Blueprint 상속 관계

### B2. Input → Character
확인:
- Enhanced Input
- Mapping Context
- Move
- Look
- Dash
- Attack

## Phase C — Player

### C1. Player Mesh
확인:
- 현재 사용 Mesh (Manny 등 임시/placeholder 가능)
- Skeleton
- Animation Blueprint
- CharacterMesh0
- 기존 Fallback Mesh

역할 분리:
- Manny / UE Mannequin = 임시 테스트 Mesh (실험·파이프라인용, 최종 아님)
- AXION = 최종 Player Canon · Mesh 교체 대상 (Three-view APPROVED · P0 Mesh 대기)

### C2. Movement
기존 Movement 시스템을 우선 재사용한다.

### C3. Dash
기존 구조가 있으면 재사용하고, 없을 경우 최소 구현만 검토한다.

## Phase D — Enemy

### D1. Enemy Mesh
확인:
- BP_ExcelionEnemy
- BP_PowerEnemy
- 실제 Spawn Class
- 실제 Skeletal Mesh
- Skeleton
- Animation Blueprint

### D2. Enemy Spawn
확인:
- Level 배치인지
- Runtime Spawn인지
- 실제 PIE 사용 Class

### D3. Enemy AI
확인:
- AIController
- Blackboard
- Behavior Tree
- NavMesh
- Target
- MoveTo

## Phase E — Combat

### E1. Attack
기존 Animation/Montage 구조를 조사한다.

### E2. Hit / Damage
기존 Damage Framework가 있으면 우선 재사용한다.

### E3. Death
최소 경로:

```
HP
↓
Damage
↓
HP <= 0
↓
Death
↓
AI Stop
↓
제거
```

## Phase F — Prototype PIE

최종 Master 검증 대상:

```
Player Spawn
↓
Player Mesh 표시 (임시 Manny 또는 placeholder 허용)
↓
Move
↓
Dash
↓
Enemy Spawn
↓
Enemy 발견
↓
Enemy 추적
↓
근접 공격
↓
Damage
↓
Enemy Death
```

PIE VERIFIED는 Master가 실제 플레이로 확인한 경우에만 기록한다.

## Agent 운영 규칙

각 작업은 반드시:

```
READ-ONLY
↓
보고
↓
Master 승인
↓
최소 수정
↓
Diff
↓
Build
↓
Master PIE
```

순서로 진행한다.

## Scope Lock

다음은 임의로 수행하지 않는다.

- 추가 기능
- 리팩터링
- 파일 이동
- 파일 삭제
- Blueprint 변경
- Asset 변경
- Canon 변경
- 프로젝트 구조 변경

## 검증 상태 정의

```
CODE VERIFIED
BUILD VERIFIED
EDITOR VERIFIED
PIE VERIFIED
NOT VERIFIED
```

자동화 테스트나 코드 존재만으로 PIE VERIFIED라고 기록하지 않는다.

## Git 작업

이번 작업에서는 작업 계획 문서만 기록한다.

허용:
- 작업 계획 문서 신규 생성 또는 기존 문서 최소 수정
- 해당 문서의 diff 확인

금지:
- C++ 수정
- Blueprint 수정
- .uasset 수정
- .ini 수정
- Asset 변경
- 프로젝트 구조 변경

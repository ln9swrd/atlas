# UNREAL_PREPARATION_STATUS — Excelion

> Updated: 2026-08-10  
> Work order: `state/WORK_ORDER_UNREAL_PREP.md`  
> P0: `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md`  
> Commit: aa6927327ac71d6e494026760ea5e2a699e26b10

---

## 완료

### 1차 준비 (d95fd57)
- 조사 + Charter · Architecture · Technical Requirements
- CORE_GAMEPLAY · COMBAT_SYSTEM · MECHA_SYSTEM · MECHA_DATA_SCHEMA
- ART_* · ASSET_REGISTER · VERTICAL_SLICE · 본 상태 문서 초판
- Master 검토 **승인** (설정 충돌 없음 · 구현 가능 · 과설계 억제 · VS 현실적)

### P0 결정 — LOCK (Master 승인 2026-08-10)
- `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md` LOCK 반영
- UE 5.4.x (개발 시작 시 구체 패치 선정·고정 · 업그레이드는 별도 검토)
- VS 보스 = 세스
- PC Win64
- 목표 60 FPS
- Root Motion = In-place + CharacterMovement
- 애니 30 fps (판정은 시간/Notify)
- Bone Naming = PascalCase + L_/R_ + 공통 표준 계층
- GAS = 1차 제외 (C++ Component + Data Asset 유지)

---

## 진행 중

- **없음** (P0 LOCK 완료)

---

## 다음 작업

### Unreal 프로젝트 생성 단계

**조건:**
- Unreal Engine 5.4.x (선정 패치 기록)
- C++
- PC / Win64
- 기존 Excelion 설계와 일치하는 최소 프로젝트
- 불필요한 플러그인 추가 금지
- 네트워크 기능 제외
- GAS 제외
- 복잡한 프레임워크 추가 금지

**첫 구현 범위 (제한):**
1. 프로젝트 정상 실행
2. C++ 기본 GameMode
3. BRAVE 기본 Character/Mecha 골격
4. Enhanced Input
5. 기본 이동
6. 기본 카메라
7. 기본 히트 판정
8. Damage Component
9. S-Core Component
10. 최소 테스트 맵

**아직 구현하지 않음:**
- 완성된 BRAVE 모델
- 완성 애니메이션
- 보스 AI
- 완성 UI
- Niagara 연출
- 풀 전투 시스템
- 스토리
- 세이브 시스템

**목표:** Unreal 프로젝트가 정상 빌드되고 BRAVE가 움직이며 히트와 S-Core 최소 골격이 검증되는 것.

**작업 규칙:**
- 작업 시작 전: UE 버전 확인 · 개발 환경 확인 · 프로젝트 경로 확인
- 문제 발생 시 임의로 범위 확장하지 말고 본 문서에 기록 후 중단
- 반드시 Git에 기록
- 완료 후 보고: Build 성공 여부 · Editor 실행 여부 · 테스트 결과 · 생성된 파일 · Git commit SHA · 다음 작업

---

## 결정 상태

| # | 항목 | 상태 |
|---|------|------|
| P0-1 | UE 5.4.x | **LOCK** |
| P0-2 | VS 보스 = 세스 | **LOCK** |
| P0-3 | PC Win64 / 개발 HW | **LOCK** |
| P0-4 | 목표 60 FPS | **LOCK** |
| P0-5 | Root Motion (In-place + CM) | **LOCK** |
| P0-6 | 애니 30 fps | **LOCK** |
| P0-7 | Bone Naming 표 | **LOCK** |
| — | GAS | **제외 LOCK** |
| P1 | 카메라·상한·해상도 등 | 측정 후 |

---

## 연속 작업 메모

- P0 LOCK 완료 · 프로젝트 생성 지시 가능
- 기존 TEXT-LOCK · SUPER_ROBOT 변경 없음
- 엔진 기준선 5.4 고정 · 상위 버전 기능 조사 후 가져오기 금지

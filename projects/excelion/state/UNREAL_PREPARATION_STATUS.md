# UNREAL_PREPARATION_STATUS — Excelion

> Updated: 2026-08-10  
> Work order: `state/WORK_ORDER_UNREAL_PREP.md`  
> P0: `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md`

---

## 완료

### 1차 준비 (d95fd57)
- 조사 + Charter · Architecture · Technical Requirements
- CORE_GAMEPLAY · COMBAT_SYSTEM · MECHA_SYSTEM · MECHA_DATA_SCHEMA
- ART_* · ASSET_REGISTER · VERTICAL_SLICE · 본 상태 문서 초판
- Master 검토 **승인** (설정 충돌 없음 · 구현 가능 · 과설계 억제 · VS 현실적)

### P0 결정안 작성
- `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md` 작성
- 권장: UE 5.4 · VS 보스 세스 · PC Win64 · 60 FPS · In-place Root · 애니 30fps · PascalCase 본 계층

---

## 진행 중

- **P0 Master 확정 대기** (권장안 승인/수정)

---

## 미착수

- Unreal 프로젝트 생성
- C++/Blueprint 코드
- 메쉬·애니 실제작
- P1 측정 항목 (카메라·액터 상한·Niagara 등)

---

## 결정 필요

| # | 항목 | 상태 |
|---|------|------|
| P0-1 | UE 5.4.x | 권장 · **승인 대기** |
| P0-2 | VS 보스 = 세스 | 권장 · **승인 대기** |
| P0-3 | PC Win64 / 개발 HW | 권장 · **승인 대기** |
| P0-4 | 목표 60 FPS | 권장 · **승인 대기** |
| P0-5 | Root Motion (A) | 권장 · **승인 대기** |
| P0-6 | 애니 30 fps | 권장 · **승인 대기** |
| P0-7 | Bone Naming 표 | 권장 · **승인 대기** |
| — | GAS | **제외** (단순 컴포넌트 유지) |
| P1 | 카메라·상한·해상도 등 | 측정 후 |

---

## 다음 작업

1. Master가 P0 권장안 승인 또는 수정 지시
2. 승인 시 UNREAL_PRE_IMPLEMENTATION_DECISIONS / 본 상태를 LOCK 표기
3. Unreal 프로젝트 생성 지시 (Win64 · C++ · 5.4)
4. 최소 골격: 이동 · 히트 · S-Core

---

## 연속 작업 메모

- 1차 문서 세트 = 승인 완료
- 프로젝트 생성은 **P0 승인 후**
- 기존 TEXT-LOCK · SUPER_ROBOT 변경 없음

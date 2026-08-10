# UNREAL_PREPARATION_STATUS — Excelion

> Updated: 2026-08-10  
> Work order: `state/WORK_ORDER_UNREAL_PREP.md`  
> P0: `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md`  
> Readiness: `docs/UNREAL_IMPLEMENTATION_READINESS.md`  
> Commit: b8051e6652252079ca32d91be0b478ab945b8e86

---

## 완료

### 1차 준비 (d95fd57)
- 조사 + Charter · Architecture · Technical Requirements
- CORE_GAMEPLAY · COMBAT_SYSTEM · MECHA_SYSTEM · MECHA_DATA_SCHEMA
- ART_* · ASSET_REGISTER · VERTICAL_SLICE · 본 상태 문서 초판
- Master 검토 **승인**

### P0 결정 — LOCK (Master 승인 2026-08-10)
- UE 5.4.x · VS 보스 세스 · PC Win64 · 60 FPS
- In-place + CharacterMovement · 애니 30 fps · PascalCase Bone
- GAS 1차 제외

### Unreal 설치 전 최종 사전점검 — 완료 (2026-08-10)
- `docs/UNREAL_IMPLEMENTATION_READINESS.md` 작성
- 판정: **READY WITH CONDITIONS**
- P0 문제 없음
- 최소 골격 구조·Input·Hit/Damage·S-Core·폴더·파이프라인·구현 순서 검증
- 현재 회사 환경에는 Unreal Engine 미설치 → 실제 프로젝트 생성/빌드 불가

---

## 진행 중

- **없음**

---

## 다음 작업

### UE 5.4 설치 환경에서

1. UE 5.4.x 구체 패치 선정·기록
2. 프로젝트 생성 (C++ · Win64 · 최소 플러그인)
3. 최소 골격 구현 (GameMode · BRAVE · Input · 이동 · 카메라 · Hit · Damage · S-Core · 테스트 맵)
4. Build / Run 검증 후 Git commit + 결과 보고

**범위 초과 금지.** 완성 모델·애니·보스 AI·UI·VFX·스토리·세이브 제외.

---

## 결정 상태

| # | 항목 | 상태 |
|---|------|------|
| P0-1 | UE 5.4.x | **LOCK** |
| P0-2 | VS 보스 = 세스 | **LOCK** |
| P0-3 | PC Win64 | **LOCK** |
| P0-4 | 60 FPS | **LOCK** |
| P0-5 | In-place + CM | **LOCK** |
| P0-6 | 애니 30 fps | **LOCK** |
| P0-7 | Bone Naming | **LOCK** |
| — | GAS | **제외 LOCK** |
| Readiness | 사전점검 | **완료** |
| P1 | 카메라·패치 버전·문서 동기화 등 | 구현 중 해결 |

---

## 연속 작업 메모

- 최신 main 기준: `0807487` → 이후 readiness 커밋 `b8051e6`
- Unreal 실제 작업은 UE 설치 환경에서만 수행
- 문제 발생 시 범위 확장하지 말고 본 문서에 기록 후 중단

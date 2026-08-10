# UNREAL_PREPARATION_STATUS — Excelion

> Updated: 2026-08-10  
> P0: `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md`  
> Readiness: `docs/UNREAL_IMPLEMENTATION_READINESS.md`  
> Data SSOT: `design/mecha/MECHA_DATA_SCHEMA.md`

---

## 완료

### P0 LOCK
- UE 5.4.x · VS 보스 세스 · PC Win64 · 60 FPS
- In-place + CM · 애니 30 fps · PascalCase Bone · GAS 제외

### Unreal 설치 전 사전점검
- Readiness 문서 · 판정 READY WITH CONDITIONS

### P1 SSOT 정리 (2026-08-10)
- **보스:** Unreal/VS 관련 문서에서 VS 보스 = **세스** 통일
  - VERTICAL_SLICE · UNREAL_DEVELOPMENT_CHARTER · COMBAT_SYSTEM · PLAYABLE_SCOPE_V1 · IMPLEMENTATION_QUEUE
  - 스토리/EP5 몬투는 유지 (중보스)
- **Data Schema:** `MECHA_DATA_SCHEMA.md`를 SSOT로 지정
  - Static Configuration = Data Asset/Table
  - Runtime State = C++ Component/Actor
- UE 5.4 구체 패치: 개발 환경 설치 시 확정 (임의 번호 미지정)

---

## P0 / P1 / P2

| 등급 | 내용 | 상태 |
|------|------|------|
| **P0** | 구현 차단 이슈 | **없음** |
| **P1** | 보스 SSOT · Data Schema SSOT | **정리 완료** |
| **P1** | UE 5.4 실제 패치 버전 | 개발 PC에서 확정 |
| **P2** | 카메라·FBX scale·액터/Niagara 상한·해상도·LOD | 프로토타입 측정 |

---

## 다음 작업

회사 환경: Unreal 사전준비 **사실상 완료**. 추가 문서 확장보다 개발 PC로 이동.

개발 PC (UE 5.4 설치 후):
1. 패치 버전 기록
2. 프로젝트 생성 (C++ · Win64 · 최소)
3. 최소 골격 (이동 · Hit · Damage · S-Core · 테스트 맵)
4. Build/Run · Git 보고

**범위 초과 금지.**

---

## 연속 작업 메모

- Unreal 실행 불가 환경에서는 프로젝트 생성 시도하지 않음
- 문제 발생 시 범위 확장하지 말고 본 문서 기록 후 중단

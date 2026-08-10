# WORK_ORDER — Unreal First Build

> 2026-08-10  
> 회사 측 사전준비 완료 기준: `e81c154`  
> 대상: UE 5.4 설치 개발 환경 에이전트

**목적:** 최소 골격만 빌드·실행한다. 전투 완성·보스·UI·VFX·스토리 금지.

---

## 전제

- P0 LOCK 유지 (`docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md`)
- VS 보스 = 세스 (스토리 EP5 몬투와 별개)
- Data SSOT = `design/mecha/MECHA_DATA_SCHEMA.md`
- GAS 미도입
- 최신 `main` pull 후 작업

---

## 순서 (이 순서만)

1. **최신 main pull**
2. **UE 5.4.x 설치** → 실제 패치 버전을 문서에 기록 후 LOCK
3. **프로젝트 생성** — C++ · Win64 · 불필요 플러그인·네트워크·GAS 제외
4. **GameMode** — C++ 기본
5. **BaseMecha / BRAVE** — 플레이스홀더 메시
6. **Enhanced Input** — Move, Look (필요 시 Attack, Evade, SCore)
7. **이동 + 카메라** — In-place + CharacterMovement · SpringArm
8. **Damage Component** — HP · 피격 수신
9. **S-Core Component** — 게이지 · 충전/소비 · 이벤트
10. **최소 테스트 맵** — 스폰 1
11. **Build / Run** 검증
12. **Git commit** + 결과 보고

---

## 첫 성공 기준 (이것만)

```
BRAVE 스폰 → 이동 → 공격/히트 → Damage 반영 → S-Core 상태 변화
```

성공 전에는 다음으로 **확장하지 않는다.**

- 보스 AI · 세스 Phase
- 완성 전투 시스템
- 완성 UI · Niagara · Audio
- 스토리 · 세이브
- 완성 메시 · 애니

---

## 작업 전 확인

- [ ] UE 버전 = 5.4.x (패치 기록)
- [ ] 플랫폼 = Win64
- [ ] C++ 프로젝트
- [ ] main 최신

## 작업 후 보고

- Build 성공 여부
- Editor 실행 여부
- 테스트 결과 (스폰·이동·Damage·S-Core)
- 생성 파일 목록
- Git commit SHA
- 다음 작업 제안

## 문제 발생 시

범위 확장 금지. `state/UNREAL_PREPARATION_STATUS.md`에 기록 후 중단.

---

## 참조

| 문서 | 용도 |
|------|------|
| `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md` | P0 LOCK |
| `docs/UNREAL_IMPLEMENTATION_READINESS.md` | 구조·첫 작업 |
| `design/mecha/MECHA_DATA_SCHEMA.md` | Data SSOT |
| `state/UNREAL_PREPARATION_STATUS.md` | 상태 |

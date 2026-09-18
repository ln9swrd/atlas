# WORK_ORDER — Unreal First Build

> 2026-08-10  
> 플레이어 기체: **AXION** (구 가칭 BRAVE)  
> S-Core: **가칭/TBD** (기능만 구현)  
> 명칭: `docs/NAMING_STATUS.md`

**목적:** 최소 골격만 빌드·실행. 전투 완성·보스·UI·VFX·스토리 금지.

---

## 전제

- P0 LOCK 유지
- VS 보스 = 세스
- Data SSOT = MECHA_DATA_SCHEMA
- GAS 미도입
- 최신 main pull

---

## 순서

1. 최신 main pull
2. UE 5.4.x 설치 → 패치 LOCK
3. 프로젝트 생성 — C++ · Win64 · 최소 플러그인
4. GameMode
5. **BaseMecha / AXION** — 플레이스홀더
6. Enhanced Input — Move, Look (Attack, Evade, SCore 가칭)
7. 이동 + 카메라
8. Damage Component
9. **S-Core Component (가칭)** — 게이지·충전/소비
10. 최소 테스트 맵
11. Build / Run
12. Git commit + 보고

---

## 첫 성공 기준

```
AXION 스폰 → 이동 → 공격/히트 → Damage → S-Core(가칭) 상태 변화
```

성공 전 확장 금지: 보스 AI · 완성 전투 · UI · Niagara · 스토리 · 세이브 · 완성 메시

---

## 보고

Build · Editor · 테스트 · 파일 · Commit SHA · 다음 작업

문제 시 범위 확장 금지 · `UNREAL_PREPARATION_STATUS.md` 기록 후 중단.

# IMPLEMENTATION_QUEUE — 실행 큐

> 2026-08-09 · 갱신 2026-08-10 · playable V1 · VS 보스 **세스** (P0 LOCK)

---

## 0순위 · 자산

- [ ] `assets/placeholder/player` BRAVE 더미
- [ ] `assets/placeholder/enemy` 속도형·파워형 각 1
- [ ] `assets/placeholder/boss` **세스** 더미 (크기만 압도)

---

## 1순위 · 플레이어

- [ ] 이동
- [ ] 기본 공격
- [ ] 피격 · HP
- [ ] 회피(대쉬) · 짧은 무적

---

## 2순위 · 적

- [ ] 적 AI 최소 (접근·공격 1패턴)
- [ ] 패턴 1개 (예고 → 판정 → 피드백)

---

## 3순위 · 보스 (VS = 세스)

- [ ] 세스 Phase 골격 (시간·씰 트리거)
- [ ] 패턴 1–2개 (`PATTERN_EXECUTION_SPEC` S*)
- [ ] 재도전 루프

---

## 4순위 · 확장 (V1 후)

- [ ] 몬투 (EP5 · 별도)
- [ ] 아누비스 인지 레이어
- [ ] 피드백 풀셋 · 실패 원인 UI

---

## 금지 (지금)

- 고퀄 모델링 선행
- 스토리 컷신 우선
- 문서만 추가하고 더미·조작 없음

---

## 완료 조건 (V1)

`PLAYABLE_SCOPE_V1` 성공 정의 충족.

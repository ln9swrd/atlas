# GAME_COMBAT_INDEX — 전투 루프 색인

> 2026-08-09 · **prototype v1 실행 레이어**

**상태: 운용**

---

## 플레이어

| 형태 | 문서 |
|------|------|
| BRAVE | mecha/brave/BRAVE_FINAL_SPEC |
| EXCELION | mecha/excelion/EXCELION_FINAL_SPEC |

---

## 중간보스

| 기 | EP | Phase | 실행 패턴 |
|----|-----|-------|----------|
| 몬투 | 5 | MIDBOSS_PHASE_DETAIL | PATTERN_EXECUTION_SPEC M* |
| 세스 | 6 | MIDBOSS_PHASE_DETAIL | PATTERN_EXECUTION_SPEC S* |
| 아누비스 | 7 | ANUBIS_PHASE · ANUBIS_MECHANICS | PATTERN_EXECUTION_SPEC A* |

---

## Prototype 레이어 (`design/combat/`)

| 문서 | 역할 |
|------|------|
| PATTERN_EXECUTION_SPEC | 패턴 → 코드/애니 |
| COMBAT_LOOP | 학습→왜곡→붕괴 루프 |
| FEEDBACK_SYSTEM | 타격·회피·위험·실패 |
| ANUBIS_MECHANICS | 인지 교란 시스템 |
| BOSS_STATS | 수치 1차 고정 |
| IMPLEMENTATION_MAP | 구현 우선순위 |
| DIFFICULTY_CURVE | 난이도 곡선 |
| SKILL_COUNTER_TABLE | 대응표 |
| TUNING_GUIDE | 튜닝 |

테스트: `design/test/COMBAT_TEST_SCENARIOS.md`

---

## 구현 체크

1. 텔레그래프 있는가  
2. 대응이 정의돼 있는가  
3. Phase = 시간+트리거인가  
4. 랜덤 즉사·비가시 없는가  

```
CURRENT: prototype execution layer indexed
NEXT: 실제 전투 프로토타입 구현
```

# GAME_COMBAT_INDEX — 전투 루프 색인

> 2026-08-09 · midboss v1.1  
> 목적: 규칙·수치·Phase 문서를 한곳에서 참조

**상태: 운용**

---

## 플레이어

| 형태 | 문서 | 루프 한 줄 |
|------|------|------------|
| BRAVE | mecha/brave/BRAVE_FINAL_SPEC | 대시·콤보·필살·광기 리스크 |
| EXCELION | mecha/excelion/EXCELION_FINAL_SPEC | 전개·봉쇄 무시·플레어·시간 벌기 |

---

## 중간보스 Phase

| 기 | EP | Phase 문서 | 루프 한 줄 |
|----|-----|------------|------------|
| **몬투** | 5 | `MIDBOSS_PHASE_DETAIL` | 다병기 → 약점 창 → 공간붕괴·폭발 |
| **세스** | 6 | `MIDBOSS_PHASE_DETAIL` | 씰 → 표시 불신 → 이중 조건 |
| **아누비스** | 7 | `ANUBIS_PHASE` | 규칙 제시 → 왜곡 → 붕괴 |

공통 구조: `MIDBOSS_DESIGN` · 타입 A/B/C

---

## 기타 보스

| 기 | EP | 문서 | 루프 한 줄 |
|----|-----|------|------------|
| 세크 | 15 | creil/CREIL_FINAL_SPEC | 방패면 → 측면 → 도구 정지 |
| 와제 | 21 | aegis/AEGIS_FINAL_SPEC | 가드 → 반격 → 문 |
| 네메시스 | 9 · 23–24 | nemesis/NEMESIS_FINAL_SPEC | 등급 벽 · 다페이즈 |

---

## 양산

| 기 | 문서 | 루프 |
|----|------|------|
| GRUNT | ORD_FINAL §B | 스폰·접근·쉽게 파괴 |
| HEAVY | §C | 저속 전면 · 측면 약 |
| GUN | §D | 원거리 · 근접 약 |

---

## 수치 · 곡선 · 튜닝

| 항목 | 위치 |
|------|------|
| 중간보스 수치 | **design/combat/BOSS_STATS.md** |
| 난이도 곡선 | design/combat/DIFFICULTY_CURVE.md |
| 스킬 대응 | design/combat/SKILL_COUNTER_TABLE.md |
| 튜닝 기준 | design/combat/TUNING_GUIDE.md |
| 레거시 표 | state/BOSS_STATS_SETH_NEMESIS.md |

Phase 전환 = **시간+트리거** · HP% 금지.

---

## 구현 체크

1. 텔레그래프·신호 있는가  
2. 대응이 30초 안에 읽히는가  
3. 학습→왜곡→신규 흐름인가  
4. 랜덤 즉사·비가시 공격 없는가  

```
CURRENT: GAME_COMBAT_INDEX · midboss combat folder 연동
```

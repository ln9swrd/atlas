# GAME_COMBAT_INDEX — 전투 루프 색인

> 2026-08-09 · 이미지 HOLD 구간용  
> 목적: FINAL §18/§28을 구현 트랙이 한곳에서 참조

**상태: 운용**

---

## 플레이어

| 형태 | 문서 | 루프 한 줄 |
|------|------|------------|
| BRAVE | mecha/brave/BRAVE_FINAL_SPEC | 대시·콤보·필살·광기 리스크 |
| EXCELION | mecha/excelion/EXCELION_FINAL_SPEC | 전개·봉쇄 무시·플레어·시간 벌기 |

---

## 보스

| 기 | EP | 문서 | 루프 한 줄 |
|----|-----|------|------------|
| **몬투** | 5 | ORD_FINAL_SPEC §E · hekaton | 다병기 패턴 → 약점 창 → P2 |
| 세스 | 6 | seth/SETH_FINAL_SPEC | 차단·씰 → 집념 돌파 → 보고 끝 |
| 세크 (구 크레일) | 15 | creil/CREIL_FINAL_SPEC | 거점 사수·방패면 → 측면 → 도구 정지 |
| 와제 (구 아이기스) | 21 | aegis/AEGIS_FINAL_SPEC | 가드 게이지 → 반격 텔레그래프 → 측면/Break → 문 열림 |
| 네메시스 | 7/9/23–24 | nemesis/NEMESIS_FINAL_SPEC | 원격 중력 → 전면 압박 → 디센트 → 오만 유지 |

---

## 양산

| 기 | 문서 | 루프 |
|----|------|------|
| GRUNT | ORD_FINAL §B | 스폰·접근·쉽게 파괴 |
| HEAVY | §C | 저속 전면 · 측면 약 |
| GUN | §D | 원거리 · 근접 약 |

---

## 수치 SoR

| 항목 | 위치 |
|------|------|
| 보스 HP 초안 | state/BOSS_STATS_SETH_NEMESIS.md 등 |
| 확정 밸런스 | **미완 · 다음 작업** |
| 규칙(루프) | 각 *_FINAL_SPEC |

규칙과 숫자를 분리: 본 인덱스는 **규칙 포인터**만.

---

## 구현 체크 (공통)

1. 플레이어 신호 (게이지·텔레그래프·중력 왜곡) 있는가  
2. 대응 행동 30초 안에 읽히는가  
3. 종료 조건이 스토리 EP와 맞는가  
4. 금지 연출(오만 붕괴·비극 주연 등)이 코드/연출에 없는가  

---

```
CURRENT: GAME_COMBAT_INDEX · 몬투 반영
NEXT: state 수치 테이블 확정 작업
BLOCKED: 이미지
```

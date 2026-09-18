# STORY_DESIGN_CONFLICTS — STEP 2

> 2026-08-08  
> 대조: novel/EP01–24 · EPISODE_MATRIX · MECHA_BIBLE · docs/05_ENEMY · 06_MECHA  
> vs design/enemy · brave · mecha · MECHA_MASTER_LIST

**상태: Done**

---

## 1. 방법

| 축 | 스토리 소스 | 디자인 소스 |
|----|-------------|-------------|
| 등장·역할 | EPISODE_MATRIX · 05_ENEMY | MECHA_MASTER_LIST · *_SPEC |
| 외형·키 | MECHA_BIBLE · 본문 암시 | FRAME · ORD · SETH · NEMESIS · CREIL · AEGIS |
| 전투 | MATRIX 전투 기믹 · 05_ENEMY | SPEC 금지·연출 |
| 수치 | BOSS_STATS (참조만) | SPEC (실루엣 중심) |

충돌 = 스토리 행동/등장과 디자인 잠금이 동시에 만족 불가한 경우.  
경미 = 표현 범위·문서 간 표기 차이.

---

## 2. 기체별 교차 결과

### BRAVE

| 항목 | 스토리 | 디자인 | 판정 |
|------|--------|--------|------|
| 키 | MECHA_BIBLE ~18–25m | FRAME **25m 고정** | **경미** — 운용은 25m 고정 |
| 색 | 백·청·황금 | #C0C8D0 / #2A3A4A / #E8A020 | OK |
| 형태 | S1 동일 · EP13 진화 | FRAME EP1–12 동일 · EP13만 전개 | OK |
| 파일럿 | 리아 | 리아 | OK |
| 전투 | 근접 고속·필살·광기 | 실루엣 단순·핀/드론 연출 | OK (구현 상세는 후속) |

### EXCELION

| 항목 | 스토리 | 디자인 | 판정 |
|------|--------|--------|------|
| EP11 | 일시 전조 | EXCELION_SPEC 전조 | OK |
| EP13 | 확장 고정 · 시간 벌기 | 동일 골격 1단계 확장 | OK |
| 별 기체 여부 | 진화 · 교체 아님 | 별 기체 금지 | OK |

### ORD 계열

| 항목 | 스토리 | 디자인 | 판정 |
|------|--------|--------|------|
| GRUNT | EP01~ 전 구간 | 양산 · 각·작음 | OK |
| MID | **EP5** 중보스 | EP5 · 병기 많음 | OK |
| GUN/HEAVY | 05: 전 구간 / MASTER: **EP17+** | 원거리·중장갑 | **경미** — 스토리 전 구간 출현 가능, MASTER First EP는 두드러진 등장 기준 |
| 성장 | 없음 · 병력 수 | 성장 없음 | OK |

### SETH

| 항목 | 스토리 | 디자인 | 판정 |
|------|--------|--------|------|
| EP | **EP6 격파** | EP6 · 손 보임 · 30m | OK |
| 역할 | 계단 · 도구 · 보고 끝 | 단정·차단 · 비극 주연 금지 | OK |
| 네메시스 시선 | EP6 원경 1 | 세스≠네메시스 실루엣 | OK |

### CREIL

| 항목 | 스토리 | 디자인 | 판정 |
|------|--------|--------|------|
| EP | EP14 예고 · **EP15** · EP20 재투입 | 동일 · 방패면 1키 | OK |
| 층 | 세스 동급 도구 | 동일 층 · 사연 없음 | OK |

### AEGIS

| 항목 | 스토리 | 디자인 | 판정 |
|------|--------|--------|------|
| EP | EP18 반응 · EP19 예고 · **EP21 격파** | 방패·입구 · 오만 금지 | OK |
| 결과 | 문 열림 · 네메시스 안 흔들림 | 격파=길이 열림 | OK |
| 전투 기믹 | 방패·반격 게이지 | SPEC에 게이지 언급 · 상세 루프 미작성 | **갭** (충돌 아님 · STEP 4 과제) |

### NEMESIS

| 항목 | 스토리 | 디자인 | 판정 |
|------|--------|--------|------|
| 노출 | EP4 이름 → EP6 시선 → EP7 원격 → EP9 전면 → 최종 | 단계 밀도 표와 정합 | OK |
| 여성형·중력·손 숨김 | 스토리·오만 문서 | NEMESIS_SPEC | OK |
| 대사 | 「급이 아니다」EP9 1회 · 「시작에 불과」EP24만 | 반복 금지와 정합 | OK |
| 아슈르 | MATRIX: 없음 | 폐기 | OK |

---

## 3. UNCONFIRMED (스토리 흔적)

| ID | 스토리 흔적 | 디자인 | 판정 |
|----|-------------|--------|------|
| OBSERVE | EP13 관측 1컷 · 형태 불명 | UNCONFIRMED | STEP 11 — 독립 기체 여부 미결 |
| INTERNAL | EP22 내부 규칙·함정 · 무명 적 가능 | UNCONFIRMED | STEP 11 |
| SUPPORT | EP15/20 팀·엄호 암시 | UNCONFIRMED | STEP 11 |

→ 스토리상 **이름 있는 기체로 고정되지 않음**. 충돌 아님 · 승격 여부만 후속.

---

## 4. 충돌 / 갭 목록

### 충돌 (차단급)

**없음.**  
아슈르 잔여·최종보스 이중 정의·세스/네메시스 실루엣 혼선은 해소됨.

### 경미 (문서 정리)

| ID | 내용 | 권장 |
|----|------|------|
| C1 | BRAVE 키 18–25 vs 25 고정 | MECHA_BIBLE을 25m로 맞춤 |
| C2 | ORD GUN/HEAVY First EP 표기 | MASTER에 “두드러진 등장 EP17” 주석 또는 05와 통일 |

### 갭 (후속 STEP · 충돌 아님)

| ID | 내용 | 담당 |
|----|------|------|
| G1 | AEGIS 가드 게이지·반격 루프·약점 상세 | STEP 4 AEGIS_FINAL |
| G2 | 전 기체 Combat Loop / Damage / AI | STEP 4–10 FINAL |
| G3 | weapon DESCRIPTION ↔ 스토리 무장 매핑 얇음 | 무기 FINAL 또는 STEP 7–9 |
| G4 | conti EP14–24 없음 | 스토리/콘티 트랙 |
| G5 | 삼면도 PNG 전무 | 이미지 HOLD |

---

## 5. 캐논 우선 규칙 (재확인)

1. EPISODE_MATRIX + novel 본문 (등장·결과·대사 잠금)
2. docs/05_ENEMY · 06_MECHA
3. design/enemy · brave FRAME/EXCELION (실루엣·금지)
4. mecha DESCRIPTION / FINAL 요약
5. MECHA_BIBLE (요약 · 숫자 충돌 시 상위로)

---

## 6. 상태 블록

```
CURRENT: STEP 2 STORY_DESIGN_CONFLICTS Done
DONE: EP01–24 × design 교차 · 충돌 0 · 경미 2 · 갭 5
NEXT: STEP 3 MECHA_STATUS
BLOCKED: 이미지 HOLD
SOURCE: EPISODE_MATRIX · MECHA_BIBLE · 05_ENEMY · 06_MECHA · *_SPEC · MASTER_LIST
DECISIONS:
  - 차단급 스토리↔디자인 충돌 없음
  - BRAVE 운용 키 = 25m
  - UNCONFIRMED는 STEP 11에서 승격 판정
OPEN QUESTIONS:
  - MECHA_BIBLE 키 문구 수정 여부
  - ORD First EP 표기 통일 여부
```

**STEP 2 = Done.**

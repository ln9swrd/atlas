# ORD_FINAL_SPEC — STEP 8 Base + 4종

> 2026-08-08 · STEP 8  
> 근거: ORD_SPEC · ORD_OFFICIAL_SETTING · ORD_VISUAL_LANGUAGE · mecha/ord-*/DESCRIPTION  
> **상태: FINAL (공통 플랫폼 + 4종 전투·구현)**

---

# A. ORD BASE (공통 플랫폼)

## 01 Identity

Order 양산·중형 실행 단위. 진영: Order (엔릴 후손).

## 02 Story Role

전 구간 병력 압박. 성장 없음. 상급이 밀리면 리아가 한계를 넘긴 결과로 읽힘.

## 03 Design Philosophy

| 항목 | 내용 |
|------|------|
| 언어 | **각·기능·투박** · BRAVE(여백·여성형·단순)와 대립 |
| 색 | 저채도 회·청흑 · 군단감 · 호박 `#E8A020` **금지** |
| 센서 | 슬릿·냉광(적/냉색 한 점) |
| 피니시 | 로봇혼급 가능 · 주인공 밀도 금지 |
| 금지 | 네메시스 위계 · 세스 동일 · 주인공 카피 · 개체 개성 과다 |

## 04–13 공통 구조

- humanoid · 각진 패널 · 여백 최소
- 성장 슬롯 없음 · 파츠 교환으로 역할만 방언
- 동력: 표준 양산 출력 · 개체 초월 에너지 금지

## 17 Combat Role (공통)

**숫자로 압박.** 한 기의 서사보다 파도·배치.

## 18 Combat Loop (공통 골격)

```
스폰 → 접근/사격 → 피격·경직 → 파괴
(정예일수록 경직 저항·화력만 상승 · 개성 AI 금지)
```

## 28 Game Implementation (공통)

| 단계 | 정의 |
|------|------|
| 신호 | 슬릿 점등 · 조준 레이저(GUN) · 발소리(HEAVY) |
| 대응 | 섬멸·우선순위 타겟팅 |
| 피격 | 표준 부위 배율 |
| 종료 | HP 0 · 잔해 소량 |

## 29 Source

enemy/ORD_* · mecha/ord-* · 05_ENEMY · EPISODE_MATRIX

---

# B. ORD-GRUNT

| 필드 | 값 |
|------|-----|
| id | ord-grunt |
| 키 | **각 · 작음 · 양산** |
| 크기 | BRAVE 이하~동급 · 위압 없음 |
| 체형 | 각진 두 · 짧은 몸 · 투박 사지 |
| 무장 | 내장 화기 · 단순 블레이드 |
| 읽힘 | “많이 나온다” |
| Source EP | EP01+ |

### Loop

접근 사격/베기 → 쉽게 경직 → 다수 교체 스폰

### Weakness

광역·필살에 약 · 단기하중

---

# C. ORD-HEAVY

| 필드 | 값 |
|------|-----|
| id | ord-heavy |
| 키 | **넓음 · 두꺼움 · 둔** |
| 크기 | BRAVE 이상 |
| 체형 | 넓은 견·두꺼운 흉 · 짧은 다리 · 저중심 |
| 무장 | 중화기·실드 판 |
| 읽힘 | “한 대가 무겁다” |
| Source EP | 전 구간 가능 · MASTER 두드러짐 EP17+ |

### Loop

저속 전진 → 전면 화력/밀치기 → 측면 기동에 약

### Weakness

측면·후 · 기동 압박 · 관절

---

# D. ORD-GUN

| 필드 | 값 |
|------|-----|
| id | ord-gun |
| 키 | **포신 · 돌출 · 원** |
| 크기 | GRUNT~약간 큼 |
| 체형 | 포신·센서 먼저 읽힘 · 근접 실루엣 약 |
| 무장 | 장포·미사일 포드 |
| 읽힘 | “멀리서 쏜다” |
| Source EP | 전 구간 가능 · MASTER EP17+ |

### Loop

원거리 견제 → 재장전 창 → 근접 시 취약

### Weakness

돌입·근접 · 포신 파괴

---

# E. ORD-MID

| 필드 | 값 |
|------|-----|
| id | ord-mid |
| 키 | **중형 · 병기 많음 · EP5** |
| 크기 | HEAVY 이상 · 1기 존재감 |
| 체형 | 중형 + 다병기 · GRUNT/HEAVY와 즉시 구분 |
| 무장 | 다총구·아암 웨폰 |
| 읽힘 | “지금까지와 다르다” |
| Source EP | **EP5** |
| 금지 | 오만 위계 · 비극 주연 |

### Loop (중보스)

```
다병기 패턴 순환 → 약점 부위 노출 창 → 페이즈2 화력 증가
→ 격파 (세스 전 계단)
```

### Weakness

과부하 부위 · 패턴 학습 후 돌파

---

# F. 식별 테스트

| 기 | 키워드 3 |
|----|----------|
| GRUNT | 각 · 작음 · 양산 |
| HEAVY | 넓음 · 두꺼움 · 둔 |
| GUN | 포신 · 돌출 · 원 |
| MID | 중형 · 병기 많음 · EP5 |
| BRAVE | 여백 · 여성형 · 단순 |
| 세스 | 단정 · 차단 · 장식 최소 |
| 네메시스 | 위계 · 길이 · 원격 |

---

# G. 삼면도 · Prompt

각 DESCRIPTION · 기존 Positive/Negative 유지 (GRUNT/HEAVY/GUN/MID).

---

# H. Open Issues

| # | 이슈 |
|---|------|
| 1 | GUN/HEAVY First EP 표기 통일 |
| 2 | 스폰 상한·웨이브 테이블 |
| 3 | PNG HOLD |
| 4 | 개별 파일 분리 필요 시 ORD_*_FINAL로 추출 |

---

## 상태 블록

```
CURRENT: STEP 8 ORD Base+4 FINAL Done
DONE: 공통 플랫폼 · 4종 키·Loop·약점
NEXT: STEP 9 SETH_FINAL_SPEC
BLOCKED: PNG · 웨이브 수치
SOURCE: ORD_SPEC · VISUAL · EP01–24
DECISIONS:
  - 통합 문서 유지 · 필요 시 개별 추출
  - MID만 중보스 루프 · 나머지 양산 루프
OPEN QUESTIONS:
  - First EP 표기
```

**STEP 8 = Done.**

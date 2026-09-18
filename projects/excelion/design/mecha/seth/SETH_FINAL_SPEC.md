# SETH_FINAL_SPEC — mecha/seth

> 2026-08-08 · STEP 9  
> 원본: `enemy/SETH_MECHA_SPEC.md` · character/seth · 05_ENEMY  
> 스토리: EP6 · EPISODE_MATRIX

**상태: FINAL**

---

## 01 Identity

| 항목 | 값 |
|------|-----|
| id | seth-001 |
| 이름 | 세스 / Seth |
| 분류 | ORD-ELITE · 실행자 |
| 기수 | 세스 |
| 격 | MID 이상 · 네메시스 미만 |

## 02 Story Role

| EP | 역할 |
|----|------|
| **6** | 보스 격파 · “넘어야 할 계단” · 최종 벽 아님 |

패배: 「…보고, 끝.」 · 절규·비극 주연 금지.  
핵심: “싫어서가 아니라 **해야 해서**.”

## 03 Design Philosophy

- **단정·차단·장식 최소 · 근육질 전사 · 손 보임**
- 네메시스 축소 카피 금지 · 카이 대칭 금지
- 감정 균열: 장면당 1회 이하

## 04 Silhouette

| 축 | 묘사 |
|----|------|
| 전체 | humanoid · 각+근골 · ≈30m · 중저 중심 |
| 두부 | 단정 헬멧 · 슬릿 · 뿔·왕관 금지 |
| 견·흉 | 넓은 견 · 가로 차단 흉갑 |
| 팔·손 | **손 보임** · 제압·리졸버 |
| 다리 | 굵은 대퇴 · 넓은 접지 |
| 배면 | 민등 · 망토·익·배팩 금지 |

**키워드:** 단정 · 차단 · 장식 최소 · 근육질 · +20%(vs BRAVE)

## 05 Dimensions

| 항목 | 값 |
|------|-----|
| 전고 | **약 30 m** (BRAVE 25m +20%) |
| 체형 | 근육질 전사 |

## 06–13 Structure / Armor / Parts

- ELITE 플랫폼 · 기능 우선 패널
- 색: 저채도 청회·흑회 · 냉광 슬릿 · 호박·광기 적열 금지
- 손 노출 유지 (네메시스 차별)

## 14 Weapons

| 무장 | 역할 |
|------|------|
| seth-line-resolver | 직선 사격·압박 |
| seth-seal-plate | 차단·씰 · 접근 거부 |
| 근접 제압 | 손·암 |

## 15 Defensive Systems

- 씰·차단판으로 전선 닫기
- 가드 게이지형(AEGIS)보다 **압박·지연**

## 16 Special Systems

- 분석·보고 · 역할 수행
- 숭배·애정 없음 (네메시스와의 층 차이)

## 17 Combat Role

**계단 보스.** 30초: “막힌다 · 집념으로 뚫는다 · 이겨도 위는 남는다.”

## 18 Combat Loop

```
[1] 압박·차단 · 씰 전개
[2] 리졸버 직선 · 위치 통제
[3] 플레이어 집념 돌파·과부하 지연 공략
[4] 페이즈2 압박 강화 (HP48 참조)
[5] 격파 → 기동 정지 · 「…보고, 끝.」
```

약점 = 집념 돌파·과부하 지연 (05_ENEMY).

## 19 AI Behavior

| 우선 | 행동 |
|------|------|
| 1 | 전선 닫기 · 플레이어 고립 |
| 2 | 감정 과시 없음 · 균열 1회 이하 |
| 3 | 패배 시 보고 후 정지 |

## 20 Weakness / Counter

| 약점 | 대응 |
|------|------|
| 집념 연속 압박 | 가드 깎기·창 |
| 과부하 지연 | 패턴 중 딜 |
| 측면 | 우회 |

## 21 Damage States

경미→중→정지. 비극·폭염 붕괴 금지.

## 22–23 VFX / Animation

냉광 · 금속 둔음 · 단정 동작 · 패배 시 무전 단절.

## 24–27 Three-view / Turnaround / Exploded / Weapon

- Front: 단정·손 보임·차단 흉
- 세스 vs 크레일: 리졸버/씰 vs **가로 방패면**
- Weapon sheet: resolver · seal-plate

## 28 Game Implementation

| 단계 | 정의 |
|------|------|
| 신호 | 씰 전개 · 리졸버 조준선 |
| 대응 | 집념 돌파 · 지연 창 딜 |
| 피격 | 전면 차단 보정 · 측면 높음 |
| 종료 | HP 0 · 보고 연출 · EP6 클리어 |

수치: state/BOSS_STATS (HP48 · 페이즈2).

## 29 Source

SETH_MECHA_SPEC · character/seth · 05_ENEMY · EP6 · weapon/seth-*

## 30 Open Issues

| # | 이슈 |
|---|------|
| 1 | 페이즈2 수치 확정 |
| 2 | PNG HOLD |
| 3 | 균열 연출 1회 슬롯 지정 |

---

## 금지

- 네메시스급 위계·손 숨김 · 왕관·망토
- 카이 대칭 · 비극 주연 · 균열 남발

---

## 상태 블록

```
CURRENT: STEP 9 SETH_FINAL_SPEC Done
DONE: EP6 계단 보스 · 차단 루프 · 손 보임
NEXT: STEP 10 EXCELION_FINAL_SPEC
BLOCKED: PNG · 수치
SOURCE: SETH_MECHA_SPEC · EP6 · 05_ENEMY
DECISIONS:
  - 계단이지 최종 아님
  - 크레일과 1키 차별 유지
OPEN QUESTIONS:
  - 페이즈2 상세
```

**STEP 9 = Done.**

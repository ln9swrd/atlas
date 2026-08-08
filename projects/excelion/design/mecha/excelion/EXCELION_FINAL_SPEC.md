# EXCELION_FINAL_SPEC — mecha/excelion

> 2026-08-08 · STEP 10  
> 원본: `brave/EXCELION_SPEC.md` · `FRAME_SPEC` · `BRAVE_FINAL_SPEC`  
> 스토리: EP11 · EP13 · EPISODE_MATRIX

**상태: FINAL**  
**별 기체 아님 · BRAVE 완전 전개 1단계.**

---

## 01 Identity

| 항목 | 값 |
|------|-----|
| id | excelion-001 (형태 상태) |
| 이름 | 엑셀리온 / Excelion |
| 베이스 | brave-001 |
| 파일럿 | 리아 |
| 분류 | BRAVE 전개형 · 프로젝트/형태명 |

## 02 Story Role

| EP | 역할 |
|----|------|
| 11 | **일시 전조** · 빛·광윤만 · 형태 확장 없음 · 네메시스 후퇴=재평가 |
| **13** | **확장 고정** · 시간 벌기 클리어 · 게이트 |
| 14+ | 필요 시 전투 가능 형태 (규칙 상속) |

세계관: “영웅기”가 아니라 **선택 가능한 공명 기체의 열린 상태** (EP17 회수).

## 03 Design Philosophy

- **같은 몸이 열린 것** · 교체 연출 금지
- 변화 = 광익·선 밀도·광윤·accent 면적만 (1단계)
- 거대 날개·두 번째 로봇 실루엣 금지

## 04 Silhouette

| 축 | BRAVE | 엑셀리온 |
|----|-------|----------|
| 골격·비율 | 25m | **동일** |
| 가로 | 단순 | **짧은 광익 1쌍**으로 한 단 증가 |
| 선 | 최소 | 패널·광 라인 증가 |
| 광윤 | 광기 시 일시 | **상시** · 코어 전면 점등 |

## 05 Dimensions

골격 동일 25m. 전개 후 가로 점유만 증가.

## 06–13 Structure / Armor / Propulsion

- FRAME 슬롯 상속
- 배면·견부 실루엣 확장 · 별 파츠 ID 남발 금지
- thruster/backpack **택 1–2 활성 가능** (거대 블록 금지)
- 팔레트 동일 · accent 면적↑

## 14 Weapons

BRAVE 무장 상속. 플레어·출력 배수는 전투 규칙.

## 15–16 Defense / Special

| 규칙 | 내용 |
|------|------|
| 봉쇄 무시/조기 소멸 | 06_MECHA · 전투 가능 |
| 출력 | 개념 ×1.5 |
| 초필 | 엑셀리온 플레어 |
| 핀 패널 | 광익이 주 · 패널 보조 |

## 17 Combat Role

**돌파·시간 벌기 형태.** EP13 목표: 게이트에서 시간을 번다.

## 18 Combat Loop

```
전개 연출 → 광익·광윤 유지 전투
→ 봉쇄 구역 돌파/무시
→ 플레어로 창 창출
→ (EP13) 클리어=시간 벌기 · 전면 격파 필수 아님
```

EP11: 형태 변화 없이 수 초 광윤만.

## 19 AI

N/A (플레이어 형태 상태).

## 20 Weakness

- 전개 유지 부하 · 스토리 한도
- 과도한 광익 판정 히트박스 (디자인 절제)

## 21 Damage

BRAVE와 동일 골격 손상 규칙. 전개 해제=스토리/게이지.

## 22–23 VFX / Animation

- 코어·라인 상시 광
- 광익 전개 짧은 애니메이션
- EP11 전조=페이드 인/아웃만

## 24–27 Three-view / Sheets

- BRAVE 삼면도와 **나란히** · 동일 포즈에서 광익·라인 차이만
- “다른 로봇”으로 읽히면 실패
- Exploded: 광익·견부 전개 파츠

## 28 Game Implementation

| 단계 | 정의 |
|------|------|
| 상태 플래그 | form=brave \| excelion_pre (EP11) \| excelion |
| 신호 | 광윤·광익 UI |
| 효과 | 봉쇄 무시 · 배수 · 플레어 |
| 종료 | 미션/스토리 · 강제 해제 가능 |

## 29 Source

EXCELION_SPEC · FRAME · BRAVE_FINAL · 06_MECHA · EP11/13

## 30 Open Issues

| # | 이슈 |
|---|------|
| 1 | EXCELION_SPEC 내 구 아슈르 문구 → 네메시스로 패치 |
| 2 | 광익 히트박스 수치 |
| 3 | PNG HOLD |

---

## 금지

- 별 기체 교체 · 거대 날개 비율 붕괴
- EP1–12 상시 엑셀리온 형태
- 팔레트 교체로 타기체화

---

## 상태 블록

```
CURRENT: STEP 10 EXCELION_FINAL_SPEC Done
DONE: 전개 1단계 · EP11≠EP13 · 전투 규칙 연결
NEXT: STEP 11 UNCONFIRMED_MECHA_REVIEW
BLOCKED: PNG · 원본 SPEC 아슈르 문구 패치
SOURCE: EXCELION_SPEC · FRAME · EP11/13
DECISIONS:
  - 별 기체 아님 · 동일 골격
  - EP11 전조는 빛만
OPEN QUESTIONS:
  - 광익 판정
```

**STEP 10 = Done.**

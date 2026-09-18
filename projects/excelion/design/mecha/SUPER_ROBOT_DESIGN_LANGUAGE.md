# SUPER_ROBOT_DESIGN_LANGUAGE — 전 메카 공통

> 2026-08-10 · **전 `design/mecha` 상위 기준**  
> 적용: BRAVE · EXCELION · NEMESIS · ORDER 전 종 · 전 보스  
> **Canon 계층:** `design/CANON_HIERARCHY.md` — DESIGN_QUALITY 하위 · SUPER_ROBOT_MODERN 상위 (Model A · 2026-08-14 Master 승인)

**상태: LOCK**

---

## 0. 한 줄

> **EXCELION의 메카는 건담이 아니다. 모든 메카는 슈퍼로봇이며, 곡선과 큰 형태로 영웅적 조형을 만든다.**

---

## 1. SUPER ROBOT FIRST

| 순위 | 개념 |
|------|------|
| **1** | **SUPER ROBOT** |
| 2 | 진영·역할 개성 (ORDER / 주인공 / 최종보스) |
| 3 | 기계 구조 (존재하되 현실공학 우선 금지) |

1차 분류는 항상 **슈퍼로봇**이다.  
`realistic mobile suit` · `military humanoid weapon` · `tactical hard-surface suit` 로 읽히면 **문서 수정 대상**.

권장 문장 구조:

- ❌ `realistic humanoid combat machine`
- ✅ `heroic super robot with mechanical construction`

---

## 2. 조형 우선순위

```
실루엣 > 장갑 덩어리 > 곡면 > 색상 블록 > 기계 디테일 > 패널라인
```

| 개념 | 의미 |
|------|------|
| **HEROIC SILHOUETTE** | 멀리서도 캐릭터·역할이 읽힘 |
| **ICONIC ARMOR** | 흉·두·견·사지는 부품 집합이 아니라 **큰 아이콘 형태** |
| **CURVED FORM** | 주요 외곽에 곡선·완만 곡면 **적극 사용** (장식 아님) |
| **LOW DETAIL, HIGH IDENTITY** | 디테일 증량 대신 큰 형태·실루엣으로 개성 |

### 곡선 우선 부위

흉부 · 어깨 · 상완/전완 · 허리 · 허벅지 · 종아리 · 머리/헬멧 · 장갑 외곽 · 대형 장비

직선·직각 **만**으로 채운 건담식 하드서피스 전면 구성 **금지**.  
모든 기체에 동일 곡률을 강제하지는 않음 — **하드서피스 일색을 피하는 것**이 목적.

---

## 3. 패널라인 정책

- 패널라인 **삭제 목적이 아님**
- 인상을 **지배하면 안 됨**
- 큰 장갑 형태를 **보조하는 수준**

**금지**

- 패널 과다 · 소형 부품 난립 · 전면 기능 패널 분할
- 건담 프라모델식 디테일 과밀
- 그리블로 실루엣 가림

---

## 4. 슈퍼로봇 검증 (기체마다)

| # | 질문 |
|---|------|
| A | 멀리서 봐도 슈퍼로봇인가? |
| B | 얼굴/머리에 캐릭터성이 있는가? (단순 센서 덩어리 금지) |
| C | 흉부에 강한 아이콘이 있는가? |
| D | 사지에 충분한 질량감이 있는가? (날씬 인간형 축소 금지) |
| E | 정지 상태에서도 돌진·타격·필살기가 연상되는가? |

---

## 5. 건담 / 리얼로봇 유도 금지

문서·프롬프트에서 다음이 **결과 인상**을 지배하면 수정:

- military realism · realistic mobile suit
- hard surface armor (단독 상위 키워드로 사용)
- industrial machine · tactical humanoid weapon
- excessive panel detailing · utilitarian armor only

필요 시에도 **SUPER ROBOT을 문장 앞에** 둔다.

---

## 6. 보존 (임의 변경 금지)

- 기체 이름 · EP · 폴더 구조 · 무장 · 전투 역할 · 스토리
- 색상 체계 · FINAL 판정 상태
- **BRAVE 여성형 설정** · 3톤 · 여백 · 저밀도 패널

위 설정은 유지하되 **슈퍼로봇으로 구현되도록 표현만 수정**.

---

## 7. BRAVE 특별

| 올바름 | 금지 해석 |
|--------|-----------|
| **여성적 비례를 가진 슈퍼로봇** | 여성을 로봇화한 날씬 휴머노이드 |
| 여백 · 3톤 · 저밀도 패널 **유지** | 질량감 제거 |

필수 강조: 흉부 상징 · 어깨 실루엣 · 팔·다리 질량 · 곡선형 장갑 · 영웅적 머리 · 허리–골반 연결 · 돌진·필살 연상 실루엣.

---

## 8. 생성/삼면도 프롬프트 공통

Positive에 우선 포함:

```text
super robot first, heroic silhouette, iconic large armor volumes,
curved outer forms, bold chest and shoulder shapes, character-like head,
low panel density relative to form, not Gundam, not real-robot mobile suit
```

Negative에 우선 포함:

```text
Gundam, real robot, military mecha, excessive panel lines, dense greeble,
utilitarian hard-surface only, skinny humanoid robot, model-kit overdetail
```

품질 바: 로봇혼/센티넬 **피니시**는 유지하되, **조형 언어는 슈퍼로봇** (프라 디테일 과밀 ≠ 목표).

---

## 9. 문서 계층

```
DESIGN_QUALITY.md                    ← 피니시 상한 (상위)
  └── SUPER_ROBOT_DESIGN_LANGUAGE.md ← 본 문서 (정체성)
        └── SUPER_ROBOT_MODERN.md    ← 구현 방법 (중밀도 패널)
              ├── ORDER_DESIGN_LANGUAGE.md
              ├── MECHA_3TONE_LOW_DETAIL
              ├── 각 기체 DESCRIPTION / FINAL_SPEC
              └── threeview/SKILL · TOPOLOGY_GUIDE
```

충돌 시 **상위 문서 우선** (`design/CANON_HIERARCHY.md`).  
본 문서는 DESIGN_QUALITY 하위 · SUPER_ROBOT_MODERN 상위.

---

## 10. 검증 체크

1. 이미지 생성 시 건담으로 나올 여지?
2. 리얼/군용 로봇으로 읽힐 여지?
3. 패널이 실루엣보다 강한가?
4. 곡선보다 직선·직각만 우세한가?
5. 「슈퍼로봇」 단어를 빼도 조형이 유도되는가?
6. 원거리 캐릭터성?
7. BRAVE = 여성형 **슈퍼로봇**인가 (휴머노이드 축소 아닌가)?

문제 시 해당 MD 추가 수정.

```
CURRENT: SUPER ROBOT FIRST · CURVED FORM · HEROIC SILHOUETTE LOCK
PRESERVE: 이름·EP·무장·역할·3톤·BRAVE 여성형
FORBIDDEN: 건담/리얼로봇 유도 상위 키워드
HIERARCHY: DESIGN_QUALITY → 본 문서 → SUPER_ROBOT_MODERN (Model A)
```

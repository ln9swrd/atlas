# SUPER_ROBOT Canon Hierarchy Review

> 2026-08-14  
> 목적: DESIGN_QUALITY / SUPER_ROBOT_DESIGN_LANGUAGE / SUPER_ROBOT_MODERN 3문서 읽기 전용 대조  
> **본 문서는 결정 자료만 작성한다. 위 3문서 내용은 수정하지 않는다.**

**상태: REVIEW (Master 결정용)**

---

## 1. 한 줄 요약

| 문서 | 한 줄 |
|------|------|
| **DESIGN_QUALITY** | 피니시·완성도 **상한** (로봇혼/센티넬) + 정보량 절제 |
| **SUPER_ROBOT_DESIGN_LANGUAGE** | Excelion 메카의 **정체성** (SUPER ROBOT FIRST · 곡선 · 영웅 조형 · 건담 금지) |
| **SUPER_ROBOT_MODERN** | 그 정체성을 **실제 패널·근골 언어**로 구현하는 방법 (중밀도 · 70s과단순/과밀도 금지) |

세 문서는 역할이 겹치지 않는다. 다만 **권위·참조 선언**이 서로 어긋나 있다.

---

## 2. 목적 비교

| 축 | DESIGN_QUALITY | SUPER_ROBOT_DESIGN_LANGUAGE | SUPER_ROBOT_MODERN |
|----|----------------|-----------------------------|---------------------|
| **목적** | 완성도·엣지·정보량 상한 | “무엇을 만드는가” (슈퍼로봇인가) | “어떻게 그리는가” (패널·밀도) |
| **질문** | 이 결과물이 로봇혼/센티넬급인가? | 이 기체가 건담/리얼로봇이 아닌가? | 패널이 근골을 읽히게 하는가? |
| **실패 조건** | 러프·과밀도·다색 조각·평면 토이 | 군용 슈트·하드서피스 일색·건담 인상 | 70s 평면 또는 선 난립 |

---

## 3. 적용 범위

| 문서 | 범위 | 비고 |
|------|------|------|
| DESIGN_QUALITY | **전 메카** (피니시 공통) | LOCK |
| SUPER_ROBOT_DESIGN_LANGUAGE | **전 메카** (BRAVE·EXCELION·NEMESIS·ORDER·보스) | LOCK **후보** |
| SUPER_ROBOT_MODERN | **BRAVE 우선** · 아군 슈퍼로봇 계열 공통 참고 | LOCK |

- DESIGN_QUALITY · SUPER_ROBOT_DESIGN_LANGUAGE = 전 진영 공통 가능  
- SUPER_ROBOT_MODERN = BRAVE/중밀도 특화 성격이 강함 (ORDER는 3TONE·ORDER_DESIGN_LANGUAGE가 더 직접)

---

## 4. 권위 수준 (현재 문서 자체 선언)

| 문서 | 자체 상태 | 자체 계층 선언 |
|------|-----------|----------------|
| DESIGN_QUALITY | **LOCK** | 피니시 상한 · 3TONE·SUPER_ROBOT_MODERN 연동 |
| SUPER_ROBOT_DESIGN_LANGUAGE | **LOCK 후보** | §9에서 **본 문서를 최상위**로 선언 (ORDER_DESIGN_LANGUAGE 등 하위) |
| SUPER_ROBOT_MODERN | **LOCK** | DESIGN_QUALITY · FRAME_SPEC · BRAVE_INFLUENCE 연동. SUPER_ROBOT_DESIGN_LANGUAGE **미언급** |

**CANON_HIERARCHY.md (2026-08-14 Master 승인 초안)**  
```
DESIGN_QUALITY
  → SUPER_ROBOT_DESIGN_LANGUAGE
  → SUPER_ROBOT_MODERN
  → 개별 규칙 → FINAL_SPEC → DESCRIPTION
```

→ 문서 자체 선언과 CANON_HIERARCHY 초안이 **일치하지 않음**.

---

## 5. 상호 참조

| 출처 → 대상 | 있음? | 내용 |
|-------------|-------|------|
| DESIGN_QUALITY → SUPER_ROBOT_MODERN | Yes | 정보량·중밀도 연동 |
| DESIGN_QUALITY → SUPER_ROBOT_DESIGN_LANGUAGE | **No** | — |
| SUPER_ROBOT_MODERN → DESIGN_QUALITY | Yes | 피니시 상한 |
| SUPER_ROBOT_MODERN → SUPER_ROBOT_DESIGN_LANGUAGE | **No** | — |
| SUPER_ROBOT_DESIGN_LANGUAGE → DESIGN_QUALITY | **No** (직접) | 품질 바는 로봇혼/센티넬을 문장으로만 언급 |
| SUPER_ROBOT_DESIGN_LANGUAGE → SUPER_ROBOT_MODERN | **No** | — |
| SUPER_ROBOT_DESIGN_LANGUAGE → ORDER_DESIGN_LANGUAGE 등 | Yes | §9 하위 계층 |

**결론:** 세 문서가 서로를 일관된 계층으로 묶고 있지 않다. 각자 독립적으로 LOCK/후보를 선언한다.

---

## 6. 중복

| 주제 | 겹침 정도 | 비고 |
|------|-----------|------|
| 저밀도·패널 절제 | 중 | DESIGN_QUALITY(정보량) · MODERN(중밀도) · DESIGN_LANGUAGE(LOW DETAIL) |
| 실루엣 우선 | 중 | 세 문서 모두 강조 |
| 로봇혼/센티넬 피니시 | 약~중 | QUALITY가 정의, 나머지가 전제 |
| 건담/리얼로봇 금지 | DESIGN_LANGUAGE만 명시적·강함 | MODERN은 “양산 리얼로봇화” 금지로 부분  overlap |
| 곡선 vs 패널 근골 | **역할 분담** | DESIGN_LANGUAGE=곡선·큰 형태, MODERN=패널로 근골 읽힘 |

중복은 있으나 **같은 말을 다른 층위에서 반복**하는 형태. 내용 충돌보다는 **역할 경계 미명시**가 문제.

---

## 7. 충돌

### 7.1 의미 충돌 (내용)

**없음 (차단급).**  
- 곡선 우선(DESIGN_LANGUAGE)과 패널로 근골 읽힘(MODERN)은 양립 가능.  
- 피니시 상한(QUALITY)과 정보량 절제는 세 문서 공통.

### 7.2 권위·선언 충돌 (구조)

| ID | 내용 | 심각도 |
|----|------|--------|
| H1 | CANON_HIERARCHY: DESIGN_LANGUAGE가 MODERN 상위 | 중 |
| H2 | DESIGN_LANGUAGE 자체: “본 문서 최상위” (QUALITY 상위 미인정) | 중 |
| H3 | MODERN: DESIGN_LANGUAGE를 전혀 참조하지 않음 | 중 |
| H4 | QUALITY: DESIGN_LANGUAGE를 참조하지 않음 | 낮~중 |

→ **내용이 아니라 “누가 위를 점하는가”가 미확정.**

---

## 8. 상하위 관계 — 가능한 모델

### 모델 A (CANON_HIERARCHY 초안 · Master 제안)

```text
DESIGN_QUALITY          (피니시 상한)
        ↓
SUPER_ROBOT_DESIGN_LANGUAGE  (정체성 · SUPER ROBOT FIRST)
        ↓
SUPER_ROBOT_MODERN      (구현 방법 · 중밀도 패널)
        ↓
개별 진영/메카 규칙
```

- **장점:** 품질 → 정체성 → 구현 방법의 자연스러운 흐름.  
- **단점:** DESIGN_LANGUAGE가 아직 LOCK 후보. MODERN이 이미 LOCK인데 하위로 내려감.  
- **필요 조치:** DESIGN_LANGUAGE LOCK 승격 + 세 문서 상호 참조 주석 정리.

### 모델 B (피니시와 정체성 병렬)

```text
        ┌─ DESIGN_QUALITY (피니시)
공통 ──┤
        └─ SUPER_ROBOT_DESIGN_LANGUAGE (정체성)
                    ↓
            SUPER_ROBOT_MODERN (구현)
```

- **장점:** QUALITY와 DESIGN_LANGUAGE가 다른 축(완성도 vs 철학).  
- **단점:** 구현자가 “어느 쪽을 먼저 볼지”가 덜 명확.

### 모델 C (MODERN을 BRAVE 특화로 고정)

```text
DESIGN_QUALITY
        ↓
SUPER_ROBOT_DESIGN_LANGUAGE  (전 메카)
        ↓
  ┌─────┴─────┐
  ↓           ↓
SUPER_ROBOT_  ORDER_DESIGN_LANGUAGE
MODERN        · 3TONE 등
(BRAVE 특화)
```

- **장점:** MODERN의 “BRAVE 우선” 문구와 정합. ORDER는 별 경로.  
- **단점:** 계층이 약간 복잡해짐.

### 모델 D (현 상태 유지 · 명시만)

세 문서를 모두 LOCK(또는 후보)으로 두고, CANON_HIERARCHY에 “역할 분담”만 쓰고 엄격한 상하를 두지 않음.  
- **장점:** 즉시 수정 부담 없음.  
- **단점:** SoR 모호성 지속.

---

## 9. 실제 제작에 미치는 영향

| 상황 | 영향 |
|------|------|
| 삼면도·이미지 프롬프트 | DESIGN_LANGUAGE(슈퍼로봇·곡선·건담 금지) + QUALITY(로봇혼) + MODERN(중밀도) 모두 쓰임 |
| ORDER 기체 | DESIGN_LANGUAGE + ORDER_DESIGN_LANGUAGE + 3TONE + QUALITY. MODERN은 간접 |
| BRAVE | 세 문서 모두 직접 관련. 계층 미확정이면 프롬프트 우선순위 흔들림 |
| Unreal 구현자 | “어느 문서를 기준으로 하는가”가 불명확하면 재작업 위험 |

**지금 당장 제작이 막히지는 않음.** 다만 계층이 확정되지 않으면 이후 FINAL·프롬프트·품질 판정에서 해석 분기가 생김.

---

## 10. 권장 (에이전트 제안 · Master 결정용)

**권장: 모델 A + 단계적 정리**

1. **내용 수정 없이** Master가 모델 A를 승인할지 확정.  
2. 승인 시:  
   - SUPER_ROBOT_DESIGN_LANGUAGE를 **LOCK**으로 승격 (상태 문구만).  
   - 세 문서 상단에 “CANON_HIERARCHY 참조 · 본 문서 역할” 한 줄 주석 추가 (내용 변경 최소).  
   - DESIGN_LANGUAGE §9 “최상위” 문구를 “DESIGN_QUALITY 하위 · 정체성 계층”으로 조정.  
3. MODERN은 BRAVE/중밀도 구현 문서로 유지 (모델 C 요소를 A에 흡수 가능).  
4. FSS 경로 표기 등 경미 정합은 그 다음에.

**대안:** Master가 모델 B 또는 C를 선호하면 그에 맞춰 CANON_HIERARCHY만 수정.

---

## 11. Master 결정이 필요한 항목

| # | 질문 |
|---|------|
| 1 | SUPER_ROBOT_DESIGN_LANGUAGE를 LOCK으로 승격하는가? |
| 2 | 계층 모델은 A / B / C / D 중 어느 것인가? |
| 3 | 승격·계층 확정 후, 세 문서에 **상단 주석만** 넣을 것인가 (내용 본문 변경 최소)? |
| 4 | MODERN을 “전 아군 공통”으로 둘 것인가, “BRAVE 특화”로 둘 것인가? |

---

## 12. 이번 단계에서 하지 않은 것

- DESIGN_QUALITY · SUPER_ROBOT_DESIGN_LANGUAGE · SUPER_ROBOT_MODERN **내용 수정 없음**
- 파일 이동·삭제 없음
- LOCK 상태 변경 없음

**본 문서는 결정 자료다. 다음 조치는 Master 지시 후에만 진행한다.**

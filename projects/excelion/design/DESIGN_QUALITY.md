# DESIGN_QUALITY — 디자인 품질 기준 (SoR)

> 2026-08-06 · Master 지시  
> **품질 목표: 반다이 로봇혼 (Robot Spirits) · 센티넬 (Sentinel) 수준**

**상태: LOCK**

---

## 한 줄

모든 기체·인물·무기 디자인은 **반다이 로봇혼 / 센티넬급** 피니시·밀도·정밀도를 목표로 한다.  
90년대 Retro 감성(비율·실루엣·색)은 유지하되, **표면 처리·패널 라인·디테일 밀도**는 현대 하이엔드 피규어/완성품 수준으로 올린다.

---

## 품질 바 (필수)

| 축 | 기준 |
|----|------|
| 실루엣 | TEXT-LOCK 키워드 엄수 (위계·단정·여백 등) |
| 비율 | 로봇혼/센티넬식 정밀 humanoid · 과장·치비·비율 붕괴 금지 |
| 패널·라인 | 고밀도 공업적 패널 라인 · 리벳·표면 분할 명확 |
| 표면 | 매트+세미글로스 혼용 · 저채도 금속감 · 깨끗하고 날카로운 엣지 |
| 디테일 | 관절·가동 암시 · 하드포인트 · 미세 홈 · 센서 슬릿까지 읽힘 |
| 색 | 지정 팔레트 유지 · 그라데이션/페인터리 금지 · 플랫+정확한 하이라이트 |
| 완성도 | “완성품 촬영” 수준의 선명도 · 스케치·러프·저밀도 금지 |

---

## 허용 / 금지

### 허용
- 로봇혼·센티넬·METAL BUILD·MG Ver.Ka 수준의 패널 밀도
- 공식 설정집 / 상품 설명서 스타일 삼면도
- 날카로운 엣지 · 정밀 관절 표현 · 미세 표면 텍스처
- 90s 비율·실루엣 + 현대 하이엔드 디테일 혼용

### 금지
- 저밀도·단순화된 카툰 메카
- 러프 스케치 · 페인터리 과다 · 시네마틱 렌즈 플레어
- 실루엣 키워드 파괴 (아슈르 손 보임, 세스 왕관, BRAVE 과무장 등)
- 치비·SD·과장 어깨·거대 무기 기본 장착으로 실루엣 붕괴
- “90년대 단순함”을 이유로 디테일을 빼는 것

---

## 프롬프트 / 제작 공통 지시

삼면도·컨셉·모델링 레퍼런스 생성 시 아래를 **필수 포함**:

```
Bandai Robot Spirits / Sentinel level finish.
Ultra high-density industrial panel lines, precise rivets and surface segmentation,
sharp clean edges, premium figure-quality mechanical detail,
matte and semi-gloss metal surfaces, orthographic model sheet,
official product reference quality, no sketch, no rough, no low-density simplification.
```

기존 “90년대 Retro · Sunrise MG Spec”은 **비율·실루엣·색 감성**으로 유지하고,  
**표면 처리·디테일 밀도**는 로봇혼/센티넬로 승격한다.

---

## 적용 범위

| 대상 | 적용 |
|------|------|
| mecha/* (BRAVE, Excelion, Ashur, Seth, ORD) | 필수 |
| character/* 삼면도 | 인물도 동일 완성도 (복장·장비 디테일) |
| weapon/* | 필수 |
| 컨셉 이미지 풀 | 채택 시 이 기준 미달이면 참고만, 제작 레퍼런스로 사용 금지 |

---

## 검증

| # | 체크 |
|---|------|
| 1 | 로봇혼/센티넬 완성품과 나란히 놓아도 밀도·엣지가 부끄럽지 않은가 |
| 2 | 실루엣 키워드가 디테일 때문에 깨지지 않는가 |
| 3 | 패널 라인이 “그려진 선”이 아니라 “기계 분할”로 읽히는가 |
| 4 | 저밀도·카툰화·러프가 없는가 |

---

## 관련

- 각 `DESCRIPTION.md` · `OFFICIAL_SETTING.md`의 스타일 문구는 본 문서를 따른다.
- `mecha/threeview/SKILL.md` · character threeview 스킬 업데이트 대상.
- FRAME_SPEC / 적 스펙의 “simple”은 **실루엣 단순함**이지 디테일 저밀도가 아니다.

**DESIGN_QUALITY = LOCK.**

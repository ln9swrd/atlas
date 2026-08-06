# DESIGN_QUALITY — 디자인 품질 기준 (SoR)

> 2026-08-06 · Master 지시  
> **품질 목표: 반다이 로봇혼 (Robot Spirits) · 센티넬 (Sentinel) 수준**  
> **슈퍼로봇 모던화:** `SUPER_ROBOT_MODERN.md` — 과단순·과밀도 금지 · 패널=근골 형상화

**상태: LOCK**

---

## 한 줄

피니시·엣지·완성도는 **로봇혼 / 센티넬급**.  
패널 **정보량**은 기체의 역할에 맞게 조절한다. 슈퍼로봇(BRAVE)은 **중밀도·구조 우선** — 선이 많아 집중을 깨면 실패.

---

## 품질 바 (필수)

| 축 | 기준 |
|----|------|
| 실루엣 | TEXT-LOCK 키워드 엄수 |
| 비율 | 정밀 humanoid · 과장·치비 금지 |
| 패널·라인 | **기계 분할로 읽힘** · 근골·구조 형상화 · 장식 난립 금지 |
| 표면 | 매트+세미글로스 · 저채도 금속 · 날카로운 엣지 |
| 디테일 | 관절·가동 암시 · 필요 부위만 · 전면 그리블 도배 금지 |
| 색 | 지정 팔레트 · 페인터리 금지 |
| 완성도 | 완성품 선명도 · 스케치·러프·70s 평면 토이 금지 |

### 밀도 대역

| 기체 | 대역 |
|------|------|
| **BRAVE / 엑셀리온** | **중밀도** · 주 라인 소수 · 여백 유지 · `SUPER_ROBOT_MODERN` |
| 세스 | 중~정돈 · 각·차단 우선 |
| 아슈르 | 중~고 · 위계 면 · 손/무장 비노출 |
| ORD | 기능 밀도 · 고급 예술 밀도 아님 |

피니시(엣지·마감)는 공통 상한. **선 개수 ≠ 품질**.

---

## 허용 / 금지

### 허용
- 로봇혼·센티넬급 엣지·단차·마감
- 구조가 읽히는 패널 (큰 분할 + 국소 미세)
- 90s 실루엣 + 모던 피니시

### 금지
- 70년대 과단순 평면 (단차 없음)
- 과밀도 그리블로 시선 분산
- 러프·페인터리·실루엣 키워드 파괴
- “고급이니까 선을 더 넣자”는 사고

---

## 프롬프트 / 제작 공통 지시

```
Bandai Robot Spirits / Sentinel level finish and edge quality.
Panel lines express mechanical structure (bone and plate), not decoration spam.
For BRAVE / super-robot: moderate panel density, few primary division lines,
Imperial negative space preserved, silhouette reads first at distance.
No 1970s flat toy simplicity, no hyper-busy greeble, no sketch, no rough.
```

---

## 적용 범위

| 대상 | 적용 |
|------|------|
| mecha/* | 필수 · 밀도는 기체 대역 |
| character/* · weapon/* | 완성도 동일 |
| 컨셉 풀 | 미달 시 제작 REF 채택 금지 |

---

## 검증

| # | 체크 |
|---|------|
| 1 | 엣지·마감이 로봇혼/센티넬급인가 |
| 2 | 실루엣이 디테일에 먹히지 않는가 |
| 3 | 패널이 구조로 읽히는가 (장식 난립 아닌가) |
| 4 | 70s 평면 / 과밀도 양 극단이 아닌가 |

---

## 관련

- `SUPER_ROBOT_MODERN.md` — 슈퍼로봇 패널·집중
- `brave/FRAME_SPEC.md` · `BRAVE_INFLUENCE.md`
- FRAME “simple” = 실루엣 단순함 ≠ 저품질 평면

**DESIGN_QUALITY = 피니시 상한 + 정보량 절제. 선 수보다 구조.**

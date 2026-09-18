# DESIGN_QUALITY — 디자인 품질 기준 (SoR)

> 2026-08-09 · 3톤/저디테일 연동  
> **품질 목표: 반다이 로봇혼 · 센티넬 수준 피니시**  
> **정보량: `MECHA_3TONE_LOW_DETAIL` · `SUPER_ROBOT_MODERN`**  
> **Canon 계층:** `design/CANON_HIERARCHY.md` — 최상위 품질 상한 (Model A)

**상태: LOCK**

---

## 한 줄

피니시·엣지·완성도 = **로봇혼 / 센티넬급**.  
패널·색 정보량 = **3톤 · 큰 면 · 제한 라인** — 선이 많아 집중을 깨면 실패.

---

## 품질 바

| 축 | 기준 |
|----|------|
| 실루엣 | TEXT-LOCK·Shape Statement 엄수 · 흑실루엣 식별 |
| 비율 | 정밀 humanoid 또는 역할형 과장 · 치비만 금지 |
| 패널·라인 | 구조·관절 중심 · 장식 난립 금지 · **3TONE 문서 Level 1–3** |
| 표면 | 매트+세미글로스 · 큰 면 유지 · 저채도 가능 |
| 색 | **주·보조·포인트 3톤** · 페인터리·다색 조각 금지 |
| 디테일 | 관절 높음 · 장갑 낮음 |
| 완성도 | 완성품 선명도 · 러프·70s 평면 토이 금지 |

### 밀도

| 기체 | 대역 |
|------|------|
| BRAVE / 엑셀리온 | 중밀도 · 주 라인 소수 · 여백 · SUPER_ROBOT_MODERN |
| ORDER 전반 | 3TONE · 실루엣 개성 · 표면 저디테일 |
| 네메시스 | 3TONE · 독자 실루엣 · 위계 |

**선 개수 ≠ 품질.**

---

## 허용 / 금지

### 허용
- 로봇혼·센티넬급 엣지·단차
- 구조가 읽히는 큰 분할 + 국소 기능선
- 과장된 대표 특징 1+

### 금지
- 70s 과단순 평면 (단차 없음)
- 과밀도 그리블
- 5–6색 조각 배색
- 러프·페인터리·실루엣 키 파괴

---

## 프롬프트 공통

```
Bandai Robot Spirits / Sentinel level finish and edge quality.
Clean large armor surfaces, low surface detail, three dominant color tones,
restrained panel lines, detailed joints only where articulation needs reading.
Silhouette and signature feature read first at distance.
No hyper-busy greeble, no sketch, no rough, no excessive color fragmentation.
```

---

## 관련

- `MECHA_3TONE_LOW_DETAIL.md` — **공통 3톤·패널·밀도 SoR**
- `mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md` — 정체성 (하위)
- `SUPER_ROBOT_MODERN.md` — 슈퍼로봇 패널 (하위)
- `ORDER_DESIGN_LANGUAGE.md` — ORDER 실루엣·색 방향

**DESIGN_QUALITY = 피니시 상한 + 정보량 절제.**

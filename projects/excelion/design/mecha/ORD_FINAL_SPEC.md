# ORD_FINAL_SPEC — STEP 8 Base

> 2026-08-08 · STEP 8  
> 근거: `design/enemy/ORD_SPEC.md` · `ORD_OFFICIAL_SETTING.md` · `ORD_VISUAL_LANGUAGE.md` · 각 mecha/ord-*/DESCRIPTION.md  
> **상태: TEXT-LOCK**

---

## 한 줄

Order 양산·중형 실행 단위. **각·기능·투박**. BRAVE와 언어 자체가 다름. 병력 수로 압박. 성장 없음.

공통 그림체 안에서 역할만 방언 (GRUNT / HEAVY / GUN / MID).

---

## 공통 규칙

| 항목 | 내용 |
|------|------|
| 진영 | Order (엔릴 후손) |
| 대비 BRAVE | BRAVE=여백·여성형·단순 / ORD=각·기능·양산 |
| 색 | 저채도 회·청흑 · 군단감 · 호박 `#E8A020` **금지** |
| 센서 | 슬릿·냉광(적 또는 냉색 한 점) |
| 피니시 | 로봇혼급 가능 · 주인공 밀도 금지 |
| 성장 | 없음 · 병력 수로 압박 |
| 금지 | 네메시스급 위계 · 세스와 동일 · 주인공기 카피 · 개별 개성 과다 |

---

## 1. ORD-GRUNT

| 항목 | 내용 |
|------|------|
| id | ord-grunt |
| 역할 | 전 구간 양산 · 섬멸 대상 |
| 크기 | BRAVE보다 작거나 비슷 · 위압 없음 |
| 실루엣 키 | **각 · 작음 · 양산** |
| 체형 | 각진 두부 · 짧은 몸 · 팔다리 투박 · 여백 거의 없음 |
| 무장 | 내장 화기 또는 단순 블레이드 · 거대 실루엣 파괴 무기 없음 |
| 읽힘 | “많이 나온다” |

### 삼면도 지침
- T/A-pose · 순백 · 정면/측면/후면
- 각진·투박·양산형
- 스타일: 90년대 retro · 기능·투박

### Prompt (Positive)
```text
ORD-GRUNT — OFFICIAL MECHANICAL DESIGN SHEET, official Japanese anime mechanical setting material. Looks like an official Sunrise mechanical reference book and Bandai Master Grade development sheet from the late 1990s. Ultra high-density industrial mechanical illustration, professional production model sheet, technical orthographic turnaround (Front / Side / Back / 3/4 View), mechanical engineering presentation, perfectly symmetrical construction drawing, extremely clean cel-shaded rendering, black technical line art, flat production colors, no painterly rendering, no cinematic lighting, white background, Japanese grid layout, mechanical callouts, color palette chips, material notes, detail closeups. Mass-production enemy mecha ORD-GRUNT: compact angular head, short boxy torso, simple blocky limbs, no decorative ornamentation, dark slate gray industrial paint, single red sensor visor, utilitarian mechanical soldier silhouette.
```

### Negative
```text
low quality, blurry, sketch, perspective distortion, dynamic combat pose, complex decorations, wings, cape, crown, amber accents, hero proportions, organic muscles, chibi, cartoon, motion blur, painterly shading, cinematic lighting, dark background
```

---

## 2. ORD-HEAVY

| 항목 | 내용 |
|------|------|
| id | ord-heavy |
| 역할 | 전선 압박 · 방어 돌파용 |
| 크기 | BRAVE 이상 · 덩치로 압박 |
| 실루엣 키 | **넓음 · 두꺼움 · 둔** |
| 체형 | 넓은 어깨·두꺼운 흉 · 다리 짧고 안정 · 이동은 둔해 보임 |
| 무장 | 중화기·실드 판 · 각이 더 큼 |
| 읽힘 | “한 대가 무겁다” |

### 삼면도 지침
- T/A-pose · 순백 · 정면/측면/후면
- 넓은 어깨·두꺼운 흉·짧은 다리
- 스타일: 90년대 retro · 중압감

### Prompt (Positive)
```text
ORD-HEAVY — OFFICIAL MECHANICAL DESIGN SHEET, official Japanese anime mechanical setting material. Looks like an official Sunrise mechanical reference book and Bandai Master Grade development sheet from the late 1990s. Ultra high-density industrial mechanical illustration, professional production model sheet, technical orthographic turnaround (Front / Side / Back / 3/4 View), mechanical engineering presentation, perfectly symmetrical construction drawing, extremely clean cel-shaded rendering, black technical line art, flat production colors, no painterly rendering, no cinematic lighting, white background, Japanese grid layout, mechanical callouts, color palette chips, material notes, detail closeups. Armor assault mecha ORD-HEAVY: extremely wide shoulders, thick heavy chest armor, short sturdy legs, low center of gravity, dark slate gray and gunmetal mass-production industrial armor, single cold red visor sensor point, heavy defensive armor plates, solid grounded presence.
```

### Negative
```text
low quality, blurry, sketch, perspective distortion, dynamic combat pose, slender waist, long legs, wings, cape, crown, amber accents, organic muscles, chibi, cartoon, motion blur, painterly shading, cinematic lighting, dark background
```

---

## 3. ORD-GUN

| 항목 | 내용 |
|------|------|
| id | ord-gun |
| 역할 | 원거리 견제 |
| 크기 | GRUNT급 또는 약간 큼 |
| 실루엣 키 | **포신 · 돌출 · 원** |
| 체형 | 포신·센서 돌출 · 몸통은 가늘거나 박스형 · 팔보다 무기 라인이 먼저 읽힘 |
| 무장 | 장포·미사일 포드 · 근접 실루엣은 약해 보임 |
| 읽힘 | “멀리서 쏜다” |

### 삼면도 지침
- T/A-pose · 순백 · 정면/측면/후면
- 포신·센서가 실루엣에서 먼저 읽히게
- 스타일: 90년대 retro · 원거리 병기

### Prompt (Positive)
```text
ORD-GUN — OFFICIAL MECHANICAL DESIGN SHEET, official Japanese anime mechanical setting material. Looks like an official Sunrise mechanical reference book and Bandai Master Grade development sheet from the late 1990s. Ultra high-density industrial mechanical illustration, professional production model sheet, technical orthographic turnaround (Front / Side / Back / 3/4 View), mechanical engineering presentation, perfectly symmetrical construction drawing, extremely clean cel-shaded rendering, black technical line art, flat production colors, no painterly rendering, no cinematic lighting, white background, Japanese grid layout, mechanical callouts, color palette chips, material notes, detail closeups. Long-range artillery mecha ORD-GUN: slender boxy torso frame dominated by shoulder-mounted long cannon barrels and sensor optics, dark slate gray industrial finish, single red sensor lens, distinctive artillery silhouette.
```

### Negative
```text
low quality, blurry, sketch, perspective distortion, dynamic combat pose, melee sword, shield, wings, cape, crown, amber accents, organic muscles, chibi, cartoon, motion blur, painterly shading, cinematic lighting, dark background
```

---

## 4. ORD-MID

| 항목 | 내용 |
|------|------|
| id | ord-mid |
| 역할 | 중보스 · EP5 정점 · 병기 감 |
| 크기 | HEAVY 이상 · 한 기만으로도 존재감 |
| 실루엣 키 | **중형 · 병기 많음 · EP5** |
| 체형 | 중형 덩치 + 병기 과다 · GRUNT/HEAVY와 즉시 구분 · 각은 유지하되 부위가 많음 |
| 무장 | 다총구·아암 웨폰 · “양산의 정점” (세스/네메시스 아님) |
| 읽힘 | “지금까지와 다르다” |
| 금지 추가 | 오만 위계 연출 · 비극 주연 연출 |

### 삼면도 지침
- T/A-pose · 순백 · 정면/측면/후면
- 중형 덩치 + 병기 과다로 GRUNT/HEAVY와 구분
- 스타일: 90년대 retro · 중보스 존재감

### Prompt (Positive)
```text
ORD-MID — OFFICIAL MECHANICAL DESIGN SHEET, official Japanese anime mechanical setting material. Looks like an official Sunrise mechanical reference book and Bandai Master Grade development sheet from the late 1990s. Ultra high-density industrial mechanical illustration, professional production model sheet, technical orthographic turnaround (Front / Side / Back / 3/4 View), mechanical engineering presentation, perfectly symmetrical construction drawing, extremely clean cel-shaded rendering, black technical line art, flat production colors, no painterly rendering, no cinematic lighting, white background, Japanese grid layout, mechanical callouts, color palette chips, material notes, detail closeups. Mid-boss commander mecha ORD-MID: medium-heavy industrial mecha frame, multiple shoulder missile pods and forearm weapon mounts, dark slate gray armor, red sensor point, heavy mass-production elite unit silhouette, complex angular paneling.
```

### Negative
```text
low quality, blurry, sketch, perspective distortion, dynamic combat pose, hero proportions, wings, cape, crown, amber accents, organic muscles, chibi, cartoon, motion blur, painterly shading, cinematic lighting, dark background
```

---

## 식별 테스트 (실루엣만)

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

## 검증

| # | 체크 | 결과 |
|---|------|------|
| 1 | 4종이 문장만으로 구분 | OK |
| 2 | BRAVE·세스·네메시스와 키 충돌 없음 | OK |
| 3 | MID=EP5 병기감 | OK |
| 4 | 공통 그림체 · 호박 accent 금지 | OK |

**STEP 8 ORD Base = TEXT-LOCK 완료.**

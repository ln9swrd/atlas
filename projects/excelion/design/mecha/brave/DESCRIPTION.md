# BRAVE (brave-001) — 기체 삼면도 레퍼런스

> 출처: FRAME_SPEC.md · BRAVE_FINAL_SPEC.md · docs/06_MECHA.md

## 기본 정보

| 항목 | 내용 |
|------|------|
| id | brave-001 |
| 이름 | BRAVE / Brave |
| codename | EX-BRAVE-001 |
| 키 | **25 m** |
| 역할 | 플레이어 기체 · S1 전 구간 동일 형태 |
| 파일럿 | 리아 |

## 실루엣 키워드

**여백 · 여성형 · 단순**

## 체형 · 외형

- humanoid · 머리 작게 · 어깨 과하지 않음 · 허리 한 단 들어가 여성형 · 다리 길어 기동감
- 머리/콕핏: 헬멧형 · 바이저 가로 슬릿 또는 단일 렌즈 · 뿔·안테나·과무장 없음
- 흉·복부: 평면 위주 · Imperial 여백 · 중앙 코어 라인만 accent
- 팔: 단순 원통+판 · 거포·방패 기본 장착 없음
- 다리: 판 최소 · 무릎 관절 읽힘 · 안정 접지형
- 배면: 백팩 없음 · thruster 돌출 없음 (초기형)

## 색

| 용도 | 값 |
|------|-----|
| primary | `#C0C8D0` (차가운 회백) |
| secondary | `#2A3A4A` (깊은 남회) |
| accent | `#E8A020` (호박 오렌지 · 관절·시선) |

## 읽힘

아군 주인공기 · ORD보다 장식 적고 사람다움

## 금지

- S1 중반 형태 변경
- 성인 히로인형 과무장·과장 실루엣
- 세스/네메시스와 동일 실루엣
- 팔레트 임의 변경

## 삼면도 생성 지침

- 포즈: T-pose 또는 A-pose, 팔 몸에서 분리
- 배경: 순백색
- 뷰: 정면 · 측면 · 후면 (orthographic)
- 25m humanoid 비율 · 여성형 허리 라인
- 백팩/스커트/무기 슬롯 비활성 (단순)
- 스타일: 90년대 retro · modern_super · simple

## AI 이미지 생성용 프롬프트 (Sunrise MG Spec V3)

### Positive Prompt
```text
BRAVE-001 — OFFICIAL MECHANICAL DESIGN SHEET, official Japanese anime mechanical setting material. Looks like an official Sunrise mechanical reference book and Bandai Master Grade development sheet from the late 1990s. Ultra high-density industrial mechanical illustration, professional production model sheet, technical orthographic turnaround (Front / Side / Back / 3/4 View), mechanical engineering presentation, perfectly symmetrical construction drawing, extremely clean cel-shaded rendering, black technical line art, flat production colors, no painterly rendering, no cinematic lighting, white background, Japanese grid layout, mechanical callouts, color palette chips, material notes, detail closeups. Protagonist mecha BRAVE-001: 25m height humanoid proportions, sleek feminine waistline, small head with clean helmet visor and horizontal glowing slit, cold blue-gray primary armor (#C0C8D0), deep navy-gray secondary joints (#2A3A4A), amber orange eye accent (#E8A020), flat clean armor plates, no heavy backpack, no wings, no weapons in hand, simple elegant heroic silhouette.
```

### Negative Prompt
```text
low quality, blurry, sketch, perspective distortion, dynamic combat pose, heavy weapons, bulky armor, wings, cape, oversized backpack, demon horns, organic muscles, red eyes, excessive spikes, asymmetrical design, chibi, cartoon, motion blur, painterly shading, cinematic lighting, dark background
```

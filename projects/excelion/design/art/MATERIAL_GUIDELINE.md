# MATERIAL_GUIDELINE — Excelion

> 2026-08-10  
> 원천: MECHA_3TONE · BRAVE_FINAL_SPEC · ART_DIRECTION

**상태: 초안**

---

## 1. 3톤 원칙

| 슬롯 | 역할 |
|------|------|
| Primary | 주 장갑 면 |
| Secondary | 그림자·내측·대비 |
| Accent | 코어·시선·필살 점등 |

기체별 팔레트는 FINAL_SPEC / DESCRIPTION을 따른다. 임의 변경 금지.

BRAVE 예:
- Primary `#C0C8D0`
- Secondary `#2A3A4A`
- Accent `#E8A020`

---

## 2. Unreal 머티리얼

- Master Material 1종 + Material Instance per 기체/파츠
- 파라미터: BaseColor (3톤) · Roughness · Metallic (최소) · Emissive (Accent)
- 과한 노멀/디테일 맵으로 패널 인상 강화 금지

---

## 3. 표면

- 매트 + 세미글로스
- 큰 면 우선 · 로컬 반사로 실루엣 파괴 금지
- 손상 상태: 스크래치·균열은 단계적 · 형태 변경으로 손상 표현 금지 (S1 중반)

---

## 4. 광기·코어

- Accent / Emissive 점등·균열광
- 실루엣 유지 · MADNESS_VISUAL 규칙 준수

---

## 5. 체크

- 원거리에서도 3톤 블록이 읽히는가?
- Accent가 시선·코어를 유도하는가?
- 리얼 밀리터리 도장으로 보이지 않는가?

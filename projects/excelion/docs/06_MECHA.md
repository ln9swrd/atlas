# 06_MECHA — 기체 파라미터

출처: `projects/paramodel/data/mecha/brave-001.json` + DESIGN.md  
상세 디자인: `docs/03_MECHA/BRAVE_SPEC.md`

## BRAVE-001 (초기형)
| 필드 | 값 |
|------|-----|
| id | brave-001 |
| name | Brave |
| codename | EX-BRAVE-001 |
| archetype | humanoid |
| category | player |
| size | height 25.0 m (scale_class 25m) |
| 설명 | 초기형 브레이브. 단순 실루엣, 성장 전 기본 기체 |

## 파라미터 (concept)
| 항목 | 값 |
|------|-----|
| mass | 48.5 |
| armor_thickness | 1.0 |
| mobility | 0.7 |
| output | 0.65 |

## Visual
- primary: #C0C8D0 / secondary: #2A3A4A / accent: #E8A020
- style_tags: modern_super, organic_mechanical, simple, retro

## 슬롯 (base_body humanoid)
head, torso_upper, torso_lower, arm_l/r, leg_l/r 활성
backpack / skirt / weapon / thruster = 비활성 (초기형)

## Size 계약 (ParaModel)
- template reference_value 2.0 m → value 25 → **sf = 12.5**
- scale_class는 라벨일 뿐 divisor 아님

## 엑셀리온 (진화 1단계)

| 항목 | 내용 |
|------|------|
| 골격 | **동일** (교체 금지) |
| 주체 | 리아가 끌어냄 |
| EP11 | 일시 전조 · 윤곽 확장 · 사그라짐 |
| EP13 | 확장 고정 · thruster/backpack 택1–2 활성 |
| 전투 | 봉쇄 무시/조기 소멸 · ×1.5 · N04 취소 |
| 초필 | 엑셀리온 플레어 |

상세: `docs/03_MECHA/BRAVE_SPEC.md`

## 상태
- status: concept + 엑셀리온 규칙 고정
- updated: 2026-08-07

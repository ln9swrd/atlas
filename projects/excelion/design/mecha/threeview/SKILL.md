---
name: mecha-threeview
description: Generate consistent three-view (front, side, back) mecha design turnaround sheets for Excelion units. Use when the user asks for 기체 삼면도, mecha turnaround, robot orthographic sheet, or mecha model sheet.
---

# Mecha Threeview

## Overview

Create professional orthographic mecha design sheets (front, side, back) for Excelion units. Ensures silhouette consistency and suitability as 3D modeling reference.

**조형 기준:** `../SUPER_ROBOT_DESIGN_LANGUAGE.md` — **SUPER ROBOT FIRST** 필수.  
**피니시:** 로봇혼/센티넬 수준의 **마감** (패널 과밀·건담식 디테일은 목표 아님).

## Storage Convention

```
projects/excelion/design/mecha/<unit-name>/threeview/
```

Read each unit's DESCRIPTION.md and SUPER_ROBOT_DESIGN_LANGUAGE before generating.

## Prompt Rules

- Orthographic, no perspective distortion
- Clean white or light gray background
- T-pose or neutral standing pose with clear limb separation
- Identical proportions and details across all three views
- Emphasize silhouette keywords from DESCRIPTION.md
- **SUPER ROBOT FIRST (mandatory)**
  - Heroic / iconic large armor volumes
  - Curved outer forms on chest, shoulders, limbs
  - Character-like head — not pure sensor block
  - Low panel density relative to form
  - Explicitly **not Gundam**, **not real-robot mobile suit**
- **Finish bar:** Bandai Robot Spirits / Sentinel **surface quality**
  - Sharp clean edges, premium figure finish
  - Matte and semi-gloss metal
  - Official product reference quality
  - No sketch, no rough, no low-effort simplification
  - **Do not** equate quality with ultra-dense industrial panel spam
- Style base: super-robot proportions & silhouette + modern high-end figure finish
- Never sacrifice silhouette keywords for extra detail

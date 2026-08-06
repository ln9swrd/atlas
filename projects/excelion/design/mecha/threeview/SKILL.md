---
name: mecha-threeview
description: Generate consistent three-view (front, side, back) mecha design turnaround sheets for Excelion units. Use when the user asks for 기체 삼면도, mecha turnaround, robot orthographic sheet, or mecha model sheet.
---

# Mecha Threeview

## Overview

Create professional orthographic mecha design sheets (front, side, back) for Excelion units. Ensures silhouette consistency and suitability as 3D modeling reference.

**품질 기준:** `../DESIGN_QUALITY.md` — **반다이 로봇혼 / 센티넬 수준** 필수.

## Storage Convention

```
projects/excelion/design/mecha/<unit-name>/threeview/
```

Read each unit's DESCRIPTION.md as the primary reference before generating.

## Prompt Rules

- Orthographic, no perspective distortion
- Clean white or light gray background
- T-pose or neutral standing pose with clear limb separation
- Identical proportions and details across all three views
- Emphasize silhouette keywords from DESCRIPTION.md
- **Quality bar (mandatory):** Bandai Robot Spirits / Sentinel level finish
  - Ultra high-density industrial panel lines, precise rivets and surface segmentation
  - Sharp clean edges, premium figure-quality mechanical detail
  - Matte and semi-gloss metal surfaces
  - Official product reference quality
  - No sketch, no rough, no low-density simplification
- Style base: 90s retro proportions & silhouette + modern high-end figure density
- Never sacrifice silhouette keywords for extra detail

---
name: mecha-threeview
description: Generate consistent three-view (front, side, back) mecha design turnaround sheets for Excelion units. Use when the user asks for 기체 삼면도, mecha turnaround, robot orthographic sheet, or mecha model sheet.
---

# Mecha Threeview

## Overview

Create professional orthographic mecha design sheets (front, side, back) for Excelion units. Ensures silhouette consistency and suitability as 3D modeling reference.

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
- Style: 90s retro mecha, modern_super, organic_mechanical, simple

---
name: character-threeview
description: Generate consistent three-view (front, side, back) character design turnaround sheets and provide tips for linking them to 3D modeling. Use when the user asks for 삼면도, character turnaround, orthographic character sheet, model sheet, 3D modeling reference, or multi-view character design images.
---

# Character Threeview

## Overview

Create professional-style character design sheets showing the same character from multiple orthographic angles (front, side, back) in a clean layout. Ensures visual consistency across views. Also provides practical tips for using the generated sheets as reference in 3D modeling workflows (Blender, Maya, ZBrush, etc.).

## When to Activate

Trigger on requests containing any of:
- 삼면도 / 삼면도 캐릭터
- character turnaround / turnaround sheet
- orthographic character / model sheet / reference sheet
- multi-view character design
- front side back character
- 3D 모델링 연계 / 3D modeling reference / 3D 레퍼런스

## Core Instructions

1. **Clarify key details first** (if missing):
   - Character description (species, gender, age, clothing, accessories, distinctive features)
   - Art style (anime, realistic, chibi, semi-realistic, pixel, etc.)
   - Color palette preference or "full color / line art only"
   - Number of views (default: front + side + back)
   - Pose (default: standing T-pose or relaxed A-pose, neutral expression)
   - Whether the sheet will be used for 3D modeling (affects pose and clarity recommendations)

2. **Prompt construction rules for consistency**:
   - Always describe the character **once** in detail, then instruct "same character from multiple angles".
   - Explicitly request orthographic / turnaround layout.
   - Specify clean white or light gray background.
   - Demand identical proportions, clothing, colors, and details across all views.
   - Include "professional character design sheet", "model sheet", "reference sheet".
   - Add "consistent lighting, no perspective distortion, flat orthographic views".
   - For 3D use: prefer T-pose or A-pose with arms slightly away from body, clear silhouette, minimal overlapping elements.

3. **Recommended prompt structure**:
   ```
   Professional character design turnaround sheet of [detailed character description], 
   shown in three orthographic views side by side: front view, side view, back view, 
   standing in neutral A-pose or T-pose, same exact character, identical proportions clothing and colors, 
   clean white background, high detail, consistent style, [art style], character model sheet, 
   clear silhouette, suitable as 3D modeling reference
   ```

4. **Generation**:
   - Use the image generation capability (Grok Imagine) with the constructed prompt.
   - Prefer landscape orientation for side-by-side views.
   - If user wants more views (top, 3/4, expression sheet), extend the prompt accordingly.

5. **Iteration**:
   - If the generated image has inconsistent details between views, regenerate with stronger consistency language ("perfectly identical details across all views", "no variation").
   - For refinements, edit the existing image or regenerate with updated description.

## 3D Modeling Linkage Tips

When the user mentions 3D modeling or asks for linkage tips, provide these practical recommendations:

### Best Practices for 3D-Ready Three-Views
- **Pose**: Prefer T-pose (arms horizontal) or A-pose (arms slightly down and away from body). Avoid crossed arms, hands in pockets, or overlapping limbs.
- **Silhouette clarity**: Keep clothing and accessories from heavily overlapping the body outline.
- **Proportions**: Emphasize accurate head-to-body ratio and limb lengths — 3D modelers rely on these measurements.
- **Details**: Show important seams, pockets, straps, and hard-surface edges clearly on all views.
- **Background**: Pure white or very light gray so the image can be easily keyed or used as image plane.
- **Scale consistency**: Keep the character the same size across all three panels.

### How to Use the Sheet in Common 3D Software
- **Blender**: Import the image as a reference image or image plane on the Front/Side orthographic views. Use Empty → Image or the Add Image as Plane addon. Match the character height to a known real-world scale if needed.
- **Maya / 3ds Max**: Create image planes on the orthographic cameras. Set the image as a texture on a plane and lock it.
- **ZBrush / Mudbox**: Use the image as a reference for sculpting, or load it into Spotlight / Texture for projection.
- **General workflow**:
  1. Block out basic proportions using the front and side views first.
  2. Extrude or sculpt the main body volume.
  3. Check the back view frequently for silhouette and backpack/accessory placement.
  4. Use the sheet for UV layout reference and texture painting later.

### Extra Views That Help 3D Artists
- Top-down view (for head shape and shoulder width)
- 3/4 view (for volume understanding)
- Hand and foot close-ups
- Expression sheet (if the character will be animated)

### Common Pitfalls to Avoid
- Perspective distortion in the generated views → insist on "flat orthographic, no perspective".
- Inconsistent clothing folds or accessory placement between views.
- Arms too close to the body (makes topology and skinning harder).
- Overly stylized proportions that are hard to translate into clean topology.

## Style Notes

- Default to clean, professional game/animation industry model-sheet aesthetic unless user specifies otherwise.
- Avoid dramatic lighting, heavy perspective, or action poses unless requested.
- Keep the character centered in each panel with even spacing.

## Output

- Generate the image when requested.
- Briefly confirm the views included.
- When 3D linkage is relevant, summarize the most useful tips above and offer to adjust the sheet (e.g., switch to strict T-pose, add top view, increase clarity of edges).

## Storage Convention (for this project)

Generated three-view images and related assets for individual characters should be stored under:

```
projects/excelion/design/character/<character-name>/threeview/
```

Example:
```
projects/excelion/design/character/hero_luna/threeview/
├── front_side_back.png
├── tpose_reference.png
└── notes.md
```

The skill file itself lives at:
```
projects/excelion/design/character/threeview/SKILL.md
```

# MODERN_SUPER_ROBOT_DESIGN_PRINCIPLES — Excelion Design Record

> 2026-09-02 · Master-defined design principle record
> Scope: Excelion visual design baseline for future character/mecha design and Base Mesh experiments
> Status: Design reference document
> Related SoR: `DESIGN_QUALITY.md` · `SUPER_ROBOT_MODERN.md` · `SUPER_ROBOT_DESIGN_LANGUAGE.md`
>
> This document is a recorded design principle reference only. It does not replace or revise canon.

---

## 1. Purpose

This document records the current Master-defined Modern Super Robot design principles for Excelion.

The goal is to establish a shared reference for future character/mecha design and Base Mesh experimentation so that decisions remain consistent and comparable over time.

The document is a design record only. It is not a production implementation guide, Unreal implementation note, or a new canon rewrite.

---

## 2. Base Design Direction

Excelion's Modern Super Robot design is grounded in the visual language of the following works, with explicit weighting:

1. Mazinger Z — highest priority
2. Getter Robo / Getter-verse — secondary priority
3. Grendizer — tertiary priority

This is not simple imitation. It is a reference system for extracting and combining the sculptural characteristics that best support the Excelion identity.

### 2.1 Design Reference Priority

- Mazinger Z is the primary reference for overall super robot mass, impact, and silhouette power.
- Getter Robo contributes attack posture, angularity, and a sharper combat silhouette.
- Grendizer contributes memorable silhouette exaggeration and iconic character presence, without overwhelming the base super robot structure.

---

## 3. Primary Reference — Mazinger Z

Mazinger Z carries the highest weight in the final design language.

### 3.1 Core Elements

- Strong symbolic face
- Powerful chest armor presence
- Monumental shoulders
- Strong upper body mass
- Super robot feel of force and overwhelming presence
- Clear, strong body blocks
- Distinct silhouette readable at a glance

### 3.2 Role

> The overall super robot shape and expression of strength are determined by the Mazinger Z reference.

This reference dictates the broad visual identity of Excelion mecha and establishes the baseline for the robot's power and recognizability.

---

## 4. Secondary Reference — Getter Robo

Getter Robo is the secondary reference and adds aggression and sharpness.

### 4.1 Core Elements

- Powerful upper body
- Sharp silhouette
- Exaggerated hands and feet
- Aggressive armor forms
- Combat-oriented impression
- Tense outer contour

### 4.2 Role

> The Mazinger-based powerful super robot form gains aggression and sharpness from Getter Robo.

This layer prevents the robot from becoming overly soft, bulky, or static. It sharpens the silhouette and strengthens the sense of conflict and motion.

---

## 5. Tertiary Reference — Grendizer

Grendizer is the tertiary reference and adds distinctive character identity.

### 5.1 Core Elements

- Extreme silhouette
- Face treated as a core character element
- Exaggeration beyond realistic machine structure
- Highly memorable unique form

### 5.2 Role

> The base super robot form remains intact while personality and unreal exaggeration are added.

However, Grendizer's extreme expression should not be blindly enlarged. The design must preserve readably strong super robot structure, not become chaotic or decorative.

---

## 6. Color Design Principles

## 6.1 General Principle

Colors should not be used excessively.

Likewise, a single color should not dominate so completely that the design becomes too monotonous.

The target is:

> To maintain diversity, depth, form distinction, and character identity inside a limited color hierarchy.

---

## 7. Primary Color — 3 Tone

The primary color is the main color that occupies the largest surface area across the robot.

The primary color is generally operated in 3 tones:

- Primary Light
- Primary Base
- Primary Dark

Example: if the primary color is white:

- White Light
- White Base
- White Dark

Important:

> This does not mean using three different colors like white, gray, and black.
> It means using one color family in three tonal steps.

The purpose is to define the robot's broad shape, mass, and layered surface without creating unnecessary color clutter.

---

## 8. Secondary Color — 2 Tone

The secondary color occupies a smaller surface area than the primary color and helps distinguish major body blocks or structural segments.

The default is a 2-tone system:

- Secondary Base
- Secondary Dark

The secondary color family should also remain limited and cohesive.

---

## 9. Other Colors

Colors outside the primary and secondary palette may be used when required by design or functionality.

Examples:

- Internal frame
- Joints
- Armaments
- Functional parts
- Specific structural elements

There is no strict mandatory tonal count for these auxiliary colors, but excessive increase of color count is discouraged.

---

## 10. Point Color

Point colors are used sparingly.

Examples:

- Eyes
- Sensors
- Energy cores
- Specific functional elements
- Symbolic weapon or armor details

Purpose:

> Guiding attention and reinforcing character identity.

Point color should not dominate the overall design.

---

## 11. Color Contrast Principle

The important issue is not simply the number of colors but the clarity of difference between colors.

Even when using different tones of the same color family, the tonal separation must be visually distinct enough to read properly.

### 11.1 Prohibited

> Different tones are named as if they are different, but in the actual image they hardly separate at all.

### 11.2 Principle

> Each color and tone should differ enough that form and structure remain recognizable.

This is essential for preserving silhouette readability and structural clarity.

---

## 12. Perspective / Depth Expression

Color and brightness are not just decoration. They help convey spatial depth and readable structure.

The following relationship must remain clear:

- protruding
- surface
- recessed / internal

Especially in the following structures, the front-back relationship should remain clear:

- shoulder armor and upper arm
- chest armor
- abdomen and waist
- pelvis armor
- joint internals
- hands and fingers
- back plate and rear structure
- overlapping armor pieces

Overlapping structures must not read as a flat plane by using nearly identical colors and similar luminance values.

Goal:

> Use color and value differences to make direction, front-back relation, and depth easy to understand.

---

## 13. Panel Line Principles

Panel lines should not be overused.

The default should be a 3-level hierarchy:

- LEVEL 1 — PRIMARY
  - Large armor divisions
  - Major body blocks
  - Lines that determine silhouette and structure
- LEVEL 2 — SECONDARY
  - Armor structure separation
  - Functional divisions
  - Joint-adjacent structure
- LEVEL 3 — TERTIARY
  - Small panels
  - Minor mechanical structure
  - Limited functional or decorative details

Not every surface should be filled with panel lines.

Panel lines are:

> structural information used to explain form.

They are not decoration by default.

---

## 14. Overall Complexity Principle

Design complexity must not be increased indiscriminately.

The following three layers must be clearly separated:

- Large form
- Structural division
- Detail

Large form must be readable first, and detail should not disrupt the silhouette.

Goal:

> A complex but not messy super robot.

---

## 15. Relationship to Base Mesh Creation

This design principle is not limited to aesthetics.

In the current Excelion Base Mesh experiments, the following factors are important for stable 3D recognition from an image:

- clear silhouette
- clear color distinction
- sufficient value difference
- clear front-back depth
- limited panel line density

This yields:

> design conditions favorable for 3D form recognition.

However, this document does not guarantee the success of any specific AI model or 3D generation tool.

---

## 16. Design Priority

The overall priority is as follows:

1. Silhouette
2. Body blocks and proportion
3. Color hierarchy
4. Color contrast
5. Spatial depth / perspective
6. Major armor structure
7. Panel lines
8. Detail

No lower-priority detail should sacrifice the higher-priority reading of the design.

---

## 17. Current Stage and Scope

The project is not in an Unreal prototyping stage.

The current priority is to continue validating Base Mesh generation viability and quality.

Therefore, the following are out of scope for this document and this task:

- Unreal implementation
- Rigging
- Animation
- Retarget
- Combat implementation
- Blueprint modification
- Actual character asset production
- Actual mecha asset production
- Hunyuan3D code modification
- New 3D generation pipeline setup
- Existing canon modification

---

## 18. Document Nature

This document is a current Master-defined design principle record.

It does not alter or replace other canon documents arbitrarily.

If a conflict is discovered between this document and existing canon, it must not be silently resolved by arbitrary modification.

Instead, report it as:

- CONFLICT
- → 근거
- → 영향
- → Master judgment required

---

## 19. Working Safety Rules

Before work begins, confirm:

- HEAD
- Branch
- Working Tree
- Existing modified files

Existing changes must never be modified or reverted.

After creating a new document, always verify the diff.

If unintended changes are found, stop immediately.

---

## 20. Git Rules

This task is limited to writing the document and checking the diff.

- Commit: not performed before Master approval
- Push: not performed

---

## 21. Final Summary

Excelion's Modern Super Robot design should aim for:

- strong, readable silhouette
- heavy and clear body block language
- controlled palette with tonal hierarchy
- enough contrast to maintain structure and depth
- limited panel line density
- a clean but powerful super robot identity

The design should remain legible, forceful, and memorable without becoming flat, noisy, or overly decorative.

This record serves as a stable reference for future design iterations and Base Mesh tests.

---

## 22. Document Status

This document is recorded as a design principle reference for Excelion and is intentionally maintained as an independent record outside the canonical implementation or asset files.

# MENOS Beam VFX Image Generation Prompt

## 목적
MENOS 전투에서 사용하는 Beam VFX용 스프라이트/이미지 원본을 생성하기 위한 프롬프트. 게임 엔진에서 후처리 없이 사용할 수 있도록 단순하고 명확한 형태를 우선한다.

## Master Prompt

Create a clean 2D game VFX sprite sheet for a futuristic energy beam attack in a stylized sci-fi action game.

Subject: a powerful straight energy beam emitted from a weapon, viewed strictly from the side, designed as a reusable horizontal beam effect.

Composition: 8 animation frames arranged in a single horizontal row, identical canvas size for every frame, centered beam, consistent origin and alignment, no camera movement, no perspective change.

Visual design: simple rounded beam core with a bright white-hot center, a saturated electric blue outer glow, subtle cyan energy edge, compact and readable silhouette, smooth rounded ends, slightly varied energy intensity between frames. The beam should feel energetic and mechanical rather than magical.

Style: clean 2D game sprite, simplified shapes, crisp silhouette, production-ready VFX reference, restrained detail, no photorealism, no 3D rendering, no environmental elements.

Animation progression: frame 1 small ignition; frames 2-3 rapid expansion; frames 4-6 full-power beam; frame 7 energy decay; frame 8 fade-out. Keep the beam position and overall direction fixed across all frames.

Background: fully transparent alpha background.

Important constraints: no character, no weapon body, no muzzle, no hands, no environment, no text, no particles outside the beam envelope, no debris, no smoke, no lens flare, no circular explosion, no perspective distortion, no diagonal beam, no inconsistent frame scale.

The final result must be suitable for slicing into individual PNG animation frames and importing into a 2D game engine.

## Negative Prompt

character, robot, weapon body, hand, environment, background, text, logo, watermark, photorealistic, 3D render, perspective, diagonal beam, camera angle change, inconsistent scale, explosion, smoke, debris, fire, excessive particles, lens flare, circular effect, complex scenery, opaque background, black background, white background, cropped beam, frame border

## Production Notes

- Target: Beam VFX sprite sheet
- Frames: 8
- Layout: 1 row x 8 columns
- Background: transparent
- View: strict side view
- Direction: horizontal
- Primary visual identity: white core + blue/cyan energy envelope
- Keep silhouette simple enough to read at gameplay scale.
- Do not treat generated art as Canon until reviewed and approved by Master.
- This document is a generation prompt only; it does not modify Runtime, Schema, or Canon.

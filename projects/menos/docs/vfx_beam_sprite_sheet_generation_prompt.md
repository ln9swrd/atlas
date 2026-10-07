# MENOS Beam VFX Sprite Sheet Generation Prompt

STATUS — PROPOSAL / NOT CANON

## 목적

MENOS 전투에서 재사용할 Neutral Beam VFX 스프라이트 시트를 이미지 생성 모델로 제작하기 위한 프롬프트다. 기존 `vfx_beam_sprite_sheet_guidelines.md`의 제작 기준을 우선하며, 생성 결과는 Master 검토 전까지 최종 Asset 또는 Canon으로 취급하지 않는다.

## Master Prompt

Create a clean, production-ready 2D game VFX sprite sheet for a reusable futuristic energy beam attack in a stylized sci-fi action game.

Create exactly 8 animation frames in one single horizontal row: 1 column of frames vertically is forbidden; use 8 equal-width columns and 1 row only.

Every frame must use the exact same canvas size, origin, baseline, center alignment, beam direction, and scale. Keep the beam horizontally aligned and suitable for slicing into eight individual PNG frames.

Subject: a straight horizontal energy beam viewed strictly from the side. The beam is a reusable source texture, not a complete weapon attack scene.

Visual design:
- Neutral white beam source texture only.
- Very bright, narrow white-hot central core.
- Soft translucent white outer glow.
- Subtle irregular energy distortion along the beam edge.
- Simple rounded beam silhouette.
- Clear silhouette that remains readable at small gameplay size.
- Clean alpha falloff at the outer glow.
- Energetic and mechanical sci-fi appearance, not magical.

Animation progression:
1. Energy formation / small ignition.
2. Rapid core expansion.
3. Rapid expansion toward full length.
4. Full-length beam at strong intensity.
5. Full-power energy pulse.
6. Maximum glow and subtle edge distortion.
7. Energy contraction and decay.
8. Fade out.

The beam must remain horizontally aligned throughout all frames. Do not change camera position, perspective, beam angle, origin, or frame scale between frames.

Background and alpha:
- Fully transparent alpha background.
- No visible background color.
- No black, white, gray, colored, gradient, or environmental background.
- No opaque pixels outside the beam and its intended glow.

Composition constraints:
- No frame borders.
- No grid lines.
- No labels or numbers.
- No text, logo, watermark, UI, or symbols.
- No cropping of the beam.
- No overlap between separate frames.
- Keep sufficient transparent padding around each frame.
- Do not include any weapon, robot, character, hand, muzzle, environment, impact point, or separate projectile.

Color constraint:
The source texture must remain neutral white. Do not bake blue, cyan, red, purple, green, gold, or other team/skill colors into the texture. The asset is intended to be recolored at runtime using Godot tint/modulate/shader parameters.

Technical target:
- 8-frame horizontal sprite sheet.
- Equal frame dimensions.
- Consistent origin and baseline.
- Transparent PNG-compatible alpha.
- Crisp core with smooth semi-transparent glow.
- Designed to support horizontal stretching and runtime recoloring.
- Suitable as a reusable VFX source for multiple robots and skills.

## Negative Prompt

robot, enemy, character, weapon body, gun, cannon, hand, muzzle, projectile, impact, explosion, environment, scenery, floor, wall, particles outside beam envelope, debris, smoke, fire, sparks unrelated to beam, lens flare, circular explosion, magic effect, photorealism, 3D render, perspective, camera angle change, diagonal beam, curved beam, inconsistent scale, inconsistent alignment, frame border, grid, text, number, logo, watermark, opaque background, black background, white background, colored background, gradient background, cropped frame, cropped beam, overlapping frames, baked blue, baked cyan, baked red, baked purple, baked green, baked gold

## 생성 후 확인 기준

1. 정확히 8개 프레임인지 확인한다.
2. 1×8 가로 배열인지 확인한다.
3. 모든 프레임의 canvas 크기와 정렬이 동일한지 확인한다.
4. Beam 방향이 모든 프레임에서 수평인지 확인한다.
5. 배경이 완전 투명인지 확인한다.
6. Core가 중립 백색인지 확인한다.
7. 외곽 Glow가 과도한 색상으로 고정되지 않았는지 확인한다.
8. 로봇/무기/총구/Impact/환경 요소가 없는지 확인한다.
9. 프레임 간 Beam 위치가 흔들리지 않는지 확인한다.
10. 게임 화면의 작은 크기에서도 Beam 실루엣이 식별 가능한지 확인한다.

## MENOS 적용 원칙

- 생성 결과는 최종 Asset이 아니라 후보 원본이다.
- Master 승인 전에는 Canon으로 승격하지 않는다.
- 기존 Beam VFX 구조와 공격 판정을 분리한다.
- Runtime 색상, 길이, 방향, 폭, 지속시간은 원본 이미지에 굽지 않는다.
- 기존 effects / projectile 구조를 우선 재사용한다.
- 실제 Runtime 적용은 생성 결과의 품질 검토 후 별도 판단한다.

## 범위 제한

이 문서는 Beam VFX 스프라이트 시트 생성용 프롬프트만 정의한다.

다음은 이 문서에서 결정하지 않는다:
- 최종 Asset 승인
- VFX ODB PK
- VFX Schema 변경
- Runtime 코드 변경
- 실제 색상값
- 실제 지속시간/폭
- 외부 Asset 사용

PROPOSAL ≠ CANON.

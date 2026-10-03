# MENOS Robot Sprite Sheet Generation Prompt Specification

## 1. 목적

이 문서는 MENOS Robot Editor를 기준으로 로봇 캐릭터의 원본 이미지와 게임용 Sprite Sheet를 생성하기 위한 공통 프롬프트 규격이다.

목표는 단순히 보기 좋은 캐릭터 이미지를 생성하는 것이 아니라 다음 Asset을 하나의 일관된 캐릭터 정의에서 파생할 수 있도록 하는 것이다.

- Character Reference
- Profile Image
- Main Sprite Animation
- Skill Animation
- Projectile Animation
- Skill Icon
- VFX
- Team Color Shader용 색상 영역

생성 결과는 이후 Visual Asset Catalog, Animation Geometry, Editor Preview 및 Runtime에서 사용할 수 있는 형태를 전제로 한다.

이 문서는 이미지 생성용 Authoring Specification이다. Visual Asset Catalog schema, Geometry schema 또는 Runtime 구현을 변경하는 문서가 아니다.

---

## 2. 핵심 원칙

### 2.1 Character Identity가 최우선

모든 이미지와 모든 프레임은 하나의 Authoritative Character Design을 기준으로 생성한다.

동일 로봇에 대해 다음 항목이 임의로 변경되면 안 된다.

- 머리 형태
- 얼굴/센서 형태
- 신체 비율
- 흉부 장갑
- 어깨 장갑
- 팔/손 구조
- 허리/골반 구조
- 다리 구조
- 발 구조
- 무장
- 장식
- 실루엣
- 재질
- 기본 색상
- 팀 색상 영역

애니메이션에 따라 자세와 동작은 변하지만 캐릭터 자체의 설계는 변하지 않는다.

### 2.2 Sprite Frame과 Character Bounds를 구분

각 애니메이션 frame은 고정된 Frame Cell을 사용한다.

Frame Cell의 크기는 일정해야 한다.

캐릭터의 실제 opaque 영역은 frame마다 달라질 수 있다.

캐릭터를 frame마다 bounding box 중심에 맞추어 재배치하지 않는다.

### 2.3 Body Center를 기준으로 애니메이션을 제작

애니메이션 정렬의 핵심 기준은 이미지 전체의 중앙이나 opaque bounding-box 중심이 아니다.

MENOS의 현재 Geometry 규격에서는 기준 포즈의 Body Center를 사용한다.

현재 Valkyrie 기준:

- 기준 애니메이션: Idle
- 기준 frame: 0
- Body Center 의미: 골반 중심
- frame-local 좌표: (65, 110)
- 좌표계: frame 좌상단 원점
- X: 오른쪽 +
- Y: 아래쪽 +

이 값은 Valkyrie의 현재 기준이며, 다른 로봇에 자동으로 복사하지 않는다.

이미지 생성 프롬프트에는 다음 규칙을 항상 포함한다.

"Every animation frame must preserve a consistent body-center reference at the character's pelvis / main body pivot. Do not independently center frames by their visible bounding boxes."

팔, 다리, 무기, 머리 장식, 이펙트 때문에 opaque bounds가 변해도 Body Center의 기준은 불필요하게 이동하지 않는다.

단, 애니메이션이 실제로 전진/후퇴/점프 등의 의도적인 이동을 표현하는 경우에는 그 동작을 제거하지 않는다. Geometry 보정은 의도된 동작을 평탄화하는 것이 아니라 불필요한 frame-to-frame jitter를 제거하기 위한 것이다.

---

## 3. Character Reference Block

모든 생성 프롬프트의 가장 앞에는 다음과 같은 Character Reference Block을 둔다.

~~~text
CHARACTER ID:
[ROBOT_ID]

AUTHORITATIVE CHARACTER DESIGN:

[Detailed visual description]

BODY PROPORTION:
[head/body/limb proportions]

HEAD:
[shape, sensors, face, antenna, visor]

CHEST:
[armor shape, reactor/core, markings]

SHOULDERS:
[armor shape and mechanical details]

ARMS:
[mechanical structure, hands, weapons]

WAIST / PELVIS:
[mechanical structure and Body Center location]

LEGS:
[armor, joints, proportions]

FEET:
[shape and ground contact]

WEAPONS:
[weapon identity and permanent design]

MATERIALS:
[metal, armor, energy material, emissive elements]

PERMANENT COLORS:
[list of colors that must not become team color]

TEAM-COLORABLE REGIONS:
[list of regions that may be recolored by runtime shader]

DISTINCTIVE SILHOUETTE:
[unique visual characteristics]

This character description is authoritative.
Do not redesign, reinterpret, replace, simplify, or mutate the character.
All animation frames and UI images must preserve the same character identity.
~~~

캐릭터 설명은 추상적인 표현보다 실제 형태를 설명하는 문장으로 작성한다.

나쁜 예:
cool female robot

좋은 예:
3-head-tall compact super robot with a broad armored chest, narrow waist, large angular shoulder armor, short mechanical legs, a distinct V-shaped head crest, cyan visor, and a large mechanical rifle mounted on the right side.

---

## 4. Master Atlas 구성

가능하면 하나의 큰 Master Sprite Atlas로 생성한다.

권장 논리 배치:

~~~text
+------------------------------------------------------+
| CHARACTER REFERENCE / DESIGN                         |
+------------------------------------------------------+
| IDLE       | MOVE       | ATTACK     | HIT          |
+------------------------------------------------------+
| DEATH      | PROJECTILE | SKILL 1    | SKILL 2      |
+------------------------------------------------------+
| SKILL 3    | SPECIAL    | FINISHER   | RESERVED     |
+------------------------------------------------------+
| PROFILE / UI REFERENCE / ICON REFERENCE             |
+------------------------------------------------------+
| VFX REFERENCE / EFFECT ELEMENTS                     |
+------------------------------------------------------+
~~~

실제 행/열 수는 최종 Canvas 크기와 각 animation frame cell 수에 따라 조정한다.

중요한 것은 영역을 명확히 분리하는 것이며, 서로 다른 animation의 frame이 섞이거나 겹치면 안 된다.

각 영역은 이후 독립적인 Visual Asset으로 등록할 수 있어야 한다.

예:
- robot.<id>.idle
- robot.<id>.move
- robot.<id>.attack
- robot.<id>.hit
- robot.<id>.death
- robot.<id>.projectile
- robot.<id>.skill1
- robot.<id>.skill2
- robot.<id>.skill3
- robot.<id>.skill(special)
- robot.<id>.skill(finisher)
- robot.<id>.profile

Skill Icon과 VFX는 별도 Asset으로 취급한다.

---

## 5. Canvas / Frame Cell 규칙

프롬프트에는 실제 숫자를 반드시 명시한다.

예:
~~~text
FRAME CELL SIZE:
384 x 384 px

MASTER ATLAS:
4096 x 4096 px

BACKGROUND:
fully transparent RGBA
~~~

또는 프로젝트에서 결정한 실제 크기를 사용한다.

반드시 다음을 명시한다.

- 모든 animation frame은 동일한 Cell Width
- 모든 animation frame은 동일한 Cell Height
- frame 간 격자 위치 고정
- frame overlap 금지
- character cropping 금지
- 중요한 silhouette가 cell 경계에 닿지 않도록 충분한 padding 확보
- 배경은 완전 투명
- 자동으로 frame 크기를 변경하지 않음

캐릭터가 frame마다 다른 크기로 보이는 것은 허용하지만 Cell 자체의 크기는 변하지 않는다.

---

## 6. Camera / Rendering Consistency

모든 frame에 다음 조건을 적용한다.

~~~text
CAMERA:
fixed orthographic 2D game camera

VIEW:
consistent 3/4 or side-facing combat view

CAMERA POSITION:
fixed

CAMERA SCALE:
fixed

CHARACTER SCALE:
consistent across frames unless the animation intentionally changes scale

LIGHTING:
consistent across frames

MATERIAL:
consistent across frames

SHADOW:
consistent style and direction

PERSPECTIVE:
do not change between frames
~~~

금지:
- frame마다 카메라 이동
- frame마다 zoom 변경
- frame마다 perspective 변경
- frame마다 조명 방향 변경
- frame마다 character redesign
- frame마다 rendering style 변경

---

## 7. Animation 목록

기본 Robot Editor Animation Set:

1. Idle
2. Move
3. Attack
4. Hit
5. Death
6. Projectile
7. Skill 1
8. Skill 2
9. Skill 3
10. Special
11. Finisher

각 animation은 반드시 다음 정보를 가진다.

~~~text
ANIMATION NAME
PURPOSE
FRAME COUNT
FRAME CELL SIZE
FRAME ORDER
POSE DESCRIPTION
MOTION DESCRIPTION
BODY CENTER RULE
WEAPON STATE
VFX STATE
START STATE
END STATE
LOOP / NON-LOOP
~~~

---

## 8. Frame Count 명시 규칙

이미지 생성 프롬프트에는 frame count를 숫자로 직접 기록한다.

예:
~~~text
IDLE: 6 frames
MOVE: 8 frames
ATTACK: 8 frames
HIT: 4 frames
DEATH: 8 frames
PROJECTILE: 6 frames
SKILL 1: 8 frames
SKILL 2: 10 frames
SKILL 3: 12 frames
SPECIAL: 14 frames
FINISHER: 18 frames
~~~

위 숫자는 Prompt Template의 예시값이다. 실제 캐릭터 제작 시 Master가 승인한 Asset specification을 사용한다.

Frame count만 쓰지 말고 각 frame의 역할도 정의한다.

예:
~~~text
ATTACK — 8 FRAMES

F01: neutral / preparation
F02: anticipation
F03: wind-up
F04: strike preparation
F05: main strike / impact
F06: follow-through
F07: recovery
F08: return toward neutral
~~~

모델이 동일한 포즈를 반복 생성하지 않도록 각 frame의 변화가 명확해야 한다.

---

## 9. Animation별 제작 규칙

### IDLE
목적: 기본 전투 대기 상태

요구:
- 안정적인 Body Center
- 미세한 기계적 호흡 또는 idle motion
- 무장 기본 위치 유지
- 과도한 움직임 금지
- loop 마지막 frame과 첫 frame의 연결이 자연스러움

### MOVE
목적: 이동

요구:
- 몸통과 골반 중심을 명확히 유지
- 다리/발의 이동이 명확
- 이동 방향이 일관됨
- 반복 가능한 cycle
- frame마다 캐릭터 전체가 불필요하게 좌우로 흔들리지 않음

### ATTACK
목적: 기본 공격

권장 구조:
- anticipation
- wind-up
- strike
- impact
- follow-through
- recovery

무기 궤적이 명확해야 한다.

Attack VFX는 가능하면 별도 Asset으로 제작한다.

### HIT
목적: 피격 반응

요구:
- 짧고 명확한 reaction
- Body Center를 유지
- 과도한 displacement 금지
- damage flash는 별도 shader/VFX 처리 가능하도록 캐릭터 기본 색상을 훼손하지 않음

### DEATH
목적: 사망

권장 구조:
- hit reaction
- instability
- collapse
- final pose

캐릭터 silhouette가 frame 밖으로 잘리지 않는다.

### PROJECTILE
Projectile은 캐릭터 자체와 별도로 취급한다.

요구:
- projectile origin
- launch
- travel
- impact

가능하면 projectile sprite와 impact VFX를 별도 Asset으로 만든다.

### SKILL 1 / 2 / 3
각 Skill은 다음을 명시한다.

- Skill identity
- activation pose
- charge/preparation
- main action
- projectile/melee action
- impact
- recovery
- VFX requirement
- weapon state
- Body Center behavior

각 Skill의 시각적 특징은 서로 명확히 구분한다.

### SPECIAL
일반 Skill보다 큰 연출을 허용한다.

단, 캐릭터 identity와 Body Center 기준은 유지한다.

Camera zoom, large VFX, screen effects 등은 캐릭터 sprite 자체와 분리하는 것을 우선한다.

### FINISHER
가장 큰 연출을 허용한다.

그러나 다음은 분리한다.
- Character animation
- VFX
- Camera effect
- Screen effect
- Impact effect

캐릭터 이미지 하나에 모든 효과를 baked-in하지 않는다.

---

## 10. Body Center / Geometry Prompt Contract

모든 Animation Prompt에 다음 문장을 포함한다.

~~~text
BODY CENTER / ANIMATION ALIGNMENT:

Use a consistent pelvis-centered body pivot as the primary
character alignment reference.

Do not center each frame independently according to its visible
bounding box.

Do not shift the entire character merely because arms, weapons,
hair, effects, or other appendages extend farther on one side.

The character may intentionally lean, jump, recoil, attack, or move,
but preserve the underlying body-center reference unless the
animation explicitly requires intentional displacement.

Keep the character's main body/pelvis position stable enough that
frame-to-frame playback does not create unintended horizontal or
vertical jitter.

Transparent padding may vary internally, but the character's
animation pivot must remain coherent.
~~~

이 규칙은 Visual Asset의 thumbnail 생성 규칙과도 구분한다.

Thumbnail:
- selected region 기준
- multiple frames이면 first frame 기준

Animation Geometry:
- Body Center 기준
- animation/frame offset으로 실제 정렬

두 기능을 하나의 이미지 생성 규칙으로 혼합하지 않는다.

---

## 11. Team Color Shader 규칙

팀 색상은 runtime shader가 처리할 수 있도록 authoring 단계에서 명확하게 분리한다.

~~~text
TEAM COLOR SHADER COMPATIBILITY:

Design dedicated team-colorable regions.

Team-color regions must use clean, contiguous, easily separable
base colors.

Avoid gradients, semi-transparent color mixing, or complex
multi-color textures inside team-color regions.

Keep permanent character colors clearly separated from team colors.

Do not use team-color regions for:
- eyes unless explicitly specified
- transparent effects
- metallic highlights
- important permanent markings
- neutral mechanical surfaces
~~~

권장 분류:
- PERMANENT: base metal, dark metal, permanent armor color, visor/eye color, permanent markings
- TEAM COLOR: shoulder accents, chest accents, forearm accents, leg accents, weapon accents

실제 부위는 로봇별로 정의한다.

---

## 12. Profile Image

Profile은 Sprite Animation의 frame을 그대로 잘라 쓰는 것이 아니라 별도의 UI용 이미지로 생성할 수 있도록 정의한다.

~~~text
PROFILE IMAGE:

Purpose:
Robot Editor / unit selection / roster / UI profile

Composition:
- readable 3/4 or front view
- neutral combat-ready pose
- full identity visible
- face and upper body clearly readable
- weapon visible if it is part of identity
- no action blur
- no excessive VFX
- no cropped head or weapon
- transparent background

Aspect ratio:
[PROJECT PROFILE RATIO]

Resolution:
[PROJECT PROFILE RESOLUTION]
~~~

Profile은 작은 UI에서도 캐릭터를 알아볼 수 있어야 한다.

---

## 13. Skill Icon

Skill Icon은 animation frame이 아니다.

~~~text
SKILL ICON:

Purpose:
UI skill button / skill list / Robot Editor skill representation

Canvas:
square 1:1

Composition:
- strong central silhouette
- skill-specific action
- skill-specific weapon/effect
- readable at small size
- minimal background clutter
- high contrast between subject and background
- no unrelated character variants
- no text unless explicitly requested
~~~

Skill Icon은 Skill 1/2/3/Special/Finisher 각각 독립적으로 생성한다.

예:
- robot.<id>.skill1.icon
- robot.<id>.skill2.icon
- robot.<id>.skill3.icon
- robot.<id>.special.icon
- robot.<id>.finisher.icon

---

## 14. VFX

VFX는 캐릭터 Sprite와 가능하면 분리한다.

기본 VFX 종류:
- attack slash
- projectile trail
- projectile impact
- hit impact
- skill activation
- skill projectile
- skill impact
- special aura
- finisher impact
- death effect

VFX 생성 프롬프트:

~~~text
VFX REQUIREMENTS:

- transparent background
- no character unless explicitly requested
- effect isolated from the robot body
- clear origin
- clear direction
- clear animation sequence
- consistent scale reference
- no baked background
- no UI text
~~~

캐릭터 Sprite에 VFX를 합쳐서 생성해야 하는 경우에는 BAKED VFX임을 명시한다.

기본 원칙은 별도 VFX Asset이다.

---

## 15. Projectile

Projectile은 다음 정보를 별도로 가진다.

- Projectile ID
- Projectile shape
- Projectile material
- Projectile color
- Team Color compatibility
- Frame count
- Cell size
- Origin
- Travel direction
- Impact state
- Trail
- Impact VFX

Projectile의 이동 애니메이션은 캐릭터 Body Center가 아니라 Projectile 자체의 중심/원점 규칙을 사용한다.

캐릭터에서 Projectile이 생성되는 위치는 별도의 gameplay spawn point로 관리한다.

---

## 16. Transparency / Background

모든 게임 Sprite는 다음을 기본으로 한다.

~~~text
BACKGROUND:
100% transparent RGBA

NO:
- white background
- black background
- gradient background
- floor
- environment
- decorative frame
- UI border
- text
- watermark
- logo
~~~

Profile이나 Skill Icon처럼 의도적으로 배경이 필요한 UI Asset은 별도 specification으로 정의한다.

---

## 17. Anti-Cropping

다음 요소가 frame 경계에서 잘리면 안 된다.

- 머리
- 안테나
- 손
- 발
- 무기
- projectile
- 주요 VFX

매우 큰 VFX가 frame 밖으로 확장되는 경우에는 해당 VFX를 별도 Asset으로 분리한다.

---

## 18. Frame-to-Frame Consistency

모든 frame에서 다음을 유지한다.

~~~text
SAME CHARACTER
SAME BODY PROPORTION
SAME MATERIAL
SAME ARMOR DESIGN
SAME WEAPON DESIGN
SAME CAMERA
SAME VIEW DIRECTION
SAME LIGHTING
SAME RENDERING STYLE
SAME BASE SCALE
SAME BODY-CENTER REFERENCE
~~~

변경 가능한 항목:
- POSE
- LIMB POSITION
- WEAPON POSITION
- BODY LEAN
- FACIAL/ENERGY STATE
- ACTION STATE
- VFX STATE
- INTENTIONAL MOTION

---

## 19. 금지 사항

~~~text
DO NOT:
- redesign the character between frames
- change armor proportions
- change head shape
- change weapon design
- change camera angle
- change camera scale
- independently center each frame
- crop the character
- merge unrelated animations
- duplicate frames unnecessarily
- introduce random accessories
- change permanent colors
- paint team-color regions inconsistently
- add background scenery
- add text
- add watermark
- add UI elements
- bake unrelated VFX into character frames
- use motion blur that destroys sprite readability
- use painterly frame-to-frame style changes
~~~

---

## 20. Animation Documentation Text

이미지 자체에 텍스트를 넣는 것이 아니라 생성 Prompt에서 각 영역을 설명한다.

~~~text
ANIMATION DOCUMENTATION:

Animation:
[NAME]

Purpose:
[DESCRIPTION]

Frame Count:
[N]

Motion:
[DESCRIPTION]

Body Center:
[DESCRIPTION]

Weapon:
[DESCRIPTION]

VFX:
[DESCRIPTION]

Loop:
[YES/NO]
~~~

최종 게임 Sprite에는 문서용 텍스트가 포함되지 않는다.

---

## 21. Master Prompt Template

아래 블록을 실제 이미지 생성 요청의 기본 템플릿으로 사용한다.

~~~text
CREATE A PRODUCTION-READY 2D GAME SPRITE MASTER ATLAS FOR
THE GAME "MENOS".

THIS IS NOT CONCEPT ART.
THIS IS NOT A CHARACTER DESIGN PRESENTATION.
THIS IS NOT AN ILLUSTRATION COLLECTION.

THIS IS A GAME-READY SPRITE ATLAS AUTHORING SHEET.

==================================================
CHARACTER IDENTITY
==================================================

CHARACTER ID:
[ROBOT_ID]

CHARACTER NAME:
[ROBOT_NAME]

AUTHORITATIVE CHARACTER DESIGN:

[INSERT COMPLETE CHARACTER DESCRIPTION]

The above character design is authoritative.

Every animation frame, profile image, skill image,
projectile, and related visual must preserve the same
character identity.

Do not redesign, reinterpret, replace, simplify,
or mutate the character.

==================================================
MASTER ATLAS
==================================================

MASTER ATLAS SIZE:
[ATLAS_WIDTH] x [ATLAS_HEIGHT] px

FRAME CELL SIZE:
[FRAME_WIDTH] x [FRAME_HEIGHT] px

BACKGROUND:
FULLY TRANSPARENT RGBA.

All animation frames use identical cell dimensions.

No frame overlap.
No accidental cropping.
No background.
No watermark.
No text in final game assets.

==================================================
CAMERA / RENDERING
==================================================

Fixed orthographic 2D game camera.

Fixed camera position.
Fixed camera scale.
Fixed character viewing direction.
Fixed lighting.
Fixed material rendering.
Fixed rendering style.

Do not change perspective or camera framing between frames.

==================================================
BODY CENTER / ANIMATION ALIGNMENT
==================================================

Use a consistent pelvis-centered body pivot.

Do not independently center frames by visible bounding-box center.

The visible opaque bounds may change between frames.

The main body/pelvis reference must remain coherent.

Allow intentional animation displacement such as leaning,
jumping, recoil, attack movement, or movement cycles.

Do not introduce unintended frame-to-frame jitter.

==================================================
TEAM COLOR SHADER
==================================================

The sprite must support runtime team-color replacement.

TEAM-COLORABLE REGIONS:
[LIST]

PERMANENT COLORS:
[LIST]

Team-color regions must use clean, contiguous base colors.

Do not use complex gradients or mixed colors inside team-color regions.

Keep permanent colors visually distinct from team-color regions.

==================================================
ANIMATION SET
==================================================

1. IDLE
Frame Count: [N]
Purpose: [DESCRIPTION]
Motion: [DESCRIPTION]
Loop: YES

2. MOVE
Frame Count: [N]
Purpose: [DESCRIPTION]
Motion: [DESCRIPTION]
Loop: YES

3. ATTACK
Frame Count: [N]
Purpose: [DESCRIPTION]
Frame Sequence:
F01 [DESCRIPTION]
F02 [DESCRIPTION]
...
FN [DESCRIPTION]

4. HIT
Frame Count: [N]
Purpose: [DESCRIPTION]
Loop: NO

5. DEATH
Frame Count: [N]
Purpose: [DESCRIPTION]
Loop: NO

6. PROJECTILE
Frame Count: [N]
Purpose: [DESCRIPTION]

7. SKILL 1
Frame Count: [N]
Purpose: [DESCRIPTION]

8. SKILL 2
Frame Count: [N]
Purpose: [DESCRIPTION]

9. SKILL 3
Frame Count: [N]
Purpose: [DESCRIPTION]

10. SPECIAL
Frame Count: [N]
Purpose: [DESCRIPTION]

11. FINISHER
Frame Count: [N]
Purpose: [DESCRIPTION]

==================================================
ANIMATION QUALITY RULE
==================================================

Every frame must contain the same character.

Every frame must preserve:
- character identity
- proportions
- materials
- permanent colors
- weapon design
- camera
- rendering style
- body-center reference

Only pose, motion, weapon state, energy state, and intentional
animation effects may change.

==================================================
PROFILE IMAGE
==================================================

Create a separate profile representation.

Neutral combat-ready pose.
Readable face and silhouette.
Consistent character identity.
No excessive VFX.
No cropping.
Transparent background.

PROFILE SIZE:
[WIDTH] x [HEIGHT] px

==================================================
SKILL ICONS
==================================================

Create separate square UI icon representations for:

Skill 1
Skill 2
Skill 3
Special
Finisher

Each icon must communicate its own skill identity.

No text unless explicitly requested.

==================================================
VFX
==================================================

Create VFX as separate visual assets whenever possible.

Required VFX:
- attack
- projectile trail
- projectile impact
- hit
- skill activation
- skill impact
- special
- finisher
- death

Transparent background.
No character unless explicitly requested.

==================================================
PROJECTILE
==================================================

Projectile must be visually consistent with the robot.

Define:
- projectile shape
- material
- permanent color
- team-color region if applicable
- frame count
- origin
- travel
- impact
- trail
- impact effect

Projectile is a separate asset from the character animation.

==================================================
FINAL VALIDATION
==================================================

Before finalizing the atlas, verify:

1. Character identity is consistent.
2. Every animation has the specified frame count.
3. Every frame uses the same cell size.
4. No frame is cropped.
5. No frame overlaps another frame.
6. Body center remains coherent.
7. No unintended horizontal or vertical jitter is introduced.
8. Team-color regions are clearly separable.
9. Permanent colors remain unchanged.
10. Profile image matches the same character.
11. Skill icons match the same character.
12. Projectile matches the same character.
13. VFX are separated unless explicitly specified as baked.
14. Background is transparent.
15. No text, watermark, logo, or unrelated artwork is present.
~~~

---

## 22. Robot별 Prompt 작성 순서

실제 생성 시 다음 순서로 Prompt를 작성한다.

1. Character Identity
2. Authoritative Character Description
3. Permanent Design Rules
4. Team Color Rules
5. Canvas / Atlas Size
6. Frame Cell Size
7. Camera / Rendering Rules
8. Body Center Rules
9. Animation List
10. Frame Count
11. Frame-by-Frame Motion Description
12. Projectile Specification
13. Profile Specification
14. Skill Icon Specification
15. VFX Specification
16. Transparency Rules
17. Negative Constraints
18. Final Validation Checklist

이 순서를 유지하면 이미지 생성 모델이 캐릭터 설명보다 장식이나 특정 Skill 연출을 우선하여 캐릭터를 변형시키는 문제를 줄일 수 있다.

---

## 23. 권장 생성 전략

하나의 Master Atlas를 목표로 하되, 실제 생성 모델의 Canvas 제한 때문에 모든 animation을 하나의 이미지로 안정적으로 생성할 수 없는 경우에는 다음 전략을 사용한다.

~~~text
MASTER CHARACTER REFERENCE
        |
        +-- CORE MOVEMENT SHEET
        |     Idle
        |     Move
        |     Attack
        |     Hit
        |     Death
        |
        +-- SKILL SHEET
        |     Skill 1
        |     Skill 2
        |     Skill 3
        |     Special
        |     Finisher
        |
        +-- PROJECTILE / VFX SHEET
        |
        +-- UI SHEET
              Profile
              Skill Icons
~~~

분할 생성하더라도 모든 Sheet는 동일한 Character Reference Block을 사용한다.

따라서 "하나의 큰 그림"은 Asset 생성의 논리적 Master Atlas이며, 반드시 물리적으로 하나의 PNG여야 한다는 의미는 아니다.

---

## 24. MENOS 현재 Geometry와의 관계

현재 MENOS Animation Geometry 규격:

- Visual Asset Catalog와 Geometry는 분리한다.
- Body Center는 별도 Geometry 계층의 기준이다.
- Valkyrie 기준 포즈는 Idle frame 0이다.
- Valkyrie Body Center는 frame-local (65,110)이다.
- 좌표는 frame-local source pixel 기준이다.
- frame region 좌상단이 원점이다.
- X는 오른쪽이 +이다.
- Y는 아래쪽이 +이다.
- animation default offset과 frame offset을 합산한다.
- 원본 pixel 좌표에서 보정한 뒤 display scaling을 적용한다.
- Geometry가 없거나 불일치하면 조용히 추측하지 않고 진단한다.

이미지 생성 단계에서는 이 Geometry를 대신 구현하지 않는다.

이미지 생성의 책임:
- 일관된 character identity
- 안정적인 body-center 제작
- frame cell consistency
- 자연스러운 motion
- team-color authoring
- 별도 VFX/Projectile/UI Asset 제작

Geometry 계층의 책임:
- 실제 frame별 정렬 보정
- animation/frame offset
- Editor/Runtime 공통 presentation

---

## 25. 중요한 구분

다음 세 가지는 서로 다른 문제다.

### A. Image Authoring

"모델이 일관된 캐릭터를 그렸는가?"

### B. Animation Geometry

"각 frame을 Body Center 기준으로 정렬했는가?"

### C. Runtime Presentation

"Editor와 게임에서 같은 frame과 같은 Geometry를 사용했는가?"

A가 완벽해도 B가 필요할 수 있다.

B가 완벽해도 C가 잘못되면 Editor와 Runtime이 다르게 보인다.

따라서 이미지 생성 Prompt에 모든 문제를 해결하려고 하지 않는다.

---

## 26. 추가로 반드시 고려할 Asset Authoring 정보

Sprite 생성 전에 다음 항목도 캐릭터별로 정의하는 것을 권장한다.

- 공격 무기와 무기 손잡이 위치
- projectile spawn 위치의 시각적 기준
- weapon muzzle 방향
- 발의 ground-contact 기준
- 캐릭터의 front / back / left / right 표현 규칙
- 팀 색상으로 변경하지 않을 고정 색상
- emissive/energy 색상
- hit reaction에서 유지해야 할 silhouette
- death animation의 최종 방향
- skill별 핵심 silhouette
- VFX의 origin과 방향
- UI profile의 crop 기준
- skill icon의 중심 피사체
- animation loop 여부
- animation 시작/종료 pose 관계
- 필요 시 공격/피격/투사체의 gameplay marker 위치

이 정보는 모두 Sprite PNG 안에 저장해야 한다는 뜻이 아니다. 이미지 생성 단계에서 일관된 결과를 얻기 위한 Authoring specification이다.

---

## 27. 최종 품질 기준

### CHARACTER
- 동일 캐릭터
- 동일 비율
- 동일 무장
- 동일 재질
- 동일 기본 색상
- 동일 카메라

### ANIMATION
- 명시된 frame count
- 명확한 frame progression
- 자연스러운 motion
- loop continuity
- stable body center
- 의도하지 않은 jitter 없음

### TECHNICAL
- fixed cell size
- transparent background
- no cropping
- no overlap
- team-color region 분리
- VFX 분리 가능
- Projectile 분리 가능
- Profile/Skill Icon 분리 가능

### EDITOR / RUNTIME
- Visual Asset으로 독립 등록 가능
- Animation Geometry로 정렬 가능
- Robot Editor에서 식별 가능
- Runtime presentation으로 연결 가능

---

## 28. 상태

STATUS: DOCUMENTED

이 문서는 이미지 생성 프롬프트의 Authoring Specification이다.

이 문서 자체가 다음 사항을 확정하는 것은 아니다.

- 새로운 Geometry schema
- Geometry 파일명
- Runtime API
- Legacy fallback 정책
- 각 로봇의 실제 frame count
- 각 로봇의 실제 Body Center 좌표
- 실제 UI Asset schema

이러한 항목은 각 해당 설계의 Master 결정에 따른다.

# MENOS — Beam VFX Sprite Sheet Guidelines

STATUS — PROPOSAL / NOT CANON

## 1. 목적

재사용 가능한 로봇 Beam VFX를 제작하기 위한 이미지 Asset 및 Runtime 적용 기준을 정의한다.

## 2. 핵심 원칙

- 하나의 Beam 원본을 여러 Robot/Skill이 재사용한다.
- 이미지 원본은 특정 팀 색상에 고정하지 않는다.
- 흰색 중심 Core + 투명 Glow를 기본으로 제작하고 Runtime에서 색상을 변경한다.
- Beam 길이, 방향, 폭, 밝기, 지속시간은 Runtime에서 제어한다.
- 공격 판정과 VFX 표현을 분리한다.
- 기존 MENOS effects / projectile 구조를 우선 재사용한다.

## 3. 이미지 생성 기준

권장 Sprite Sheet:
- 8 animation frames
- 1×8 horizontal layout
- 동일 canvas size
- 동일 origin / baseline
- 프레임 간 동일한 위치 정렬
- 프레임 겹침 없음
- frame border / grid / text 없음
- 완전 투명 배경

Beam 표현:
- 순백색에 가까운 밝은 Core
- 매우 얇고 강한 중심광
- 부드러운 반투명 외곽 Glow
- 약간의 에너지 왜곡
- 작은 Gameplay 크기에서도 식별 가능한 명확한 실루엣
- 검정/색상 배경 금지
- 로봇, 적, 무기, 환경, 총구, 별도 Impact 포함 금지

색상:
- 원본은 Neutral White
- 청색/적색/보라색/금색 등 특정 색상으로 고정하지 않음
- Godot shader/modulate를 이용한 Runtime Tint를 전제로 한다.

## 4. 8프레임 애니메이션

1. Beam 에너지 형성
2. Core 급속 확장
3. Full Length 도달
4. 최대 에너지 강도
5. 에너지 Pulse
6. 가장 강한 Glow / Edge Distortion
7. 에너지 수축
8. Fade Out

## 5. Runtime 구조 제안

현재 MENOS의 공격 구조는 effects 기반 projectile/VFX 표현과 피해 판정을 분리하고 있으므로 Beam은 기존 구조를 확장하는 방향을 권장한다.

Weapon / Skill
→ weapon_fired
→ Beam Effect
→ Beam VFX rendering
→ damage_requested
→ existing Impact VFX

권장 데이터:
- VFX ODB PK
- Texture / Sprite Sheet Reference
- Animation
- Duration
- Width
- Color / Tint
- Layer / Z Order
- Optional Shader

beam_color는 VFX 원본 Asset과 분리하여 Robot/Skill 또는 Runtime parameter로 제공하는 것을 권장한다.

## 6. 재사용 예

Beam Source Texture
- Robot A → Blue
- Robot B → Red
- Robot C → Purple
- Enemy Robot → Gold

원본 Sprite Sheet를 복제하여 색상을 각각 굽는 방식은 지양한다.

## 7. 최소 구현안

1. Neutral White Beam Sprite Sheet 1개 제작
2. 기존 proj_defender 계열 effects 구조 확인 및 재사용
3. Beam 길이/방향을 start → target으로 계산
4. Runtime Tint로 색상 변경
5. 기존 damage_requested 경로 유지
6. 기존 procedural Impact VFX 재사용
7. 실제 PIE에서 시각 품질 확인 후 필요할 때만 Muzzle / Impact Asset을 추가

## 8. 이미지 생성 프롬프트 기준

Create a clean 2D game VFX sprite sheet for a reusable energy beam weapon effect.

8 animation frames in a single horizontal row, identical canvas size and alignment, equal spacing, no frame borders, no grid lines, no cropping, transparent background.

Long straight horizontal energy beam, bright white energy core, very bright narrow center, soft translucent outer glow, subtle irregular energy distortion, consistent beam alignment across all frames.

Neutral white source texture only. Do not bake blue, red, purple, green, or yellow coloration into the beam. The texture must be suitable for runtime tinting in Godot.

No robot, enemy, weapon, muzzle, environment, impact effect, text, symbols, UI, shadows, or colored background.

Production-ready 2D VFX sprite sheet, crisp alpha edges, soft alpha falloff, consistent origin and baseline, designed to be stretched horizontally and recolored at runtime.

## 9. 현재 MENOS 구조와의 관계

CONFIRMED 조사 결과:
- game_controller.gd는 effects 배열을 이용해 projectile 및 impact VFX를 렌더링한다.
- 현재 proj_defender는 start/target/progress 기반으로 이동 VFX를 표현한다.
- 피해 처리는 VFX 렌더링과 별도의 gameplay 경로에서 수행된다.
- 현재 projectile/impact에는 procedural draw_line, draw_circle, draw_arc가 사용된다.

따라서 Beam은 새로운 전투 판정 시스템보다 기존 effect 경로를 확장하는 것이 최소 변경 방향이다.

## 10. 범위 제한

본 문서는 Beam VFX 제작 및 구조 제안만 정의한다.

확정하지 않는 사항:
- 새로운 ODB PK 할당
- 실제 VFX Schema 변경
- Production 코드 수정
- 최종 Beam 디자인
- 실제 색상값
- 실제 Runtime 지속시간/폭
- 외부 Asset 사용

PROPOSAL ≠ CANON.

## 11. 검증 상태

- CODE VERIFIED — 기존 공격/VFX 경로 조사 완료
- BUILD VERIFIED — 해당 없음
- EDITOR VERIFIED — Beam Asset 미생성
- PIE VERIFIED — 미실시

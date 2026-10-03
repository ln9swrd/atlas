# MENOS Animation Frame Alignment Development Plan

## 1. 목적
발키리와 향후 모든 캐릭터의 애니메이션에서 프레임마다 스프라이트의 실제 크기와 중심이 달라도 게임 화면에서 캐릭터가 불필요하게 튀거나 흔들리지 않도록 한다.

모든 프레임을 동일한 외형 크기로 강제하는 것이 목적이 아니다.
- 원본 스프라이트의 자연스러운 크기 차이는 허용한다.
- 프레임마다 발생하는 투명 여백 차이와 실제 캐릭터 위치 차이를 처리한다.
- Editor Preview와 Runtime이 동일한 정렬 규칙을 사용한다.
- Visual Asset ID를 기준으로 source / region / frames를 해석한다.
- 기존 Asset을 임의로 재가공하거나 덮어쓰지 않는다.

## 2. 현재 상태
### CONFIRMED
Robot Editor Animation Preview는 Visual Asset Resolver를 거쳐 source + region + frames를 얻은 뒤 frame 영역을 균등 분할하고 AtlasTexture로 표시한다. 프레임 내부의 실제 opaque pixel bounds나 gameplay anchor 보정은 없다.
Runtime도 Sprite2D의 hframes/vframes로 프레임을 분할하고 전체 frame size에 따라 scale을 적용한다. 프레임별 실제 캐릭터 중심은 보정하지 않는다.
따라서 Preview에서 관찰되는 frame-to-frame 위치 흔들림이 Runtime에서도 발생할 수 있는 구조다.

### 별도 확인이 필요한 문제
Runtime 일부 경로는 VisualAssetResolver를 거치지 않고 catalog field를 직접 load한다. 또한 Robot Runtime에는 animation frame count가 코드에 하드코딩된 부분이 있다.
이는 Frame Alignment 구현과 함께 검토하되, 이번 계획의 핵심은 정렬 기준과 공통 처리 계층을 정의하는 것이다.

## 3. 범위
### IN SCOPE
1. Visual Asset animation frame 추출 규칙 통일
2. frame별 실제 이미지 bounds 분석
3. 공통 animation anchor/pivot 개념 도입
4. baseline / anchor 기준 프레임 정렬
5. Editor Preview와 Runtime의 공통 frame presentation 데이터 사용
6. 발키리 전체 animation 검증
7. 다른 로봇에도 적용 가능한 구조 확보

### OUT OF SCOPE
- 캐릭터 원본 이미지 재생성
- 원본 PNG 픽셀 수정
- 임의 Sprite Atlas 재생성
- 모든 캐릭터를 동일한 외형 크기로 강제
- gameplay balance 변경
- 이동 속도/공격 판정/충돌 영역 변경
- 새로운 캐릭터 제작

## 4. 설계 원칙
### 4.1 Visual Asset이 단일 진입점
Animation은 asset_id, source, region, frames에서 시작한다. 경로 문자열 직접 해석은 Legacy compatibility 용도로만 유지한다.

### 4.2 Frame과 Character Bounds를 분리
Animation frame의 전체 사각형과 실제 캐릭터가 차지하는 영역은 서로 다른 개념으로 취급한다.
예: Frame Rect 117x176, Character Bounds 93x168. Runtime frame texture는 Frame Rect를 유지하되 alignment 계산에는 Character Bounds를 사용한다.

### 4.3 Anchor를 기준으로 정렬
기본 기준은 캐릭터의 gameplay pivot이다.
우선순위:
1. 명시적인 Asset anchor
2. animation 공통 anchor
3. 자동 분석된 baseline / center
4. legacy fallback

bounding-box center를 자동으로 gameplay anchor로 확정하지 않는다. 공격/이동 동작에서 bounding box가 움직일 수 있기 때문이다.
로봇은 우선 발/지면 접점에 해당하는 anchor를 검토한다.

### 4.4 Preview와 Runtime은 같은 계산을 사용
정렬 계산을 Editor에 별도로 구현하지 않는다. 공통 resolver/presentation layer가 source texture, frame region, frame index, frame count, character bounds, anchor, normalized frame offset, normalized scale/presentation data를 반환하고 Editor와 Runtime이 이를 소비한다.

## 5. 권장 데이터 구조
Visual Asset 또는 별도 animation metadata에 최소 alignment 정보를 정의한다.

예시:
    {
      "id": "robot.valkyrie.idle",
      "source": "res://...",
      "region": [122, 10, 936, 176],
      "frames": 8,
      "alignment": {
        "mode": "anchor",
        "anchor": [58.0, 174.0],
        "baseline": 174.0
      }
    }

위 anchor 값은 예시이며 Canon이 아니다. 실제 값은 분석 후 결정한다.
가능하면 frame별 값을 직접 저장하기보다 animation-level 공통 anchor를 우선한다.
실제로 frame별 예외가 필요한 경우에만 frame_offsets를 추가한다.

## 6. 처리 파이프라인
### Phase A — 분석
READ-ONLY.
1. 발키리 모든 animation asset resolve
2. 각 frame 실제 pixel bounds 추출
3. 각 frame의 bounds 크기/중심 계산
4. 발 위치 또는 적절한 공통 anchor 후보 계산
5. 현재 Preview와 차이 기록
6. Runtime frame count 및 source region과 대조

성공 조건: 각 animation의 실제 frame 구조가 설명 가능하고 잘못된 frame count/region은 별도 데이터 문제로 기록한다.

### Phase B — 별도 Frame Geometry / Presentation 계층 (Master 선택 B)
Visual Asset Catalog와 정렬/표시 Geometry를 분리한다. Catalog는 원본 source, region, frames 등 이미지 분할 사실만 보유하고, 별도 Geometry 계층은 Body Center 및 animation/frame별 presentation 보정 정보를 보유한다.
개념적 흐름: Visual Asset Catalog -> Frame Set(분할 결과) + Animation Geometry(정렬 데이터) -> 공통 Frame Presentation API -> Editor Preview / Runtime.
Presentation API는 frame source/region/index, frame size, opaque bounds(측정 정보), 기준 anchor, animation/frame offset, 최종 display transform을 제공한다. Alpha Bounds는 측정 근거이지 Body Center의 자동 대체값이 아니다.
Editor와 Runtime은 동일한 Presentation API를 소비하며, Catalog와 Geometry를 각각 직접 해석하는 중복 로직을 두지 않는다.

#### Geometry 데이터 구조 제안 (PROPOSAL, 미승인)
별도 파일 후보: `content/animation/animation_geometry.json` (경로/파일명은 미확정). Master가 좌표계와 보정 합성 규칙을 승인했으나, 이 데이터 구조와 파일명 자체는 아직 승인되지 않았다.
최소 논리 구조 예시:
```json
{
  "schema_version": 1,
  "robots": {
    "valkyrie": {
      "reference": {
        "animation": "idle",
        "frame": 0,
        "anchor_type": "body_center",
        "anchor_source_px": [65, 110]
      },
      "animations": {
        "idle": {
          "default_offset_px": [0, 0],
          "frame_offsets_px": {}
        }
      }
    }
  }
}
```
`anchor_source_px`는 Master가 선택한 공통 Body Center frame-local 좌표 `[65,110]`을 기록한다. 값의 단위는 원본 source pixel 기준이다. 개별 frame offset은 근거가 확인된 경우에만 기록하고, 미기록 프레임은 공통 Body Center 기준을 그대로 사용한다. 자동 Alpha Bounds 중심 보정은 금지한다.

#### 책임 경계
- Visual Asset Catalog: source, region, frames, owner/category 등 이미지 식별·분할 데이터
- Geometry 데이터: 기준 포즈, 공통 Body Center, animation/frame별 명시 offset 및 추적 가능한 보정 근거
- Frame Presentation API: 두 데이터 소스를 resolve하고 좌표 변환/offset 적용을 일관되게 수행
- Editor/Runtime: API 결과를 렌더링할 뿐 별도 정렬 수식을 구현하지 않음
- Geometry 누락/불일치: 조용히 추측하지 않고 명시 오류/진단을 제공. 레거시 fallback 허용 범위는 별도 결정

#### 구현 가능한 데이터/API 계약 초안 (PROPOSAL, 미승인)

**Geometry v1 제안**
- `reference.anchor_source_px`: Master가 선택한 frame-local Body Center `[65,110]`을 기록한다. reference animation/frame은 `idle`/`0`으로 고정한다.
- `animations.<animation>.default_offset_px`: 승인된 좌표계에서 animation 전체에 적용할 기본 이동량. 초기값 `[0,0]`.
- `animations.<animation>.frame_offsets_px`: 프레임 index 문자열을 키로 하는 추가 offset map. 기록이 없으면 `[0,0]`.
- `frame_offsets_px`에는 실제 비교/검증으로 근거가 확보된 프레임만 기록한다. 값은 원본 pixel 단위이며 화면 이동 방향 부호를 따른다.
- Catalog와 Geometry의 animation/frame count가 불일치하면 자동 보정하지 않고 validation error로 보고한다.

**Frame Presentation API 제안**
- 입력: `visual_asset_id`, `animation_id`, `frame_index`, 선택적 `legacy_policy`.
- 출력: resolved source/region, frame size, reference anchor (frame-local px), 합성 offset px, 표시용 transform, 진단 목록.
- 처리: Visual Asset Catalog에서 frame을 resolve → Geometry에서 공통 anchor와 animation/frame offset resolve → `default_offset + frame_offset` 합성 → 원본 pixel 좌표 보정 후 display scale 적용.
- 범위 오류, Geometry 누락, frame count 불일치, 잘못된 offset 형식은 구조화된 진단으로 반환한다. 조용한 기본값 대체 금지.
- Editor Preview와 Runtime은 이 API의 동일 결과를 소비하며 각각 자체 offset 계산을 두지 않는다.

**남은 Master 결정 — Legacy fallback 정책**
- A: Strict — Geometry가 없거나 불일치하면 해당 애니메이션 표시를 실패 처리하고 진단한다. 정렬 규칙이 조용히 바뀌지 않는 장점이 있으나 기존 Legacy asset을 별도 마이그레이션해야 한다.
- B: Explicit opt-in — asset/robot별로 Legacy fallback을 명시한 경우에만 기존 렌더 경로를 허용한다. 신규/이관 asset은 strict로 유지하며, fallback 사용 사실을 진단한다. 호환성을 유지하지만 두 렌더 경로를 한동안 관리해야 한다.

**마리의 기술 제안:** B(명시적 opt-in). 기존 Legacy asset을 무조건 중단시키지 않으면서 fallback이 암묵적으로 확대되는 것을 막는다. 이 선택은 데이터/런타임 호환 정책이므로 Master 승인이 필요하며, 승인 전 구현하지 않는다.

### Phase C — Anchor 계산
1. frame region 추출
2. alpha 기준 실제 opaque bounds 추출
3. anchor 후보 계산
4. animation 전체 frame의 anchor 분포 분석
5. 공통 anchor 선택
6. 각 frame의 presentation offset 계산

무기/이펙트가 anchor 계산을 오염시키는 경우 별도 기준이 필요하다. 필요하면 Asset authoring 단계에서 명시 anchor를 지정한다.

### Phase D — Editor Preview 적용
현재 robot_editor.gd의 단순 AtlasTexture 분할을 공통 presentation 결과 사용으로 교체한다.
Preview는 동일 frame source, frame index, anchor, display offset을 사용한다.

### Phase E — Runtime 적용
Runtime robot sprite 생성/갱신도 동일 presentation 결과를 사용한다.
특히 runtime 하드코딩 animation frame count, Visual Asset ID 직접 texture load, frame마다 동일하다고 가정한 scale 계산을 제거 또는 격리 대상으로 조사한다.
Runtime은 Visual Asset Catalog에서 frame source/region/count를, 별도 Geometry 계층에서 anchor/offset을 읽고 공통 Presentation API를 통해 최종 frame presentation을 얻는다. 두 계층의 책임을 중복 저장하지 않는다.

## 7. 발키리 적용 순서
1. idle
2. move
3. attack
4. hit
5. death
6. projectile
7. skill1
8. skill2
9. skill3
10. special
11. finisher

idle/move/attack부터 anchor 품질을 검증하고 동일 규칙이 성립하면 나머지 animation에 확대 적용한다.

## 8. 검증 기준
### CODE VERIFIED
- 모든 animation이 공통 presentation layer를 통과
- frame count가 Asset metadata와 일치
- Preview와 Runtime이 동일 계산을 사용

### EDITOR VERIFIED
- 발키리 모든 animation의 frame extraction 확인
- frame별 anchor/bounds 확인
- Preview에서 불필요한 위치 튐 감소 확인

### BUILD VERIFIED
- Godot project build 성공
- parser/runtime errors 없음

### PIE VERIFIED
Master가 실제 게임에서 확인한다.
최소 확인 항목: idle loop, move loop, attack transition, skill transition, hit/death, animation 전환 시 위치 튐, 바닥 접점 안정성, 팀 색상 shader 적용 후 정렬 변화 없음.
자동화 검증 PASS는 PIE VERIFIED로 간주하지 않는다.

## 9. 검증용 수치 기준
각 animation에 대해 anchor X/Y drift, opaque bounds width/height 변화, frame-to-frame display offset을 기록한다.
허용 오차는 실제 발키리 기준점을 확인한 뒤 결정한다. 임의의 숫자를 Canon으로 지정하지 않는다.

## 10. 변경 안전성
구현 시작 전 HEAD, Branch, Working Tree, 기존 변경사항을 확인한다.
기존 변경사항을 보존한다.
구현 중 한 번에 하나의 변수만 변경하고 Diff를 확인한다. Asset 원본 덮어쓰기와 외부 Asset 추가는 금지한다.
검증 결과가 예상과 다르면 즉시 HOLD한다.

## 11. 단계별 종료 조건
Phase A: 모든 발키리 frame 구조와 anchor 후보를 설명할 수 있음.
Phase B: Preview와 Runtime이 동일 presentation API를 사용함.
Phase C: 발키리 anchor가 실제 gameplay 기준으로 안정적임.
Phase D/E: Preview와 Runtime에서 동일한 정렬 결과가 관찰됨.
목적 달성 후 추가 리팩터링은 자동 진행하지 않는다.

## 12. 리스크
### R1. 캐릭터가 아닌 무기가 bounds에 포함
명시 anchor를 우선하고 필요하면 authoring metadata에서 character anchor를 정의한다.

### R2. 애니메이션마다 기준점이 다름
animation-level anchor를 허용하고 공통 robot pivot과 animation offset을 분리한다.

### R3. 원본 프레임 자체의 제작 오류
alignment layer로 해결 가능한 문제와 Asset 재제작이 필요한 문제를 분리한다. 원본 수정은 별도 승인한다.

### R4. Editor와 Runtime 구현이 다시 분기
공통 presentation layer를 단일 source of truth로 사용한다.

### R5. Legacy asset과 Visual Asset 혼용
resolver compatibility를 유지하고 신규 경로는 Visual Asset ID 우선, Legacy는 명시적인 fallback으로 격리한다.

## 13. Master 결정 사항 및 미확정 항목
### 결정 완료 — Body Center 정렬 정책
Master 결정: **공통 Body Center를 기본 기준으로 사용하고, 실제 근거가 확인된 animation에 한해 animation별 보정을 허용한다.** (공통 기준 + 필요한 animation만 개별 보정)

이 결정은 정렬 정책에 대한 것이다. 공통 Body Center 좌표는 후속 Master 결정으로 frame-local `(65,110)`으로 확정되었다. animation별 개별 보정값은 미확정이다. Alpha Bounds 전체 중심을 Body Center로 자동 간주하지 않는다.

### 결정 완료 — Body Center 산정 기준
Master 결정: **기준 포즈 기반**. 기준 포즈에서 공통 Body Center를 정의하고, 다른 프레임은 그 기준에 맞춰 보정한다.

### 결정 완료 — 기준 포즈
Master 결정: **Valkyrie Idle 첫 프레임**을 기준 포즈로 사용한다.

이 결정은 기준 포즈의 선택이다. 공통 Body Center는 Master가 선택한 골반 중심 C, frame-local `(65,110)`으로 후속 확정되었다. 개별 animation/frame 보정값은 아직 미확정이다. Alpha Bounds 전체 중심을 자동으로 Body Center로 간주하지 않는다.

### Master 결정 — Body Center 지정 방식
Master 선택: **3 — 기준 프레임에서 수동 지정한 픽셀을 공통 기준점으로 사용**.
Body Center는 Alpha Bounds 전체 중심에서 자동 계산하지 않는다. Valkyrie Idle 첫 프레임에서 Master가 선택한 C(골반 중심) 후보의 ROI centroid를 기준점으로 사용한다. 확정 좌표는 frame-local `(65,110)`이며 산출 원값은 `(64.99,109.96)`이다. 좌표 지정이 완료되었으나 Geometry 구현 및 개별 보정값 확정은 별도 계약 구체화 이후 진행한다.

### 구현 전 추가 확인
- 공통 기준점과 animation별 보정값의 데이터 표현 및 좌표계
- Editor Preview와 Runtime이 동일한 frame geometry를 소비할 최소 API
### Master 승인 — Geometry 좌표 및 보정 계약
- 좌표계: 프레임 로컬 원본 픽셀(px). 각 프레임 영역의 좌상단이 원점이며 X는 오른쪽, Y는 아래쪽이 양수다.
- 좌표 처리: frame region을 분할한 뒤 frame-local 좌표에서 보정하고, 원본 픽셀 기준 보정 이후 표시 배율을 적용한다.
- 기준점: Valkyrie Idle 첫 프레임에서 정의하는 Body Center.
- 보정값: animation 기본 offset과 해당 프레임의 추가 offset을 합산한다. 프레임별 offset이 없으면 [0, 0]으로 취급한다.
- 부호: offset은 화면상 프레임 원점을 이동시키는 방향으로 정의한다.
- 누락·불일치: 명시적 진단을 제공하며 자동 추측하지 않는다.

### 구현 전 추가 확인
- Geometry schema/version, 필드 검증기 및 기존 데이터 마이그레이션 경계
- Legacy fallback 허용 범위와 명시적 설정 방식
- 공통 Presentation API의 구체적 입력/출력 계약

Master 선택: **B — 별도 Geometry 계층**.
Master 승인: **프레임 로컬 원본 픽셀 좌표계, 좌상단 원점 및 축 방향, 보정 적용 시점, Body Center 기준, offset 합성 순서와 부호, 누락·불일치 진단 원칙**.
Geometry 데이터 구조/파일명/schema와 animation별 개별 보정값은 미확정이며 PROPOSAL이다. Master가 선택한 공통 Body Center는 frame-local `(65,110)`이며, 계산 원값과 선택 근거는 Phase A 후보 분석 기록을 참조한다.

## 14. 최종 판정 기준
- 프레임별 자연스러운 크기 차이는 유지된다.
- 캐릭터가 불필요하게 좌우/상하로 튀지 않는다.
- Preview와 Runtime의 위치가 일치한다.
- Visual Asset Catalog는 frame source/region/count의 기준 데이터이며, 별도 Geometry 계층은 anchor/offset의 기준 데이터다.
- Runtime의 하드코딩 frame count 의존이 제거 또는 격리된다.
- 원본 Asset은 변경하지 않는다.

## 15. 현재 상태
STATUS: HOLD — 공통 Body Center 좌표 결정 완료. Geometry schema/검증, 공통 API 및 Legacy fallback 계약의 구체화가 남아 있음.
Master가 B(별도 Geometry 계층)를 선택했고, 프레임 로컬 원본 픽셀 좌표계, 원점/축 방향, 보정 적용 시점, Body Center 기준, offset 합성 순서/부호, 누락·불일치 진단 원칙을 승인했다. Geometry schema/파일명, 공통 API 세부 계약 및 Legacy fallback은 미확정 PROPOSAL이다.
Body Center 정렬 정책, 산정 원칙, 기준 포즈(Valkyrie Idle 첫 프레임), 골반 중심 후보 C 및 frame-local 좌표 `(65,110)`는 Master 결정으로 확정되었다. 좌표 산출 원값은 `(64.99,109.96)`이며, animation별 개별 보정값은 미확정이다.
원본 시트의 Idle 표기는 6 FRAMES이며, Master의 선택 1에 따라 Catalog의 robot.valkyrie.idle.frames를 8에서 6으로 정정했다. Region(122, 10, 936, 176)은 변경하지 않았다. Editor Preview의 프레임 폭은 156px(936/6)로 계산된다.
Catalog의 image.* 삭제 및 skill2/skill3의 owner/region/source 등 추가 변경은 Master가 수행한 것으로 확인되었다. 해당 변경은 보존하며 원복하지 않는다. 이 변경의 주체/시점 불명은 더 이상 HOLD 사유가 아니다.
READ-ONLY 조사에서 Editor Preview는 VisualAssetResolver를 통해 Visual Asset Catalog의 source/region/frames를 사용하지만, Runtime의 game_controller.gd는 robots.json의 sprite_* 필드와 별도 *_rect 필드를 읽고 고정 프레임 수(Idle 6, Attack 7, Move/Skill 5)를 설정하는 것으로 확인되었다. Runtime 경로에서 VisualAssetResolver 호출은 확인되지 않았다.
따라서 현재 Editor/Runtime은 동일한 프레임 메타데이터를 소비하지 않는다. Runtime은 Sprite2D 기본 중심과 프레임 크기 기반 스케일을 사용하며 Body Center 기준 보정은 확인되지 않았다. 실제 PIE 동작은 아직 검증하지 않았다.
이번 문서 갱신에서는 Master의 C 선택과 좌표 `(65,110)`를 반영했으며 원본 Asset과 Runtime/Editor 코드는 변경하지 않았다. 남은 설계 결정은 Geometry schema/검증 계약, 공통 API 세부 계약, Legacy fallback 범위다. 해당 항목은 구현 전에 구체화해야 한다.
## Phase A 조사 결과 — 2026-10-04

- **CONFIRMED:** Valkyrie 원본 스프라이트 시트의 실제 이미지 크기는 1536x1024이다.
- **CONFIRMED (Phase A 기준선):** 조사 당시 Catalog 프레임 수는 idle 8, move 8, attack 8, hit 4, death 8, projectile 6, skill1 8, skill2 10, skill3 12, special 14, finisher 18이었다. 이후 Master 승인에 따라 idle은 6으로 정정되었다.
- **CONFIRMED:** 프레임별 Alpha Bounds 분석 결과 X축 중심 이동은 모든 조사 애니메이션에서 0px로 측정되었다.
- **CONFIRMED:** Y축 Alpha Bounds 중심 이동 범위는 idle 3px, move 4px, attack 6.5px, hit 0px, death 6.5px, projectile 0px, skill1 0px, skill2 0px, skill3 0px, special 0px, finisher 5px이다.
- **INFERENCE:** 현재 어색함의 주요 후보는 프레임 자체의 X 위치 문제가 아니라, 일부 포즈에서 캐릭터의 실제 불투명 영역이 프레임 중앙에서 Y축으로 이동하는 현상이다.
- **CONFIRMED:** Editor Preview는 Visual Asset의 region/frames를 사용하지만 프레임별 Body Center 보정은 하지 않는다.
- **CONFIRMED:** Runtime은 game_controller.gd에서 catalog 값을 직접 load()하고, robot animation frame count를 6/7/5/5로 하드코딩한다.
- **CONFIRMED:** Valkyrie의 catalog 값은 Visual Asset ID이므로 현재 Runtime의 직접 load() 방식과 데이터 의미가 일치하지 않는다.
- **PROPOSAL:** Body Center 기준을 유지하되, Alpha Bounds 중심을 최종 Canon으로 자동 채택하지 않는다. 공통 Presentation 계층에서 Master가 선택한 Body Center `(65,110)`을 기준으로 프레임별 보정값을 계산/적용할 수 있도록 한다. 실제 개별 보정값은 핵심 동작 프레임 분석 후 확정한다.
- **정정:** 공통 Body Center + 근거가 확인된 animation별 보정 정책은 Master 결정으로 이미 확정되었다. 아래 후보 분석은 그 공통 기준점의 의미와 픽셀 위치를 좁히기 위한 것이며 정책을 다시 결정하는 항목이 아니다.

## Body Center 후보 계산 — Valkyrie Idle frame 0 (2026-10-04)

**범위/기준:** 원본 1536x1024 PNG의 Catalog region `(122, 10, 936, 176)`을 6등분한 첫 frame. frame-local 크기 156x176px. 좌표 원점은 frame 좌상단. 원본 이미지/Catalog는 변경하지 않았다.

**CONFIRMED — 픽셀 계산:** alpha threshold 128 기준 전체 frame의 opaque bbox는 `(4, 1)..(155, 164)`, opaque pixel centroid는 `(64.86, 87.37)`이다. 단, 전체 frame에는 오른쪽으로 뻗은 총기, 머리 장식 및 등 장식이 포함되므로 이 값은 Body Center로 채택하지 않는다.

**후보 산출(계산값은 INFERENCE; C는 아래 Master 결정으로 선택됨):**
- A — 비무기 실루엣 중심: ROI `(24,0)..(90,166)`으로 제한한 opaque pixel centroid 약 `(58.2, 83.8)`. 무기를 일부 제외한 분석용 ROI일 뿐 자동 segmentation은 아니며, 머리/장식/등 장식의 영향이 남아 있어 몸통 기준점으로는 부적합할 수 있다.
- B — 몸통 핵심 영역 중심: 시각적으로 몸통 중심부로 잡은 ROI `(38,66)..(88,125)` 안의 opaque pixel centroid 약 `(63.1, 95.4)` (alpha threshold 16/128/200에서 거의 동일). 무기와 머리 장식의 영향이 줄어든 후보이나 ROI 경계는 해부학적 segmentation이 아닌 분석자가 정한 범위다.
- C — 골반 영역 중심: ROI `(48,95)..(82,125)`의 opaque pixel centroid 약 `(65.0, 110.0)` (threshold 변화 영향 미미). 이동/지면 접촉 시 안정적인 기준이 될 수 있으나, 이는 몸체 중심보다는 골반/하체 pivot에 가까운 의미다.

**판정:** 자동 픽셀 계산만으로 A/B/C 중 하나를 객관적 Body Center로 확정할 수는 없었으나, Master가 C를 선택함으로써 공통 기준점의 의미와 좌표가 결정되었다. ROI는 분석자가 정의한 골반 영역이며, 향후 다른 캐릭터/애니메이션에 적용할 때 동일한 ROI를 자동 일반화하지 않는다.

**Master 결정 — 공통 기준점 선택 (2026-10-04):** Master가 `C — 골반 중심` 후보를 선택했다. 이에 따라 Valkyrie Idle frame 0의 공통 Body Center는 골반 ROI `(48,95)..(82,125)`의 alpha pixel centroid를 가장 가까운 정수 픽셀로 반올림한 frame-local `(65,110)`으로 기록한다. 계산 원값은 약 `(64.99,109.96)`이며, 이는 Alpha Bounds 전체 중심이 아니라 선택된 골반 ROI 안의 픽셀 중심이다. Catalog region 원점 `(122,10)`을 더한 원본 시트 좌표는 `(187,120)`이다. **좌표 선택의 근거는 Master의 C 선택이며, 숫자 산출은 분석 계산**이다. 이는 해당 기준점의 의미/위치를 확정한 것이며, 다른 animation의 개별 보정값이나 Geometry schema/API 구현 승인은 포함하지 않는다.

**다음 결정 지점:** Geometry schema/검증 계약, 공통 Presentation API의 입력·출력, Legacy fallback 범위. 해당 항목은 구현 전에 구체화하고 Master 결정이 필요한 경계에서 HOLD한다.

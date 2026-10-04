# MENOS Editor / Content / Visual Asset Normalization Redesign
## 2026-10-04

## 1. 목적

현재까지 구현된 Content Editor, Asset Catalog Editor, Image/Visual Asset 처리, Robot Editor, Unit Editor, Tower Editor, Stage/Map Editor를 전면 재작성하지 않고 공통 데이터 계층으로 정규화한다.

핵심 목표는 신규 콘텐츠를 추가할 때 Editor별 별도 구현을 반복하지 않고,

Source Asset 등록 -> Visual Asset 정의 -> Content Entity 구성 -> Editor 검증 -> Runtime Resolver

의 동일한 파이프라인을 사용하게 만드는 것이다.

목적 달성 후 추가 기능 개발은 자동 진행하지 않는다.

## 2. 현재 확인된 구조

CONFIRMED

- `content/editor/asset_catalog.json`은 Map/Tiles/Object 계열의 Catalog 데이터와 source rect를 보유한다.
- `content/editor/visual_assets.json`은 VisualAsset 전용 데이터 저장소이며 현재 파일은 비어 있다.
- `scripts/visual_asset_definition.gd`는 source, region, frames, columns, rows, frame_order, anchor, owner, usage, team_mask, frame_regions를 이미 표현할 수 있다.
- `scripts/visual_asset_resolver.gd`는 Visual Asset ID와 legacy source path를 모두 resolve한다.
- `content/robots/robots.json`은 로봇별 gameplay 수치와 animation_rects, sprite 관련 필드가 혼재한다.
- Tower/Unit/Robot Editor는 각각 JSON을 직접 읽고 쓰면서 이미지 선택/Preview/Animation 처리의 일부를 중복 구현한다.
- Content Editor는 여러 Editor scene을 교체하는 상위 Host 역할을 한다.
- 현재 Working Tree에는 `editor/tower_editor.gd` 수정과 tower improvement 문서가 이미 존재한다. 이 변경은 본 설계의 기준선에서 임의로 수정하지 않는다.

## 3. 핵심 재설계 원칙

### 3.1 Source와 Visual Asset을 분리

원본 PNG/SVG는 Source Asset이다.

Visual Asset은 Source의 특정 의미 있는 시각 자원을 식별하는 논리 ID다.

예:
- source: `res://images/robot/asura/...`
- visual asset: `visual.robot.asura.idle`
- visual asset: `visual.robot.asura.profile`
- visual asset: `visual.robot.asura.skill1`

Source 경로를 Robot/Unit/Tower 데이터에 직접 저장하는 것을 신규 데이터에서는 금지한다.

### 3.2 Visual Asset을 모든 Editor의 공통 언어로 사용

Robot, Unit, Tower, Enemy, Item, Map Object, Projectile, Effect, UI 등은 가능한 경우 이미지 경로가 아니라 Visual Asset ID를 참조한다.

Editor는 Visual Asset을 직접 해석하지 않고 공통 Resolver/Definition API를 사용한다.

### 3.3 Entity와 Visual을 분리

Entity는 게임 의미와 수치를 보유한다.

Visual Asset은 이미지와 프레임/영역/앵커 정보를 보유한다.

따라서:
- Robot = gameplay identity + stats + animation bindings
- Unit = gameplay identity + stats + visual bindings
- Tower = gameplay identity + stats + visual bindings
- VisualAsset = source + region/frame/anchor/render metadata

### 3.4 Editor는 데이터 소유자가 아니다

Editor는 JSON schema를 임의로 정의하지 않는다.

공통 Repository/Definition 계층이 load/save/validate를 담당하고 Editor는 이를 편집한다.

### 3.5 Runtime과 Editor가 같은 Resolver를 사용

Preview 전용 해석과 Runtime 전용 해석을 별도로 만들지 않는다.

동일한 VisualAssetDefinition을 사용하되 Preview는 추가 표시 옵션만 적용한다.

## 4. 목표 데이터 계층

```
Content Repository
    |
    +-- Content Entity
    |      +-- Robot
    |      +-- Unit
    |      +-- Tower
    |      +-- Enemy
    |      +-- Skill
    |      +-- Stage
    |      +-- Map
    |
    +-- Visual Asset Repository
    |      +-- Static Visual
    |      +-- Sprite Animation
    |      +-- Profile
    |      +-- Projectile
    |      +-- Effect
    |      +-- Tile/Object
    |
    +-- Source Asset Registry
           +-- PNG
           +-- SVG
           +-- other imported resources
```

Editor 계층:

```
Content Editor Host
    |
    +-- Catalog / Asset Browser
    +-- Visual Asset Editor
    +-- Robot Editor
    +-- Unit Editor
    +-- Tower Editor
    +-- Enemy Editor
    +-- Skill Editor
    +-- Stage Editor
    +-- Map Editor
```

공통 서비스:

```
ContentRepository
VisualAssetRepository
VisualAssetResolver
AssetThumbnailService
AnimationFrameResolver
ContentValidator
ReferenceScanner
```

## 5. Visual Asset 정규 Schema

기존 VisualAssetDefinition을 확장하되 현재 필드를 최대한 유지한다.

예시:

```json
{
  "id": "visual.robot.asura.idle",
  "schema_version": 2,
  "type": "animation",
  "category": "robot",
  "source": "res://images/robot/asura/idle.png",
  "region": [0, 0, 1536, 1024],
  "frames": 8,
  "columns": 4,
  "rows": 2,
  "frame_order": "row_major",
  "frame_regions": [],
  "anchor": {
    "mode": "BOTTOM_CENTER",
    "x": 0.5,
    "y": 1.0
  },
  "render": {
    "scale": 1.0,
    "offset": [0, 0],
    "flip_h": false
  },
  "team_mask": {
    "source": "res://images/robot/asura/profile_team_mask.png"
  },
  "owner": "robot.asura",
  "usage": "idle"
}
```

중요한 점은 frame geometry를 단순히 columns/rows에만 의존하지 않는 것이다.

- 균일 Grid: columns/rows 사용
- 비균일 Cell: frame_regions 사용
- 프레임별 위치 보정: frame metadata 확장 가능
- 프레임별 anchor가 필요해지면 frame_anchor 배열을 추가

따라서 현재 발견된 2행 및 비균일 Cell 문제를 공통 모델에서 수용한다.

## 6. Animation 정규화

현재 robots.json의 animation_rects와 sprite_*_rect는 장기적으로 Visual Asset으로 이동한다.

기존:

```json
"animation_rects": {
  "idle": [ ... ],
  "attack": [ ... ]
}
```

목표:

```json
"visuals": {
  "profile": "visual.robot.asura.profile",
  "idle": "visual.robot.asura.idle",
  "move": "visual.robot.asura.move",
  "attack": "visual.robot.asura.attack",
  "hit": "visual.robot.asura.hit",
  "death": "visual.robot.asura.death",
  "skill1": "visual.robot.asura.skill1",
  "finisher": "visual.robot.asura.finisher",
  "projectile": "visual.projectile.default"
}
```

Entity 데이터에는 frame rect를 직접 저장하지 않는다.

## 7. Robot / Unit / Tower 공통 구조

세 Editor의 공통점을 먼저 추출한다.

공통 Entity Base:

```json
{
  "id": "robot.asura",
  "schema_version": 2,
  "display_name": "ASURA",
  "tags": [],
  "stats": {},
  "visuals": {},
  "abilities": {},
  "progression": {},
  "editor": {}
}
```

각 타입은 필요한 부분만 확장한다.

Robot:
- energy
- progression
- skills
- combat behavior
- visual animation bindings

Unit:
- unit class/type
- stats
- deployment data
- animation bindings

Tower:
- cost
- range
- cooldown
- projectile
- upgrade data
- animation bindings

공통 Visual Binding UI를 세 Editor에서 공유한다.

## 8. Catalog의 역할 재정의

현재 Asset Catalog는 Tile/Object Catalog와 Visual Asset Catalog를 한 화면에서 합성하고 있다.

이를 유지하되 내부적으로 두 종류를 명확히 구분한다.

Catalog Item:
- MapAsset
- VisualAsset

Catalog는 Authoring Index다.

실제 데이터의 소유자는 각각:
- Map/Object Asset Repository
- Visual Asset Repository

Catalog는 이를 검색/선택/연결하는 통합 Browser 역할을 한다.

따라서 Catalog가 Visual Asset 데이터를 별도로 복제해서 소유하지 않는다.

## 9. Content Editor의 역할 재정의

현재 Content Editor는 Editor Scene Host 역할이 중심이다.

이를 다음 구조로 유지한다.

Content Editor:
- Editor navigation
- 현재 entity context
- selection context
- shared services
- validation result
- unsaved state

개별 Editor:
- 자기 Entity의 schema 편집
- 해당 Entity의 Visual Binding 편집
- domain-specific validation

Editor끼리 JSON 파일을 직접 읽고 쓰지 않는다.

## 10. 공통 Selection Context

현재 ImageEditorState 방식의 selection return 흐름을 일반화한다.

```
EditorSelectionContext
- source_editor
- target_editor
- target_field
- owner_type
- owner_id
- current_asset_id
- expected_usage
- expected_frames
- return_scene
```

Catalog/Visual Asset Editor에서 선택하면:

```
select VisualAsset
 -> validate compatibility
 -> assign ID
 -> save entity
 -> refresh preview
 -> return to source editor
```

이 흐름을 Robot/Unit/Tower 모두 동일하게 사용한다.

## 11. 공통 Thumbnail Pipeline

Thumbnail 생성도 Editor마다 구현하지 않는다.

```
AssetThumbnailService.create(asset_id, options)
```

Resolver가:
1. VisualAsset ID인지 확인
2. source/region/frame metadata resolve
3. 지정 frame 추출
4. anchor/scale preview 적용
5. texture 반환

Catalog 목록, Robot Editor, Unit Editor, Tower Editor 모두 동일한 Thumbnail Service를 사용한다.

이렇게 하면 현재 발견된 "같은 Asset인데 Editor별 썸네일이 다르게 보이는 문제"를 구조적으로 줄일 수 있다.

## 12. 공통 Animation Preview Pipeline

```
AnimationPreviewModel
    source VisualAsset
    frame index
    playback fps
    loop
    anchor
    scale
    offset
    team color
    mask
```

Preview UI는 Model을 표시하기만 한다.

Robot/Unit/Tower가 각각 frame 계산을 구현하지 않는다.

특히:
- 1행
- 2행
- N행
- 비균일 Cell
- frame_regions
- anchor
- scale
- offset

을 동일 resolver로 처리한다.

## 13. Team Color / Mask 정규화

Team color는 Entity의 색상 데이터와 Visual Asset의 mask source를 분리한다.

Entity:

```json
"team": {
  "color": "#b7e30f"
}
```

Visual Asset:

```json
"team_mask": {
  "source": "res://..."
}
```

Renderer:

```
VisualAsset
+
TeamColor
+
TeamMask
=
RenderedVisual
```

따라서 profile, gameplay sprite, animation이 동일한 mask를 무조건 공유하는 구조가 아니라 Asset별 mask 정책을 가질 수 있다.

## 14. Repository 구조

신규 공통 코드 후보:

```
scripts/content/
    content_repository.gd
    content_definition.gd
    content_validator.gd
    content_reference_scanner.gd

scripts/visual/
    visual_asset_definition.gd
    visual_asset_repository.gd
    visual_asset_resolver.gd
    animation_frame_resolver.gd
    asset_thumbnail_service.gd
    visual_render_config.gd

editor/shared/
    editor_selection_context.gd
    visual_asset_picker.gd
    visual_binding_panel.gd
    animation_preview_panel.gd
```

기존 파일은 즉시 이동하지 않는다.

먼저 공통 API를 추가하고 기존 Editor가 그것을 사용하도록 전환한다.

## 15. 저장 책임

현재 가장 중요한 구조적 개선점이다.

목표:

```
Editor UI
   |
Definition Model
   |
Repository
   |
JSON
```

금지:

```
Editor UI
   |
직접 JSON Dictionary 수정
   |
FileAccess
```

Repository는 다음을 보장한다.

- load
- save
- schema_version
- validation
- atomic-ish write + reopen verification
- reload/invalidation
- reference lookup

Editor는 저장 성공 여부만 받는다.

## 16. ID 규칙

모든 Content와 Visual Asset은 namespace 기반 안정 ID를 사용한다.

예:

```
robot.asura
robot.valkyrie

unit.basic
unit.heavy
unit.flying

tower.cannon
tower.gatling

skill.finisher
skill.area_attack

visual.robot.asura.profile
visual.robot.asura.idle
visual.robot.asura.attack
visual.robot.asura.skill1

visual.unit.basic.idle
visual.tower.cannon.anim
visual.projectile.default
```

파일명이나 표시 이름을 ID로 사용하지 않는다.

ID 변경은 일반 이름 변경과 분리한다.

## 17. Legacy 호환

즉시 기존 JSON을 모두 변환하지 않는다.

현재 VisualAssetResolver의 legacy source fallback은 migration 기간 동안 유지한다.

단계:

1. Legacy source path 읽기 허용
2. 신규 저장은 Visual Asset ID 사용
3. 기존 데이터 자동 변환 도구 작성
4. 전체 reference scan
5. Runtime/Editor 검증
6. Legacy fallback 제거는 별도 승인 후 진행

따라서 현재 콘텐츠를 한 번에 깨뜨리는 위험을 피한다.

## 18. Editor 통합 우선순위

1. 공통 Visual Asset Resolver 강화
2. 공통 Thumbnail/Animation Frame Resolver
3. Robot Editor를 기준 구현으로 정규화
4. Unit Editor를 Robot 공통 구조에 연결
5. Tower Editor를 Robot 공통 구조에 연결
6. Catalog Editor를 통합 Asset Browser로 정리
7. Stage/Map Editor의 Asset 선택도 동일 Picker 사용
8. Enemy/Item/Skill Editor에 확장

Robot Editor를 Reference Implementation으로 삼는 이유는 현재 가장 복잡한 animation/visual 요구사항을 이미 가지고 있기 때문이다.

## 19. Migration 순서

### Phase A — Read-only normalization

- 현재 JSON schema 조사
- 공통 Definition 모델 작성
- Repository 작성
- 기존 Editor는 변경하지 않고 resolver만 병행 사용
- 기존 데이터와 새 모델의 결과 비교

성공 조건:
기존 Runtime/Editor 결과가 변하지 않는다.

### Phase B — Visual Asset canonicalization

- Asura의 profile/idle/move/attack/hit/death/skill/finisher을 Visual Asset으로 등록
- Valkyrie 동일 구조 적용
- 2행/비균일 Cell/anchor 검증
- Robot Editor Preview 검증

### Phase C — Editor binding normalization

- Robot Editor의 Select Asset을 공통 Picker로 교체
- Unit Editor 적용
- Tower Editor 적용
- 저장 후 재연결 검증

### Phase D — Catalog normalization

- Catalog가 Repository를 통해 Visual Asset을 표시
- Visual Asset과 Map/Object Asset의 표시 형식 통일
- usage/reference scanner 통합

### Phase E — Legacy migration

- robots.json의 animation_rects/sprite rect를 Visual Asset ID로 변환
- Tower/Unit의 직접 source path 변환
- reference scan
- old field 제거 여부 판단

## 20. 최소 검증 기준

각 Phase마다 최소한 다음을 확인한다.

CODE VERIFIED:
- Repository load/save
- VisualAsset resolve
- frame resolve
- legacy resolve

EDITOR VERIFIED:
- Asset 선택
- 썸네일
- Preview
- 저장
- 재로드

BUILD VERIFIED:
- 프로젝트 build/import 오류 없음

PIE VERIFIED:
- Master가 실제 Runtime에서 확인한 경우에만 부여

특히 자동화 테스트 PASS를 PIE VERIFIED로 승격하지 않는다.

## 21. 하지 않을 것

이번 정규화에서 다음은 범위 밖이다.

- 새로운 게임플레이 기능
- 새로운 Sprite 생성
- 새로운 외부 Asset 도입
- Runtime 전면 재작성
- 모든 JSON을 한 번에 새 schema로 변환
- Editor UI의 미관 전면 개편
- 사용하지 않는 기존 Asset 정리

## 22. 예상 효과

정규화가 성공하면 신규 로봇 추가 비용이 다음처럼 감소한다.

현재:
- Robot Editor 개별 필드 연결
- Animation rect 직접 설정
- Thumbnail 처리
- Preview frame 처리
- Asset 선택 연결
- 저장 로직
- Runtime 경로 연결

목표:
- Visual Asset 등록
- Robot Entity 생성
- Visual Binding 지정
- Stats/Ability 입력
- Validation
- Preview

즉, 새로운 콘텐츠가 새로운 기능 구현이 아니라 데이터 authoring에 가까워진다.

## 23. 핵심 판단

CONFIRMED:
현재 프로젝트는 이미 정규화에 필요한 핵심 재료를 상당 부분 갖고 있다.

HIGH CONFIDENCE:
전면 재작성보다 기존 VisualAssetDefinition/Resolver와 Robot Editor를 기준으로 공통 계층을 추출하는 방법이 가장 현실적이다.

PROPOSAL:
Robot Editor를 Reference Implementation으로 만들고 Unit/Tower를 그 구조에 맞추는 것이 가장 안전하다.

PROPOSAL:
Catalog는 데이터 저장소가 아니라 통합 Asset Browser/Picker로 재정의하는 것이 장기적으로 적합하다.

UNVERIFIED:
현재 모든 Editor가 동일한 데이터 모델로 완전히 수렴 가능한지는 각 Editor의 전체 schema를 추가 대조해야 한다.

## 24. 종료 기준

다음 조건이 충족되면 정규화 작업을 1차 완료로 판정한다.

- Robot/Unit/Tower가 동일한 Visual Asset 선택 흐름을 사용
- 동일한 Animation Frame Resolver 사용
- 동일한 Thumbnail Pipeline 사용
- Source path 직접 참조가 신규 Entity 데이터에서 제거
- Save -> Reload 후 Visual Binding 유지
- 2행 이상 및 비균일 Cell 처리 유지
- 기존 Asura/Valkyrie 결과가 regress하지 않음
- Runtime resolver가 Editor Preview와 동일한 VisualAssetDefinition을 사용

그 시점에서 추가 정규화의 정보 가치와 비용을 다시 판단한다.

## 25. 판정

STATUS — PROPOSAL

목적 — 현재 구현된 Content Editor, Catalog, Visual Asset, Robot/Unit/Tower Editor를 반복 가능한 콘텐츠 제작 시스템으로 정규화

마리의 판정 — 정규화 가치가 높다. 다만 대규모 일괄 마이그레이션보다 공통 Resolver/Repository를 먼저 세우고 Editor를 단계적으로 전환하는 방식이 현실적이다.

현실성 판단 — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE / RECOMMENDED

현재 단계 — 설계 완료. 구현은 별도 승인/작업 범위로 둔다.

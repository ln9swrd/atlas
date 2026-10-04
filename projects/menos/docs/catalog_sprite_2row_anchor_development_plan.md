# MENOS Catalog Editor — 2+ Row Sprite Sheet / Anchor 개발계획

## 1. 목적

MENOS Catalog Editor에서 2행 이상의 Sprite Sheet를 정확하게 등록·미리보기하고, Robot Editor의 애니메이션 Preview에서도 동일한 프레임과 위치 기준을 사용하도록 확장한다.

핵심 목표는 단순히 `frames` 수를 늘리는 것이 아니라 **고정 Cell Grid + 공통 Anchor**를 Visual Asset의 명시적 메타데이터로 정의하는 것이다.

## 2. 현재 기준선

- Project: `E:\atlas\projects\menos`
- Godot: `E:\godot 4.7.2`
- 기준 Branch: `main`
- 현재 Working Tree: CLEAN (조사 시점)
- 관련 핵심 파일:
  - `godot/scripts/visual_asset_definition.gd`
  - `godot/editor/image_editor.gd`
  - `godot/editor/asset_region_view.gd`
  - `godot/editor/robot_editor.gd`
  - `content/editor/visual_assets.json`

## 3. 확인된 현재 문제

### 3.1 VisualAssetDefinition

현재 저장 정보는 다음 수준이다.

- id
- category
- source
- region
- frames
- owner
- usage
- frame_regions

아직 다음 정보가 없다.

- columns
- rows
- frame_order
- anchor

### 3.2 Robot Editor

현재 `_animated_texture()`는 `region.width / total_frames` 방식으로 프레임 폭을 계산하며 Y 위치를 고정한다.

따라서 기본적으로 1행 가로 Sprite Sheet를 전제로 한다.

2행 Sheet의 경우 실제 프레임 위치를 올바르게 계산하지 못한다.

### 3.3 Catalog Editor

최근 업데이트로 Asset ID 선택, region 저장, Catalog 재스캔, 썸네일 갱신 등의 흐름은 개선되어 있다.

이 기능은 유지하고, 2+행 처리를 위한 Grid/Anchor 기능만 확장한다.

### 3.4 Anchor 문제

프레임별 Alpha Bounding Box를 기준으로 위치를 잡으면 투명 여백 차이 때문에 캐릭터가 프레임마다 흔들릴 수 있다.

따라서 Anchor는 각 프레임의 실제 투명 픽셀 영역이 아니라 **고정 Cell을 기준으로 하는 공통 좌표**여야 한다.

## 4. 목표 데이터 구조

Visual Asset에 다음 메타데이터를 추가한다.

```text
region
columns
rows
frames
frame_order
anchor
  mode
  x
  y
```

권장 Anchor 표현은 Cell 기준 정규화 좌표다.

```text
x: 0.0 ~ 1.0
y: 0.0 ~ 1.0
```

MENOS 캐릭터 기본값은 다음을 권장한다.

```text
mode: BOTTOM_CENTER
x: 0.5
y: 1.0
```

이는 캐릭터의 발/지면 접점을 고정하기 위한 것이다.

## 5. Frame Grid 규칙

Region을 Columns × Rows의 고정 Cell로 나눈다.

예:

```text
region = 1440 × 448
columns = 9
rows = 2

cell = 160 × 224
```

Row-major 순서는 다음과 같다.

```text
01 02 03 04 05 06 07 08 09
10 11 12 13 14 15 16 17 18
```

프레임 계산:

```text
column = frame % columns
row = frame / columns

frame_left = region.x + floor(region.width * column / columns)
frame_right = region.x + floor(region.width * (column + 1) / columns)
frame_top = region.y + floor(region.height * row / rows)
frame_bottom = region.y + floor(region.height * (row + 1) / rows)
```

frame_order는 우선 row_major를 기본값으로 한다.

### 5.1 비균일 Cell 정책

Master 결정: Region을 Columns/Rows로 나눈 결과가 정수로 나누어지지 않아도 허용한다.

프레임 경계는 누적 정수 경계로 계산한다.

start = floor(size * index / count)
end = floor(size * (index + 1) / count)

따라서 인접 Cell 사이에 빈 픽셀이나 중복 픽셀이 생기지 않으며, Cell 크기는 축마다 최대 1px 차이가 날 수 있다.

예: Valkyrie Finisher 1536 × 450, 9 × 2, 18 frames
- 가로 Cell: 170px 또는 171px
- 세로 Cell: 225px
- Frame 0: x=0..169, y=300..524
- Frame 8: x=1365..1535, y=300..524
- Frame 9: x=0..169, y=525..749
- Frame 17: x=1365..1535, y=525..749

## 6. Catalog Editor 개발 범위

### 6.1 데이터 입력 UI

Region 정보 옆에 다음 항목을 제공한다.

- Columns
- Rows
- Frames
- Frame Order
- Anchor Mode
- Anchor X
- Anchor Y

### 6.2 Grid Preview

선택된 Region 위에 Cell Grid를 표시한다.

필수 표시 요소:

- 전체 Region
- Cell 경계
- 현재 Frame
- Anchor Marker

### 6.3 Anchor Preset

최소 다음 Preset을 제공한다.

- CENTER
- BOTTOM_CENTER
- CENTER_LEFT
- BOTTOM_LEFT
- CUSTOM

### 6.4 입력 검증

다음 조건을 저장 전에 검증한다.

```text
columns >= 1
rows >= 1
frames >= 1
frames <= columns * rows
region.width > 0
region.height > 0
anchor.x >= 0 && anchor.x <= 1
anchor.y >= 0 && anchor.y <= 1

Cell boundaries use cumulative integer flooring, so non-divisible regions are valid:
start = floor(size * index / count)
end = floor(size * (index + 1) / count)
This produces adjacent integer cells with no overlap or gap; widths/heights may differ by one pixel.
```

조건을 만족하지 않으면 저장하지 않는다.

## 7. Robot Editor 개발 범위

Robot Editor는 Catalog의 동일한 Visual Asset 메타데이터를 사용해야 한다.

### 7.1 Frame Rect 계산

기존의 단순 `region.width / frames` 계산을 제거하고 Columns/Rows/Frame Order를 사용한다.

각 프레임은 고정 Cell Rect로 계산한다.

### 7.2 Anchor 적용

계산된 Cell 안에서 Anchor 위치를 게임 좌표의 공통 기준점으로 사용한다.

예:

```text
cell = 120 × 120
BOTTOM_CENTER = (60, 120)
```

프레임별 Alpha Trim을 Anchor 계산에 사용하지 않는다.

### 7.3 Catalog와 Robot Editor 일치성

동일 Asset에 대해 다음 값이 양쪽에서 반드시 동일해야 한다.

- Region
- Columns
- Rows
- Frames
- Frame Order
- Anchor

## 8. VisualAssetDefinition 변경

`visual_asset_definition.gd`에 다음 필드를 추가한다.

```text
columns: int
rows: int
frame_order: String
anchor_mode: String
anchor_x: float
anchor_y: float
```

`from_dict()`와 `to_dict()` 양쪽을 함께 수정한다.

## 9. Legacy 호환

기존 Asset을 깨뜨리지 않도록 누락값에 기본값을 적용한다.

```text
columns = frames
rows = 1
frame_order = row_major
anchor = 기존 동작과 호환되는 기본값
```

단, 새로 등록하는 캐릭터 Sprite Sheet에는 명시적인 Columns/Rows/Anchor 저장을 권장한다.

## 10. frame_regions와의 관계

기존 `frame_regions`는 즉시 제거하지 않는다.

첫 구현에서는 다음 우선순위를 적용한다.

1. 명시적 Grid metadata가 있는 Asset → Grid 방식 사용
2. Grid metadata가 없는 Legacy Asset → 기존 frame_regions 또는 1행 fallback 사용

이를 통해 기존 Asset과 새 2행 Asset을 동시에 처리한다.

## 11. Alpha Trim 정책

Sprite Animation의 공통 Anchor 안정성을 위해 자동 Alpha Trim을 프레임 위치 계산의 기준으로 사용하지 않는다.

Region 선택 자체의 Trim 기능은 유지하되, Animation Cell의 좌표와 Anchor는 고정 Cell 기준으로 유지한다.

프레임별 Anchor Override는 이번 개발 범위에서 제외한다.

## 12. 구현 순서

### Phase 1 — Data Model

1. VisualAssetDefinition 확장
2. JSON serialization/deserialization 추가
3. Legacy default 처리
4. 데이터 검증 함수 추가

### Phase 2 — Catalog Editor

1. Columns/Rows/Frames 입력
2. Frame Order 입력
3. Anchor Mode/좌표 입력
4. Grid Overlay
5. Frame Highlight
6. Anchor Marker
7. 입력값 검증
8. JSON 저장

### Phase 3 — Robot Editor

1. Grid 기반 Frame Rect 계산
2. Frame Order 처리
3. Anchor 계산
4. Preview 위치 적용
5. Legacy fallback 유지

### Phase 4 — 최소 검증

1. 1행 Legacy Asset
2. 2행 Asset
3. 3행 이상 Asset
4. Frames < Columns × Rows
5. BOTTOM_CENTER Anchor
6. CUSTOM Anchor
7. 기존 Asset 회귀 확인

## 13. 최소 성공 조건

다음 조건을 모두 만족하면 구현 성공으로 판정한다.

1. Catalog Editor에서 2행 Sprite Sheet를 등록할 수 있다.
2. Grid가 실제 Cell 경계와 일치한다.
3. 모든 프레임을 순서대로 선택할 수 있다.
4. Anchor Marker가 고정 Cell 기준으로 표시된다.
5. Robot Editor Preview가 동일한 프레임 순서를 사용한다.
6. 프레임 간 캐릭터 위치가 Anchor 기준으로 안정적으로 유지된다.
7. 기존 1행 Asset이 깨지지 않는다.

## 14. 검증 상태 기준

- CODE VERIFIED: 관련 코드 경로와 데이터 흐름 확인
- BUILD VERIFIED: 실제 Godot Build 성공
- EDITOR VERIFIED: Catalog Editor에서 Asset/Grid/Anchor 확인
- PIE VERIFIED: Master가 실제 Runtime에서 결과 확인

자동화 또는 정적 검증 PASS는 PIE VERIFIED로 승격하지 않는다.

## 15. 변경 안전성

구현 시작 전에 반드시 다음을 확인한다.

- HEAD
- Branch
- Working Tree
- 기존 변경사항

기존 변경은 임의로 되돌리거나 덮어쓰지 않는다.

각 Phase의 수정 후 Diff를 확인한다.

의도하지 않은 변경이 발견되면 즉시 중단하고 HOLD한다.

## 16. 범위 제외

이번 개발에서 다음은 수행하지 않는다.

- 새로운 Sprite Asset 제작
- 기존 Asset 이미지 변환
- 프레임별 Anchor Override
- Animation 시스템 전체 개편
- Runtime Animation 구조의 전면 재설계
- Catalog UI의 비관련 기능 개선
- Commit / Push

## 17. 현실성 판단

TECHNICALLY POSSIBLE: YES

PRACTICALLY FEASIBLE: YES

RECOMMENDED: YES

핵심 변경은 기존 Visual Asset metadata와 Robot Editor의 Frame Rect 계산을 확장하는 작업이다. 현재 Catalog Editor가 이미 Asset ID 및 region 저장/갱신 흐름을 가지고 있으므로, 기존 기능을 폐기하기보다 그 위에 Grid와 Anchor metadata를 추가하는 것이 가장 작은 변경 경로다.

BUSINESS VIABLE: 프로젝트 내부 개발 목적 기준으로 판단 가능하며, 외부 사업성 평가는 본 문서 범위에 포함하지 않는다.

## 18. 최종 개발 원칙

**고정 Cell이 프레임의 기준이다.**

**Anchor는 Cell 기준의 공통 좌표다.**

**Catalog Editor와 Robot Editor는 동일한 metadata를 소비해야 한다.**

**Legacy Asset은 깨뜨리지 않는다.**

**목표가 달성되면 추가 기능으로 자동 확장하지 않는다.**

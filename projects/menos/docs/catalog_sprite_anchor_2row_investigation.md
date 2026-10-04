# MENOS — 카탈로그 에디터 2행 이상 Sprite Sheet Anchor 지원 조사

## 목적
2행 이상의 Sprite Sheet를 Robot Editor Animation Preview에서 정상 표시하려면 카탈로그 에디터가 어떤 메타데이터와 편집 기능을 제공해야 하는지 조사한다.
핵심은 Rows/Columns만 추가하는 것이 아니라 여러 프레임의 게임 좌표 기준을 유지하는 Anchor/Pivot 정의다.

## 기준선
- Project: E:\\atlas\\projects\\menos
- Godot: E:\\godot 4.7.2
- 확인 파일: godot/editor/image_editor.gd, godot/editor/asset_region_view.gd, godot/editor/robot_editor.gd, godot/scripts/visual_asset_definition.gd, content/editor/visual_assets.json
- 이번 조사에서는 코드와 Asset을 변경하지 않았다.

## CONFIRMED — 현재 데이터 구조
VisualAssetDefinition은 id, category, source, region, frames, owner, usage를 저장한다.
현재 Rows, Columns, Frame Order, Anchor/Pivot은 저장하지 않는다.
따라서 frames는 총 프레임 수만 표현하며 2차원 Sprite Sheet의 배치를 표현하지 못한다.

## CONFIRMED — Robot Editor Preview의 한계
robot_editor.gd의 _animated_texture()는 현재 region.width / total_frames로 frame width를 계산하고 frame의 Y 좌표는 고정한다.
즉 현재 구현은 사실상 1행 × N열 Sprite Sheet 전용이다.
2행 Sheet에서는 frame row를 계산하지 않으므로 정상적인 2차원 분할이 불가능하다.

## CONFIRMED — 카탈로그 에디터의 현재 선택 영역
image_editor.gd는 Visual Asset 등록 시 source, region, frames, category, owner, usage를 저장한다.
AssetRegionView는 selected_region을 Rect2i로 관리한다.
현재 카탈로그 에디터에는 프레임별 Anchor/Pivot을 지정하는 UI가 없다.

## CONFIRMED — Alpha Trim 문제
asset_region_view.gd의 _commit_region_drag()는 _trim_region_to_visible_pixels()를 통해 선택 영역을 실제 Alpha bounding box로 줄일 수 있다.
일반 Asset에는 유용하지만 Animation Frame마다 투명 여백이 다르면 프레임별 bounding box가 달라진다.
이 값을 각 프레임의 실제 Sprite 크기나 위치 기준으로 사용하면 캐릭터가 Animation Preview에서 좌우/상하로 흔들릴 수 있다.

## 핵심 설계 결론
2행 이상 Sprite Sheet는 다음 정보를 하나의 Visual Asset 메타데이터로 가져야 한다.
1. Region
2. Columns
3. Rows
4. Frames
5. Frame Order
6. Cell Anchor

데이터 흐름은 Catalog → VisualAssetDefinition → VisualAssetResolver → Robot Editor Preview → Runtime으로 동일해야 한다.

## PROPOSAL — 권장 데이터 구조
기존 frames를 유지하면서 columns, rows, frame_order, anchor.mode, anchor.x, anchor.y를 추가한다.
Region은 Sprite Sheet 전체 선택 영역이다.
Columns는 가로 Cell 수, Rows는 세로 Cell 수, Frames는 실제 사용 프레임 수, Frame Order는 프레임 순서, Anchor는 각 Cell을 게임 좌표에 붙이는 공통 기준점이다.
기존 Asset 호환 기본값은 columns=frames, rows=1, frame_order=row_major로 한다.

## Anchor의 의미
Anchor는 그림 자체의 중앙을 정하는 값이 아니라 각 Sprite Cell을 게임 좌표에 붙이는 기준점이다.
MENOS 캐릭터에는 기본적으로 발 또는 지면 접점을 기준점으로 사용하는 것이 적합하다.
권장 기본값은 Cell 기준 BOTTOM_CENTER, normalized (0.5, 1.0)이다.
Anchor를 Alpha Bounding Box의 중앙으로 자동 결정하면 프레임마다 투명 여백이 달라질 때 기준점이 움직일 수 있으므로 피해야 한다.

## Cell과 Visible Bounding Box를 분리
Sprite Cell은 Sheet에서 프레임이 차지하는 고정 영역이다.
Visible Bounding Box는 Cell 내부에서 실제 Alpha가 존재하는 영역이다.
Anchor는 기본적으로 Visible Bounding Box가 아니라 고정 Cell 좌표를 기준으로 해야 한다.
이렇게 해야 동일한 Animation에서 캐릭터의 지면 기준이 유지된다.

## 카탈로그 에디터 UI 제안
현재 Region 선택 UI에 Sprite Sheet 설정 패널을 추가한다.
필수 항목: Region X/Y/Width/Height, Columns, Rows, Frames, Frame Order, Anchor Mode, Anchor X, Anchor Y.
Columns와 Rows 입력 시 Cell Width/Height를 자동 계산한다.
Frames는 기본적으로 Columns × Rows에서 계산하고 필요하면 실제 사용 프레임 수로 제한한다.
Frame Order 기본값은 row_major로 한다.
Anchor Preset은 CENTER, BOTTOM_CENTER, CENTER_LEFT, BOTTOM_LEFT, CUSTOM을 제공할 수 있다.
Preview에는 Grid Overlay, 현재 Frame Cell, Anchor Marker를 표시한다.

## 2행 예시
Region이 1440 × 448이고 Columns=9, Rows=2이면 Cell은 160 × 224이다.
row_major 순서는 01~09가 첫 행, 10~18이 둘째 행이다.
Frame 계산은 column = frame % columns, row = frame / columns, frame_x = region.x + column × cell_width, frame_y = region.y + row × cell_height 방식으로 한다.

## Anchor 적용
normalized Anchor를 사용하면 anchor_px.x = cell_width × anchor.x, anchor_px.y = cell_height × anchor.y로 계산한다.
예를 들어 BOTTOM_CENTER는 Cell의 중앙 하단이다. 120 × 120 Cell이면 Anchor Pixel은 60, 120이다.
Robot Editor는 이 Anchor가 동일한 Preview 기준 좌표에 오도록 Sprite를 배치해야 한다.

## 카탈로그 에디터 검증 규칙
- columns >= 1
- rows >= 1
- frames >= 1
- frames <= columns × rows
- region.width가 columns로 나누어지는지 확인
- region.height가 rows로 나누어지는지 확인
- normalized anchor가 0.0~1.0 범위인지 확인
잘못된 값은 저장 전에 차단한다.

## Robot Editor와의 관계
카탈로그만 수정해서는 충분하지 않다.
Robot Editor의 _animated_texture()도 Columns/Rows를 사용하여 2차원 Frame Rect를 계산해야 한다.
또한 Anchor offset을 적용하여 각 Frame이 동일한 게임 기준점에 배치되도록 해야 한다.
Runtime도 같은 Visual Asset 정의를 사용해야 한다. Catalog Preview와 Runtime이 서로 다른 Frame 또는 Anchor 계산을 사용하면 불일치가 발생한다.

## 피해야 할 구현
1. frames만 18로 변경하는 방식
2. Sprite2D의 hframes/vframes만 변경하고 Catalog 메타데이터를 추가하지 않는 방식
3. Frame마다 Alpha Trim하여 서로 다른 크기의 Sprite를 만드는 방식
4. Preview TextureRect 중앙을 Anchor로 임의 사용하는 방식

## Frame별 Anchor Override
향후 필요하면 Frame별 Anchor Override를 추가할 수 있다.
그러나 1차 구현에는 권장하지 않는다.
먼저 고정 Cell + 공통 Anchor로 표준 Sprite Sheet를 처리하고, 실제 Asset에서 공통 Anchor로 해결할 수 없는 경우에만 Override를 추가한다.

## 구현 우선순위
1. VisualAssetDefinition에 columns/rows 추가
2. frame_order 추가
3. anchor 추가
4. Catalog Editor에 Grid 설정 UI 추가
5. Catalog Editor에 Anchor 설정 UI 추가
6. Catalog Preview에 Grid/Anchor 표시
7. Robot Editor의 2차원 Frame 계산
8. Robot Editor Anchor 적용
9. Legacy Asset 기본값 호환
10. 최소 Runtime 검증

## 최종 판단
CONFIRMED: 현재 Catalog에는 Rows/Columns/Frame Order/Anchor가 없다. Robot Editor Preview는 1행을 전제로 프레임을 계산한다. Region View에는 Alpha Trim이 존재한다.
INFERENCE: 2행 이상의 Sprite Sheet에서 안정적인 Animation Preview를 만들려면 단순 Grid 지원만으로 부족하며 고정 Cell과 공통 Anchor가 필요하다.
PROPOSAL: MENOS Visual Asset Sprite Sheet의 표준 메타데이터를 Region + Columns + Rows + Frames + Frame Order + Cell Anchor로 정의한다. 기본 Anchor는 BOTTOM_CENTER = normalized (0.5, 1.0)을 권장한다.

## 상태
STATUS: PASS — 조사 및 문서화 완료
CODE VERIFIED: 관련 코드 경로 확인
EDITOR VERIFIED: Catalog Editor와 Region View 구조 확인
BUILD VERIFIED: NOT VERIFIED
PIE VERIFIED: NOT VERIFIED
코드 변경: 없음
Asset 변경: 없음
다음 단계는 Master 승인 후 실제 Catalog Editor / VisualAssetDefinition / Robot Editor / Runtime 수정으로 진행한다.
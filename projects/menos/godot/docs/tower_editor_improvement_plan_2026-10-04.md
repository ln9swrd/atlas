# MENOS — Tower Editor 개선 계획

작성일: 2026-10-04
대상: `godot/editor/tower_editor.gd`
참조 기준: `godot/editor/robot_editor.gd`

## 1. 목적

현재 Tower Editor는 기본적인 애니메이션 프리뷰와 이미지 자산 점검 기능을 이미 갖고 있다.

이번 개선의 목적은 Tower Editor를 Robot Editor의 현재 Visual Asset 편집 구조와 동일한 기준으로 정렬하는 것이다.

핵심은 Tower Editor에 별도의 이미지 처리 규칙을 추가하는 것이 아니라, 이미 Robot Editor에서 검증된 다음 원칙을 Tower 슬롯에도 적용하는 것이다.

- Semantic Visual Asset ID를 슬롯의 정체성으로 사용
- Catalog를 Asset의 Source of Truth로 사용
- Sprite Atlas 메타데이터를 기반으로 프리뷰
- Image Editor와 원본 Editor 사이의 owner/context 유지
- Catalog 선택을 실제 슬롯 배정으로 취급
- 슬롯 변경 후 즉시 데이터 저장
- 편집 화면에서 Asset 상태를 검증

## 2. 현재 Tower Editor의 기준선

CONFIRMED:

현재 Tower Editor에는 다음 기능이 이미 존재한다.

- Tower 선택
- 기본 능력치 편집
- LV2 Upgrade 편집
- Sprite Animation 슬롯
- IDLE / ATTACK / HIT / DEATH 슬롯
- Projectile 슬롯
- Animation Preview
- Image Asset Management
- 이미지 존재 여부 검사
- Image Editor 진입
- Catalog에서 전달된 Asset 선택 수신

따라서 Tower Editor는 기능이 없는 상태에서 새로 만드는 대상이 아니다.

개선의 중심은 **기존 기능을 Robot Editor의 최신 Asset 구조와 연결하는 것**이다.

## 3. 우선 개선사항

### P0 — Visual Asset 기반 Sprite Atlas 프리뷰 통일

현재 Tower Editor의 `_animated_texture()`는 이미지 전체를 가로 방향으로 `total_frames`개로 나누는 방식이다.

현재 방식의 문제:

- 1행 Sprite Sheet를 전제로 한다.
- 2행 이상 Atlas를 처리하지 못한다.
- `columns` / `rows`를 사용하지 않는다.
- `frame_order`를 사용하지 않는다.
- Visual Asset의 `region`을 사용하지 않는다.
- 비균일 Cell을 표현할 수 없다.
- Catalog에 등록된 Asset 정의와 Editor 프리뷰의 해석 방식이 달라질 수 있다.

Robot Editor의 방식으로 통일해야 한다.

개선 방향:

`VisualAssetResolver.resolve()` 또는 동일한 중앙 Asset 해석 경로를 사용하여 다음 정보를 가져온다.

- source
- region
- frames
- columns
- rows
- frame_order

프레임 계산은 Tower Editor가 자체적으로 임의의 Sprite Sheet 규칙을 갖지 않고 등록된 Visual Asset 정의를 따른다.

성공 조건:

- 1행 Atlas 정상 프리뷰
- 2행 이상 Atlas 정상 프리뷰
- row_major 정상
- column_major 정상
- region이 지정된 Asset 정상
- 기존 단일 이미지 정상

### P0 — Tower 슬롯 Semantic Visual Asset ID

Robot Editor는 슬롯 자체가 Visual Asset의 정체성을 가진다.

Tower도 동일한 원칙을 적용한다.

권장 기본 ID:

- `tower.<tower>.sprite`
- `tower.<tower>.profile` 또는 `tower.<tower>.default`
- `tower.<tower>.idle`
- `tower.<tower>.attack`
- `tower.<tower>.hit`
- `tower.<tower>.death`
- `tower.<tower>.projectile`

단, 실제 Canon 슬롯 이름은 구현 전에 Tower 데이터 구조와 Runtime 사용처를 확인하고 결정한다.

중요:

Source image 경로에서 ID를 역산하지 않는다.

동일 이미지를 여러 슬롯이 공유할 수 있으므로 슬롯의 semantic identity를 기준으로 한다.

### P0 — Catalog 선택을 실제 슬롯 배정으로 처리

현재 Tower Editor의 `_apply_pending_asset_selection()`은 선택된 Asset을 LineEdit에 넣고 프리뷰를 갱신하지만 즉시 `_save_data()`하지 않는다.

Robot Editor처럼 다음 흐름으로 통일한다.

Catalog 선택
→ 해당 Tower 슬롯에 Asset ID 배정
→ 필요한 region/metadata 동기화
→ towers.json 즉시 저장
→ 프리뷰 갱신
→ 상태 표시

성공 조건:

Catalog에서 Asset을 선택하고 Tower Editor로 돌아왔을 때 별도의 SAVE 버튼을 누르지 않아도 해당 슬롯의 Asset ID가 JSON에 유지된다.

### P0 — Image Editor Context 전달 통일

현재 Tower Editor는 다음과 같이 단순 호출한다.

`IMAGE_STATE.open_image(path, target, asset_id)`

Robot Editor는 owner와 usage 정보를 포함한 Context를 전달한다.

Tower도 다음 정보를 전달하도록 개선한다.

- owner_kind = tower
- owner_key = selected_type
- usage = 현재 슬롯
- frames = 현재 Asset의 frame count
- return_scene = `res://editor/tower_editor.tscn`

예:

`tower.<tower>.idle`

이 방식으로 Image Editor가 어느 Tower의 어느 슬롯에서 호출됐는지 명확히 유지한다.

### P1 — 빈 슬롯에서도 Catalog 선택 가능

현재 Tower Editor의 `_open_image_editor_for_target()`은 이미지 경로가 비어 있으면 중단한다.

Robot Editor의 현재 설계는 Select Asset 자체를 Catalog 진입점으로 사용한다.

따라서 Tower에서도:

빈 슬롯
→ Select Asset
→ Catalog Editor
→ Asset 선택
→ 해당 슬롯 배정

흐름을 허용하는 것이 적절하다.

이 변경으로 새 이미지를 먼저 직접 입력해야 하는 불필요한 순서를 제거한다.

### P1 — Preview / Thumbnail 해석 경로 통합

현재 Tower Editor에는 자체적인 `_animated_texture()`와 파일 Thumbnail 로딩이 존재한다.

개선 후에는 다음 원칙을 적용한다.

- Catalog Thumbnail
- 슬롯 Thumbnail
- Animation Preview
- 기본 Preview

가능한 범위에서 동일한 Visual Asset metadata 해석 경로를 사용한다.

목표는 같은 Asset이 Catalog에서는 한 방식, Tower Preview에서는 다른 방식으로 보이는 문제를 제거하는 것이다.

### P1 — Animation Preview 범위 확장

현재 Tower에는:

- IDLE
- ATTACK
- HIT
- DEATH

가 있다.

Tower Runtime에 실제 MOVE 또는 기타 상태가 존재한다면 추가할 수 있지만, Runtime에서 사용하지 않는 슬롯은 Editor에 임의로 추가하지 않는다.

원칙:

**Runtime 계약 확인 → 필요한 슬롯만 노출**

이는 Scope 확장을 방지하기 위한 것이다.

## 4. P2 — Asset 상태 검증 강화

현재 Image Asset Management는 파일 존재 여부를 검사한다.

Robot Editor 기준으로 한 단계 더 나아가 다음을 검증하는 것을 권장한다.

- Asset ID 존재 여부
- Source 존재 여부
- Region 유효 여부
- Frame count 유효 여부
- Columns × Rows와 Frames의 일관성
- 선택 슬롯과 Asset usage의 일치 여부

예:

`Frames = 12, Columns = 4, Rows = 3`

이면 12프레임 Atlas로 정상.

반면:

`Frames = 13, Columns = 4, Rows = 3`

이면 명시적인 경고가 필요하다.

단, 비균일 Cell이 허용되는 최종 Visual Asset 구조가 확정되면 검증 규칙은 그 Canon에 맞춰야 한다.

## 5. P2 — 저장 상태와 Editor 상태 분리

현재 Tower Editor의 직접적인 LineEdit 변경은 저장 전까지 UI 상태에 머무른다.

다음 상태를 구분하는 것이 좋다.

- EDITED — UI 값이 변경됨
- ASSIGNED — Catalog Asset이 슬롯에 배정됨
- SAVED — JSON에 반영됨
- INVALID — Asset 또는 데이터가 잘못됨

특히 Catalog 선택은 Robot Editor와 동일하게 ASSIGNED + SAVED까지 한 번에 처리한다.

일반 수치값 변경은 기존 SAVE JSON 흐름을 유지한다.

## 6. P3 — Tower Profile / Team Color 여부

Robot Editor에는 Profile Visual Asset과 Team Color Shader가 존재한다.

Tower에도 팀 색상이 필요한지는 Runtime 계약을 먼저 확인해야 한다.

현재 문서에서는 Tower에 Robot의 Team Color Shader를 무조건 복제하지 않는다.

다음 조건을 모두 만족할 경우에만 별도 설계를 진행한다.

1. Tower Runtime이 팀 색상을 실제로 요구함
2. 현재 Tower Asset으로 구분할 수 없음
3. 기존 Shader로 대체할 수 없음
4. Master가 범위를 승인함

따라서 현재는 OUT OF SCOPE로 둔다.

## 7. 구현 순서

1. Tower Runtime이 실제 사용하는 이미지/애니메이션 슬롯 확인
2. Tower Visual Asset 등록 현황 확인
3. Tower semantic slot ID Canon 제안
4. Robot Editor의 Visual Asset 프레임 해석 로직 재사용
5. Tower Preview를 Visual Asset metadata 기반으로 변경
6. Image Editor Context 연결
7. Catalog 선택 즉시 저장
8. 빈 슬롯 Catalog 진입 지원
9. Asset 상태 검증 강화
10. 최소 GUI 검증

한 단계씩 변경하며 각 단계 후 Diff를 확인한다.

## 8. 금지사항

이번 개선에서 다음 작업은 자동으로 수행하지 않는다.

- 기존 Tower Asset 삭제
- 이미지 재생성
- Sprite Sheet 변환
- JSON 전체 재작성
- Runtime Tower 로직 변경
- Shader 신규 제작
- 불필요한 Animation 슬롯 추가
- 기존 Asset ID의 일괄 변경
- Commit / Push

특히 기존 Asset ID가 이미 Runtime이나 Catalog에서 사용되고 있다면 Migration 없이 변경하지 않는다.

## 9. 최소 검증 기준

### CODE VERIFIED

Tower Editor가 Godot 4.7.2에서 오류 없이 로드된다.

### EDITOR VERIFIED

다음 동작을 실제 Editor에서 확인한다.

1. Tower 선택
2. 기존 단일 이미지 프리뷰
3. 1행 Atlas 프리뷰
4. 2행 이상 Atlas 프리뷰
5. Catalog Asset 선택
6. Tower 슬롯 배정
7. Editor 재진입
8. JSON 값 유지
9. Image Editor 진입 후 Tower Editor 복귀

### BUILD VERIFIED

프로젝트 Build/Headless Editor 로드 성공.

### PIE VERIFIED

Tower Runtime에서 실제 사용되는 Asset 경로가 변경된 경우에만 수행한다.

Editor 전용 변경이라면 PIE VERIFIED는 필수 조건으로 만들지 않는다.

## 10. 성공 조건

다음 조건을 만족하면 개선 완료로 판단한다.

- Tower Preview가 Visual Asset Catalog와 동일한 Atlas 해석 결과를 사용한다.
- 2행 이상 Sprite Atlas가 정상 프리뷰된다.
- Tower 슬롯의 Visual Asset ID가 semantic identity를 가진다.
- Catalog 선택 결과가 해당 Tower 슬롯에 정확히 저장된다.
- Image Editor 왕복에서 Tower/slot context가 유지된다.
- 기존 Tower 데이터와 Asset이 손상되지 않는다.

## 11. 진행 결과

### IMPLEMENTED

이번 단계에서 결정 없이 적용 가능한 P0 개선을 Tower Editor에 반영했다.

- Visual Asset metadata 기반 Animation Preview
- 2행 이상 Atlas Preview
- row_major / column_major 지원
- frame_regions 기반 비균일 Cell Preview
- Catalog 선택 즉시 저장
- Asset region의 `<field>_rect` 동기화
- Image Editor의 Tower owner/context 전달
- 빈 슬롯의 Catalog 진입 허용
- JSON 저장 후 재읽기 검증

### VERIFIED

- Godot 4.7.2 프로젝트 Editor 초기화 성공
- Unit Editor scene 로드 성공
- Tower Editor scene 로드 성공
- `git diff --check` 기준 whitespace 오류 없음

### HOLD — MASTER DECISION REQUIRED

Tower의 Semantic Visual Asset ID를 실제 Catalog Canon으로 도입하는 것은 아직 보류한다.

현재 `visual_assets.json`에는 `tower.*` Semantic Asset이 존재하지 않는다.
따라서 지금 임의로 `tower.<tower>.<usage>` ID를 JSON에 기록하면 기존 Tower Runtime의 Asset 계약과 Catalog 구조를 동시에 변경하게 된다.

결정이 필요한 질문은 하나다.

**Tower도 Robot과 동일하게 `tower.<tower>.<usage>`를 정식 Visual Asset ID Canon으로 채택할 것인가?**

채택하면 다음 단계에서 기존 Tower image source를 Catalog에 semantic slot으로 등록하고 Tower JSON을 해당 ID로 migration하는 작업이 필요하다.

채택하지 않으면 현재처럼 기존 Tower JSON source/legacy reference를 유지하면서 Editor Preview만 Visual Asset metadata를 사용하는 구조로 종료할 수 있다.

## 13. 판정

STATUS: HOLD

현재 조사만으로도 Robot Editor를 기준으로 Tower Editor를 개선할 기술적 방향은 명확하다.

가장 중요한 개선은 **Sprite Atlas 해석을 Tower Editor 자체 규칙에서 Visual Asset Catalog 기준으로 통일하는 것**이다.

그 다음 우선순위는 **semantic Asset ID + 즉시 저장 + Image Editor context 통일**이다.

Team Color나 Runtime 기능 확장은 현재 범위에 포함하지 않는다.

## 14. 다음 작업 조건

Master가 구현을 승인한 경우에만 다음 단계로 진행한다.

완료된 P0 항목:

1. Visual Asset 기반 Atlas Preview
2. Catalog 선택 즉시 저장
3. Image Editor Context

보류된 P0 항목:

1. Tower semantic slot ID Canon 결정 및 migration

위 결정이 내려지기 전에는 추가 Tower Asset migration을 수행하지 않는다.
문서 목적과 현재 안전 범위의 구현을 완료했으므로 여기서 HOLD한다.

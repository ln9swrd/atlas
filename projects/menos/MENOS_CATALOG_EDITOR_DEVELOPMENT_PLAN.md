# MENOS Catalog Editor Development Plan

> 작성일: 2026-10-06
> 상태: PROPOSAL — Master 승인 후 순차 실행
> 목적: MENOS Catalog Editor를 단일 이미지와 Sprite Sheet를 안전하게 편집하고, Visual Asset의 Frame/Anchor/Team Mask/Variant를 일관되게 관리할 수 있는 제작 도구로 완성한다.

## 1. 범위

본 계획의 대상은 다음이다.

- Catalog Editor / Image Editor
- Visual Asset 정의와 편집 결과 연결
- 단일 이미지와 Sprite Sheet 편집
- Frame/Region/Anchor 보존
- 색상 샘플링/투명화/색상 치환/Alpha 처리
- Team Mask 생성 및 연결
- Preview / Apply / Save / Validation
- Variant 및 작업 Recipe 관리

다음은 본 계획의 범위가 아니다.

- 전투 규칙 변경
- Runtime Shader 자체의 신규 설계
- 게임의 팀 색상 Canon 결정
- 대규모 신규 Asset 제작
- 기존 원본 Asset 삭제/대체
- SQLite 콘텐츠 전환
- Commit / Push

## 2. 현재 기준선

- Project: MENOS
- Branch: main
- HEAD: `be074c5db35b7c4d548a24cf448b404463e5fe6d`
- Godot: 4.7.2.stable.official.ed1daf0bf
- Project root: `D:\\Atlas\\projects\\menos\\godot`
- Working Tree:
  - `M godot/content/menos.sqlite` — 기존 Robot SQLite 작업
  - `M godot/editor/asset_region_view.gd` — 기존 Eyedropper 작업
  - `M godot/editor/image_editor.gd` — 기존 이미지 편집 기능 작업
  - `?? godot/addons/godot-sqlite/bin/~libgdsqlite.windows.template_debug.x86_64.dll~RF81adb69f.TMP` — 미확인 임시 파일
  - `?? godot/images/Gemini_Generated_Image_mzsakimzsakimzsa.png` — 미확인 Asset
- 위 기존 변경사항과 미확인 파일은 본 계획 작성에서 수정/삭제하지 않는다.
- Commit / Push는 수행하지 않는다.

## 3. 현재 구현 상태

### CONFIRMED — 완료된 이미지 편집 기반

현재 Image Editor에는 다음 기능이 구현되어 있다.

1. Background Color Eyedropper
2. 선택 색상 → 투명
3. 선택 색상 → 다른 색상 치환
4. 선택 색상 → 지정 Alpha 적용
5. Tolerance
6. Edge-connected only

Eyedropper는 이미지 영역에서 실제 픽셀을 샘플링한다.

Color Replace와 Team Alpha 처리는 기존 Edge-connected 규칙을 유지하면서 전체 이미지의 매칭 픽셀 또는 연결된 영역을 처리한다.

### CONFIRMED — 기존 Visual Asset 구조

`VisualAssetDefinition`에는 다음 관련 데이터가 존재한다.

- id
- category
- source
- region
- frames
- columns / rows
- frame_order
- anchor_mode
- anchor_x / anchor_y
- owner_id
- usage
- team_mask_source
- frame_regions
- frame_anchors

따라서 Frame/Anchor/Team Mask를 위한 기존 데이터 기반을 우선 재사용한다.

### CONFIRMED — Robot Editor 연결

Robot Editor는 Image Editor와 Visual Asset 선택을 연결하는 기존 경로를 가지고 있다.

- Image Editor에서 Asset 선택
- pending asset selection 소비
- Visual Asset resolver 갱신
- Asset ID / region 반영
- Robot 데이터 저장

따라서 새 Catalog Editor 구조는 이 연결을 깨지 않는 것을 전제로 한다.

## 4. 설계 원칙

### 4.1 원본 보존

원본 Sprite Sheet / Source Image는 직접 덮어쓰지 않는다.

기본 흐름:

```
Source
  ↓
Edit / Recipe
  ↓
Preview
  ↓
Validate
  ↓
Variant / Mask 저장
  ↓
Visual Asset 연결
```

### 4.2 Asset 정의와 이미지 편집 분리

Catalog Editor는 Visual Asset의 메타데이터를 관리하고 Image Processor는 실제 픽셀 작업을 담당한다.

권장 구조:

```
Catalog Editor UI
      ↓
Visual Asset
      ↓
Image Processing
      ↓
Preview / Result
      ↓
Validation
      ↓
Save
```

### 4.3 Sprite Sheet는 Frame 기준으로 처리

전체 PNG를 하나의 그림으로만 취급하지 않는다.

지원 범위:

- Entire Image
- Selected Frame
- All Frames
- 필요 시 Selected Region

Frame 처리는 기존 `frame_regions`를 우선 사용한다.

### 4.4 Team Color는 일반 Replace와 분리

일반 색상 변경:

```
Source → Pixel Replacement → Variant
```

팀 색상:

```
Source → Team Mask → Runtime Team Color
```

Team Color를 원본 픽셀의 실제 RGB 교체로만 해결하지 않는다.

### 4.5 Runtime 책임 분리

Editor:

- Team Mask 생성/검증
- Visual Asset 연결

Runtime:

- Team Mask 기반 Team Color 적용

게임의 팀 색상 규칙과 Shader 최종 구현은 별도 범위로 유지한다.

## 5. 목표 UI

Image Editor는 다음 개념을 지원하는 방향으로 확장한다.

```
Image / Sprite Sheet Preview

Background
  Color       [ColorPicker] [Eyedropper]
  Tolerance   [0.08]
  [Remove Background]

Replace
  Color       [ColorPicker]
  [Replace Color]

Team
  Alpha       [1.00]
  [Set Team Alpha]

Scope
  ( ) Entire Image
  ( ) Selected Frame
  ( ) All Frames

Team Mask
  [Create / Update Mask]

Preview
  [Original] [Result] [Mask]
```

정확한 UI 배치는 기존 Editor 레이아웃과 실제 사용성을 확인한 뒤 결정한다.

## 6. 개발 단계

### CED-0 — 기준선 / 구조 조사

목적:
현재 Catalog Editor와 Visual Asset 구조를 보호하면서 실제 수정 지점을 확정한다.

조사:
- HEAD / Branch / Working Tree
- image_editor.gd
- asset_region_view.gd
- visual_asset_definition.gd
- visual_asset_resolver.gd
- robot_editor.gd
- 관련 TSCN
- visual_assets.json

성공 조건:
- 수정 대상 파일과 보존 대상이 명확하다.
- 기존 Asset ID / Region / Anchor 경로를 확인한다.

검증:
- CODE VERIFIED

판정:
PASS → STOP

### CED-1 — 편집 범위 모델

목적:
단일 이미지와 Sprite Sheet를 같은 처리 엔진으로 안전하게 다룬다.

작업:
- Entire Image
- Selected Frame
- All Frames
- 기존 frame_regions 활용
- Frame 외부 영역 보호
- Frame 수/Region 유효성 검사

성공 조건:
- 선택 범위에 속한 픽셀만 변경된다.
- Frame Region / Anchor / Order는 변경되지 않는다.

검증:
- CODE VERIFIED
- 최소 이미지 처리 테스트

### CED-2 — 공통 Image Processing 계층

목적:
UI 코드에 픽셀 처리 로직이 과도하게 집중되지 않도록 분리한다.

작업:
- Sample
- Transparent
- Replace Color
- Set Alpha
- Tolerance
- Edge-connected
- Frame batch 처리

원칙:
동일한 처리 함수가 Single Frame과 All Frames에서 사용되어야 한다.

성공 조건:
- 동일 입력 + 동일 Recipe에서 재현 가능한 결과가 나온다.
- UI와 픽셀 처리 로직을 독립적으로 검증할 수 있다.

### CED-3 — Preview / Apply / Save

목적:
대량 변경을 실제 파일에 바로 적용하는 위험을 제거한다.

작업:
- Original Preview
- Result Preview
- Zoom / Pixel 확인
- 변경 픽셀 수 표시
- 0 pixel 변경 경고
- 비정상적으로 큰 변경량 경고
- Apply
- Save
- Discard

성공 조건:
- Preview 단계에서는 Source가 변경되지 않는다.
- Save 후 결과 파일을 다시 열어 검증할 수 있다.
- 미저장 변경 상태를 구분할 수 있다.

### CED-4 — Variant 관리

목적:
원본을 보존하면서 편집 결과를 재사용 가능한 Asset으로 관리한다.

작업:
- Source / Generated / Mask 구분
- Variant 저장 규칙
- Asset ID와 파일 경로 분리
- 중복 Variant 방지
- Source 변경 시 stale 판정
- Generated Asset의 재귀적 Source 사용 방지

권장 관계:

```
Source + Recipe → Variant
```

Variant를 다시 Source로 삼는 구조는 기본적으로 허용하지 않는다.

### CED-5 — Team Mask

목적:
Sprite Sheet의 팀 색상 영역을 별도 Mask Asset으로 관리한다.

작업:
- 원본과 동일한 크기의 Mask Sheet 생성
- Frame Region 정합성 유지
- grayscale/alpha 기반 강도 표현
- Selected Frame / All Frames 생성
- Mask Preview
- Mask와 Source 크기/Frame 수 검증
- `team_mask.source` 연결

Mask 의미:

```
0.0 = 적용 안 함
0.5 = 부분 적용
1.0 = 전체 적용
```

성공 조건:
- Source와 Mask의 픽셀 좌표가 일치한다.
- Frame 수/Region이 불일치하면 저장을 거부한다.
- 기존 Visual Asset의 Team Mask 경로와 호환된다.

### CED-6 — Visual Asset 연결

목적:
생성된 Variant / Team Mask가 실제 Catalog Asset 정의와 연결되도록 한다.

작업:
- Asset ID 연결
- Source 연결
- Region / Frame 정보 유지
- Anchor 유지
- Team Mask 연결
- Robot Editor 등 기존 Editor 소비 경로 확인

성공 조건:
- Catalog에서 선택한 Asset이 올바른 Source/Region/Mask를 가리킨다.
- 기존 Robot Editor의 Asset 선택 흐름이 깨지지 않는다.

검증:
- CODE VERIFIED
- EDITOR VERIFIED

### CED-7 — Validation

목적:
Asset 제작 과정에서 흔한 오류를 자동 검출한다.

검사:
- Source 존재
- Source 포맷
- Region이 이미지 범위 내인지
- Frame 수/Region 수 일치
- Anchor 유효성
- Mask 존재
- Mask 크기 일치
- Mask Frame 정합성
- Asset ID 중복
- Variant Source 관계
- Catalog 경로 유효성

결과 상태:

```
VALID
STALE
BROKEN
```

### CED-8 — Recipe / 재현성

목적:
편집 결과를 다시 생성할 수 있도록 작업 조건을 기록한다.

Recipe 최소 정보:

```
source
operation
target_color
replacement_color
tolerance
edge_connected
scope
team_alpha
algorithm_version
```

성공 조건:
- 동일 Source와 동일 Recipe에서 동일 결과를 재생성할 수 있다.
- Source가 변경되면 기존 결과의 stale 여부를 판단할 수 있다.

Recipe 저장 방식은 구현 시 기존 Catalog 데이터 구조와 충돌 여부를 확인한 뒤 결정한다.

### CED-9 — Batch / 안정성

목적:
All Frames 및 향후 여러 Asset 처리를 안전하게 수행한다.

작업:
- 진행률 표시
- Cancel
- 임시 파일 처리
- Atomic Save
- 부분 성공 방지
- 실패 프레임 기록
- 저장 후 재오픈 검증

성공 조건:
- 중간 실패가 최종 Asset에 부분 반영되지 않는다.
- 작업 취소가 원본을 변경하지 않는다.

### CED-10 — 최종 Acceptance

최소 검증 세트:

1. 단일 삼면도 색상 샘플링
2. 배경 투명화
3. 색상 치환
4. Alpha 적용
5. Sprite Sheet Selected Frame
6. Sprite Sheet All Frames
7. Frame 경계 보호
8. Anchor 보존
9. Team Mask 생성
10. Mask/Source 정합성 검사
11. Variant 저장
12. Catalog 재로드
13. Robot Editor Asset 선택
14. 잘못된 Asset/Mask 오류 검출

PIE가 필요한 Runtime Team Color 동작은 별도 Master 확인으로 분리한다.

## 7. 우선순위

### P0 — 반드시 필요한 기반

- 원본 보존
- Scope: Entire / Selected Frame / All Frames
- Frame Region 처리
- 공통 Image Processing
- Preview / Apply / Save
- Source/Result 분리
- 기본 Validation

### P1 — 제작 파이프라인 완성

- Variant 관리
- Team Mask
- Visual Asset 연결
- Mask/Frame 정합성
- Undo/Discard
- Dirty 상태
- 저장 후 재검증

### P2 — 유지보수/확장

- Recipe
- Source Hash
- stale 감지
- Batch progress/cancel
- 작업 결과 통계
- 참조 검색
- 최근 색상
- 고급 Preview

### P3 — 향후 확장

- Palette Swap
- Primary/Secondary/Accent 다중 Mask
- 여러 Visual Asset 일괄 처리
- Material/Emissive Mask
- 복합 Runtime Tint

P2/P3는 P0/P1 성공 후에도 실제 필요성이 확인될 때만 진행한다.

## 8. 데이터 정책

### Source

원본 제작 Asset. 직접 수정하지 않는다.

### Variant

Recipe에 의해 생성된 결과 Asset. Runtime에서 사용할 수 있다.

### Team Mask

Team Color 적용 영역을 나타내는 별도 Asset.

### Visual Asset

Source/Variant/Mask와 Frame/Region/Anchor를 연결하는 정의.

### Recipe

Variant 또는 Mask를 재생성하기 위한 작업 정의.

## 9. 중요한 기술 조건

### Alpha

완전 투명 픽셀의 RGB를 어떻게 처리할지는 실제 Runtime sampling 특성을 확인한 뒤 확정한다.

### Anti-aliasing

경계 픽셀은 RGB + Alpha를 함께 고려한다. 단순 RGB 교체만으로 halo가 발생하지 않는지 검증한다.

### Texture Filtering

Sprite Sheet 인접 Frame의 색이 섞이지 않도록 Region/Atlas padding 및 Godot texture filtering 설정을 확인한다.

### Color Space

Editor의 픽셀 비교와 Runtime의 색 처리 기준이 불필요하게 달라지지 않도록 한다. 실제 프로젝트 설정을 확인하기 전에는 특정 color-space 변환을 Canon으로 확정하지 않는다.

### Frame Transform

Flip/Rotation이 필요한 경우 Source와 Mask가 동일한 변환을 받도록 한다. 현재 요구사항에 없는 기능은 구현하지 않는다.

## 10. 안전성 규칙

- 기존 Source 삭제 금지
- 기존 Asset ID 임의 변경 금지
- 기존 Frame Region 임의 재계산 금지
- 기존 Anchor 임의 변경 금지
- 미확인 Asset 자동 삭제 금지
- 다른 Editor의 데이터 구조 임의 변경 금지
- 대규모 Asset 변환 금지
- 외부 Asset 추가 금지
- Commit / Push 금지

변경 전:
- HEAD
- Branch
- Working Tree
- 관련 Asset

확인.

변경 후:
- Diff
- 파일 존재
- 데이터 유효성
- 최소 기능 검증

확인.

## 11. 검증 상태 정의

- CODE VERIFIED — 실제 코드 경로 확인
- EDITOR VERIFIED — 실제 Catalog/Visual Asset Editor 동작 확인
- BUILD VERIFIED — 실제 Build 성공
- PIE VERIFIED — Master가 실제 Runtime 결과 확인
- NOT VERIFIED — 아직 확인하지 않음

Headless check 성공만으로 EDITOR 또는 PIE VERIFIED를 선언하지 않는다.

## 12. 현재 작업의 판정

현재 구현된 Eyedropper / Replace Color / Team Alpha는 이 계획의 기반 기능으로 인정한다.

다음 실제 구현 작업은 **CED-1 — 편집 범위 모델**이다.

단, 본 문서 작성 자체는 CED-1 구현을 시작하지 않는다.

### 현실성

- TECHNICALLY POSSIBLE
- PRACTICALLY FEASIBLE
- RECOMMENDED: 기존 `frame_regions`, `team_mask_source`, Visual Asset Resolver를 재사용하는 단계적 구현
- BUSINESS VIABLE: 본 계획에서는 판단하지 않음

## 13. 완료 정의

이 계획의 1차 목표는 "완성형 Photoshop 대체 도구"가 아니다.

다음이 가능하면 Catalog Editor의 핵심 목적을 달성한 것으로 본다.

1. 원본 Asset을 보존한다.
2. 단일 이미지와 Sprite Sheet를 동일한 편집 체계로 처리한다.
3. 특정 Frame 또는 모든 Frame에 동일한 작업을 적용한다.
4. Frame/Region/Anchor를 보존한다.
5. 결과를 Preview하고 명시적으로 저장한다.
6. Variant를 Catalog에서 관리한다.
7. Team Mask를 Source와 정합되게 생성/관리한다.
8. 잘못된 Asset/Mask 관계를 자동 검출한다.
9. 기존 Robot/Visual Asset Editor 연결을 유지한다.
10. 성공 후 추가 기능을 자동으로 확장하지 않고 STOP한다.

## 14. 상태

**IMPLEMENTATION PARTIAL / APP-6 HOLD**

2026-10-06 기준 Catalog Editor 개발계획의 핵심 P0/P1 구현은 실제 코드에 반영되었다. 다만 최종 Acceptance에 필요한 Catalog Save/Reopen, Animation 시각 검증, PIE Team Color 시각 검증은 아직 확인하지 않았으므로 전체 완료로 선언하지 않는다.

본 문서는 개발계획과 실제 구현/검증 상태를 함께 기록한다. 추가 기능은 Master의 별도 지시 없이 확장하지 않는다.

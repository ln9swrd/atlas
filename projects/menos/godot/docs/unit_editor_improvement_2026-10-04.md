# MENOS Unit Editor 개선사항

작성일: 2026-10-04
대상: `godot/editor/unit_editor.gd`
참조 기준: `godot/editor/robot_editor.gd`

## 1. 목적

Unit Editor를 현재 Robot Editor의 편집 흐름과 시각적 검증 수준에 맞추되, 기존 Unit/Enemy JSON 데이터 구조와 Runtime 계약은 유지한다.

핵심 목표는 다음과 같다.

- Sprite Atlas의 다행/다열 프레임을 Editor에서 동일한 방식으로 미리보기
- Unit의 이미지 자산 상태를 편집 화면에서 즉시 확인
- Image Editor와 Unit Editor 사이의 선택 컨텍스트를 명확하게 전달
- Catalog에서 선택한 Asset의 슬롯 배정을 즉시 저장
- 프리뷰 Shader 상태를 일관되게 유지

## 2. 적용한 개선사항

### 2.1 애니메이션 프리뷰

기존 Unit Editor에는 애니메이션 슬롯 입력만 있고 Robot Editor와 같은 실시간 애니메이션 프리뷰가 없었다.

다음 기능을 추가했다.

- IDLE
- MOVE
- ATTACK
- HIT
- DEATH

각 슬롯에 90x120 프리뷰 영역을 제공한다.

0.12초 주기의 Timer로 프레임을 순환한다.

### 2.2 다행 Sprite Atlas 지원

Robot Editor의 Visual Asset 해석 방식을 Unit Editor 프리뷰에도 적용했다.

Visual Asset이 존재하면 다음 메타데이터를 사용한다.

- source
- frames
- columns
- rows
- frame_order
- region

따라서 단일 행뿐 아니라 2행 이상의 Sprite Atlas도 등록된 Visual Asset 메타데이터에 따라 프리뷰할 수 있다.

프레임 순서는 row_major와 column_major를 지원한다.

### 2.3 Profile/Sprite 프리뷰 개선

Profile Image가 비어 있는 경우 Sprite를 fallback으로 사용한다.

기존 `sprite_rect`가 있고 Visual Asset 자체에 region이 없는 경우에는 `sprite_rect`를 적용한다.

Preview Shader는 Material이 이미 존재하더라도 매 갱신 시 Unit Shader를 명시적으로 다시 지정하도록 변경했다.

### 2.4 Image Asset Management

Robot Editor의 이미지 자산 점검 흐름을 Unit Editor에도 추가했다.

현재 선택된 Unit에 대해 다음 자산을 점검한다.

- Sprite
- Profile Image
- Projectile
- IDLE
- MOVE
- ATTACK
- HIT
- DEATH

필수 자산과 선택 자산을 구분하고 다음 상태를 표시한다.

- OK
- MISSING
- EMPTY

현재 기준 필수 자산은 Sprite이며, IDLE과 ATTACK이 명시적으로 등록된 경우에는 해당 애니메이션도 필수 자산으로 표시한다.

### 2.5 Image Editor 컨텍스트 전달

Unit Editor에서 Image Editor를 열 때 다음 컨텍스트를 전달한다.

- owner_kind = unit
- owner_key = 선택된 Unit ID
- usage = 현재 슬롯
- frames = 현재 Visual Asset의 프레임 수
- return_scene = res://editor/unit_editor.tscn

이로써 Robot Editor와 같은 방식으로 원본 편집 대상의 소유자와 용도를 명확히 전달한다.

### 2.6 Catalog Asset 선택 즉시 저장

Catalog에서 Asset을 선택하고 Unit Editor로 돌아온 경우 단순히 UI 필드만 변경하지 않고 즉시 `_save_data()`를 수행하도록 변경했다.

따라서 선택한 Asset은 Robot Editor와 동일하게 해당 Unit/Enemy JSON에 바로 저장된다.

## 3. 변경하지 않은 영역

다음 영역은 이번 작업 범위에 포함하지 않았다.

- Unit/Enemy JSON 스키마 재설계
- Visual Asset Catalog의 Unit 전용 semantic ID 체계 신설
- allied_unit_color.gdshader 자체 수정
- Runtime Unit 렌더링 코드 수정
- Unit/Enemy Asset 자체 생성 또는 변환
- Commit / Push

## 4. 검증

### CODE VERIFIED

`unit_editor.gd` 변경 후 Godot 4.7.2 프로젝트 Editor 초기화 및 스크립트 로딩을 확인했다.

### BUILD VERIFIED

Godot 4.7.2 headless 실행에서 프로젝트 초기화가 정상 완료되었다.

### EDITOR VERIFIED

`res://editor/unit_editor.tscn`을 Godot 4.7.2 headless 환경에서 실제 씬으로 로드했으며 exit code 0으로 종료되었다.

이는 Unit Editor 씬과 스크립트가 로드 가능한 상태임을 확인한다.

실제 GUI에서 프리뷰 프레임 변화, 버튼 클릭, Catalog 왕복 동작은 별도 화면 검증이 필요하다.

### PIE VERIFIED

해당 없음. 이번 작업은 Editor 기능 개선이며 실제 게임 Runtime 검증은 수행하지 않았다.

## 5. 현재 판정

STATUS: PASS

목적 충족: Robot Editor를 기준으로 Unit Editor의 이미지/애니메이션 편집 검증 기능을 강화했다.

현실성 판단:

- TECHNICALLY POSSIBLE: CONFIRMED
- PRACTICALLY FEASIBLE: CONFIRMED
- RECOMMENDED: 현재 Editor 구조에 적합
- BUSINESS VIABLE: 프로젝트 내부 Editor 생산성 향상 범위에서 판단 가능

## 6. 미확인 사항

- 실제 GUI에서 2행 이상 Atlas가 프리뷰와 정확히 일치하는지
- 실제 Catalog 선택 후 Unit JSON 재로드까지 값이 유지되는지
- Unit Shader의 색상 적용이 모든 Unit Asset에서 의도한 결과인지

위 항목은 현재 코드/씬 로드 검증만으로는 PIE/GUI 결과까지 확정할 수 없다.

## 7. 변경 파일

- `godot/editor/unit_editor.gd`
- `godot/docs/unit_editor_improvement_2026-10-04.md`

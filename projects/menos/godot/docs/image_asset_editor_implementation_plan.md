# MENOS Image / Asset Editor 개선 구현 계획

## 1. 목적

Image Editor가 단순 이미지 편집기인지 카탈로그 관리 도구인지 구분하기 어려운 현재 UX를 정리한다.

목표는 Unit / Robot / Tower / Map / Enemy가 이미 사용하는 서로 다른 데이터 카탈로그를 유지하면서, 사용자는 하나의 Asset Browser에서 이미지와 이미지 영역을 찾고 선택할 수 있게 만드는 것이다.

핵심 원칙:
- 물리적 JSON 카탈로그를 하나로 합치지 않는다.
- Source Image와 게임 정의(Game Definition)를 구분한다.
- Sprite Sheet의 Region / Frame Count를 향후 독립적인 Visual Asset 개념으로 취급할 수 있도록 구조를 준비한다.
- 기존 콘텐츠 JSON의 호환성을 우선한다.
- 기존 작업 파일을 임의로 되돌리거나 덮어쓰지 않는다.

## 2. 현재 기준선

확인된 편집기:
- Map Editor
- Stage Editor
- Unit Editor
- Robot Editor
- Tower Editor
- Image Editor
- Asset Catalog Editor

확인된 주요 카탈로그/정의 파일:
- `content/editor/asset_catalog.json`
- `content/allied_units/allied_units.json`
- `content/enemies/enemies.json`
- `content/towers/towers.json`
- `content/robots/robots.json`
- `content/stages/stage_catalog.json`

현재 Image Editor는 연결 이미지 스캔, 이미지 편집, 다른 이미지에서 교체, Asset Catalog 등록, 참조 점검을 한 화면에서 처리한다.

## 3. 구현 단계

### Phase 0 — 문서화 / 기준선 확인
- 현재 Git HEAD / Branch / Working Tree 확인
- Image / Asset / Unit / Robot / Tower / Map Editor 구조 확인
- 기존 변경사항 보호

### Phase 1 — Image Editor를 Asset Browser 중심 UX로 정리
- 제목과 안내 문구를 Asset Browser 중심으로 변경
- 유형 필터: 전체 / Map / Unit / Robot / Tower / Enemy / Runtime
- 검색: 이름 / 경로 / 용도 기준
- 목록에 Asset 유형과 사용처를 명시
- 선택된 항목의 Source / Owner / Field / Usage 정보를 별도 표시
- 기존 이미지 편집 기능은 유지
- 기존 JSON 구조 및 저장 방식은 변경하지 않음

### Phase 2 — 다른 Editor와 선택 흐름 통합
- Unit / Robot / Tower의 이미지 선택을 Asset Browser 호출 중심으로 통합
- `Select Asset` → Asset Browser → `Use Selected` → 원래 Editor 복귀 흐름을 만든다.
- 현재 Image Editor 직접 진입 방식과 FileDialog 방식을 단계적으로 대체한다.

### Phase 3 — Visual Asset / Region 표준화
Source Image:
- 실제 PNG/JPG/WEBP/SVG 파일

Visual Asset:
- source path
- region
- frame count
- 필요 시 fps / pivot 등

Game Definition:
- Unit / Robot / Tower가 Visual Asset을 참조

예시 개념:
`robot.valkyrie.attack` → source + region + frame_count

이 단계에서는 기존 JSON과의 호환 전략을 먼저 확정한 뒤 변경한다.

### Phase 4 — Owner / Dependency 탐색
- Used By 표시
- Owner Editor 열기
- 같은 Source가 여러 정의에서 사용되는 경우 모든 참조 표시
- Source 교체 시 영향 범위를 미리 표시

## 4. 안전 원칙

- 삭제 / 덮어쓰기 / Asset 변환은 별도 승인 없이 수행하지 않는다.
- 기존 변경사항을 수정하지 않는다.
- 구현 후 diff와 Godot parse/build 검증을 수행한다.
- 기능적으로 필요한 최소 범위만 먼저 구현한다.

## 5. 결정이 필요한 지점

Master가 제안을 수용했으므로 Phase 2의 공통 선택 UX를 진행한다.

이번 단계의 Canon:
- Asset Browser는 Unit / Robot / Tower의 공통 Asset 선택 UI로 사용한다.
- 선택 결과는 기존 Editor가 기존 JSON 구조에 저장한다.
- 기존 이미지 경로 데이터는 유지한다.
- Visual Asset의 영속 데이터 모델은 아직 변경하지 않는다.

다음 결정 지점은 Sprite Sheet Region / Frame Count를 독립 Visual Asset으로 승격할지 여부다.

## 6. 현재 판정

Phase 1 + Phase 2 공통 선택 흐름을 구현 대상으로 확정했다.
Phase 3의 Visual Asset 데이터 모델은 별도 결정 전까지 HOLD한다.

## 7. Phase 1 진행 결과

### CONFIRMED
- Image Editor의 명칭을 `Asset Browser / Image Editor`로 변경했다.
- Asset 목록에 `전체 / Map / Unit / Robot / Tower / Enemy / Runtime` 필터를 추가했다.
- 이름 / 경로 / 용도 / Owner 경로를 대상으로 검색할 수 있게 했다.
- 선택 Asset에 Category / Usage / Source / Owner / Field 정보를 표시한다.
- Source 교체 및 Map Asset Catalog 등록 등 기존 기능의 버튼 명칭을 작업 목적이 드러나도록 정리했다.
- 기존 JSON 데이터 모델은 변경하지 않았다.
- 기존 `game_controller.gd` 작업 변경사항은 수정하지 않았다.

### 검증
- `git diff --check` PASS
- Godot 4.7.2 headless editor initialization PASS
- `res://editor/image_editor.tscn` headless scene launch PASS
- 실제 화면에서의 UX 확인은 아직 미실시

### 현재 상태
Phase 1 구현 후 Master 승인에 따라 Phase 2를 진행했다.

## 8. Phase 2 진행 결과

### CONFIRMED
- `ImageEditorState`에 선택 대상과 선택 대기 상태를 추가했다.
- Unit / Robot / Tower의 이미지 Browse 동작을 `Select Asset` 흐름으로 연결했다.
- Asset Browser의 `선택 Asset 사용` 버튼으로 선택한 Source를 호출한 Editor에 반환하는 흐름을 추가했다.
- 반환된 경로는 Unit / Robot / Tower가 기존 LineEdit/기존 JSON 저장 구조에 적용한다.
- 기존 JSON schema를 변경하지 않았다.
- 기존 FileDialog 구현은 삭제하지 않고 호환 경로로 남겨 두었다.
- Visual Asset의 Region / Frame Count 데이터 모델은 추가하지 않았다.

### 검증
- `git diff --check` PASS
- 현재 Working Tree 변경은 Phase 2 관련 5개 editor 파일로 제한됨.
- 실제 Godot 실행 파일 경로를 현재 연결 PC에서 확인하지 못해 Godot parse/build는 UNVERIFIED.
- 실제 Editor 화면의 `Select Asset → Use Selected → 복귀` 동작은 UNVERIFIED.

## 9. MASTER DECISION GATE — Phase 3

다음 결정이 필요한 사항은 Visual Asset의 영속 데이터 모델이다.

결정 질문:
1. Sprite Sheet Region / Frame Count를 별도의 Visual Asset 데이터로 저장할 것인가?
2. Visual Asset ID를 `robot.valkyrie.attack` 같은 안정적인 식별자로 둘 것인가?
3. 기존 직접 이미지 경로와 Visual Asset ID를 일정 기간 함께 지원하는 Resolver를 Canon으로 둘 것인가?

Visual Asset 데이터 모델 방향이 Master 승인되었으므로 Phase 3-A 구현을 진행했다.

## 10. Phase 3-A 진행 결과

### CONFIRMED
- `scripts/visual_asset_definition.gd`를 추가했다.
- `scripts/visual_asset_resolver.gd`를 추가했다.
- `content/editor/visual_assets.json`을 추가했다.
- Valkyrie의 9개 Visual Asset을 기존 `robots.json`의 실제 source / region과 대조해 등록했다.
- `RobotDefinition`에서 Visual Asset Resolver를 사용할 수 있도록 연결했다.
- 기존 `robots.json` 및 기존 Editor 저장 구조는 변경하지 않았다.
- 기존 직접 이미지 경로를 `legacy:<path>` Visual Asset으로 해석하는 호환 경로를 유지했다.

### 검증
- Visual Asset JSON parse 및 9개 레코드 schema 검증 PASS.
- Valkyrie source / region / frame count 대조 PASS.
- `git diff --check` PASS.
- 현재 연결 PC에서 `D:\Godot_v4.7.2` 및 주요 경로의 Godot 실행 파일을 찾지 못함.
- 따라서 GDScript parser / Editor 실행 / Build / 실제 Visual Asset preview는 UNVERIFIED.

## 11. 현재 판정

Phase 3-A의 데이터 계층은 목적에 필요한 최소 범위까지 구현했다.
다음 작업은 Robot Editor가 기존 이미지 경로 대신 Visual Asset ID를 선택하고 저장하도록 연결하는 단계다.
이 단계는 실제 Godot Editor에서 UI 및 저장 결과를 확인해야 하므로 현재 환경에서는 HOLD한다.

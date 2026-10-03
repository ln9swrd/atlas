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

Phase 1은 기존 데이터 구조만 사용하므로 별도 Canon 결정 없이 진행 가능하다.

Phase 2 이후에는 다음 중 어떤 UX를 Canon으로 할지 결정이 필요하다.

A. Asset Browser는 선택/탐색 중심으로만 사용하고 각 Editor가 기존 JSON을 직접 저장한다.

B. Asset Browser에 Visual Asset을 1급 데이터로 도입하고 Unit / Robot / Tower가 이를 참조한다.

특히 Sprite Sheet Region / Frame Count를 독립 Asset으로 관리할 것인지가 핵심 결정사항이다.

## 6. 현재 판정

Phase 1은 기존 데이터 호환성을 유지한 상태로 구현 진행한다.
Phase 2~4의 데이터 모델 변경은 Phase 1 검증 후 Master 결정 대상으로 HOLD한다.

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
Phase 1 구현은 목적에 필요한 최소 범위까지 진행했다. 추가적인 데이터 모델 변경 없이 더 진행하려면 Phase 2의 Asset 선택/복귀 흐름 설계가 필요하다.

## 8. MASTER DECISION GATE

다음 작업부터는 단순 UI 개선을 넘어 Unit / Robot / Tower가 Asset Browser를 어떻게 참조할지 결정해야 한다.

결정 질문:
1. Asset Browser를 기존 JSON의 이미지 경로를 선택하는 공통 UI로 먼저 사용할 것인가?
2. Sprite Sheet의 Region / Frame Count를 별도의 Visual Asset 데이터로 승격할 것인가?
3. `Select Asset → Use Selected → 원래 Editor 복귀`를 Unit / Robot / Tower 공통 흐름으로 Canon화할 것인가?

위 결정 전에는 Phase 2 구현을 자동 진행하지 않는다.

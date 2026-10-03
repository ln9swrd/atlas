# MENOS — GDScript 하드코딩 값 외부 저장소 전환 개발계획

- 작성일: 2026-10-04
- 기준 HEAD: 57f13974
- 기준 Branch: main
- 상태: PLAN ONLY / 구현 미착수

## 1. 목적

43개 GDScript 전체를 조사하여 코드에 직접 정의된 설정성 값과 데이터성 값을 식별하고, 별도의 Config Repository에서 로드하도록 단계적으로 전환한다.

목표 구조:
GDScript → 기존 Domain Loader / Config Repository facade → content/settings 및 domain JSON → validation/default → Runtime 또는 Editor

기존 domain JSON과 loader를 권위로 유지하고, 공통 설정만 Config Repository 계층에서 통합 접근한다. 새로운 저장소를 만드는 것이 목적이 아니라 설정의 권위와 접근 경로를 단일화하는 것이 목적이다.

## 2. 현재 조사 결과

CONFIRMED

- 프로젝트에는 GDScript 43개가 존재한다.
- 하드코딩 값은 Runtime, Editor, UI, Loader/Definition, Test 영역에 분산되어 있다.
- game_controller.gd에는 맵 크기, 카메라 값, 인벤토리 행/열, 기본 Robot ID, 타일 source ID, 시각 리소스와 SFX 등이 존재한다.
- editor/robot_editor.gd에는 animation 목록과 frame 관련 값이 존재한다.
- 여러 Editor 스크립트에는 content 경로와 Editor 기본값이 존재한다.
- ui/title_screen.gd에는 UI 간격, 색상, 표시 문자열과 시간 관련 값이 존재한다.
- editor/editor_canvas.gd에는 Undo history 제한값이 존재한다.
- editor/tower_editor.gd에는 Tower/Projectile animation frame 기본값이 존재한다.
- 프로젝트에는 이미 content JSON, ContentCatalogLoader, GameSettingsLoader, SettingsManager, VisualAssetResolver 등의 데이터 접근 계층이 있다.
- 따라서 완전히 별도의 시스템을 새로 만드는 것보다 기존 구조를 확장하는 것이 우선 검토 대상이다.

UNVERIFIED

- 모든 43개 파일의 각 literal이 실제 외부화 대상인지 여부.
- 동일 의미 값의 정확한 중복 개수.
- Engine/API 고정값과 프로젝트 설정값의 최종 경계.
- 기존 JSON schema와 새 Config Repository의 최종 통합 schema.

## 3. 외부화 대상 분류

### A. 프로젝트 경로 / 리소스 참조
예: res://content, assets, sound, Editor scene, shader 경로.

제안 저장소: content/config/paths.json

단, 프로젝트 구조 자체를 결정하는 고정 경로까지 무조건 데이터화하지 않는다.

### B. 게임 밸런스 / Runtime 설정
예: HP, damage, cooldown, range, spawn delay, wave gap, camera speed, inventory size, energy, 기본 Robot ID.

제안 저장소: 기존 domain JSON과 충돌하지 않는 공통 항목은 content/config/gameplay.json.

### C. 맵 / 배치 / 화면 크기
예: MAP_TILES, MAP_ORIGIN, MAP_PIXEL_SIZE, sidebar 위치, HUD 높이.

제안 저장소: content/config/layout.json.

특정 맵의 좌표와 배치는 global config가 아니라 해당 map JSON에 유지한다.

### D. Animation / Visual 설정
예: animation frame count, thumbnail size, preview size, target height, canvas size, 공통 animation 정책.

Asset source/region/frame은 이미 visual_assets.json이 권위 저장소이므로 복제하지 않는다.

Editor 공통 preview 정책은 content/config/editor_visual.json으로 분리한다.

### E. Editor 설정
예: Editor scene path, undo history, thumbnail 크기, dialog 기본 크기, column 폭, file dialog 기본 경로, filter/default view.

제안 저장소: content/config/editor.json.

### F. 문자열 / 표시값
사용자 표시 문자열은 장기적으로 localization resource로 분리한다.

내부 식별자와 표시 문자열은 분리한다.

### G. Enum / Engine 고정값
알고리즘 자체에 필요한 sentinel과 Engine enum은 무조건 외부화하지 않는다.

예: selected_enemy_index = -1 같은 내부 상태 초기값은 코드에 유지 가능하다.

반대로 실제 게임 규칙이나 프로젝트 설정에 의해 바뀌는 값은 외부화 대상으로 분류한다.

## 4. 권장 저장소 구조

현재 확인된 권위 저장소를 우선 사용한다.

content/settings/gameplay.json
- Runtime 공통 gameplay 설정의 현재 권위 저장소
- GameSettingsLoader가 이미 이 파일을 읽고 있음

content/editor/visual_assets.json
- Visual Asset source / region / frames의 권위 저장소

content/maps/*.json / content/stages/*.json / content/robots/robots.json / content/towers/towers.json / content/allied_units/allied_units.json / content/enemies/enemies.json / content/skills/skills.json
- 각 domain 데이터의 권위 저장소

추가 공통 설정이 실제로 필요할 때만 다음을 추가한다.
- content/settings/editor.json
- content/settings/layout.json
- content/settings/paths.json

공통 접근 계층:
scripts/config_repository.gd

ConfigRepository는 새 데이터 권위를 만들지 않고 기존 settings/domain loader를 감싸는 facade 역할을 우선 검토한다.

역할:
- JSON load
- schema/version
- default handling
- type conversion
- missing key 처리
- cache
- reload
- validation
- error reporting

예상 API:
- get_value(section, key, default)
- get_section(section)
- reload()
- validate()

API 이름과 최종 schema는 구현 단계에서 확정한다.

## 5. 권위 데이터 원칙

중복 저장소를 만들지 않는다.

현재 조사에서 이미 확인된 `content/settings/gameplay.json`을 새 `content/config/gameplay.json`으로 복제하지 않는다.

권위 우선순위:
1. 기존 domain JSON / content/settings
2. Visual Asset Catalog
3. ConfigRepository facade가 제공하는 공통 접근 경로
4. 코드 기본값

예:
- Robot animation frame이 visual_assets.json에 있으면 Config Repository에 복제하지 않는다.
- 기본 Robot ID가 공통 게임 설정이면 Config Repository로 이동한다.
- 맵 고유 타일 좌표는 map JSON에 유지한다.
- Editor thumbnail 기본 크기는 Editor config로 이동한다.

## 6. Migration 단계

### Phase 0 — Baseline / Inventory
43개 GDScript를 전수 스캔했다. `const` 선언, `:=` 초기화, resource path, `.get(..., default)`, Vector/Rect/Color 생성 및 주요 UI dimension/animation frame 후보를 조사했다.

CONFIRMED
- GDScript 파일 수: 43개.
- `:=` 초기화 검색 결과는 1,557건이며 대부분 지역 변수/런타임 상태이므로 그대로 외부화 대상으로 취급하면 안 된다.
- `const` 검색 결과는 86건이며 preload/class reference와 실제 설정값이 혼재한다.
- 설정 후보가 집중된 파일은 `game_controller.gd`, `editor/editor_canvas.gd`, `editor/asset_region_view.gd`, `editor/image_editor.gd`, `editor/robot_editor.gd`, `editor/tower_editor.gd`, `editor/unit_editor.gd`, `editor/map_editor.gd`, `ui/title_screen.gd`이다.
- `game_controller.gd`의 wave delay는 이미 `content/settings/gameplay.json`에서 로드된다.
- Map 위치/크기 관련 값은 `MapLoader`가 map JSON에서 읽는 구조가 이미 존재한다.
- Visual Asset source/region/frames는 `VisualAssetResolver`가 `content/editor/visual_assets.json`을 권위로 사용한다.
- `SettingsManager`는 사용자 언어를 `user://menos_settings.cfg`에 저장한다.

외부화 후보가 아닌 대표 항목:
- Engine enum/sentinel (`-1` 등)
- 임시 지역 변수 초기값
- 반복문/수학 계산의 고정 계수
- preload 대상 Script/Shader/Resource 자체
- 테스트 코드의 테스트 시나리오 값

외부화 후보 대표 항목:
- Runtime tuning 및 공통 기본값
- Editor thumbnail/preview/UI dimension 정책
- 반복되는 Editor 기본 경로
- 공통 Undo/history 제한
- 공통 animation preview 정책

산출물:
- 파일
- line
- 값
- 의미
- 변경 빈도
- 공유 여부
- 권위 데이터
- 외부화 여부
- migration priority

성공 조건: 43개 파일 모두 inventory에 포함.

### Phase 1 — Repository Foundation

DONE / 최소 구현 완료.

- scripts/config_repository.gd 추가
- 기존 ContentCatalogLoader를 하부 로더로 재사용
- dictionary cache / reload 제공
- section/value 접근 제공
- required section validation 제공
- GameSettingsLoader는 기존 API를 유지하면서 content/settings/gameplay.json을 ConfigRepository를 통해 읽도록 전환

검증 완료:
- Godot 4.7.2 headless editor load: PASS
- 실제 ConfigRepository smoke test: PASS
- wave_auto_start.delay: 2.5 확인
- wave_group_gap.delay: 0.3 확인
- skill_slots.1: area_attack 확인

미실시:
- 새 JSON schema 강제
- unknown key validation
- 전체 GDScript migration

이 단계에서는 기존 저장소의 권위를 변경하지 않았다.

### Phase 2 — Low-risk Shared Constants
공통 경로, thumbnail/editor 크기, 공통 UI layout, animation display 정책, 반복되는 저위험 제한값부터 이동한다.

### Phase 3 — Runtime Gameplay Configuration
camera tuning, inventory size, spawn/wave timing, gameplay limits, 기본 선택값을 이동한다.

기존 config와 동일한 기본값으로 Runtime 동작 비교가 필수다.

### Phase 4 — Editor Configuration
Editor dimensions, thumbnail 정책, undo limit, dialog 기본값, filter/default view를 이동한다.

### Phase 5 — Visual / Asset Configuration 정리
visual_assets.json을 Asset source/region/frame의 권위 저장소로 유지하고 Robot/Editor의 중복 frame/region을 제거한다. Thumbnail/preview 정책만 공통 config로 이동한다.

### Phase 6 — Dead Constant / Duplicate Cleanup
migration 완료 후 사용되지 않는 const와 중복 값을 제거한다.

## 7. 변경 안전성

각 Phase 시작:
- HEAD 확인
- Branch 확인
- Working Tree 확인
- 기존 변경사항 보존

변경:
- 한 영역씩 migration
- 가능한 한 한 변수군만 변경
- 기존 JSON을 임의로 재작성하지 않음

종료:
- diff 확인
- git diff --check
- Godot headless Editor load
- 관련 smoke test
- 필요 시 PIE

현재 작업 중인 변경사항은 migration 전에 보존해야 한다:
- content/robots/robots.json
- content/editor/visual_assets.json
- editor/image_editor.gd
- editor/robot_editor.gd
- content/editor/edited_assets/*
- scripts/editor_thumbnail_util.gd

이 파일들은 원인과 무관한 변경을 되돌리지 않는다.

## 8. 금지사항

- 모든 숫자 literal을 무조건 JSON으로 옮기지 않는다.
- Engine API 고정값을 무분별하게 외부화하지 않는다.
- 동일 값을 여러 JSON에 복제하지 않는다.
- 기존 domain JSON과 Config Repository의 권위를 충돌시키지 않는다.
- migration과 동시에 gameplay 설계를 변경하지 않는다.
- migration을 이유로 범위 밖 리팩터링을 하지 않는다.
- Commit / Push하지 않는다.

## 9. 검증 기준

CODE VERIFIED:
모든 외부화 참조가 Config Repository에서 올바른 값을 얻는다.

BUILD VERIFIED:
프로젝트 Build 성공.

EDITOR VERIFIED:
관련 Editor에서 기존 데이터가 동일하게 표시/저장된다.

PIE VERIFIED:
Master가 실제 Runtime에서 기존 동작과 동등함을 확인한다.

migration에서는 "값이 로드된다"보다 "기존 동작이 동일하다"를 핵심 검증으로 삼는다.

## 10. 최종 성공 기준

- 외부화 대상 inventory에 미분류 항목이 없다.
- 설정성 값은 명확한 단일 권위 저장소를 가진다.
- 동일 의미 값이 여러 GDScript/JSON에 중복되지 않는다.
- Runtime과 Editor가 동일한 Config Repository 정책을 사용한다.
- 누락/형식 오류가 검증 가능하다.
- 기존 gameplay와 Editor 동작에 regression이 없다.

## 11. 현실성 판단

TECHNICALLY POSSIBLE:
기존 JSON loader/definition/resolver 계층이 있어 구현 가능하다.

PRACTICALLY FEASIBLE:
43개 파일을 한 번에 바꾸지 않고 단계별 migration하는 것이 적절하다.

RECOMMENDED:
먼저 inventory를 완성하고 외부화 대상을 확정한 뒤 Repository를 구현한다.

BUSINESS VIABLE:
현재 규모에서는 유지보수성과 Editor/Runtime 일관성 개선 효과가 있으므로 적용 가능하다. 다만 구현 비용이 있으므로 저위험 값부터 적용한다.

## 12. 현재 판정

STATUS — HOLD

Phase 0 조사에서 기존 `content/settings/gameplay.json`, domain JSON, `visual_assets.json`, `SettingsManager`가 이미 서로 다른 종류의 권위 저장소로 존재하는 것이 확인되었다. 따라서 새 `content/config/*`를 바로 추가하면 중복 권위가 생길 수 있다.

Master 결정 필요:
1. 기존 `content/settings`를 공통 설정의 물리적 저장소로 유지하고 `ConfigRepository`를 facade/validation 계층으로 둘 것인지
2. 별도 `content/config` 저장소를 신설할 것인지

현재 기술 판단(PROPOSAL): 1번이 기존 구조를 가장 적게 변경하며 권위 충돌을 피한다.

Master 결정 전에는 Phase 1 구현 및 GDScript migration을 시작하지 않는다.

OUT OF SCOPE:
- ConfigRepository 구현
- JSON schema 실제 생성
- GDScript 수정
- 기존 값 migration
- Build/PIE 검증


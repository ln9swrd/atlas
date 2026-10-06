# MENOS — GDScript JSON → SQLite 전환 대상 조사

## 목적
현재 godot/**/*.gd의 JSON 직접 접근 및 JSON 기반 Loader/Repository 호출을 조사하여 SQLite 전환 대상을 수집한다. 본 문서는 조사 문서이며 코드 전환은 수행하지 않는다.

## 기준선
- Branch: main
- HEAD: 7c97acc97be9262b50fe84b691de9b0dbdbd94e5
- SQLite: godot/content/menos.sqlite
- JSON migration: 23/23, payload integrity PASS
- Runtime SQLite 전환: NOT DONE
- 기존 Working Tree 변경사항: 유지

## 조사 결과
JSON 관련 접근이 확인된 GDScript: 24개.

### 1. Runtime 핵심 전환 대상
- godot/scripts/content_catalog_loader.gd — 공통 JSON catalog loader. 최우선 전환점.
- godot/scripts/object_repository.gd — robots/allied_units/enemies/towers.
- godot/scripts/faction_repository.gd — factions.
- godot/scripts/mission_definition_loader.gd — missions.
- godot/scripts/reward_definition_loader.gd — rewards.
- godot/scripts/skill_definition_loader.gd — skills.
- godot/scripts/config_repository.gd — editor/gameplay settings.
- godot/scripts/game_settings_loader.gd — gameplay settings.
- godot/scripts/stage_manager.gd — stage_catalog/main_campaign.
- godot/scripts/stage_loader.gd — stage JSON 직접 load/validate.
- godot/scripts/map_loader.gd — map JSON load/save.
- godot/game_controller.gd — items/asset_catalog 및 user save JSON.

### 2. Runtime-adjacent / Editor data
- godot/scripts/visual_asset_repository.gd — visual_assets.
- godot/editor/content_validator.gd — skills, visual_assets, gameplay, missions, rewards, items, stages 등.
- godot/ui/title_screen.gd — stage JSON scan.
- godot/editor/map_editor.gd — asset_catalog, map JSON, user favorites JSON.
- godot/editor/stage_editor.gd — stage/mission/reward/asset catalogs.

### 3. Editor CRUD 전환 대상
- godot/editor/asset_catalog_editor.gd — asset_catalog/visual_assets read/write.
- godot/editor/image_editor.gd — visual_assets, asset_catalog 및 robot/tower/unit/enemy JSON read/write.
- godot/editor/robot_editor.gd — robots/visual_assets read/write.
- godot/editor/tower_editor.gd — towers read/write.
- godot/editor/unit_editor.gd — allied_units/enemies read/write.

### 4. 별도 결정
- godot/tests/editor_data_smoke_test.gd — JSON 기반 테스트 fixture/검증.
- godot/scripts/object_persistence.gd — JSON stringify 기반 객체 직렬화.
- game_controller.gd의 user://menos_campaign_robot_profile.json — 사용자 저장 데이터.
- map_editor.gd의 user://map_editor_file_dialog_favorites.json — Editor UI preference.

user:// 데이터는 content SQLite와 목적이 다르므로 자동으로 통합하지 않는다.

## 핵심 전환 지점

### ContentCatalogLoader
현재:
FileAccess.open → JSON.parse → Dictionary

여기를 SQLite-backed repository/adapter로 만들면 object/faction/mission/reward/skill/config 계열을 공통 경로로 전환할 수 있다.

### Stage
stage_loader.gd와 stage_manager.gd는 Stage/Campaign 관계와 validation을 담당한다. stage_id 기반 SQLite API가 필요하다.

### Map
map_loader.gd는 읽기뿐 아니라 JSON 저장도 한다. SQLite 전환은 read migration이 아니라 CRUD/transaction 설계가 필요하다.

### Editor
Editor CRUD는 단순 loader 교체가 아니다. JSON write를 SQLite transaction/API로 변경해야 한다.

## SQLite에 이미 마이그레이션된 데이터
1. allied_units
2. campaign/main_campaign
3. editor/asset_catalog
4. editor/visual_assets
5. enemies
6. factions
7. items
8. maps/map_01
9. maps/map_01_src
10. maps/map_02
11. maps/map_03
12. missions
13. rewards
14. robots
15. settings/editor
16. settings/gameplay
17. skills
18. stages/stage_01
19. stages/stage_02
20. stages/stage_03
21. stages/stage_catalog
22. towers
23. map_data/northbridge_sector_01

## 현재 SQLite schema 주의
현재 DB는 migration bridge 성격이다. 대부분 raw_json을 보존하고 있으므로 최종 Production relational schema로 간주하지 않는다.

Runtime 전환 전에 결정할 항목:
1. Runtime query schema
2. ID/foreign key
3. nested JSON 정규화 범위
4. Editor CRUD API
5. JSON fallback 정책
6. Runtime SQLite read-only 정책
7. user save의 SQLite 포함 여부

## 권장 구현 순서
Phase 1: ContentCatalogLoader SQLite adapter
Phase 2: robots → allied_units → enemies → towers → factions → skills → missions → rewards → items
Phase 3: campaign → stage_catalog → stage → map
Phase 4: visual_assets → asset_catalog → validator/UI
Phase 5: Editor CRUD
Phase 6: JSON fallback/삭제 여부 결정

## 금지
- JSON 삭제 금지
- 조사 단계에서 Runtime loader 변경 금지
- user:// save를 content DB에 자동 병합 금지
- bridge schema를 최종 schema로 간주하지 않음
- 기존 Working Tree 변경사항 revert 금지

## 판정
STATUS — PASS
조사 결과 — JSON 관련 GDScript 24개 확인 및 Runtime/Editor/Persistence로 분류.
검증 상태 — CODE 조사 VERIFIED / Runtime SQLite 전환 NOT VERIFIED.
OUT OF SCOPE — 코드 전환, schema 정규화, JSON 삭제, PIE 검증.
현실성 — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE.

## 2026-10-06 Migration Completion Update

- MENOS-created Content JSON files under `godot/content/` have been removed; current count is 0.
- `godot/content/menos.sqlite` is the authoritative Content Canon.
- Final direct-JSON audit: no MENOS Content JSON file read/write path remains in runtime/editor GDScript.
- Robot, Unit, Tower, Stage, Map, and Asset Catalog Editors were statically verified to consume SQLite-backed repositories/loaders.
- All six Editor scenes were headlessly launched successfully.
- Tower Editor had one confirmed empty `sprite_anim` resource-load edge case; the minimum guard was applied and the scene was revalidated with exit code 0 and no Godot error output.
- JSON retained in GDScript is limited to JSON serialization/parsing of SQLite fields, compatibility path mapping, UI wording/filter text, and intentionally separate `user://` state.
- Runtime/manual PIE acceptance remains separate and is not claimed by this migration audit.

STATUS: PASS
VERIFICATION: CODE VERIFIED / EDITOR SCENE RUNTIME VERIFIED / PIE VERIFIED = NOT CLAIMED

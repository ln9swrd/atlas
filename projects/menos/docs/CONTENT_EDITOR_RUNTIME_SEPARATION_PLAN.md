# MENOS Content Editor 분리 및 Runtime 콘텐츠 공급 계획

## Current Status Index — 2026-10-09

This index is the current summary. Dated entries below are chronological evidence and may describe older baselines or earlier states.

- Current repository: `D:\Atlas\projects\menos`; branch `main`; HEAD at this review: `a5aadb04e759ca3cb11029e88720055d735bb1ae`.
- The `E:\\atlas\\projects\\menos` path and HEAD `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1` in the original plan header are historical investigation baseline values, not current values.
- Independent project exists at `content_editor/`; its authoring database is `content_editor/data/menos.sqlite`. Runtime project remains `godot/`, with existing Runtime DB `godot/content/menos.sqlite`.
- DB-copy integrity/hash matching previously demonstrated copy equality at that time only; it does not establish ongoing synchronization or approved data-authority transfer.
- Current data-authority transition: UNVERIFIED. Published package/manifest and a complete Runtime loader contract: NOT COMPLETE / UNVERIFIED.
- Headless isolated menu smoke reported 15/15 scene instantiation/host attachment. This does not prove full visual menu interaction, GUI save/reload, or Master PIE acceptance.
- The latest recorded isolated GUI attempt was PARTIAL PASS / HOLD: GUI opened to Map, but responsiveness/menu transitions and GUI persistence acceptance were not established. The reported GUI hang/black-screen cause remains UNVERIFIED.
- Existing runtime asset paths include hard-coded `res://` dependencies and database-driven paths; a publisher must resolve and validate both before a package can be considered complete.
- Master-approved short-term design (2026-10-09): each map's authoring source is an independent JSON file; the published Runtime package is a filtered SQLite DB plus manifest and referenced Assets; supported modes are Campaign and Single Play only.
- Runtime owns the game title/main screen and gameplay screens/behavior. Content Editor owns authoring UI and content creation/editing/validation/preview. Runtime-facing content such as map definitions and UI labels may be authored in the Editor, but the Editor does not own or execute Runtime screens.
- This approval authorizes design documentation and read-only pre-implementation analysis only. It does not authorize code changes, database migration, map conversion, publisher implementation, Build/PIE work, Commit, or Push.
- Current review baseline: branch `main`, HEAD `a5aadb04e759ca3cb11029e88720055d735bb1ae`; Working Tree has 13 pre-existing modified `godot/` import/project files that must be preserved.

## 0.1 Authority and status interpretation

Use `state/CURRENT_STATE.md` for current implementation status, `MENOS_COMBAT_CANON.md` for approved combat Canon, and this document for the Editor/Runtime separation investigation. Historical baseline lines and dated progress reports below are retained for traceability; they must not override this current index.


- 작성일: 2026-10-09
- 상태: 방향 승인, 조사·설계 단계
- 목적: 콘텐츠 에디터를 MENOS 게임 런타임과 분리하고, 런타임에는 게임 실행에 필요한 콘텐츠 데이터와 리소스만 공급한다.
- 저장소: E:\\atlas\\projects\\menos
- 기준선: branch `main`, HEAD `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`
- 변경 권한: 현재 단계는 READ-ONLY. 코드/프로젝트 분리, 데이터 이동, 경로 변경, 리소스 재배치는 구현 계획과 위험을 확인한 후 진행한다.

## 1. 목표 구조

1. **MENOS Content Editor (독립 제작 도구)**
   - 독립적으로 실행·배포한다.
   - 콘텐츠 생성, 수정, 검증, 미리보기 등 제작 기능을 소유한다.
   - 게임 런타임 전용 코드와 UI를 포함하지 않는다.
2. **공유 콘텐츠 계약**
   - 콘텐츠 ID, 스키마/버전, 데이터 형식, Asset 참조 규칙을 정의한다.
   - Editor와 Runtime이 같은 계약을 사용하되 Editor UI 코드를 공유 계약에 넣지 않는다.
3. **MENOS Runtime**
   - 게임 플레이에 필요한 콘텐츠 데이터와 승인된 리소스만 로드한다.
   - 제작 전용 UI, 편집기 전용 플러그인, 불필요한 미리보기 도구는 포함하지 않는다.
   - 런타임 콘텐츠는 명시된 콘텐츠 패키지/데이터 루트를 통해 공급받는다.

## 2. 의미 범위

“에디터 리소스 중 일부를 런타임에 부여”한다는 방향은 **에디터 전체를 런타임에 넣는 것이 아니라, 게임에서 실제 사용하는 데이터·Asset·런타임 로더만 선별하여 공급하는 것**으로 해석한다. 실제 패키징 단위와 저장 위치는 조사 후 확정한다.

초기에는 콘텐츠 원본을 이동하거나 복사하지 않는다. 현재 저장 구조를 보존한 채 의존성 경계를 먼저 파악한다.

## 3. 현재 확인된 사실

- `godot/project.godot`의 앱 이름은 `MENOS`이며 게임 메인 장면은 `res://ui/title_screen.tscn`이다.
- 콘텐츠 에디터는 `res://editor/content_editor.tscn`에서 실행 가능한 장면이며, 하위 편집기를 별도 장면으로 로드한다. 이것은 같은 Godot 프로젝트 안의 분리이지 독립 배포를 증명하지 않는다.
- SFX/BGM/VFX 저장소는 `res://content/menos.sqlite` 및 `res://scripts/...` 기반 로더·저장 유틸리티를 참조한다.
- 일부 콘텐츠는 `res://` Asset 경로를 데이터 값으로 사용한다. 독립 앱과 Runtime 사이에서 경로 해석 규칙을 명시해야 한다.
- Voice는 별도 Repository를 가지나 공통 콘텐츠 로더/저장 유틸리티에 대한 완전한 독립성은 아직 확인되지 않았다.
- 기준선의 Working Tree에는 기존 수정사항이 다수 있다. 본 작업은 이를 되돌리거나 일괄 정리하지 않는다.

## 4. 단계 계획

### Phase 0 — READ-ONLY 의존성 맵 작성
- Editor 진입점과 하위 편집기, Editor 전용 플러그인/도구 식별
- Runtime에서 사용하는 정의·로더·리소스·SQLite 접근 식별
- Editor/Runtime 양쪽에서 참조하는 스크립트와 Asset을 분류
- 모든 `res://` 경로의 역할(앱 코드, 콘텐츠 데이터, 원본 Asset, 생성물)을 구분
- 저장 방식과 콘텐츠 원본의 현재 기준 위치 확인

**통과 조건:** 독립 경계와 최소 런타임 콘텐츠 집합을 파일 단위로 설명할 수 있음.

### Phase 1 — 콘텐츠 계약 및 패키징 설계
- 데이터 스키마/버전과 ID 참조 규칙 정리
- Runtime에서 필요한 데이터와 Asset만 선택하는 manifest/package 규격 제안
- 절대 경로/상대 경로/프로젝트 루트 해석 규칙 결정안 작성
- Editor가 관리하는 원본과 Runtime에 배포되는 산출물을 구분
- 현재 MENOS 콘텐츠를 읽는 호환성 계획 수립

**통과 조건:** 데이터 복사·변환 전에 Master가 경로, 패키징, 원본 보관 규칙을 검토할 수 있음.

### Phase 2 — 최소 독립 실행 PoC
- 별도 앱 디렉터리/프로젝트에서 Editor 진입점만 실행하는 최소 PoC 설계 및 구현
- 기존 콘텐츠 데이터와 Asset은 읽기 전용으로 참조
- 원본 DB/Asset을 변경하거나 이동하지 않음
- 필요한 공유 코드/플러그인 의존성만 최소 복제 또는 공통 모듈화 후보로 평가

**통과 조건:** MENOS Runtime을 실행하지 않고 Editor를 시작할 수 있음. 이는 전체 분리/배포 완료를 뜻하지 않음.

### Phase 3 — Runtime 콘텐츠 공급 PoC
- 선택된 콘텐츠만 포함하는 manifest/package를 생성하거나 참조
- Runtime에서 선택된 콘텐츠를 로드하고 기존 ID/Asset 참조가 유효한지 확인
- 저장 원본을 건드리지 않는 격리 테스트 데이터로 검증
- 누락 Asset, 잘못된 ID, 버전 불일치에 대한 오류 보고 확인

**통과 조건:** 최소 샘플 콘텐츠가 Runtime에서 로드되고, 기존 플레이 흐름의 관련 경로가 회귀하지 않음.

### Phase 4 — 단계적 분리 및 수용
- 승인된 콘텐츠 유형 단위로 적용 범위를 넓힘
- Editor 전용 의존성이 Runtime 산출물에 포함되지 않는지 확인
- 독립 실행, 저장/재열기, 패키징, Runtime 로딩, 호환성 검증
- 실제 Build 및 GUI/PIE 검증을 별도 기록

**통과 조건:** 승인된 범위의 독립 실행과 콘텐츠 전달이 검증됨. 성공하면 중단하고 후속 범위는 자동 확장하지 않음.

## 5. 범위 잠금 및 금지사항

- 현 단계에서 게임 로직, 콘텐츠 의미, Canon, 데이터 스키마를 임의 변경하지 않는다.
- 원본 SQLite, Asset, 카탈로그를 이동·변환·대량 복사하지 않는다.
- 외부 패키지/플러그인을 새로 다운로드하거나 설치하지 않는다.
- 독립 실행 PoC 성공을 전체 Production 분리 완료로 간주하지 않는다.
- 기존 Working Tree 변경을 되돌리거나 이 작업에 무관한 변경을 커밋하지 않는다.
- Commit/Push는 분리 단계의 검증과 diff 분류가 끝난 뒤 별도 승인 규칙에 따라 판단한다.

## 6. 검증 분류

- **CODE VERIFIED:** 실제 코드 경계와 참조 확인
- **BUILD VERIFIED:** 독립 Editor 및 Runtime 산출물 실제 빌드 성공
- **EDITOR VERIFIED:** 독립 앱에서 편집/저장/재열기 확인
- **PIE VERIFIED:** Master가 실제 Runtime 결과를 확인
- **NOT VERIFIED:** 아직 확인되지 않음

## 7. 현재 판정

- 기술적 가능성: **HIGH CONFIDENCE**
- 실제 독립 실행/별도 배포: **UNVERIFIED**
- Runtime에 필요한 최소 리소스 집합: **UNVERIFIED**
- 원본 콘텐츠 이동/변경: **수행하지 않음**
- 코드 변경: **수행하지 않음**
- 다음 작업: Phase 0 READ-ONLY 의존성 맵 작성. 분리 구현이나 데이터 이동 전까지 HOLD하지 않고 조사·문서화만 진행한다.


## Phase 0 — Initial dependency findings (2026-10-09)

- **CONFIRMED:** `ContentCatalogLoader` hard-codes `res://content/menos.sqlite`; it opens the SQLite database read-only for loading.
- **CONFIRMED:** `ObjectPersistence` also hard-codes the same database path and contains write/update/delete transaction logic. It is not yet separated into an injectable production content-store boundary; the alternate DB path is currently exposed only through debug test hooks.
- **CONFIRMED:** SFX/BGM/VFX repositories depend on shared loaders/persistence and `res://` project paths. Voice uses the shared catalog loader and persistence utility.
- **CONFIRMED:** Windows Desktop export preset currently has `export_filter="all_resources"` and includes `content/menos.sqlite`. This config indicates broad resource inclusion; actual exported file contents have not been inspected, so editor code inclusion in a built package is **UNVERIFIED**.
- **INFERENCE:** Independent editor execution and selective Runtime resource packaging need two separate boundaries: (a) app/code boundary, and (b) content-data/Asset boundary. A single project-root path convention currently couples these concerns.
- **NOT VERIFIED:** Exact set of scripts/assets required by Runtime, which editor-only plugins/code are included in export, standalone Editor save/reopen, and selective Runtime package loading.
- **Action:** No implementation until the full dependency map identifies the smallest safe slice. No source, data, or export settings changed.


## Phase 0 — Dependency map findings (continued, 2026-10-09)

### Code and data boundary
- **CONFIRMED:** `project.godot` has no declared `[autoload]` or `[editor_plugins]` section in the inspected configuration. This reduces known global/editor-plugin coupling but does not prove no implicit plugin dependency.
- **CONFIRMED:** The editor entry point preloads the editor-specific scene family and image editing helpers. Asset/image editing code writes under `res://content/editor/edited_assets` and `res://content/editor/team_masks`; these are authoring outputs and should not be shipped to Runtime by default unless a selected Asset explicitly references a produced file.
- **CONFIRMED:** `ContentCatalogLoader` opens the single SQLite DB read-only for runtime-style reads. `ObjectPersistence` opens the same DB read/write and owns save/delete/transaction operations. Both production paths hard-code `res://content/menos.sqlite`; only test hooks permit a different path.
- **CONFIRMED:** Runtime gameplay scripts use the shared loader for robot/unit/enemy/tower catalogs, mission/reward/skill data, stage/campaign/map documents, factions/configuration, and VFX/SFX/BGM/Voice definitions. Visual assets are resolved through `VisualAssetRepository`, which reads the `visual_assets` catalog from that same DB.
- **CONFIRMED:** The database contains both runtime-facing tables (e.g. `robots`, `allied_units`, `enemies`, `towers`, `stage_catalog`, `map_01`, `vfx_definitions`, `sfx_definitions`, `bgm_definitions`, `voice_definitions`, `visual_assets`) and authoring/catalog tables (e.g. `editor`, `asset_catalog`). This is evidence that the current DB mixes content/runtime data and authoring metadata; exact field-level runtime necessity still needs validation.
- **CONFIRMED:** Current Windows Desktop export preset uses `export_filter="all_resources"` and includes `content/menos.sqlite`. The project configuration therefore does not express a selective runtime resource boundary. Actual exported package membership remains **UNVERIFIED**.
- **INFERENCE:** A safe separation should not simply copy the whole editor folder or whole database into a new app. It needs (1) an independent editor app/code boundary, (2) an explicit runtime content package/resource manifest, and (3) a defined authoring-source versus runtime-deployment data flow.

### Main unresolved architecture decision
- Should the editor edit the authoritative project content source and then publish a validated runtime package, or should the runtime itself be the authoritative editable store? The current architecture combines both responsibilities in one SQLite file. A publish pipeline is the safer default because it prevents authoring metadata/editor-only assets from being mixed into the shipped runtime package, but Master approval is required before changing source-of-truth or write ownership.

### Phase 0 status
- **PARTIAL:** Main entry points, shared DB access, core runtime repositories, visual asset catalog, authoring output paths, and export preset identified.
- **UNVERIFIED:** Full resource-level dependency closure for each runtime scene; exact export package contents; actual standalone editor launch; runtime package loading from an external path; full editor write paths beyond inspected samples.
- **No implementation performed.** No SQLite rows or schemas changed; database was inspected read-only. No export settings changed.


## Phase 1 — Content contract / package design proposal (2026-10-09)

### Decision applied
- **Master approved:** editor-managed authoritative source -> validated/published Runtime content package. The Editor source remains the authoring authority; Runtime consumes a published package, not the writable authoring database.
- Approval applies to architecture direction only. It does not authorize source DB migration, schema changes, bulk Asset copying, or production rollout.

### Proposed minimum-risk contract
1. **Authoring source:** retain the existing `godot/content/menos.sqlite` and current Asset tree as the source during PoC. Do not relocate or rewrite them.
2. **Publish output:** generate a separate Runtime package in a new, isolated output directory. Initial package format proposal is a filtered SQLite database plus a manifest and only the referenced runtime Assets. This reuses the current SQLite-oriented loaders and avoids an immediate schema conversion.
3. **Manifest:** include package format version, content schema version, build/revision identifier, included catalog/table list, Asset paths and hashes/sizes where practical. A missing or incompatible required entry must fail validation before Runtime load.
4. **Path contract:** authoring values may retain existing `res://...` references during the first compatibility stage, but the publisher must resolve them against the source project root and write a normalized package-relative path into the manifest. Runtime resolution must not assume the Editor's project root. Do not mass-rewrite existing catalog rows during the PoC.
5. **Read-only Runtime:** Runtime loads the published package and selected Assets read-only. It must not write to the source DB or silently mutate the published package. Save-game/profile data remains a separate user-data concern and must not be placed in the content package.
6. **Separation boundary:** Editor scenes, editor-only scripts, authoring metadata (including `editor` and authoring-only portions of `asset_catalog`), temporary/edited output folders, and previews are excluded unless a referenced file is proven necessary for gameplay.
7. **ID compatibility:** preserve existing catalog IDs and legacy-ID/ODB registry mappings used by stage, mission, unit, robot, and other references. Do not redesign identifiers in this phase.

### Candidate minimum Runtime content groups (not yet final)
- Core entity catalogs: robot, allied unit, enemy, tower, building, faction, skill, mission, reward and other definitions used by loaded gameplay flows.
- Campaign/stage/map documents and ID registry mappings needed by the active campaign path.
- Runtime definitions for VFX, SFX, BGM and Voice, plus only the actual referenced audio/visual files.
- Visual asset metadata required by Runtime resolution, filtered to the IDs actually referenced by included content.
- Any additional resources discovered through scene/script dependency closure and the active campaign path.

This list is a candidate, not a package whitelist. Each item must be validated against actual Runtime code paths and references before generation.

### Minimum PoC acceptance checks
- Publisher reads the source database read-only and writes only to an isolated output directory.
- Manifest validation reports missing IDs, unresolved asset references, duplicate IDs, and unsupported schema/package versions.
- Runtime can load the published sample package without requiring the Editor scene family or editor-only output directories.
- A representative start-to-gameplay flow resolves required data/assets; Master performs final visual/runtime confirmation before PIE is marked verified.
- Source database hash and working-tree baseline remain unchanged by the publish test, excluding only the explicitly approved documentation changes.

### Design risks / still unverified
- Current `ContentCatalogLoader` maps `res://content/...` strings to SQLite table names rather than opening arbitrary JSON files; current production path is fixed to `res://content/menos.sqlite`. Runtime package injection will require a narrow loader boundary change or an adapter, but no code change has been made.
- `ObjectPersistence` writes to the source database through a separate fixed path. It must remain Editor-only; Runtime build should not include authoring write APIs unless separately justified.
- Asset catalog entries use project-root `res://` paths. Exact path normalization and resource import sidecar requirements are not yet inventoried.
- The final filtered table set cannot safely be fixed from table names alone; nested IDs and runtime scene dependencies need a read-only reference closure pass.
- The actual exported PCK/package contents and a separate Editor launch are still unverified.

### HOLD — one implementation choice needs Master confirmation
The low-risk first PoC is to **keep the source DB unchanged and publish a filtered SQLite runtime package**. Alternative is to convert published content to JSON files, which is a larger loader/schema compatibility change. Recommendation: filtered SQLite for the first PoC, with JSON conversion explicitly out of scope. Do not implement the publisher/loader until this format choice is confirmed.


## Phase 1 — SQLite package contract accepted; dependency inventory update (2026-10-09)

- **Master approved:** first PoC uses a filtered SQLite Runtime package. JSON conversion is out of scope.
- **CONFIRMED:** Current database contains 31 application tables plus SQLite internal `sqlite_sequence` (32 listed total including internal table). Tables mix runtime content, authoring metadata, migration bookkeeping, and player profile data.
- **CONFIRMED — candidate Runtime tables from direct loader calls:** `allied_units`, `bgm_definitions`, `campaign`, `enemies`, `factions`, `map_01`, `map_01_src`, `map_02`, `map_03`, `missions`, `rewards`, `robots`, `sfx_definitions`, `skills`, `stage_01`, `stage_02`, `stage_03`, `stage_catalog`, `towers`, `vfx_definitions`, `visual_assets`, `voice_definitions`. `northbridge_sector_01`, `gameplay`, `items`, `buildings`, and other tables may be required by paths not yet closed; this list is a candidate, not an approved whitelist.
- **CONFIRMED:** `odb_registry` is used by `ContentCatalogLoader.resolve_odb_pk()` and reverse lookup; it may be required to preserve legacy IDs and must be included or safely materialized for the runtime-referenced content set.
- **PROPOSED EXCLUSIONS pending reference check:** `editor`, authoring-only portions of `asset_catalog`, `schema_migrations`, and `player_profile`. `player_profile` is explicitly player-state-like and should not be merged into the content package; runtime profile persistence is a separate concern.
- **CONFIRMED:** Runtime resource references include images under `res://images/...`, audio under `res://sound/...`, and at least one content row references `res://content/editor/edited_assets/range_edit_208771618.png`. Therefore, the blanket rule “exclude content/editor outputs” is unsafe: publish must include any referenced file that is actually required for gameplay, even if its current source location is under an editor directory. Path-based exclusions alone are not sufficient.
- **CONFIRMED:** BGM/SFX/VFX/Voice repositories include save operations through `ObjectPersistence`, but the inspected callers are repository methods and the precise caller/UI separation still needs verification. Runtime packaging must ensure gameplay does not invoke authoring writes; a read-only published DB is a defense-in-depth boundary, not a substitute for checking call paths.
- **HIGH CONFIDENCE:** Package generator should create a new database by copying an explicit validated table set and preserving schema/IDs, then include a manifest and reference-closed Asset list. Do not delete rows from or modify the source DB to create the package.

### Next inventory gate
Before writing publisher code, finish the read-only closure for the active Campaign 1 start-to-gameplay path: trace campaign -> stage catalog -> stage -> map -> enemy/unit/robot/tower/mission/reward/skill/faction/gameplay definitions, visual asset resolution, and audio/VFX references. Resolve all nested IDs and resource paths; report missing references rather than silently omitting them. Also verify whether Godot resource import sidecars or other project resources are required for standalone asset loading.

### Safety baseline
- HEAD remains `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`, branch `main`.
- Existing unrelated Working Tree changes remain present and are not to be reset or normalized.
- `git diff --check` produced line-ending conversion warnings for pre-existing files; no whitespace error was reported in the inspected output.
- No game code, source DB, Asset, export preset, or Runtime package was changed or generated.


## Architecture decision update — Standalone Content Editor project (2026-10-09)

- **Master direction supersedes the earlier interpretation:** the Content Editor must be a separate Godot project, not merely an editor scene removed from the runtime export. MENOS Runtime is also its own project/application boundary.
- **Target topology (proposal, not yet implemented):**
  - `projects/menos/content_editor/` — independent Godot project with its own `project.godot`, main scene, editor scenes/scripts, authoring UI, authoring DB access and Asset import tools.
  - `projects/menos/godot/` — MENOS Runtime project. It consumes a published, validated runtime package and must not require editor scenes/scripts, authoring tables, or editor write services.
  - A versioned content contract and package manifest defines schema/package version, stable IDs, required tables, referenced Assets, hashes and validation rules.
- **Path is a proposal:** no new project directory has been created. Master has approved the separate-project goal, not yet every proposed directory/API detail.
- **CONFIRMED:** current Godot project is named MENOS and its main scene is `res://ui/title_screen.tscn`; all 17 inspected editor scenes live in the same project under `res://editor/`. This is not a standalone editor project today.
- **CONFIRMED:** editor scenes/scripts rely on project-root `res://editor/... `, shared `res://scripts/... `, the common SQLite database, and source Assets. The content loader and persistence layer map logical paths to SQLite tables; persistence exposes writes. Directly copying only editor scenes into a new project would therefore be insufficient.
- **CONFIRMED:** at least one runtime-content record references an Asset currently stored under `res://content/editor/edited_assets/`. Asset inclusion must be based on the resolved reference closure, not directory-name exclusions.
- **Migration constraint:** preserve current `projects/menos/godot/` as the existing game project during the transition. Do not move/delete/rename existing scenes, scripts, DB or Assets as part of the initial PoC. The new project must be introduced additively, with a separate authoring-data path/copy or an explicit source selector so the current Runtime project cannot accidentally mutate the source DB during early tests.

### Revised phased plan
1. **READ-ONLY dependency map (current gate):** classify editor-only scripts/scenes, shared content contract code, runtime-only code, and Assets by reference closure. Trace Campaign 1 from campaign -> stages -> map -> entities -> mission/reward/skills/faction -> visual/audio/VFX. Identify every authoring write path and every Runtime read path.
2. **Standalone project skeleton:** create a new independent Godot project in an additive directory with its own `project.godot` and editor main scene. Initially use no destructive moves and no writes to the existing source DB. Prove the editor can launch independently before migrating the complete tool suite.
3. **Authoring boundary:** relocate/copy editor-owned scenes/scripts and their dependencies into the new project; replace assumptions about project-root paths with explicit project/config paths where needed. Keep the source project untouched until parity checks pass.
4. **SQLite package publisher:** publish an allowlisted, dependency-closed Runtime SQLite DB plus manifest and referenced Assets to a separate output directory. Validate schema, IDs, resource existence, hashes and package version. Never modify the authoritative authoring DB while publishing.
5. **Runtime consumer:** change the Runtime project to load a published package through a narrow data-source boundary, with read-only access and a clear failure report for absent/incompatible packages. Keep save-game/profile data separate.
6. **Acceptance gate:** standalone Editor launch; representative authoring save/reload; package validation; Runtime load of published package; Campaign 1 start-to-gameplay checks; source DB/Asset hashes unchanged. Automated test pass does not count as Master-confirmed PIE.

### HOLD / not authorized by current evidence
- No code or Asset migration until dependency closure and copy/write boundaries are documented.
- No source DB schema changes, table deletion, ID rewrite, bulk Asset relocation, project rename, commit or push.
- Exact location/name of the standalone project, how it chooses the authoritative authoring DB, and whether a future shared content-contract library is needed remain design details. The proposed sibling path is a reversible default for the PoC.
- **Current status:** planning and read-only inspection only; no standalone project has been created, no publisher exists, no build or Runtime verification has occurred.


## Editor dependency graph follow-up (READ-ONLY, 2026-10-09)

- **CONFIRMED:** Editor scripts have an internal dependency graph under `res://editor/` (image texture loading, image editor state, asset region view, validators, previews, content validation runner) and direct dependencies on shared `res://scripts/` models/repositories. The map editor also preloads `res://assets/menos/maps/northbridge_tileset.tres`.
- **CONFIRMED:** direct shared-script dependencies include BGM/SFX/VFX/Voice definitions and repositories, visual-asset frame utilities, and other content data services. This means editor separation needs an explicit dependency boundary; moving scenes alone will break resource paths and may accidentally pull runtime/editor responsibilities into the wrong project.
- **CONFIRMED:** proposed additive path `projects/menos/content_editor/` does not exist yet.
- **Working Tree caution:** `CURRENT_STATE.md` already contains a large existing diff (current diff summary shows 323 changed lines, 310 insertions and 13 deletions). Preserve the entire existing diff; do not restore or rewrite this file. The new plan document is untracked, as expected from this task. Line-ending warnings are present on the state file.
- **Decision status:** no additional Master decision is required to continue READ-ONLY dependency mapping. Do not create the new project until the editor/runtime/shared-code split and authoritative authoring-data path are specified well enough to avoid data loss or path breakage.


## HOLD — authoritative authoring database location required (2026-10-09)

- **CONFIRMED:** both `ContentCatalogLoader` and `ObjectPersistence` default to `res://content/menos.sqlite`. Editor save operations (e.g. map editor settings and image editor catalog helpers) call the shared persistence service. Several other editor repositories also save through this shared DB.
- **CONFIRMED:** current `projects/menos/godot/content/` contains `menos.sqlite` and an `editor/` Asset-output directory. The current repository working tree already has a modification to `projects/menos/godot/content/menos.sqlite` before this next migration step; its contents must not be reset or overwritten.
- **INFERENCE:** creating the standalone project while leaving two editable DBs without a clear owner would create split-brain content. Pointing the new project to an absolute path inside the Runtime project would couple the editor back to the Runtime project and defeat the intended separation.
- **PROPOSAL:** establish `projects/menos/content_editor/data/menos.sqlite` as the future authoritative authoring DB. For a safe transition, first copy the current DB to that new path (never move or overwrite the existing DB), compare schema/table counts and row-level/content hashes, then configure the new Editor to use only the copy. Keep the current Runtime project's DB unchanged until the Runtime-package consumer is implemented and validated. After that, the Runtime consumes only a separately published read-only package.
- **HOLD:** this changes which file is authoritative for future authoring, and requires an explicit Master decision before creating/copying the DB or wiring editor writes. No project directory or DB copy has been created.
- Baseline at inspection: HEAD `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`, branch `main`. The Working Tree contains numerous pre-existing changes including `projects/menos/godot/content/menos.sqlite`, `project.godot`, editor/runtime scripts and imported-resource metadata. All must remain untouched.


## Authoring DB copy — completed and verified (2026-10-09)

- **STATUS: PASS — additive copy only.** Master approved the new authoritative authoring DB location.
- Created `projects/menos/content_editor/data/menos.sqlite` by copying the current `projects/menos/godot/content/menos.sqlite`. Source file was not moved, overwritten, or edited by this operation.
- **CONFIRMED:** source SHA-256 and destination SHA-256 both equal `D4FF06697788800FB249C907EC3C068B4C2209AD3ECBE7C8AEDC06A3DF9A9EDC`; both SQLite `integrity_check` results are `ok`; all 31 application tables match; table names, column lists, row counts, and per-table serialized row hashes match exactly.
- **IMPORTANT:** this copy is now the designated future authoring DB by Master decision, but the editor code has not yet been redirected to it. Until the standalone Editor is implemented and verified, the current project still has its existing connection to its own DB. Avoid editing content from both projects during the transition to prevent divergence; source ownership should switch only when the standalone Editor is ready.
- No editor/runtime scripts, project settings, original DB, or Assets were changed in this step. No build/runtime test was run.

## Implementation method gate — additive selective migration

- The existing editor includes 17 primary scenes plus helper scenes/scripts, shared data repositories, the Godot SQLite addon, localization files, image/audio/tileset dependencies, and numerous project-root `res://` paths. A scene-only copy is not viable.
- **PROPOSAL:** create the standalone project's minimal shell first, then migrate the editor scene/script dependency closure and only the required shared utilities, SQLite addon, translations, and referenced editor Assets. Keep the original MENOS project untouched. Use explicit path/config boundaries to point editor writes to its new authoring DB. Runtime-specific gameplay scenes/controllers are excluded unless a genuine editor dependency is identified.
- **Alternative considered:** clone the whole MENOS Godot project and prune it later. Rejected as the default because it duplicates Runtime-only assets/data, obscures the separation boundary, and creates avoidable drift.
- **HOLD before script migration:** the dependency closure must be completed and an explicit file allowlist generated before copying editor implementation files. No existing code or Assets have been migrated yet. This is a reversible, additive implementation plan; if the allowlist reveals substantial coupling that cannot be safely separated in one pass, stop and report before widening scope.


## HOLD — Image Editor has direct Runtime source-code coupling (2026-10-09)

- **CONFIRMED:** the editor dependency scan found `editor/image_editor.gd` directly reads `res://main.gd` to scan image preloads, removes preload references, and replaces Runtime image paths by writing back to that file (functions `_scan_main_preloads`, `_remove_main_preload_reference`, `_replace_main_path`). The standalone Content Editor is not intended to own or modify the Runtime's main script.
- **CONFIRMED:** several shared repositories/loaders hard-code `res://content/menos.sqlite`. A standalone project must explicitly use its own `res://data/menos.sqlite`; copying the files alone will not redirect persistence.
- **CONFIRMED:** the Editor dependency closure includes the SQLite native extension, shared `scripts/` code, editor scripts/scenes, image/tileset/shader resources, audio resources, and translations. A scene-only migration would fail.
- **HOLD:** before migrating `image_editor.gd`, Master must decide how to preserve its Runtime preload-management feature without granting the standalone Editor write access to the Runtime source tree. Options: (A) remove/disable Runtime `main.gd` scanning/editing in the standalone Editor and manage references only through the asset catalog; (B) replace it with an explicit read-only Runtime asset manifest and a separate publish/apply step that remains outside the Editor; (C) keep an opt-in external Runtime-project path and allow changes only through a reviewed export/patch artifact, never direct writes. No code has been migrated or modified. Recommend B for clear separation, but this is a design decision.
- Existing project safety baseline remains HEAD `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`, branch `main`. Working Tree contains extensive pre-existing changes; all preserved. The new authoring DB copy is additive and verified as recorded above.


## Standalone project skeleton and first dependency migration (2026-10-09)

- **STATUS: HOLD — first headless Editor import is blocked by SQLite GDExtension DLL staging.**
- Created additive project shell at `projects/menos/content_editor/project.godot`, using `res://editor/content_editor.tscn` as main scene. Added standalone copies of the `editor/` directory, shared `scripts/` directory, `addons/godot-sqlite/`, editor translation files, relevant shader/tile-set paths, editor output directories, and the verified authoring DB. These are new-project copies only; source project files were not modified.
- **CONFIRMED:** copied shared repositories/loaders now use `res://data/menos.sqlite` in the standalone project. Original Runtime project retains its own path/configuration.
- **CONFIRMED:** `image_editor.gd` in the standalone copy now reads `res://runtime_manifest/runtime_assets.json` only when the manifest explicitly has `access: read_only`; entries use `owner_kind=runtime_manifest`. Runtime manifest entries are non-editable through replacement/deletion, and direct `res://main.gd` read/write helpers were removed from the standalone copy.
- **UNVERIFIED:** the initial manifest is intentionally empty because `main.gd` contains no image `preload()` declarations. This is only the interface/safety boundary, not yet a populated authoritative Runtime asset inventory. The actual Runtime Asset dependency closure still needs a data-driven inventory from catalog/database and scenes.
- **CONFIRMED BLOCKER:** Godot 4.7.2 headless Editor startup reports failure to stage/load `addons/godot-sqlite/bin/libgdsqlite.windows.template_debug.x86_64.dll`, with failed copy to a hidden temporary DLL path. The source and destination DLLs exist and have matching reported size, but no successful project scan/build/runtime result was obtained. A separate existing Godot process is running the original MENOS project (PID 21076); it was not stopped or modified. Avoid deleting temporary DLL artifacts or altering the native addon while the other process may hold it.
- **NEXT:** diagnose the DLL staging failure without affecting the original Runtime process; then run the standalone project scan and resolve missing-resource/script parse errors. Do not declare the Editor runnable until a clean headless import and GUI/Runtime launch are verified.


## Headless validation update (2026-10-09)

- Removed stale `~libgdsqlite...` temporary copy artifacts only from the new standalone project's addon directory after confirming no standalone Godot process was active. Retried Godot 4.7.2 headless editor import; the SQLite DLL staging error did not recur.
- **CONFIRMED:** standalone `--headless --editor --path projects/menos/content_editor --quit` completed without reported errors; standalone main-scene smoke run with `--headless --path ... --quit-after 10` also completed with process exit code 0. This is headless smoke validation only, not GUI/PIE verification.
- Copied `assets/menos/robots/`, `assets/menos/sprites/`, and `sound/` additively into the standalone project to satisfy legacy editor previews and audio editors. Did not copy the 292 MB general `images/` tree because it is not yet proven to be part of the required dependency closure; image-editor source browsing remains to be exercised in GUI verification.
- **CONFIRMED:** no remaining `res://content/menos.sqlite` constants were found in the standalone copied `scripts/*.gd`; copied repositories target `res://data/menos.sqlite`.
- **CONFIRMED:** standalone `editor/image_editor.gd` contains no `res://main.gd` references; runtime-manifest entries are marked read-only and replacement/deletion are blocked. The manifest remains empty pending a reliable Runtime Asset dependency inventory.
- Existing Runtime project changes shown by `git status`/`git diff` are pre-existing worktree changes. This task made no edits to Runtime project source; no reset, commit, or push was performed.
- **Remaining HOLD:** GUI interaction and DB read/write exercise of the standalone editor, full missing-resource/dependency validation, and manifest population. Headless success alone does not establish the independent editor is production-ready.


## 2026-10-09 — Standalone GUI validation follow-up

- STATUS: HOLD. Runtime separation boundary remains intact; no Runtime project source or database was modified during this step.
- Baseline rechecked: HEAD `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`, branch `main`; pre-existing Working Tree changes preserved. No commit/push.
- In the standalone copy only, added missing map tileset textures and selected preview images. Removed 13 copied `.import` sidecars under `assets/menos/maps`, `images/active`, `images/tower`, and `images/Unit` because their recorded source paths did not match the copied filenames; Godot regenerated sidecars for inspected assets.
- Headless editor scan and 10-frame scene smoke commands returned without reported command errors, but this does not establish GUI success. Latest app log still reports missing-loader errors for three image resources and two script/runtime initialization errors: typed `EditorCanvas` assignment receives `Node2D`, and `AssetCatalogWindow` is Nil when `map_editor.gd` connects `close_requested`.
- The Korean atlas filename and its `.import` source path remain inconsistent/corrupted in the log representation. Root cause is not yet confirmed. The two script errors may be independent of the import-path issue.
- GUI navigation, editor initialization, and DB read/write/reload remain UNVERIFIED. Authoritative authoring DB was not used for write testing.
- Next work is limited to read-only diagnosis of resource filename/sidecar consistency and scene/script references in the standalone copy. Do not change Runtime files or DB; stop if a code/design decision or broader asset migration is required.


## 2026-10-09 — Asset dependency closure and GUI launch recheck

- STATUS: PARTIAL PASS / HOLD for full GUI workflow.
- Rechecked baseline: HEAD `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`, branch `main`; existing changes preserved. No commit/push.
- Read-only traversal of the authoring SQLite JSON source fields identified 8 missing catalog preview dependencies present in Runtime (about 15.4 MB). Copied only those files into the standalone Content Editor project; no Runtime assets were changed. Godot then imported the new files using `--headless --editor --import --quit`.
- Relaunched the standalone GUI process. Current `godot.log` has zero matching error/script-error/resource-loader lines after import. Eight warnings remain in `northbridge_tileset.tres` because copied ext_resource UIDs are not valid in the independent project; Godot falls back to the corresponding text paths.
- Both Runtime `content/menos.sqlite` and standalone `data/menos.sqlite` report SQLite `integrity_check=ok`, 31 application tables, and matching SHA-256 `D4FF06697788800FB249C907EC3C068B4C2209AD3ECBE7C8AEDC06A3DF9A9EDC`. No DB write test was performed.
- GUI process launch and error-free latest log are confirmed; actual visual inspection, navigation through editor menus, and DB save/reload remain UNVERIFIED. No claim of EDITOR VERIFIED or PIE VERIFIED.
- Temporary validation log files created during this step were removed. Runtime source/process and authoring DB content were not modified.
- Next: verify GUI navigation and safely test DB write/reload using a disposable DB copy; before expanding asset coverage beyond catalog dependencies, review the exact dependency closure.


## 2026-10-09 — Menu transition verification attempt

- STATUS: HOLD. No project code or DB content changed during this verification attempt.
- Baseline rechecked: HEAD `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`, branch `main`; existing Working Tree changes preserved.
- Standalone GUI process remains running. A headless entry-scene launch returned without visible error output; latest application log previously had zero matching error/script-error/resource-loader lines. This is not visual GUI verification.
- Attempted an isolated temporary Godot menu smoke harness to instantiate the app and emit all editor-menu buttons. The harness produced no test output, so its result is invalid/UNVERIFIED; temporary harness/log files were removed. Do not count this as menu-transition PASS.
- Runtime and authoring DB remain byte-identical with `integrity_check=ok`, 31 application tables, SHA-256 `D4FF06697788800FB249C907EC3C068B4C2209AD3ECBE7C8AEDC06A3DF9A9EDC`. No DB write test was run.
- Actual GUI menu navigation and application-level save/reload remain UNVERIFIED. No commit/push; Runtime files and DB were not modified in this step.
- HOLD reason: this environment exposes no verified desktop screenshot/input action for operating the running GUI, and the temporary headless harness did not yield trustworthy evidence. Avoid inferring GUI success from process launch alone.


## 2026-10-09 — Visual GUI inspection

- STATUS: PARTIAL PASS / HOLD for menu transitions and DB write/reload.
- Captured the Windows desktop and visually inspected `MENOS Content Editor (DEBUG)` running in the standalone project. The Map editor is visibly initialized: top-level editor navigation is rendered, the map canvas shows the loaded map and grid, the left toolbox and asset catalog previews are populated, and the status bar reads `Loaded map: map_01 | Linked stages: stage_01`.
- This establishes GUI rendering and Map editor initialization, not successful transitions for other menus or persistence.
- Attempted clicking Stage through injected Windows mouse input, but the captured screen remained on Map. This is not counted as a successful transition; input injection may not have reached the Godot window. Menu-transition PASS is not claimed.
- Runtime and authoring SQLite DBs remain integrity `ok`, 31 application tables, matching SHA-256 `D4FF06697788800FB249C907EC3C068B4C2209AD3ECBE7C8AEDC06A3DF9A9EDC`. No write test performed.
- No project source or DB content changed. Temporary screenshot files are to be removed. HEAD/branch unchanged; no commit/push.
- Next: obtain reliable interactive input or a corrected isolated test harness to verify menu transitions. DB write/reload must use a disposable DB copy only.


## 2026-10-09 — Menu test retry

- STATUS: HOLD. Retried menu validation using a temporary `SceneTree` harness that instantiated the main scene and invoked each editor-opening method. The process did not produce a trustworthy result report; the report file was absent/empty, so this attempt is INVALID and no menu is marked PASS from it.
- Retried Windows mouse input after foregrounding the standalone Godot window. The captured screen remained on Map; this input route is not reliable enough to validate menu transitions.
- Temporary harness and screenshot files were removed. The standalone GUI remains running. No Runtime files or SQLite DB content were modified. HEAD remains `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`, branch `main`; no commit/push.
- Menu transition and app-level save/reload remain UNVERIFIED. Continue only after establishing a test mechanism with observable results; any persistence test must use a disposable DB copy.


## 2026-10-09 — Isolated menu transition smoke test

- STATUS: PASS for scene-switch smoke test; persistence remains HOLD.
- A temporary Godot `SceneTree` harness was corrected to write its report under the Godot `user://` directory, avoiding an invalid `res://` write. The harness instantiated `editor/content_editor.tscn`, called each of the 15 menu-opening methods, waited for scene-tree frames, and checked `current_editor_scene`, `current_editor`, and its parent against `content_host`.
- RESULT: `PASS total=15 failures=0`. Verified methods: Map, Stage, Mission, Campaign, Faction, Robot, Unit, Tower, Building, Skill, Catalog/Image, VFX, SFX, BGM, Voice. This confirms scene instantiation and host attachment in headless Godot; it is not a full visual or PIE test.
- The harness emitted nonfatal invalid-UID warnings from `northbridge_tileset.tres`; referenced text paths were used as fallback. These warnings are recorded, not changed in this scoped test.
- The result is reliable and observable in `user://_validation_menu_smoke.log`. Temporary harness and workspace report files are to be removed after preserving this summary. No application source, Runtime files, or DB content changed. No commit/push.
- Save/reload is still UNVERIFIED. The editors reference the project-local `res://data/menos.sqlite`; safely testing writes requires an isolated disposable project/DB target rather than swapping the live authoring DB while the GUI may be running.

## 2026-10-09 PROGRESS — Content Editor 정합성 후속 점검

**STATUS: PARTIAL PASS / HOLD**

- **BASELINE:** `E:\atlas`, branch `main`, HEAD `3620dea9a6e0f5be21fa06a2ac79a028bc7259e1`. 기존 Working Tree 변경사항 다수 확인, 보존. Commit/Push 없음.
- **CONFIRMED / FIXED:** `projects/menos/content_editor/editor/content_editor.gd`의 `_set_active_button()`에서 누락된 `BtnSFX`와 `BtnVoice`의 `button_pressed` 동기화 대입을 추가했습니다. 기존 메뉴 전환 동작이나 데이터 경로는 변경하지 않았습니다.
- **STATIC CHECK PASS:** 15개 메뉴 버튼의 활성 상태 대입 존재 여부를 검사했고 15/15 통과했습니다. 이 검사는 코드 정적 확인이며 GUI 동작 검증은 아닙니다.
- **DISPOSABLE DB ROUNDTRIP PASS:** 임시 DB 복사본에서 `asset_catalog.raw_json` 값을 트랜잭션으로 변경하고 재조회한 뒤 원래 값으로 복원했습니다. 임시 DB 파일 삭제를 확인했습니다. 실제 Godot Editor 저장/재열기 검증과는 구분합니다.
- **CONFIRMED:** 원본 Runtime DB와 standalone authoring DB의 SHA-256은 테스트 전후 동일하며 양 DB 모두 SQLite integrity_check=`ok`; 32개 테이블(내부 sqlite_sequence 포함), 애플리케이션 테이블 31개입니다.
- **HOLD / UNVERIFIED:** 이 세션에서 Godot 실행 파일을 확인하지 못해 독립 에디터의 실제 저장/재열기 및 씬/GUI 회귀 테스트를 실행하지 못했습니다. 따라서 EDITOR VERIFIED 및 BUILD VERIFIED로 승격하지 않습니다.
- **OUT OF SCOPE:** Runtime Asset manifest는 여전히 비어 있으며 게시 파이프라인은 구현하지 않았습니다. 그 문제를 이번 수정에서 확장하지 않았습니다.
- **DIFF / SAFETY:** 변경은 `content_editor/editor/content_editor.gd`의 버튼 상태 동기화 두 줄에 한정. `git diff --check` 완료(기존 파일들에 대한 LF/CRLF 경고만 존재). DB/Runtime 소스 수정 없음. Commit/Push 없음.

**NEXT GATE:** Godot 실행 파일/실행 경로를 확인한 뒤 격리된 프로젝트 및 disposable DB로 실제 Editor 저장·재열기를 검증합니다. 실행 환경을 확인할 수 없으면 HOLD를 유지합니다.

## 2026-10-09 FOLLOW-UP — Runtime validation completed after locating Godot

**STATUS: PASS for menu scene + active-state validation and ObjectPersistence round-trip; HOLD for broader editor/runtime acceptance.**

- Godot executable was located at `E:\godot 4.7.2\Godot_v4.7.2-stable_win64.exe`; prior note that it was unavailable is superseded by this follow-up.
- **CODE/EDITOR SCRIPT SCAN:** Godot 4.7.2 `--headless --editor --path projects/menos/content_editor --quit` exited 0; no script/parse/resource errors were matched in the scan output.
- **CONFIRMED FIX:** `BtnSFX` and `BtnVoice` active-state assignments are now included in `_set_active_button()`. `BtnVoice` was also missing `toggle_mode = true` in `editor/content_editor.tscn`; this was added after the first menu-state test exposed the issue. No extra BGM handler change remains; its existing active-state call was preserved.
- **MENU TEST PASS:** A temporary headless Godot test invoked all 15 menu handlers and checked expected scene path, editor attachment under `content_host`, exactly one active button, and target-button state. Final result: `MENU_SCENE_AND_ACTIVE_STATE_PASS total=15`, exit code 0.
- The menu test logged unresolved resource references `res://unit.basic.default` (twice) and `res://tower.rail.default` (once) while instancing Unit/Tower editor scenes. They did not fail the menu assertions; their cause was not investigated or changed because it is outside this active-indicator fix.
- **PERSISTENCE PASS:** A separate temporary Godot test called `ObjectPersistence.save_content_document()` against a disposable copy of the DB, reloaded the `map_01` row, verified the marker, restored the original JSON exactly, and exited 0 (`OBJECT_PERSISTENCE_ROUNDTRIP_PASS`). This verifies the shared persistence method with an isolated DB; it does not constitute full UI-level Editor Save/Reopen acceptance.
- All temporary test scripts, their generated UID files, and the disposable DB were removed. Runtime DB and standalone authoring DB still have identical SHA-256 `d4ff06697788800fb249c907ec3c068b4c2209ad3ecbe7c8aedc06a3df9a9edc`; both integrity checks remain `ok`.
- No Runtime project code/data was changed. No commit or push. Runtime Asset manifest remains empty and package publishing remains unimplemented.

**NEXT GATE:** The approved menu-indicator and persistence checks are complete. Hold broader acceptance until the unresolved Unit/Tower resource references are assessed separately and the Editor's real interactive Save/Reopen flow is validated. Do not broaden automatically.

## 2026-10-09 FOLLOW-UP — Unit/Tower unresolved visual-asset IDs (decision gate)

- **CONFIRMED:** The three `Resource file not found` messages during the 15-menu test are generated by Unit/Tower editor preview code paths, not by missing database rows alone.
- **CONFIRMED:** `allied_units` contains `visuals.sprite` and `visuals.default_image` values equal to `unit.basic.default`; `towers` contains `sprite_anim` / `default_image` values equal to `tower.rail.default`. Both IDs exist in the `visual_assets` catalog, with source paths `res://images/Unit/basic.png` and `res://images/tower/tower.png` respectively.
- **CONFIRMED:** Unit Editor's `_refresh_image_thumbnail()` routes the selected ID to `_texture_from_sprite_data()`, which calls `load(path)` directly rather than resolving the visual-asset ID first. Tower Editor's `_refresh_tower_list()` likewise calls `load(sprite_path)` directly on the `sprite_anim` field. These direct calls explain the logged ID-as-resource-path errors. Unit's separate animated preview path does use `VisualAssetResolver`, so the issue is specifically in thumbnail/list-icon paths inspected here.
- **PROPOSAL / HOLD:** Fixing these preview paths is a separate Unit/Tower editor behavior change, outside the approved SFX/Voice/active-state fix. Do not apply without Master approval. No Unit/Tower source or catalog data was changed.

## 2026-10-09 FOLLOW-UP — Unit/Tower Asset resolution and editor persistence

**STATUS: PASS for scoped fixes and headless tests; HOLD for interactive GUI acceptance and publishing.**

- **CONFIRMED / FIXED:** Unit Editor _refresh_image_thumbnail() now resolves semantic visual Asset IDs with VisualAssetResolver before loading the source texture. When the asset defines a region, the thumbnail uses that region.
- **CONFIRMED / FIXED:** Tower Editor _refresh_tower_list() now resolves semantic Asset IDs before loading the icon texture and applies the configured atlas region when present.
- **MENU + ASSET TEST PASS:** Godot 4.7.2 headless test resolved unit.basic.default and tower.rail.default, invoked all 15 menu handlers, and checked expected scene paths, editor attachment, and exclusive active-button state. Result: MENU_AND_ASSET_RESOLUTION_PASS total=15 assets=2, exit code 0. No script/parse/resource-not-found errors matched the test logs.
- **EDITOR SAVE/RELOAD PASS:** On a disposable copy of the authoring DB, instantiated the actual Unit and Tower editor scenes, changed the selected record name through each editor's UI-backed field, invoked each editor's actual _save_data() handler, reloaded the repository, and verified the saved values. Result: EDITOR_SAVE_RELOAD_PASS unit=basic tower=rail, exit code 0. This is headless scene/handler verification, not manual mouse/keyboard GUI acceptance.
- **DB SAFETY:** Runtime DB and standalone authoring DB both return SQLite integrity ok and identical SHA-256 d4ff06697788800fb249c907ec3c068b4c2209ad3ecbe7c8aedc06a3df9a9edc. Disposable DB and temporary scripts were removed. No source DB was used for writes.
- **DIFF CHECK:** git diff --check passed for checked scoped source paths. No commit/push. No Runtime code changes.
- **UNVERIFIED / OUT OF SCOPE:** Manual GUI Save/Reopen, PIE/runtime behavior, non-empty Runtime Asset manifest, and publishing pipeline remain unverified or incomplete. The manifest/publisher were not changed.

**NEXT GATE:** Scoped Asset resolution, 15-menu state, and editor-handler persistence checks are complete. Broader acceptance still requires explicit interactive GUI verification and a separate decision on Runtime manifest/publishing.

## 2026-10-09 FOLLOW-UP — Interactive GUI acceptance HOLD

- **STATUS: HOLD.** Attempted to open a disposable copy of the Content Editor project for visual GUI acceptance, using a copied authoring DB. The Godot window appeared black and Windows reported the application as not responding. The same result occurred when the disposable copy was configured to open Unit Editor first instead of Map Editor.
- **CONFIRMED:** The GUI process was marked hung by Windows; its client area remained black in captured screenshots. The process logs contained invalid external-resource UID warnings for the existing Northbridge tileset. No causal link between those warnings and the hang is established.
- **UNVERIFIED:** The root cause of the GUI hang is not established. Interactive mouse/keyboard Save/Reopen acceptance therefore was not completed. Headless menu/asset resolution and disposable-DB editor-handler save/reload tests remain passing as recorded above; they do not replace GUI acceptance.
- **SAFETY:** The validation project was a disposable clone outside the source project. Its database hash matched the source authoring DB hash, and the clone and hung validation process were removed/stopped. The source project DB was not written by this GUI attempt. No commit or push.
- **STOP GATE:** Do not alter unrelated map/editor startup logic or the tileset to make the GUI test proceed without a separate diagnosis and approval. Investigate the GUI hang with a narrower read-only diagnosis before another interactive acceptance attempt.

## 2026-10-09 FOLLOW-UP — Interactive GUI acceptance HOLD

- **STATUS: HOLD.** Attempted to open a disposable copy of the Content Editor project for visual GUI acceptance, using a copied authoring DB. The Godot window appeared black and Windows reported the application as not responding. The same result occurred when the disposable copy was configured to open Unit Editor first instead of Map Editor.
- **CONFIRMED:** The GUI process was marked hung by Windows; its client area remained black in captured screenshots. The process logs contained invalid external-resource UID warnings for the existing Northbridge tileset. No causal link between those warnings and the hang is established.
- **UNVERIFIED:** The root cause of the GUI hang is not established. Interactive mouse/keyboard Save/Reopen acceptance therefore was not completed. Headless menu/asset resolution and disposable-DB editor-handler save/reload tests remain passing as recorded above; they do not replace GUI acceptance.
- **SAFETY:** The validation project was a disposable clone outside the source project. Its database hash matched the source authoring DB hash, and the clone and hung validation process were removed/stopped. The source project DB was not written by this GUI attempt. No commit or push.
- **STOP GATE:** Do not alter unrelated map/editor startup logic or the tileset to make the GUI test proceed without a separate diagnosis and approval. Investigate the GUI hang with a narrower read-only diagnosis before another interactive acceptance attempt.

## 2026-10-09 — Master-approved short-term goal / pre-implementation gate

**STATUS: DESIGN APPROVED; IMPLEMENTATION NOT AUTHORIZED.** This is a scoped design approval, not a new Canon entry.

### Approved decisions
- **Map authoring source:** one independent JSON file per map. Each file must carry a stable `map_id`; its identity must not depend solely on its filename. Filename/path convention, schema validation and import/export migration mechanics remain implementation details to specify before coding.
- **Runtime delivery:** a filtered SQLite database plus a versioned manifest plus the transitive closure of referenced Runtime Assets. The publisher must read authoring inputs without mutating them and write only to a fresh isolated output directory. Runtime opens the published database read-only; player profile/save state remains separate.
- **Supported modes:** Campaign and Single Play only. This defines the short-term supported product scope, not proof that existing code and stored map data already conform.
- **Screen ownership:** Runtime owns the title/main menu, settings/menu navigation, gameplay scene, HUD and gameplay behavior. Content Editor owns authoring tools and editable data, including map definitions. Editor preview is an authoring feature and must not become the Runtime screen implementation.

### Confirmed current gaps
- `content_editor/scripts/map_loader.gd` currently persists fixed maps through SQLite tables (`map_01`, `map_01_src`, `map_02`, `map_03`) and dynamic maps through SQLite `map_documents`; it does not yet implement the approved per-map JSON source-of-truth contract. `content_editor/data/maps/` does not yet exist, `godot/content/maps/` contains no `.json` maps, and the one inspected `godot/map_data/northbridge_sector_01.json` is not used by the current SQLite-backed MapLoader path.
- `ContentCatalogLoader` maps legacy `res://content/...json` identifiers to SQLite table names and reads from SQLite. A `.json`-looking path therefore does not prove direct JSON-file loading.
- The Runtime package/manifest flow is incomplete; `content_editor/runtime_manifest/runtime_assets.json` currently has an empty `assets` array. Existing Runtime loader path assumptions and all transitive Asset references still require dependency closure.
- Map Editor and map parsing code still expose/default `multiplayer` metadata and mode toggles. Existing data/code must be audited for compatibility; do not infer that multiplayer is a supported Runtime mode from those fields alone.
- Runtime's configured main scene is `res://ui/title_screen.tscn`. This confirms the main-screen entry point belongs to the Runtime project; the Content Editor is a separate authoring application boundary.

### Proposed implementation contract (PROPOSAL; not yet approved as implementation detail)
1. Authoring source directory: `content_editor/data/maps/`; one UTF-8 JSON file per map named `<map_id>.json`. The JSON `map_id` is authoritative and must match the filename stem. Do not silently overwrite on create/rename; validate path-safe IDs and uniqueness across all map files.
2. Stage/Campaign references: introduce a stable `map_id` reference in the shared content contract. During compatibility transition, accept existing `map_file` values as legacy aliases resolved through a single adapter; do not mass-rewrite stage records until a migration plan and tests are approved.
3. Runtime package representation: publish validated map JSON into a single `map_documents(map_id PRIMARY KEY, raw_json)` table inside the filtered Runtime SQLite DB. Preserve required legacy fixed-map tables/aliases only where the read-only dependency audit proves existing runtime paths need them. This lets authoring remain file-per-map while Runtime retains SQLite delivery.
4. Manifest: include package/schema version, map IDs and source hashes, included table list, normalized asset paths and asset hashes/sizes. The manifest describes the generated package; it is not a second writable source of truth.
5. Unsupported modes: authoring UI and validation should only offer/accept Campaign and Single Play for the approved short-term scope. Preserve legacy multiplayer fields in existing files during the first compatibility stage, but ignore/reject their use as a supported mode and report them clearly; any removal or destructive migration requires separate approval.
6. Minimum checks: valid UTF-8/JSON and schema; unique safe map IDs; Stage reference resolves; referenced IDs/assets exist; generated SQLite integrity check passes; manifest matches generated files; source map JSON and authoring DB hashes remain unchanged; Runtime loader opens the package read-only.

### Approval boundary / next gate
1. Specify map JSON schema, canonical directory/filename convention, stable ID uniqueness, duplicate/missing ID errors, and safe create/rename/delete behavior. Never silently overwrite an existing map file.
2. Define how Campaign/Stage references resolve a map ID to the corresponding authoring JSON file.
3. Define the publish transform: validate map JSON, then materialize the approved map content into the filtered Runtime SQLite package while keeping each JSON file as the authoring source. Manifest records package/schema versions and included maps/assets with integrity metadata.
4. Complete read-only dependency closure from Campaign start through Stage, map, entities, gameplay definitions, visual/audio/VFX/Voice resources and Godot import dependencies. Do not freeze a table allowlist from names alone.
5. Specify how unsupported multiplayer fields/modes are handled for this short-term goal. Do not delete or rewrite existing stored data before compatibility and migration policy is approved.
6. Define minimal validation for malformed JSON, duplicate map IDs, unresolved references, missing assets, package/schema mismatch, source-file hash preservation and Runtime read-only loading.

### Approval boundary / next gate
- Continue READ-ONLY code/data/dependency inspection and document the implementation plan until the remaining design contract is precise enough for a bounded implementation proposal.
- **Stop before modifying code, DBs, map files, Assets or Runtime configuration.** Publisher/loader implementation, migration, Build and Runtime validation require a subsequent implementation authorization. Master will perform final GUI/PIE visual acceptance; automated checks do not replace it.
- Preserve the existing Working Tree. No Commit or Push.

## Canon update: independent project documents and code (2026-10-09)

Master-approved **Canon**: Content Editor and Runtime must manage their documents and code independently. Project-specific documents and implementation belong to their respective project boundaries; shared interfaces require explicit ownership and cross-project impact review. Root integration documents do not replace project-owned documents.

This Canon does not authorize code/document relocation, duplication, database migration or implementation changes. Current conformance of project-local documentation sets and shared-contract governance remains UNVERIFIED and must be assessed READ-ONLY before proposing structural changes.


## 2026-10-09 FOLLOW-UP ? Isolated Runtime package Publisher PoC

**STATUS: PASS for isolated package generation and headless Runtime loader smoke; HOLD for deployment/Production acceptance.** Master authorized continued work through the next decision gate.

### Implemented under Content Editor ownership
- `content_editor/tools/publish_runtime_package.py` builds a filtered SQLite database, `manifest.json`, and the referenced Runtime data Assets into a caller-selected fresh output directory.
- `content_editor/docs/RUNTIME_PACKAGE_PUBLISHER.md` documents invocation, package layout, filtering, compatibility and limitations.
- `content_editor/tests/test_runtime_publisher.py` provides a Python integration test that publishes to a temporary directory and verifies the manifest, assets, database contents, source hashes and refusal to overwrite an existing output.
- `content_editor/data/maps/*.json` remains the map-authoring source. The publisher materializes those maps into both the Runtime-compatible fixed tables and `map_documents`; no authoring JSON or source DB is modified.

### Package policy
- The source table set is checked against an explicit 31-table inventory. `editor`, `player_profile`, and `schema_migrations` are excluded. The generated DB contains the reviewed Runtime content tables plus `map_documents`.
- Legacy `map_01` resolves to the canonical `northbridge_sector_01`; `map_02` and `map_03` remain stable. Campaign Stage, map, Mission and Reward references are checked before output.
- 31 distinct `res://` content-resource paths were found and resolved. Their source files and available adjacent `.import` metadata are copied to a package-local matching path and hashed in the manifest.
- Legacy Multiplayer is reported in manifest warnings and removed from the published `play_modes` list; authoring JSON retains its source metadata unchanged. Supported published modes are Campaign and Single Play.
- Output creation refuses an existing destination, uses a temporary sibling directory, validates output hashes and SQLite integrity, checks authoring input hashes, then renames the completed package into place.

### Verification
- Python publisher integration test: **PASS** (`python -m unittest content_editor.tests.test_runtime_publisher -v`).
- One isolated package generated successfully: 30 SQLite tables including `map_documents` and `runtime_settings`, 3 maps, 31 resource paths, 62 copied files including available `.import` sidecars, and 1 Multiplayer compatibility warning. Output size was approximately 41.1 MB.
- Generated SQLite `PRAGMA integrity_check`: `ok`. Manifest database and asset hashes matched generated files. `editor`, `player_profile`, and `schema_migrations` were absent.
- Godot 4.7.2 headless Runtime smoke against the generated database: **PASS** for fixed map aliases, canonical map ID, Campaign, Stage and robot catalog through existing `MapLoader` / `ContentCatalogLoader` debug test-path overrides.
- Authoring DB and map JSON hashes remained unchanged during integration testing. Runtime DB and Runtime source code were not changed by this publishing work. No GUI/PIE, deployment, Commit or Push.

### Limitations / acceptance boundary
- This is a **data/Asset package PoC**, not a standalone game build. It does not include Runtime scenes/scripts or every hard-coded scene dependency, and it has not been overlaid onto the Runtime project. The production deployment/activation procedure remains separate and unverified.
- The database resource closure is based on `res://` references discovered in included content rows. It does not claim full transitive closure of every Runtime scene/script dependency.
- Runtime loader compatibility was checked through isolated headless tests, not actual exported-game execution or Master PIE acceptance.
- The Runtime project remains independently owned and unchanged. No automatic synchronization or copying into `godot/` occurs.

**Judgment: ACCEPT?STOP for the isolated Publisher PoC.** Next proposal: define and approve a controlled package activation/deployment procedure, including whether the Runtime consumes a selected package from a separate package root or receives an explicit staged replacement of its shipped content DB/Assets. Do not implement either option or perform GUI/PIE until that boundary is approved.


## 2026-10-10 ? Option A: Runtime external package root

Master selected **A ? Runtime consumes a selected package from a separate package root**. Runtime now reads `user://runtime_content_package.json` to select a validated package directory, without overwriting `godot/content/menos.sqlite`. The package helper validates the manifest, DB hash, and each listed Asset's size/hash. ContentCatalogLoader and MapLoader share the selected DB; dynamic content image/audio loading supports PNG/JPG/JPEG/WebP/BMP/TGA and OGG/WAV/MP3. The Publisher keeps the full `editor` table excluded and projects only the title-screen subsection into `runtime_settings`, because the Runtime title screen uses those visual defaults.

**Verification:** Godot 4.7.2 headless scan/import PASS; Publisher Python integration PASS; package DB/map/catalog and external PNG/OGG/WAV smoke PASS; config-based selection PASS. Windows Release export PASS; exported executable headless startup with selected package returned exit code 0 and logged zero `ERROR`, script or SQL errors. The test restored/removes its temporary user config and all package/export artifacts were removed. No GUI/PIE, automatic deployment, commit or push. Static scenes/scripts/shaders and other hard-coded dependencies are not externally overridden. See `godot/docs/runtime_content_package_selection.md` and section 9 of the Runtime supplementation plan.

**Status:** PASS for external package-root PoC and Windows Release headless startup; HOLD for Master Runtime visual/PIE acceptance.


## 2026-10-10 ? A Option Selected: External Runtime Package Root

**STATUS: PASS for headless package selection, fail-closed behavior and Windows Release startup; HOLD for Master PIE/visual acceptance.** Master selected option A (Runtime reads an explicitly configured package from a separate package root). The selection is implemented; it does not activate a package by default.

### Implementation
- Runtime package selection is configured outside the project at `user://runtime_content_package.json`, with an absolute `package_root`. Removing the file returns Runtime to the bundled `res://content/menos.sqlite` path.
- `godot/scripts/runtime_content_package.gd` validates package format, manifest, database SHA-256, and every listed asset's path, size and SHA-256. Only manifest-listed `content_asset` paths can redirect supported image/audio loading into the package root.
- `MapLoader` and `ContentCatalogLoader` read the selected package DB. Image/audio runtime adapters use the package resolver. Runtime database writes remain disabled outside the editor.
- Invalid selection is fail-closed: MapLoader returns no maps/data and ContentCatalogLoader returns no catalog data. An invalid package does not silently fall back to the bundled DB.
- `godot/docs/runtime_content_package_selection.md` records setup, reset, limitations and tests. No GUI package picker, package deployment UI, auto-update, or rollback workflow was added.

### Verification
- Publisher integration test PASS; generated isolated package included 3 maps, 31 referenced resource paths and 62 files.
- `runtime_content_package_smoke_test.gd`: PASS for package validation, MapLoader, legacy map alias, ContentCatalogLoader and external PNG/OGG/WAV loading.
- `runtime_content_package_config_test.gd`: PASS for user config selection and invalid-package fail-closed behavior.
- Content Editor `map_authoring_contract_test.gd`: PASS.
- Windows Desktop Release export: PASS. Exported executable with a valid package config started headlessly with exit code 0 and no Runtime/package/SQL errors.
- Exported executable with a configured missing package root emitted the manifest rejection and did not attempt to open the built-in Runtime DB; fail-closed check PASS.
- User selection config was restored/removed after test. Test package and build are isolated under temporary directories; they are not deployed into the project.
- `git diff --check`: PASS. No Commit/Push; no GUI/PIE.

### Limits / acceptance
- This selects a package root; it is not a GUI package picker and does not copy or install packages. Master must place a generated package at a stable location and configure the selection file explicitly.
- The package is a data/Asset overlay, not a standalone executable. Only the explicitly manifested and supported external image/audio types are redirected; scenes/scripts/materials and all transitive Runtime dependencies are not packaged.
- The headless Release run verifies startup/configuration, not gameplay correctness, visual fidelity, long-session stability or Master PIE acceptance.

**Judgment: ACCEPT?STOP for option A's explicit package selection mechanism and headless Release verification.** Next proposal: Master performs the planned GUI/PIE acceptance. Do not add a GUI picker, automatic deployment/update or further package scope without a new decision.


## 2026-10-10 ? Remove embedded Content Editor from Runtime project

**STATUS: IMPLEMENTED; verification in progress.** Master approved removal of the duplicate editor implementation from `godot/` while preserving Content Editor preview and package publishing.

- Removed the legacy `godot/editor/` directory after confirming it had no pre-existing local modifications.
- Moved 16 tests that directly referenced `res://editor/*` from `godot/tests/` to `content_editor/tests/`, preserving test content and `.uid` files.
- Publisher now requires `--runtime-root` explicitly; it no longer defaults to `../godot`. The Runtime root is a controlled source of referenced data Assets only.
- `godot/project.godot` still launches `res://ui/title_screen.tscn`; `content_editor/project.godot` still launches `res://editor/content_editor.tscn`. Neither project startup configuration refers to the other project.
- Content Editor's preview state helper is owned by `content_editor/editor/image_editor_state.gd`; Runtime's duplicate is no longer present.
- Publisher integration test with explicit `MENOS_RUNTIME_ROOT`: PASS. Publisher CLI with explicit `--runtime-root`: PASS; omission correctly fails.
- Content Editor map JSON contract test: PASS.
- Windows Desktop Release export: PASS; exported headless startup: PASS; export contains zero `res://editor/` resources and no script/parse/load errors.
- Runtime and Content Editor database hashes remained unchanged. `git diff --check`: PASS.
- No DB/schema migration, asset movement, automatic sync, GUI launch, Commit or Push.

**Acceptance:** ACCEPT?STOP for the approved source boundary cleanup. Migrated legacy editor smoke tests were not run wholesale because some may write fixtures or project data; their status remains NOT VERIFIED. Master PIE/visual verification remains separate.


## 2026-10-10 ? Content Editor relocated to sibling project directory

**STATUS: PASS ? relocated project paths verified.** Master moved the Content Editor Godot project from the historical `projects/menos/content_editor/` location to `projects/content_editor/`. Treat `D:\Atlas\projects\content_editor` as the current Content Editor root and `D:\Atlas\projects\menos\godot` as the Runtime root. Earlier sections retain their historical paths because they describe the topology and actions at the time they occurred.

- Confirmed the old Content Editor directory no longer exists and the new directory contains `project.godot`, editor scenes/scripts, DB, JSON maps, Publisher and tests.
- Headless Content Editor startup: PASS. Map authoring contract test: PASS.
- Publisher integration test run from the new project root with explicit `MENOS_RUNTIME_ROOT`: PASS. A real isolated Publisher smoke run produced a package (3 maps, 62 files, 31 referenced resources) and its temporary output was removed.
- Publisher source DB and map defaults are relative to the moved project root; no hard-coded `projects/menos/content_editor` paths were found in Content Editor source/config files. Runtime root remains explicit, so moving the editor does not couple its startup to Runtime.
- The `projects/menos/` integration plan and state files remain with Runtime/integration records; do not move them as part of this relocation.
- No database/schema migration or source asset move occurred as part of this verification. No GUI/PIE, Commit or Push.

## 2026-10-10 — Runtime structure and existing-content management audit

- Master requested Runtime project cleanup and Content Editor support for both publishing content and managing existing Runtime data.
- Read-only baseline: branch `main`, HEAD `a5aadb04e759ca3cb11029e88720055d735bb1ae`; existing working-tree changes were preserved.
- `projects/content_editor/data/menos.sqlite` and `projects/menos/godot/content/menos.sqlite` are separate files with identical current SHA-256 `B681FFF79513E9E0C65481A1ABE750937CAA77970BF1FDB85422CD451449E2A8`. This is a current snapshot only, not an ongoing sync contract.
- Runtime `game_controller.gd` directly preloads `res://content/editor/edited_assets/enemy_giant_edit_292534902.png`; both DBs reference `res://content/editor/edited_assets/range_edit_208771618.png`. This directory cannot be removed as editor code without first migrating content references.
- `.godot`, `build`, and `builds` are generated/cache areas covered by ignore rules. Several root screenshots/candidate images are Git-tracked, so they cannot be assumed disposable. No deletion/move was performed.
- Proposal added at `projects/content_editor/docs/RUNTIME_CONTENT_IMPORT_CONTRACT.md`: explicit Runtime DB/package source selection, read-only preview, confirmed import into the separate authoring DB, backup/staging, per-map JSON materialization, validation, then separate publish and Runtime activation.
- Import overwrite/merge semantics remain PROPOSAL, not Canon. No DB/assets/source code changed; no GUI/PIE, Commit or Push.

## 2026-10-10 — Runtime data management UI and root artifact cleanup

- Added `RUNTIME DATA` to the Content Editor main toolbar with `Import Runtime Data` and `Publish Runtime Package` actions.
- Added `tools/import_runtime_content.py`: preview-only by default; explicit confirmation applies the import; SQLite/schema/map checks occur before writes; authoring DB and maps are backed up; source Runtime DB is never written.
- The Runtime map import reads the actual loader-compatible `map_01` table for `northbridge_sector_01`, preserving 309 objects; reading the separate canonical table would lose those objects.
- Publisher UI selects the Runtime root and a parent output directory, then creates a new timestamped package. Package activation remains separate.
- Archived unreferenced tracked screenshots/contact sheets under `projects/menos/docs/runtime_artifacts/verification/` and road-candidate images under `projects/menos/docs/runtime_artifacts/asset_research/`. Files were moved, not deleted. The pre-existing modified `_ui_baseline_temp.png.import` and image were left untouched.
- Import tests PASS (4/4) on temporary target copies; Publisher integration test PASS; Content Editor headless main-scene startup exit 0 with no script/parse errors. Existing invalid external-resource UID warnings in `northbridge_tileset.tres` remain unrelated and unmodified.
- Both production DB hashes remain unchanged and equal: `B681FFF79513E9E0C65481A1ABE750937CAA77970BF1FDB85422CD451449E2A8`.
- GUI interaction and Master PIE/visual acceptance remain NOT VERIFIED. No Commit/Push.

## 2026-10-10 ? Content Editor Runtime toolbar

- Scope constraints: 3D is out of scope; single-user workflow; preserve current DB table-set equality policy.
- Content Editor starts maximized and has a dedicated `MENOS RUNTIME` toolbar row separate from its long editor-module strip.
- `RUNTIME DATA` exposes import and publish actions; `RUN RUNTIME` selects a Runtime project root and launches it in a separate process after checking `project.godot`.
- Runtime launch is an explicit user action; no automatic package activation, deployment, or direct Runtime DB editing is introduced.
- Headless startup and existing non-GUI tests pass as recorded in `state/CURRENT_STATE.md`; visual interaction remains NOT VERIFIED.

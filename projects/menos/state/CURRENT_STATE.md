# MENOS Current State

작성일: 2026-10-07
상태: CURRENT IMPLEMENTATION STATE

## 1. 기준선

- Branch: main
- Git HEAD: 현재 저장소의 main 기준. 이 문서는 현재 구현 상태를 기록하며 고정 SHA를 권위 정보로 사용하지 않는다.
- Remote: upstream/main 기준 동기화 상태를 별도 Git 상태 확인으로 판단한다.
- Working Tree: 이 문서에는 프로젝트 현재 상태만 기록하며 실제 Git 상태는 작업 시작 시 확인한다.
- Godot: 4.7.2.stable.official
- Runtime Content DB: godot/content/menos.sqlite
- Combat Canon: MENOS_COMBAT_CANON.md
- Integrated Reference: docs/MENOS_MASTER_REFERENCE.md

## 2. 현재 구현 상태

### Content / Data
- 현재 Content authority는 godot/content/menos.sqlite이다.
- MENOS-created godot/content/**/*.json은 현재 0개이다.
- Robot / Unit / Tower / Stage / Map / Asset Catalog / Faction / Mission / Reward / Skill은 SQLite-backed Repository/Loader 경로를 사용한다.
- Content 변경은 ObjectPersistence를 통해 SQLite에 반영한다.
- 사용자 설정(user://)과 Content DB는 분리한다.

### Runtime
- Stage → Encounter → Wave → Group → Enemy 실행 경로가 존재한다.
- Stage Editor는 Encounter/Wave/Enemy Group과 Stage Wave Auto Start, Wave Group Gap, Allied Support를 authoring한다.
- Single Play와 Campaign은 Stage를 공통 Runtime 경로에서 소비한다.
- Robot 직접 조작, 기본 공격, 특수 공격, Special, Skill, Finisher가 구현되어 있다.
- AI Allied Unit과 Fixed Tower의 배치/이동 지원 경로가 존재한다.
- Giant Runtime의 Victory / Defeat / Restart 경로가 존재한다.
- Campaign Stage 전환 및 Reward 처리 경로가 존재한다.
- Combat damage path는 weapon_fired → projectile/effect → damage_requested → damage_* 구조를 사용한다.

### Editor
- Content Editor 및 개별 Content Editor가 존재한다.
- Faction / Skill Editor의 SQLite 서비스 경로가 확인되었다.
- Asset Catalog / Image Editor가 Visual Asset 메뉴를 관리한다.
- VFX Definition/Repository/Loader/Validator/Runtime Adapter/Runtime Instance 및 Editor Scene이 구현되어 있고 Content Editor VFX entry가 활성화되어 있다.
- SFX Definition/Repository/Loader/Validator/Runtime Adapter/Editor가 구현되어 있고 ROBOT_LASER_FIRE P0 pilot과 Content Editor SFX entry가 활성화되어 있다.
- BGM Definition/Repository/Loader/Validator/Runtime Controller/Editor가 구현되어 있고 Faction 01 Normal/Combat/Victory/Defeat pilot과 Content Editor BGM entry가 활성화되어 있다.
- Voice Definition/Repository/Loader/Validator/Runtime Adapter/Editor가 구현되어 있고 VOICE_PILOT_FACTION_01_ATTACK_01_KO P0 pilot과 최소 Wave-start Runtime trigger 및 Content Editor Voice entry가 활성화되어 있다.
- Full Dialogue/Subtitle architecture와 실제 BGM crossfade playback은 현재 범위 밖이며 별도 검증이 필요하다.

### Localization
- locale/en.po, locale/ko.po가 Localization source이다.
- Runtime / Editor는 Godot TranslationServer 경로를 사용한다.
- 과거 JSON Localization 계획은 현재 권위 경로가 아니다.

## 3. 검증 상태

### CODE VERIFIED
- Core combat event/damage path
- Robot / Enemy / Giant / Tower Runtime path
- Campaign / Stage / Map data connection
- SQLite Content loader/repository path
- Content Editor 주요 SQLite 서비스 경로

### BUILD VERIFIED
- Windows Release Export 성공
- godot/builds/MENOS-test-release.exe 생성
- Exported EXE headless startup exit 0
- content/menos.sqlite PCK 포함 확인

### EDITOR VERIFIED
- Content Editor GUI 실행
- Faction / Skill Editor 전환
- VFX / SFX / BGM / VOICE Authoring/Runtime entry 및 관련 Editor Scene 경로 확인
- Content Editor headless initialization PASS

### RUNTIME / PIE
- Title → Single Play → Stage 1 → Wave 진입 경로 확인
- Background Combat Runtime Smoke PASS
- Giant / Combat Timing / Pilot HUD / Fixed Tower background smoke PASS
- Campaign 1 integrated background smoke PASS: 3 stages, Giant, final Campaign Victory
- Background/headless 검증은 PIE VERIFIED가 아니다.
- 실제 화면 가시성/연출에 대한 Master 직접 PIE acceptance는 별도 미확인이다.
- Campaign smoke에서 확인된 reward 21.0, 22.0, 23.0 참조 문제는 StageLoader의 규격화된 reward reference 사용으로 수정되었다.

## 4. 현재 Acceptance Gap

- Giant Boss: background Runtime Smoke PASS / PIE VERIFIED 미확인
- Pilot HUD: background Runtime Smoke PASS / 실제 전투 가시성 및 PIE VERIFIED 미확인
- Fixed Tower: background Runtime Smoke PASS / PIE VERIFIED 미확인
- Attack / Hit / Damage: background Runtime Smoke PASS / PIE VERIFIED 미확인
- Campaign 1: integrated background Runtime Smoke PASS

## 5. 문서 통합

- docs/MENOS_MASTER_REFERENCE.md는 현재 구현과 Canon에 연결되는 통합 기준 문서다.
- state/HANDOFF_HISTORY.md는 과거 작업의 Handoff 기록이다.
- archive/는 과거 문서/기록 보존 영역이다.
- 과거 JSON authority 및 구형 Tower Defense 중심 구조는 현재 권위 경로가 아니다.
- 현재 문서의 책임 경계를 유지하고 병렬 구조를 새로 만들지 않는다.

## 6. 최근 코드 / 문서 정합성 조사

2026-10-07 조사 결과:
- SQLite authority: 코드와 문서 일치
- Visual Asset Repository / Resolver 구조: 코드와 문서 일치
- Localization .po + TranslationServer: 코드와 문서 일치
- 2026-10-07 당시 VFX/SFX/BGM/VOICE 메뉴 상태는 이후 2026-10-08 구현 진행으로 갱신되었다. 현재 VFX/SFX/BGM/VOICE entry와 각 Definition/Authoring/Runtime 기반은 현재 Editor 섹션 및 후속 진행 기록에 반영되어 있다.
- Campaign / Stage / Wave / Combat damage path: 코드와 문서 일치
- 과거 문서의 HEAD 기록은 현재 Git 상태의 권위 정보로 사용하지 않는다.

판정: 현재 조사 범위에서 구현 상태와 핵심 문서의 주요 책임 경계 불일치는 발견되지 않았으며, 현재 상태 보강은 후속 진행 기록에 반영한다.

## Content Editor Authoring Re-review

현재 콘텐츠 authoring 흐름 기준으로 주요 메뉴 책임을 정리한다.

CATALOG → Game Object Authoring → MAP → MISSION → STAGE → CAMPAIGN → Runtime Validation

Catalog는 Visual Asset을 관리하고, Game Object Editor는 게임 객체의 정의/참조를 관리한다. Map은 공간 배치, Mission은 목표, Stage는 실행 단위, Campaign은 Stage 묶음과 진행을 관리한다. 상세 규격은 docs/MENOS_MASTER_REFERENCE.md의 Catalog / Authoring sections에 기록한다.

Status: PROPOSAL / NOT CANON

## 2026-10-08 Development Progress

- Background/headless validation is the Canon test method for screen-related verification.
- Content validation is now PASS with 0 errors / 0 warnings after ODB PK normalization and Map/Team Mask validator alignment.
- Combat timing, Fixed Tower, Pilot HUD, Map/Catalog, Campaign Runtime, and VFX authoring/runtime smoke paths PASS.
- Content Editor VFX entry is enabled and background entry smoke PASS.
- PIE VERIFIED remains unconfirmed; automated/background PASS is not promoted to PIE.
- SFX P0 authoring + technical pilot is implemented through ROBOT_LASER_FIRE: approved CC0 source provenance recorded, runtime WAV imported, SQLite Definition registered, SFX Editor enabled, Save/Reload/Delete validation PASS, Content Validation 0 errors/0 warnings, and Definition?占폗dapter?占폗udioStream resolution verified. Master listening/Production Acceptance remains unverified.
- The temporary VFX SQLite test side-effect was restored to HEAD after approved Editor shutdown. The current SQLite modification is intentional: it registers the ROBOT_LASER_FIRE SFX pilot Definition.

Status: HOLD ??SFX technical pilot PASS; Master listening/Production Acceptance and PIE VERIFIED remain unconfirmed.

## 2026-10-08 SFX Production Candidate Progress
- Existing SFX IDs expanded through Definition binding.
- Four unresolved local SFX assets replaced with CC0 Kenney Interface Sounds candidates.
- Provenance recorded in `godot/sound/ATTRIBUTION.md`.
- SFX technical/authoring validation remains PASS.
- PIE/audio listening acceptance remains UNVERIFIED.
- Next decision gate: Master listening/Production Acceptance of the SFX candidate set.

## 2026-10-08 BGM P0 Pilot Progress
- BGM technical foundation implemented.
- Faction 01 pilot assets registered for Normal/Combat/Victory/Defeat.
- CC0 provenance recorded.
- Automated technical/runtime-controller verification PASS.
- Master listening / Production Acceptance remains UNVERIFIED.


## 2026-10-08 BGM Runtime Binding Progress

CONFIRMED:
- `game_controller.gd` now owns a `BGMController` instance for the active run.
- BGM faction resolution uses the Robot Catalog faction and falls back to `FACTION_01` for the current pilot.
- Run-state synchronization maps `RUNNING ??COMBAT`, `READY/GROWTH ??NORMAL`, `VICTORY ??VICTORY`, and `DEFEAT ??DEFEAT`.
- Stage reset explicitly selects NORMAL; wave start explicitly selects COMBAT.
- Existing gameplay authority and legacy SFX behavior were not changed.
- Godot project headless initialization PASS.
- BGM validation PASS (0 warnings), Definition/Adapter PASS, Runtime Controller PASS.
- Combat Timing and Pilot HUD smoke regressions PASS.
- `git diff --check` PASS.

VERIFICATION:
- CODE VERIFIED ??BGMController binding and run-state mapping inspected.
- BUILD VERIFIED ??Godot 4.7.2 headless project initialization and smoke scripts PASS.
- EDITOR VERIFIED ??BGM definitions/assets resolve through the existing repository/loader path.
- PIE VERIFIED ??UNVERIFIED.
- Actual audio listening / Production Acceptance ??UNVERIFIED.

KNOWN TEST WARNING:
- BGM Runtime Controller smoke exits with ObjectDB/resource cleanup warnings. The functional test prints PASS and exits successfully, but cleanup warnings remain unresolved and are not treated as a clean zero-warning result.

PROPOSAL:
- Do not expand BGM beyond the four-context pilot until Master confirms actual listening/Production Acceptance.
- After acceptance, keep the state-driven binding and add only the required Faction/Context definitions.
- Crossfade is currently a Definition field; actual crossfade playback is not yet implemented.

STATUS: PASS ??BGM runtime-state binding foundation; acceptance gate remains Master listening/PIE.

## 2026-10-08 Voice P0 Technical Foundation Progress

CONFIRMED:
- Voice P0 authoring foundation implemented: Definition, Loader, Repository, Validator, Runtime Adapter, and Voice Editor scene.
- Content Editor VOICE entry is enabled and background entry smoke PASS.
- SQLite voice_definitions catalog exists with one Draft pilot definition: VOICE_PILOT_FACTION_01_ATTACK_01_KO.
- Pilot definition intentionally has no Voice Asset yet; validator reports one warning and preserves Silent Fallback policy.
- Repository Save/Reload/Delete smoke PASS.
- Runtime Adapter Silent Fallback smoke PASS.
- Voice Editor entry smoke PASS.
- Content Editor Voice entry smoke PASS.
- No external Voice source was introduced.

VERIFICATION:
- CODE VERIFIED ??P0 Voice structure inspected and smoke-tested.
- BUILD VERIFIED ??Godot 4.7.2 headless script compilation/execution paths PASS.
- EDITOR VERIFIED ??Voice Editor scene instantiates and Content Editor VOICE button resolves.
- PIE VERIFIED ??UNVERIFIED.
- Actual Voice playback/listening ??UNVERIFIED.

DECISION GATE:
- Master must provide/approve the first actual Voice Asset and its Voice Profile/Dialogue performance before Voice Production Acceptance.

PROPOSAL:
- Keep P0 to one Dialogue/Voice Profile pilot.
- Do not create 3-Faction character voice sets before the pilot is accepted.
- Keep missing Voice non-blocking through Silent Fallback.
- Use a dedicated Voice bus later if/when separate Voice volume control is required; current pilot uses Master because the project has no dedicated Voice bus.
- Do not introduce external generated voice assets without Master approval of the source/tool and production terms.

STATUS: HOLD ??Voice technical foundation PASS; actual voice asset and Master listening acceptance are the next decision gate.


## 2026-10-08 Voice P0 Asset Progress

CONFIRMED:
- Master approved continuation at the Voice decision gate.
- Actual pilot asset exists: `godot/sound/VOICE_PILOT_FACTION_01_ATTACK_01_KO.wav`.
- SQLite pilot Definition now resolves to `res://sound/VOICE_PILOT_FACTION_01_ATTACK_01_KO.wav`.
- Technical audio inspection: 22.05 kHz, mono, 16-bit PCM, 1.242 s, peak 0.3929, RMS 0.0429, no clipping samples detected.
- Background Voice validation/repository/runtime/editor/Content Editor smoke suite PASS with exit code 0.
- Voice source/tool evidence: local Ppaso-TTS repository at `D:\Atlas\_ppaso_voice`; repository LICENSE is Apache 2.0 and README identifies a Korean single-speaker TTS model. Exact generation command, script text, and generation prompt were not recovered.

UNVERIFIED:
- Master listening / pronunciation / acting / character suitability.
- PIE observation of actual Voice playback.
- Production Acceptance / Production Lock.
- Exact source-generation record and prompt provenance.

DECISION GATE:
- Master listening of the pilot Voice Asset is now the minimum remaining acceptance decision. Do not expand Voice content before that decision.

PROPOSAL:
- Keep the single pilot as the acceptance target.
- Record the exact script and generation prompt before any additional Voice asset is produced.
- If the pilot is accepted, add subtitle/dialogue runtime linkage as the next minimum verification rather than expanding character/language coverage.

STATUS: HOLD ??technical Voice asset integration PASS; Master listening/PIE/Production Acceptance remains open.


## 2026-10-08 Voice Runtime Asset Verification Progress

CONFIRMED:
- Godot 4.7.2 reimported the Voice pilot WAV successfully.
- The project resource loads as AudioStream and runtime playback invocation completes in a background headless check.
- Voice validation/repository/editor-entry/Content Editor smoke tests PASS.

UNVERIFIED:
- Human listening quality, pronunciation, acting, character suitability.
- PIE VERIFIED and Production Acceptance.

PROPOSAL:
- Do not expand Voice coverage before pilot acceptance.
- After acceptance, verify one Dialogue -> Voice -> subtitle/runtime E2E path before scaling.


## 2026-10-08 Voice Minimum Runtime Integration

- CONFIRMED: `godot/content/menos.sqlite` `voice_definitions` catalog contains `VOICE_PILOT_FACTION_01_ATTACK_01_KO` with `voice_asset=res://sound/VOICE_PILOT_FACTION_01_ATTACK_01_KO.wav`.
- CONFIRMED: `game_controller.gd` now resolves the pilot through `VoiceDefinitionRepository` and plays it once through `VoiceRuntimeAdapter` / `AudioStreamPlayer` at first Wave start.
- CODE VERIFIED: Godot headless integration test `voice_runtime_integration_smoke_test.gd` passed.
- BUILD/EDITOR VERIFIED: project initialization/editor scan passed after the runtime change.
- PIE VERIFIED: NOT VERIFIED.
- Production Acceptance / human listening: NOT VERIFIED.
- CONFIRMED: SQLite currently contains only `voice_definitions`; no `dialogue_definitions` / Dialogue Catalog table exists. The pilot `dialogue_id` is therefore an identifier for future linkage, not a resolved Dialogue record.
- PROPOSAL: Keep this as a single pilot trigger. Do not add Dialogue/Subtitle architecture or expand Voice asset coverage until Master accepts the pilot playback.
- PROPOSAL: Before Production Lock, recover or recreate exact pilot script/generation provenance and establish one authoritative Dialogue record; do not infer either from the current Voice Definition.


## 2026-10-08 Voice P0 Master Approval

CONFIRMED:
- Master approved the actual Voice P0 pilot asset `VOICE_PILOT_FACTION_01_ATTACK_01_KO`.
- Voice P0 pilot status is now APPROVED as a Production Candidate within the current scope.
- Existing Voice Definition/Repository/Runtime Adapter and minimum Wave-start runtime trigger remain the approved implementation boundary.
- No additional Voice assets, full Dialogue/Subtitle architecture, or 3-Faction Voice expansion were authorized by this approval.

VERIFICATION:
- CODE VERIFIED: PASS.
- BUILD VERIFIED: PASS.
- EDITOR VERIFIED: PASS.
- PIE VERIFIED: NOT VERIFIED as a separate Master runtime observation.
- Master Voice Approval: APPROVED for the P0 pilot candidate.

PROPOSAL:
- On the next Voice work request, establish one authoritative Dialogue record and exact script/provenance, then verify one Dialogue -> Voice -> Subtitle/Presentation E2E path before scaling Voice coverage.
- Record exact Script Text, Voice Profile, Generation Tool/Model, Generation Prompt, Conditions, and source revision before producing additional Voice assets.

STATUS: PASS ??Voice P0 pilot approved; scope remains locked.


## 2026-10-08 Settings P0 E2E Progress

CONFIRMED:
- Master approved preservation of the pre-existing `godot/content/menos.sqlite` working-tree change.
- The approved SQLite difference is isolated to `player_profile.level` (`31 ??33`) and `player_profile.xp` (`2516 ??672`); no table/schema/count changes were found and SQLite integrity checks pass.
- Settings uses `user://menos_settings.cfg` and does not use the authoritative content SQLite path.
- Settings P0 now includes Restore Defaults: confirmation dialog, `ko / 1.0 / 1.0` reset, immediate runtime apply, and persistence.
- Settings P0 E2E background verification PASS: language change, BGM/SFX change, UI reload, Restore Defaults, corrupt-file fallback, and separate-process persistence all passed.
- Windows Release export after the Settings changes completed with exit code 0.
- `git diff --check` PASS.

VERIFICATION:
- CODE VERIFIED: PASS ??SettingsManager and SettingsScreen paths inspected and exercised.
- BUILD VERIFIED: PASS ??Windows Desktop export completed successfully.
- EDITOR VERIFIED: PASS ??Settings scene and new Restore Defaults control loaded during E2E.
- PIE VERIFIED: NOT VERIFIED ??screen observation remains reserved for Master.

UNVERIFIED:
- Master-observed PIE visual presentation of the Settings screen.

PROPOSAL:
- Treat Settings P0 as technically complete and stop implementation work here.
- Next approval gate is Master PIE observation of Settings and, if accepted, the final Campaign 1 production-acceptance decision.
- Do not expand Settings into Display/Controls/Accessibility without a separate Master request.

STATUS: PASS ??Settings P0 implementation and background E2E complete; Master PIE/production acceptance remains open.

## 2026-10-08 Campaign 1 Production Acceptance

CONFIRMED:
- Campaign 1 background Runtime Smoke verification passed: `CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true impact_vfx=true` with process exit code 0.
- CODE / BUILD / EDITOR verification was already PASS before this approval gate.
- Actual screen PIE remained NOT VERIFIED through the available background-only tooling.
- Master approved Campaign 1 Production Acceptance after the completed verification and approval gate.

VERIFICATION:
- CODE VERIFIED: PASS.
- BUILD VERIFIED: PASS.
- EDITOR VERIFIED: PASS.
- PIE VERIFIED: NOT VERIFIED as a separate screen-observation status.
- Production Acceptance: APPROVED by Master.

SCOPE:
- Campaign 1 existing integrated flow only: Stage -> Wave -> general combat -> Giant -> Victory/Defeat.
- No new gameplay, UI expansion, asset replacement, or unrelated cleanup authorized by this approval.

STATUS: PASS -- Campaign 1 Production Acceptance approved; scope locked; stop at this gate.


## 2026-10-08 Gameplay P1 Implementation Gate

CONFIRMED:
- Master approved proceeding with Serra/Copilot's P1 implementation proposal within the locked Gameplay scope.
- Implementation scope is limited to P1-2 Player Profile persistence boundary, P1-3 `defeat_giant` objective gating, and P1-4 Gameplay-critical Stage/Wave/Map/Enemy/Lane reference fail-fast validation.
- P1-1 Reward Gold economy semantics remain intentionally UNRESOLVED; no new economic meaning or next-Stage build-budget transfer is authorized by this instruction.
- Existing Campaign 1 Production Acceptance remains approved and is not being reopened; only minimum regression protection is required.
- Commit / Push are not authorized for this work stage.
- Existing working-tree changes, including `godot/content/menos.sqlite`, Map Editor, Settings, and unrelated `mk` changes, must be preserved.

VERIFICATION:
- Implementation result: PENDING ??Serra/Copilot has the execution task; completion report has not yet been added to `state/COPILOT_TO_MARIE.md`.
- CODE VERIFIED: NOT YET for the new P1 changes.
- BUILD VERIFIED: NOT YET for the new P1 changes.
- EDITOR VERIFIED: NOT YET for the new P1 changes.
- PIE VERIFIED: NOT VERIFIED.

SAFETY:
- Baseline checked before this record: HEAD `335f3800b111f45c1b246148d8b4b2a50ee092bb`, Branch `main`, Working Tree dirty with the pre-existing changes listed by Git.
- No project code, Asset, SQLite content, or unrelated change was modified by this documentation update.

STATUS: HOLD ??waiting for Serra/Copilot implementation and minimum verification report. Stop at this gate until the result is reviewed.

PROPOSAL:
- After Serra reports completion, Marie reviews the actual diff and verification evidence before any further decision.
- No automatic P2 expansion or Commit/Push follows from a successful P1 result.


## 2026-10-08 Current State Reconciliation after Gameplay P1

CONFIRMED:
- Gameplay P1 implementation was approved, committed as 94b53fe3, and pushed to origin/main.
- P1-2 Player Profile persistence boundary, P1-3 defeat_giant objective gating, and P1-4 Stage/Wave/Map/Enemy/Lane fail-fast validation are complete.
- P1-1 Reward Gold economy semantics remain UNRESOLVED and unchanged.
- Campaign 1 Production Acceptance remains approved and is not reopened.
- Existing Settings, Map Editor, SQLite, and unrelated mk working-tree changes remain outside the P1 commit.

VERIFICATION:
- CODE VERIFIED: PASS.
- BUILD VERIFIED: PASS.
- EDITOR VERIFIED: PASS.
- PIE VERIFIED: NOT VERIFIED as separate Master screen observation.
- Commit/Push: PASS.

NEXT DEVELOPMENT GATE:
- Reconcile Map Editor P0 against the integrated development plan.
- Investigate New/Duplicate/Delete and Grid Snap semantics read-only first.
- Do not implement identity/deletion/Production Lock/robot_id semantics without an authoritative decision.

STATUS: PASS - Gameplay P1 closed; Map Editor P0 is the next controlled work area.

PROPOSAL:
Proceed with Map Editor schema/persistence read-only investigation. Stop and report when a Canon/design decision is required.


## 2026-10-08 Map Editor P0 Investigation Result

PROGRESS:
- READ-ONLY inspection of MapEditor, EditorCanvas, and MapLoader completed.
- Persistence is fixed SQLite document mapping (map_01, map_01_src, map_02, map_03).
- Save updates an existing document row; generic create/duplicate/delete paths do not exist.
- 32px grid semantics are already intrinsic to placement and resize; no separate Snap toggle is required for current P0 behavior.

CONFIRMED:
- New/Duplicate/Delete require an authoritative map identity and persistence policy before implementation.
- Delete also requires reference protection and hard-delete/soft-delete semantics.

STATUS: HOLD - Canon/design decision required before Map CRUD implementation.

PROPOSAL:
Keep current Map Editor unchanged. Decide the authoritative map identity/CRUD policy, then resume. No automatic implementation beyond this gate.


## 2026-10-08 Map CRUD Implementation Result

CONFIRMED:
- Master approved stable Map ID identity, protected canonical maps, dynamic author-created map records, hard-delete for unreferenced dynamic maps, and Stage reference protection.
- Map CRUD implementation is complete within this approved scope.
- 32px grid behavior remains intrinsic; no Snap toggle was added.

IMPLEMENTED:
- Map selector.
- New Map.
- Duplicate Map.
- Delete Map with Stage-reference protection.
- Dynamic SQLite map_documents persistence.
- Dynamic map save/load serialization compatible with the existing raw map schema.

VERIFICATION:
- CODE VERIFIED: PASS.
- BUILD/Editor headless compile: PASS.
- MAP_CRUD_SMOKE_PASS.
- MAP_NEW_SMOKE_PASS.
- MAP_DYNAMIC_SAVE_SMOKE_PASS.
- PIE VERIFIED: NOT VERIFIED.
- Test DBs were copies; production menos.sqlite was not changed by CRUD smoke tests.

STATUS: PASS ??Map CRUD implementation gate complete; awaiting final diff review before commit/push.

PROPOSAL:
Perform final Map Editor diff/regression review now, then stop for Master Commit/Push approval if no unintended changes are found.

## 2026-10-08 Map Editor Final Diff / Regression Review

CONFIRMED:
- Final read-only review of the current Map Editor working-tree diff completed.
- Current `godot/editor/map_editor.gd` delta is limited to Save-time `validate_map()` blocking and Save As Map ID preservation; no unrelated Map CRUD code was changed in this delta.
- `godot/editor/map_editor.gd` and `godot/scripts/map_loader.gd` pass Godot 4.7.2 `--check-only` parsing.
- Existing production maps `map_01`, `map_02`, and `map_03` all pass `MapEditor.validate_map()` with 0 errors / 0 warnings in a background headless scene-level gate.
- `git diff --check` PASS.
- No production SQLite write was performed by the validation gate.

VERIFICATION:
- CODE VERIFIED: PASS.
- BUILD / SCRIPT PARSE VERIFIED: PASS.
- EDITOR DATA VALIDATION: PASS for the three existing production maps.
- PIE VERIFIED: NOT VERIFIED.
- GUI Save → Reload → Runtime screen observation: NOT VERIFIED.

STATUS: PASS — Map Editor final diff/regression review complete; commit/push remains a separate Master approval gate.

PROPOSAL:
- Do not modify Map Editor further in the current scope.
- Treat this scope as ACCEPT·STOP pending Master Commit/Push approval.
- Do not begin another Map feature or expand CRUD semantics automatically.


## 2026-10-08 P0 E2E Visual Gate Result

STATUS: PASS — Unit/Tower Visual Asset Catalog boundary established for minimum E2E; full PIE remains unverified.

CONFIRMED:
- Existing Unit/Tower image assets were reused; no new image asset was generated.
- Added Catalog Visual Assets: `unit.basic.default` → `res://images/Unit/basic.png`, and `tower.rail.default` → `res://images/tower/tower.png`.
- `allied_units.basic.visuals.sprite` and `default_image` now reference `unit.basic.default`.
- `towers.rail.sprite_anim`, `default_image`, and `animations.idle` now reference `tower.rail.default`.
- The data migration was applied in one SQLite transaction and persisted successfully.
- Source image files exist at the registered paths.
- Runtime code path was confirmed: Unit profile/sprite resolves through `VisualAssetResolver`; Tower sprite resolves through `VisualAssetResolver`.
- The failed first migration attempt rolled back without partial data persistence.

VERIFICATION:
- CODE VERIFIED: PASS — Catalog IDs, Unit/Tower definitions, Resolver paths, and runtime texture loading paths inspected.
- DATA / PERSISTENCE VERIFIED: PASS — SQLite transaction commit and post-write query verification passed.
- BUILD VERIFIED: NOT VERIFIED by the new custom gate; existing Godot project initialization is known to pass.
- EDITOR VERIFIED: PARTIAL — Unit/Tower Editor Save/Reload code paths were inspected, but a fresh GUI Save/Reload operation was not executed.
- PIE VERIFIED: NOT VERIFIED.
- RUNTIME VISUAL DISPLAY: NOT VERIFIED as a screen observation.
- Existing `editor_data_smoke_test.gd` currently fails at an unrelated `MapEditorMain.current_map_data` access and was not used to promote this gate to PASS.

UNVERIFIED:
- Actual Unit Editor Save → Reload → Runtime display.
- Actual Tower Editor Save → Reload → Runtime display.
- Master-observed PIE visual presentation.

PROPOSAL:
- Keep the common Catalog Visual Asset contract unchanged.
- Treat `unit.basic.default` and `tower.rail.default` as the minimum representative data gate, not as completion of every Unit/Tower visual asset.
- Before Production Lock, perform one real Editor Save → Reload → Runtime display verification for Unit and Tower separately.
- Do not expand Visual Asset registration to every Unit/Tower until that minimum E2E gate passes.

## 2026-10-08 Map Commit / Working Tree Consolidation Gate

CONFIRMED:
- Map Editor P0 validation change was committed as `53d97f7b` (`Validate Map Editor saves`) and pushed to `upstream/main`.
- `main` and `upstream/main` are aligned at `53d97f7b` for that commit.
- Remaining working-tree changes are separate accumulated document, Content Editor, presentation-pipeline, SQLite, and asset-import changes; they were not included in the Map commit.
- Temporary Godot SQLite extension files generated during background probing were cleaned; no source files were intentionally changed by that cleanup.

STATUS: HOLD — the Map Editor commit is closed. The remaining working tree requires separate scope classification and verification before any additional commit/push.

PROPOSAL:
- Do not bulk-commit the remaining working tree.
- Classify the remaining changes into coherent gates and verify each gate independently before proposing another commit.
- Keep PIE / Master visual acceptance separate from technical commits.


### Current Authoring Boundary ? STAGE / MISSION / REWARD

- MISSION Editor is the sole Mission mutation owner.
- STAGE Editor exposes Mission as a reference; Mission definition fields are read-only and are not persisted by STAGE SAVE.
- STAGE Editor remains the Reward mutation owner for the current scope.
- STAGE + Reward persistence uses one SQLite transaction via `ObjectPersistence.save_catalog_pair_atomic()`.
- Mission reference existence is validated before persistence.
- Godot 4.7.2 `--check-only` passed for `stage_editor.gd`; PIE remains NOT VERIFIED.

## GUI Verification Tooling — 2026-10-08

- 듀얼 모니터/대형 이미지 환경 GUI 검증 수단 확보.
- mss + 축소 캡처 + pyautogui 입력 방식을 사용한다.
- winapp CLI는 창/DPI/물리 좌표 진단용으로 유지한다.
- pywinauto는 검증 후 제거하였다.
- ROBOT → UNIT → TOWER Editor 진입 및 RELOAD 최소 GUI E2E PASS.
- GUI 검증은 Master PIE acceptance와 구분한다.

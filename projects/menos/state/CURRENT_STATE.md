# MENOS Current State

?�성?? 2026-10-07
?�태: CURRENT IMPLEMENTATION STATE

## 1. 기�???

- Branch: `main`
- Git HEAD: `main` branch???�제 HEAD??Git??권위 ?�천?�며 문서?�는 고정 SHA�?기록?��? ?�는??
- Remote: `upstream/main`�??�기?�된 ?�태�??��??�다.
- Working Tree: ?�재 검�?기�??�서??clean ?�태�?목표�??�다.
- Godot: `4.7.2.stable.official`
- Runtime Content DB: `godot/content/menos.sqlite`
- Combat Canon: `MENOS_COMBAT_CANON.md`
- Integrated Reference: `docs/MENOS_MASTER_REFERENCE.md`

## 2. ?�제 구현 ?�태

### Content / Data
- ?�재 Content authority??`godot/content/menos.sqlite`??
- MENOS-created `godot/content/**/*.json`???�재 0개다.
- Robot / Unit / Tower / Stage / Map / Asset Catalog / Faction / Mission / Reward / Skill?� SQLite-backed Repository/Loader 경로�??�용?�다.
- Content ?�?��? `ObjectPersistence`�??�해 SQLite??반영?�다.
- ?�용???�???�이??`user://`)??Content DB?� 분리?�다.

### Runtime
- Stage ??Encounter ??Wave ??Group ??Enemy ?�행 경로가 존재?�다.
- Stage Editor가 Encounter/Wave/Enemy Group�??�께 Stage�?Wave Auto Start, Wave Group Gap, Allied Support�??�집?????�다.
- Single Play?� Campaign 모두 ?�택/진행??Stage ?�이?��? ?�일 Runtime 경로?�서 ?�비?�다.
- Robot 직접 ?�동, 기본 공격, ?��??�택, Special, Skill, Finisher가 구현?�어 ?�다.
- AI Allied Unit�??�전 배치 Fixed Tower???�동 지??경로가 존재?�다.
- Giant Runtime�?Victory / Defeat / Restart 경로가 존재?�다.
- Campaign Stage ?�환�?Reward 처리 경로가 존재?�다.
- Combat damage path??`weapon_fired ??projectile/effect ??damage_requested ??damage_*` 구조??

### Editor
- Content Editor �?개별 Content Editor?�이 존재?�다.
- Faction / Skill Editor??SQLite ?�비 경로가 ?�인?�었??
- Asset Catalog / Image Editor가 Visual Asset 메�??�이?��? 관리한??
- VFX Definition/Repository/Loader/Validator/Runtime Adapter/Runtime Instance are implemented and use the SQLite `vfx_definitions` Catalog. The Content Editor VFX menu button is now enabled and its opener/scene path passed background smoke validation. SFX menu button is disabled; SFX has legacy direct-file Runtime playback plus SFX bus/settings, but no dedicated Definition/Authoring layer. BGM menu button is disabled; BGM currently has bus/settings only, with no dedicated Definition/Authoring/Runtime playback layer. VOICE menu button is disabled; no dedicated Voice Definition/Authoring/Runtime dialogue layer is currently established. Recommended menu implementation order remains VFX acceptance ??SFX Pilot ??BGM Pilot ??VOICE Pilot.

### Localization
- `locale/en.po`, `locale/ko.po`가 Localization source??
- Runtime / Editor??Godot `TranslationServer` 경로�??�용?�다.
- 과거 JSON Localization 계획?� ?�재 ?�행 권한???�다.

## 3. 검�??�태

### CODE VERIFIED
- Core combat event/damage path
- Robot / Enemy / Giant / Tower Runtime path
- Campaign / Stage / Map data connection
- SQLite Content loader/repository path
- Content Editor 메뉴 �?주요 SQLite ?�비 경로

### BUILD VERIFIED
- Windows Release Export ?�공
- `godot/builds/MENOS-test-release.exe` ?�성
- Exported EXE headless startup exit 0
- `content/menos.sqlite` PCK ?�함 ?�인

### EDITOR VERIFIED
- Content Editor GUI ?�행
- Faction / Skill Editor ?�환
- VFX Authoring/Runtime code and Editor Scene are implemented. The Content Editor VFX menu button is enabled and background entry validation passes. SFX/BGM/VOICE menu buttons are disabled; SFX legacy Runtime/bus/settings are present, while BGM has bus/settings only.
- Content Editor headless initialization PASS

### RUNTIME / PIE
- Title ??Single Play ??Stage 1 ??Wave 진입 경로 ?�인
- Background Combat Runtime Smoke PASS
- Giant / Combat Timing / Pilot HUD / Fixed Tower background smoke PASS
- Campaign 1 integrated background smoke PASS: 3 stages, Giant, final Campaign Victory
- ?�동??�?background/headless 검증�? PIE VERIFIED�??�격?��? ?�는??
- ?�제 ?�면 가?�성/?�출�?Master 직접 PIE acceptance??미확?�이??
- Campaign smoke?�서 ?�인??reward `21.0`, `22.0`, `23.0` 참조 문제??StageLoader???�규?�된 reward reference ?�용?�로 ?�정?�다.

## 4. ?�재 Acceptance Gap

- Giant Boss: background Runtime Smoke PASS / PIE VERIFIED 미확??
- Pilot HUD: background Runtime Smoke PASS / ?�제 ?�투 가?�성 �?PIE VERIFIED 미확??
- Fixed Tower: background Runtime Smoke PASS / PIE VERIFIED 미확??
- Attack ??Hit ??Damage: background Runtime Smoke PASS / PIE VERIFIED 미확??
- Campaign 1: integrated background Runtime Smoke PASS

## 5. 문서 ?�합??

- `docs/MENOS_MASTER_REFERENCE.md`???�재 구현�?Canon???�결?�는 ?�합 기�??�다.
- `state/HANDOFF_HISTORY.md`????��??Handoff 기록?�다.
- `archive/docs_consolidated_2026-10-07/`????�� ?�료?�며 ?�재 ?�행 권한???�다.
- 과거 JSON authority, 구형 Tower Defense 중심 구조, 과거 Git HEAD�??�재 ?�실�??�사?�하지 ?�는??
- ?�재 ?�일 구조 책임 경계�??��??�며 병렬 구조�??�의�?만들지 ?�는??

## 6. 최근 코드 ??문서 ?�합??조사

2026-10-07 코드 ??문서 ?��?결과:
- SQLite authority: 코드?� 문서 ?�치
- Visual Asset Repository / Resolver 구조: 코드?� 문서 ?�치
- Localization `.po ??TranslationServer`: 코드?� 문서 ?�치
- VFX Definition/Repository/Loader/Validator/Runtime Adapter/Runtime Instance and dedicated VFX Editor Scene are implemented; SQLite `vfx_definitions` contains the `impact_explosion` pilot. The Content Editor VFX menu button is enabled and its entry path passed background validation. One authored VFX definition and Runtime adapter/instance path also passed smoke validation. SFX has legacy Runtime/bus/settings but no Definition/Authoring layer. BGM has bus/settings but no Definition/Authoring/Runtime playback layer. Voice has no dedicated Definition/Authoring/Runtime dialogue layer. SFX/BGM/VOICE menu entries remain disabled.
- Campaign / Stage / Wave / Combat damage path: 코드?� 문서 ?�치
- 기존 문서??HEAD ?�기�??�제 HEAD보다 ?�처???�어 ?�재 기�??�으�?갱신??

?�정: ?�재 조사 범위?�서 기능 구현???�못 기술???�심 문서 ?�류??발견?��? ?�았?�며, 기�????�재 ?�태 ?�현??보완?�다.

## Content Editor Authoring Re-review

?�제 콘텐�??�작 ?�름 기�??�로 주요 메뉴 책임???�정?�했??

CATALOG ??Game Object Authoring ??MAP ??MISSION ??STAGE ??CAMPAIGN ??Runtime Validation

Catalog??Visual Asset??관리하�?객체 Editor??게임 ?��?/?�치�?관리한?? Map?� 공간�?배치�? Mission?� 목표�? Stage?????�의 ?�행 ?�이?��?, Campaign?� Stage ?�서�??�당?�다. ?�세 ?�펙?� docs/CONTENT_EDITOR_RUNTIME_AUTHORING_REQUIREMENTS.md??기록?�다.

Status: PROPOSAL / NOT CANON

## 2026-10-08 Development Progress

- Background/headless validation is the Canon test method for screen-related verification.
- Content validation is now PASS with 0 errors / 0 warnings after ODB PK normalization and Map/Team Mask validator alignment.
- Combat timing, Fixed Tower, Pilot HUD, Map/Catalog, Campaign Runtime, and VFX authoring/runtime smoke paths PASS.
- Content Editor VFX entry is enabled and background entry smoke PASS.
- PIE VERIFIED remains unconfirmed; automated/background PASS is not promoted to PIE.
- SFX P0 authoring + technical pilot is implemented through ROBOT_LASER_FIRE: approved CC0 source provenance recorded, runtime WAV imported, SQLite Definition registered, SFX Editor enabled, Save/Reload/Delete validation PASS, Content Validation 0 errors/0 warnings, and Definition?�Adapter?�AudioStream resolution verified. Master listening/Production Acceptance remains unverified.
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
- Run-state synchronization maps `RUNNING → COMBAT`, `READY/GROWTH → NORMAL`, `VICTORY → VICTORY`, and `DEFEAT → DEFEAT`.
- Stage reset explicitly selects NORMAL; wave start explicitly selects COMBAT.
- Existing gameplay authority and legacy SFX behavior were not changed.
- Godot project headless initialization PASS.
- BGM validation PASS (0 warnings), Definition/Adapter PASS, Runtime Controller PASS.
- Combat Timing and Pilot HUD smoke regressions PASS.
- `git diff --check` PASS.

VERIFICATION:
- CODE VERIFIED — BGMController binding and run-state mapping inspected.
- BUILD VERIFIED — Godot 4.7.2 headless project initialization and smoke scripts PASS.
- EDITOR VERIFIED — BGM definitions/assets resolve through the existing repository/loader path.
- PIE VERIFIED — UNVERIFIED.
- Actual audio listening / Production Acceptance — UNVERIFIED.

KNOWN TEST WARNING:
- BGM Runtime Controller smoke exits with ObjectDB/resource cleanup warnings. The functional test prints PASS and exits successfully, but cleanup warnings remain unresolved and are not treated as a clean zero-warning result.

PROPOSAL:
- Do not expand BGM beyond the four-context pilot until Master confirms actual listening/Production Acceptance.
- After acceptance, keep the state-driven binding and add only the required Faction/Context definitions.
- Crossfade is currently a Definition field; actual crossfade playback is not yet implemented.

STATUS: PASS — BGM runtime-state binding foundation; acceptance gate remains Master listening/PIE.

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
- CODE VERIFIED — P0 Voice structure inspected and smoke-tested.
- BUILD VERIFIED — Godot 4.7.2 headless script compilation/execution paths PASS.
- EDITOR VERIFIED — Voice Editor scene instantiates and Content Editor VOICE button resolves.
- PIE VERIFIED — UNVERIFIED.
- Actual Voice playback/listening — UNVERIFIED.

DECISION GATE:
- Master must provide/approve the first actual Voice Asset and its Voice Profile/Dialogue performance before Voice Production Acceptance.

PROPOSAL:
- Keep P0 to one Dialogue/Voice Profile pilot.
- Do not create 3-Faction character voice sets before the pilot is accepted.
- Keep missing Voice non-blocking through Silent Fallback.
- Use a dedicated Voice bus later if/when separate Voice volume control is required; current pilot uses Master because the project has no dedicated Voice bus.
- Do not introduce external generated voice assets without Master approval of the source/tool and production terms.

STATUS: HOLD — Voice technical foundation PASS; actual voice asset and Master listening acceptance are the next decision gate.


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

STATUS: HOLD — technical Voice asset integration PASS; Master listening/PIE/Production Acceptance remains open.


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

STATUS: PASS — Voice P0 pilot approved; scope remains locked.


## 2026-10-08 Settings P0 E2E Progress

CONFIRMED:
- Master approved preservation of the pre-existing `godot/content/menos.sqlite` working-tree change.
- The approved SQLite difference is isolated to `player_profile.level` (`31 → 33`) and `player_profile.xp` (`2516 → 672`); no table/schema/count changes were found and SQLite integrity checks pass.
- Settings uses `user://menos_settings.cfg` and does not use the authoritative content SQLite path.
- Settings P0 now includes Restore Defaults: confirmation dialog, `ko / 1.0 / 1.0` reset, immediate runtime apply, and persistence.
- Settings P0 E2E background verification PASS: language change, BGM/SFX change, UI reload, Restore Defaults, corrupt-file fallback, and separate-process persistence all passed.
- Windows Release export after the Settings changes completed with exit code 0.
- `git diff --check` PASS.

VERIFICATION:
- CODE VERIFIED: PASS — SettingsManager and SettingsScreen paths inspected and exercised.
- BUILD VERIFIED: PASS — Windows Desktop export completed successfully.
- EDITOR VERIFIED: PASS — Settings scene and new Restore Defaults control loaded during E2E.
- PIE VERIFIED: NOT VERIFIED — screen observation remains reserved for Master.

UNVERIFIED:
- Master-observed PIE visual presentation of the Settings screen.

PROPOSAL:
- Treat Settings P0 as technically complete and stop implementation work here.
- Next approval gate is Master PIE observation of Settings and, if accepted, the final Campaign 1 production-acceptance decision.
- Do not expand Settings into Display/Controls/Accessibility without a separate Master request.

STATUS: PASS — Settings P0 implementation and background E2E complete; Master PIE/production acceptance remains open.

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
- Implementation result: PENDING — Serra/Copilot has the execution task; completion report has not yet been added to `state/COPILOT_TO_MARIE.md`.
- CODE VERIFIED: NOT YET for the new P1 changes.
- BUILD VERIFIED: NOT YET for the new P1 changes.
- EDITOR VERIFIED: NOT YET for the new P1 changes.
- PIE VERIFIED: NOT VERIFIED.

SAFETY:
- Baseline checked before this record: HEAD `335f3800b111f45c1b246148d8b4b2a50ee092bb`, Branch `main`, Working Tree dirty with the pre-existing changes listed by Git.
- No project code, Asset, SQLite content, or unrelated change was modified by this documentation update.

STATUS: HOLD — waiting for Serra/Copilot implementation and minimum verification report. Stop at this gate until the result is reviewed.

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

STATUS: PASS — Map CRUD implementation gate complete; awaiting final diff review before commit/push.

PROPOSAL:
Perform final Map Editor diff/regression review now, then stop for Master Commit/Push approval if no unintended changes are found.

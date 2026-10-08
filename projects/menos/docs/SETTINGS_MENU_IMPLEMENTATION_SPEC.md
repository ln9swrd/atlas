# MENOS — SETTINGS MENU IMPLEMENTATION SPEC

Status: PROPOSAL / P0 boundary defined from current implementation

## 1. Purpose

Settings is a Runtime User Settings domain, not a Content Authoring menu.

`Settings UI → SettingsManager → user://menos_settings.cfg → Runtime presentation/audio/localization`

Settings must not edit Content Catalog, Stage, Mission, Campaign, Robot, Unit, Tower, Building, Faction, VFX, SFX, BGM, or Voice content definitions.

## 2. Confirmed current implementation

Existing files:
- `godot/ui/settings_screen.tscn`
- `godot/ui/settings_screen.gd`
- `godot/scripts/settings_manager.gd`

Current persistent settings:

| Section | Key | Type | Allowed | Default |
|---|---|---|---|---|
| general | language | String | `ko`, `en` | `ko` |
| audio | bgm_volume | float | `0.0..1.0` | `1.0` |
| audio | sfx_volume | float | `0.0..1.0` | `1.0` |

Current runtime behavior:
- Language changes apply through `TranslationServer`.
- BGM/SFX values apply to AudioServer BGM/SFX buses.
- Values persist to `user://menos_settings.cfg`.
- Missing/invalid language falls back to `ko`.
- Audio values are clamped to `0.0..1.0`.

## 3. P0 Settings UI

### General
- Language selector: Korean / English.
- Restore Defaults.

### Audio
- BGM Volume: 0–100% slider.
- SFX Volume: 0–100% slider.

### Actions
- Back.

Every control must expose:
`Label → Control → Current Value → Apply Behavior → Persistence → Validation`.

## 4. Setting schema contract

Every setting must define:
- Section
- Stable Key
- Type
- Default
- Allowed Values / Range
- Runtime Consumer
- Apply Mode: immediate / deferred / restart-required
- Persistence
- Validation
- Reset Behavior

Setting keys are persistent identifiers and must not be casually renamed after release.

## 5. Persistence contract

Player settings are stored only in:
`user://menos_settings.cfg`

Rules:
1. Never store player settings in the authoritative content SQLite database.
2. Never store them in Content Catalog/domain JSON.
3. Missing file is valid and loads defaults.
4. Missing key loads its default.
5. Invalid type/value is normalized or replaced by default.
6. A settings save failure must not affect content data.
7. Settings must survive application restart.

## 6. Apply semantics

Immediate:
- Language
- BGM volume
- SFX volume

Deferred or restart-required settings must not be added until the relevant runtime contract is confirmed.

## 7. Audio boundary

Confirmed path:
`SettingsScreen → SettingsManager → normalized volume → AudioServer BGM/SFX bus`

Settings chooses volume only. It does not select audio assets or define gameplay audio bindings.

Future Voice Volume and Master Volume are P1 PROPOSALS, not current Canon.

## 8. Localization boundary

Current locales:
- `ko`
- `en`

Language changes must:
- validate the locale;
- update TranslationServer;
- persist it;
- refresh visible Settings text;
- fall back safely on invalid persisted values.

Content IDs remain language-neutral.

## 9. Restore Defaults

P0:
`Restore Defaults → confirmation → reset all P0 user settings → apply → persist`

Defaults:
- language = `ko`
- bgm_volume = `1.0`
- sfx_volume = `1.0`

Reset must never delete or modify authored content.

## 10. Validation and recovery

Validation:
`UI Validation → Settings Schema Validation → Persistence Validation → Runtime Apply Validation`

Minimum checks:
- supported locale;
- numeric range;
- type correctness;
- missing-key fallback;
- corrupted-value fallback;
- persistence write result;
- runtime subsystem availability.

If a setting cannot be applied, preserve the last known valid value where possible and report the failed setting. Do not corrupt unrelated settings.

If the settings file is unreadable, load defaults and keep content data untouched.

## 11. Editor Settings separation

Editor preferences are a separate domain from player Settings.

Examples:
- editor language;
- editor theme;
- thumbnail/preview size;
- undo history policy;
- default editor view;
- file-dialog defaults.

They must not silently share the player Settings schema.

The existing Content Editor has separate language persistence logic. Converging it on a common persistence contract is a PROPOSAL and requires a later implementation task.

## 12. P1 candidates — not Canon

Display:
- fullscreen/windowed;
- resolution;
- VSync;
- UI scale;
- frame-rate limit;
- safe confirmation/revert for display changes.

Controls:
- keyboard remapping;
- controller remapping if supported;
- conflict detection;
- reset controls.

Accessibility:
- text/UI scale;
- subtitle settings;
- screen-shake toggle;
- reduced motion/effects;
- color presentation options.

Audio:
- Master Volume;
- Voice Volume;
- mute toggles.

These remain P1 until actual runtime contracts are verified.

## 13. P0 E2E acceptance test

1. Open Settings.
2. Read current language/BGM/SFX.
3. Change language.
4. Change BGM volume.
5. Change SFX volume.
6. Leave Settings.
7. Reopen Settings and verify values.
8. Restart the game.
9. Verify the values persist.
10. Verify BGM/SFX buses receive the expected values.
11. Verify no Content data changed.

Success:
`Settings change → runtime apply → persistence → restart → same settings restored`

## 14. Production gate

Settings P0 is implementation-ready when:
- P0 controls are defined;
- schema/defaults are fixed;
- persistence path is fixed;
- validation/recovery is defined;
- apply semantics are defined;
- reset behavior is defined;
- runtime consumers are identified;
- P0 E2E persistence test passes.

## 15. Current judgment

CONFIRMED: Language/BGM/SFX P0 Settings foundation is implemented, including Restore Defaults confirmation and persistence.

CONFIRMED: P0 E2E verified immediate runtime application, UI value reload, Restore Defaults, corrupt-file fallback, and persistence across separate Godot process launches.

CONFIRMED: Settings persistence remains isolated to `user://menos_settings.cfg`; the approved `godot/content/menos.sqlite` change is unrelated player-profile data and was not modified by the Settings implementation.

UNVERIFIED: Master-observed PIE behavior and future display/input/accessibility runtime contracts.

PROPOSAL: keep Settings scope locked to Language/BGM/SFX P0; do not expand into Display/Controls/Accessibility until their runtime contracts are separately confirmed.

OUT OF SCOPE: content authoring, gameplay balance, asset creation/editing, and audio/voice content definition authoring.

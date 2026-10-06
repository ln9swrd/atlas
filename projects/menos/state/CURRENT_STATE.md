# MENOS Current State

## Status

현재 프로젝트 기준 문서는 이 파일을 사용한다. 과거 작업 기록은 state/HANDOFF_HISTORY.md에 보존한다.

Core Combat Canon과 현재 코드의 주요 구조는 대체로 정합하다. 직접 조종, 기본 공격, 타깃 전환, 특수공격, 스킬 슬롯, 필살기, XP/레벨, AlliedUnitAI, Giant 보스 패턴, 고정형 Tower 지원, Campaign/Stage/Map 경로가 코드상 확인되어 있다.

## Baseline

- Project: MENOS
- Branch: main
- HEAD at state split start: 8d57320e7116cd24c1bce2ef7fad5f879bd72154
- Godot: D:\Godot_v4.7.2-stable, version 4.7.2.stable.official
- Canon: MENOS_COMBAT_CANON.md — MASTER APPROVED / CANON
- Historical Handoff: state/HANDOFF_HISTORY.md

## Current Implementation

- Manual robot movement and direct combat input paths exist.
- Basic attack, target switching, Special, skill slots, and Finisher paths exist.
- XP / Level progression path exists.
- Allied Unit AI exists.
- Giant boss attack patterns exist.
- Tower functions as fixed automatic support in the current minimum implementation.
- Campaign / Stage / Map loading paths exist.
- Content Editor, Map Editor, Stage Editor, Enemy/Tower/Robot Editor, and Asset Catalog/Image tooling exist at their current documented implementation levels.

## Verification

- CODE VERIFIED: Core implementation paths have been directly inspected in the current audit.
- BUILD VERIFIED: UNVERIFIED.
- EDITOR VERIFIED: Full manual acceptance pass UNVERIFIED.
- PIE VERIFIED: NOT VERIFIED for the current full project.
- Current acceptance boundary is Runtime/PIE verification, not a newly identified core-code gap.

## Current Implementation Gaps / Decisions

- GAP-01 Giant boss behavior: minimum implementation present; PIE unverified.
- GAP-02 Pilot-centered combat HUD: minimum implementation present; PIE unverified.
- GAP-03 Fixed Tower support: minimum implementation present.
- GAP-04 Attack-to-hit-to-damage timing: code implemented; runtime/PIE unverified.
- GAP-05 Campaign 1 minimum integration: minimum implementation present; full start-to-finish PIE unverified.
- Mission Contract Canon: Tower Defense=defend_base, Elimination=clear_encounters, Giant Boss Battle=defeat_giant.
- defeat_giant runtime delta has been investigated; historical implementation details remain in HANDOFF_HISTORY.md.
- Lane/Spawn semantics and other unresolved contract questions must not be changed without the applicable Master decision.
- Player Count / Multiplayer semantics remain outside the current confirmed Runtime contract.

## Data Pipeline

- SQLite is the authoritative Runtime and Editor content source. MENOS-created Content JSON files have been removed after migration; remaining JSON use is limited to serialization inside SQLite or intentionally separate user:// data.
- Content payload migration to `godot/content/menos.sqlite` is complete for the existing migrated documents; `godot/content/**/*.json` count is 0.
- Runtime content loaders for objects, factions, missions, rewards, skills, items, visual assets, asset catalog, stages/campaign, and maps use SQLite-backed loaders.
- Content save through `ObjectPersistence` updates and verifies SQLite; it does not write MENOS Content JSON files.
- Final direct-JSON audit found no MENOS Content JSON file I/O in Editor/runtime code. Remaining `.json` path references are compatibility mappings, UI text/filters, or non-Content `user://` state.
- SQLite Runtime code path is headless-checked; direct PIE acceptance remains separate and is currently deferred by Master instruction.
- User save data under `user://` remains JSON and is intentionally separate from content SQLite.

## Current Restrictions

- Do not change Canon without Master approval.
- Do not treat PROPOSAL as Canon.
- Do not report PIE as verified without direct runtime acceptance.
- Do not expand into new content, balance, or meta systems without a new Master-directed task.
- Preserve existing Working Tree changes.
- No commit/push unless explicitly approved.

## Next One Thing

Perform the next Master-directed task only. The SQLite migration/editor consumption audit is complete and must not be expanded automatically.

## Historical Record

All previous Handoff records, including their original HEAD/Branch/Verification/Next information, are preserved in state/HANDOFF_HISTORY.md. Historical records are not current-state authority.

## Current State Rule

When this file conflicts with an older Handoff, use this file for current project state and HANDOFF_HISTORY.md for historical evidence. Canon remains governed by MENOS_COMBAT_CANON.md.

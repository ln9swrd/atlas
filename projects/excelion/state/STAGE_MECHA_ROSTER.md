# Excelion 12-Stage Mecha Roster

> Status: Prototype planning document
> Scope: 12 gameplay stages mapped from the EP01-24 story structure
> Principle: enemy composition teaches the stage's combat verb; bosses are not the only encounter content.

## Roster Rules

- Player unit: **BRAVE / Axion prototype** in every stage.
- Common enemies are modular ORD units, not named characters.
- Common enemy base types:
  - **ORD-GRUNT**: melee swarm, short dash, lane pressure.
  - **ORD-GUN**: ranged harassment, forces approach and route choice.
  - **ORD-HEAVY**: slow blocker, shield or heavy weapon, controls the axis.
- Elite units are named role modules and appear in small numbers.
- A main boss is used only when the stage has a meaningful pattern lesson.
- Event stages may have mobs without a boss. This protects story pacing and keeps boss encounters distinct.

## 12-Stage Roster

| Stage | Story function | Common units | Elite / midboss | Main boss | Combat lesson |
|---|---|---|---|---|---|
| 01. Collapse Route | Adaptation and escape | GRUNT x4-6 | None | None | Move, turn, basic attack, escape pressure |
| 02. Settlement Defense | Hold the evacuation route | GRUNT wave + GUN | None | None | Protect an area while clearing lanes |
| 03. Rescue Zone | Reach a survivor signal | GRUNT + GUN | HEAVY blocker | None | Choose a route instead of fighting everything |
| 04. Recovery Site | Recover and remount | Small GRUNT group | None | None | Low-intensity movement and first Nemesis observation |
| 05. Northern Front | First major wall | GRUNT + HEAVY + GUN | Montu | Montu | Read pressure, find openings, survive space collapse |
| 06. Lunar Shadow | Break a sealed line | GRUNT + GUN | Seth | Seth | Decode defense, distrust false openings, counter |
| 07. Threshold of Madness | Survive a remote execution pattern | GUN + fast GRUNT | Anubis | Anubis | React to telegraphs and short burst windows |
| 08. Choice and Loss | Kai sacrifice / forced retreat | Sparse GRUNT + HEAVY | None | None | Retreat, protect a route, carry narrative pressure |
| 09. First Nemesis Contact | A deliberate power gap | GRUNT screen only | None | Nemesis | Recognize an unwinnable encounter and escape |
| 10. Surveillance Line | Break repeated observation locks | GRUNT + GUN | Hor | Hor | Rotate lanes, avoid short-range denial, reposition |
| 11. Escort Corridor | Protect allied movement | GRUNT + HEAVY | Nekh | Nekh | Advance while maintaining an escort corridor |
| 12. Gate Approach | Final approach and entry | Mixed GRUNT + GUN + HEAVY | Thoth, Sekh, Sobek, Wadjet, Ammit as sequential or selected encounters | Nemesis | Combine learned responses before the final confrontation |

## Stage 12 Internal Encounter Order

Stage 12 is intentionally a compound finale rather than six simultaneous bosses.

1. **Thoth**: analysis gate. Short pattern-reading encounter.
2. **Sekh**: breakthrough encounter. Close-range pressure and shield edge.
3. **Sobek**: raid encounter. Dense GRUNT waves with HEAVY support.
4. **Wadjet**: gate defense. Guard gauge and opening timing.
5. **Ammit**: internal function trap. Movement restriction and route selection.
6. **Nemesis**: final confrontation. Multi-phase judgment encounter.

Only one named encounter should be active at a time. Between encounters, use a short traversal or recovery space so the player can read the change in combat language.

## Common Enemy Deployment By Stage

| Stage group | GRUNT | GUN | HEAVY | Recommended purpose |
|---|---:|---:|---:|---|
| 01-02 | High | Low | None | Teach basic combat and movement |
| 03-04 | Medium | Medium | Low | Teach route choice and protection |
| 05-07 | Medium | Medium | Medium | Build pressure before named bosses |
| 08-09 | Low | Low | Situational | Preserve narrative focus and escape tension |
| 10-11 | Medium | High | Medium | Force rotation, escort, and spacing |
| 12 | High | Medium | Medium | Final combined skill check |

## Variant Budget

Do not create a unique mesh for every spawn type. Reuse the three ORD bases with behavior and equipment variants:

- `GRUNT_Assault`: faster approach and short dash
- `GRUNT_Swarm`: low durability, appears in groups
- `GUN_Scout`: relocates after firing and exposes the player route
- `GUN_Suppressor`: wider firing lane, slow reposition
- `HEAVY_Shield`: frontal defense, side/rear weakness
- `HEAVY_Cannon`: slow area attack, vulnerable while charging

## Prototype Implementation Order

1. Stage 01: GRUNT group and movement route
2. Stage 02: GUN support and defense point
3. Stage 03: HEAVY blocker and route choice
4. Stage 05: Montu as the first named midboss
5. Stage 09: Nemesis observation / escape state
6. Stage 12: sequential encounter shell, without final boss tuning

## Completion Criteria

The roster is ready for implementation when every stage has:

- A clear combat verb
- At least one common enemy composition
- A defined reason for the elite or boss to appear
- A victory condition other than simply defeating every unit
- A spawn budget that does not require all enemy types at once

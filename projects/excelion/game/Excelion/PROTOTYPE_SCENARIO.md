# Excelion Axion Prototype Scenario

## Purpose

Verify the feel and reliability of Axion's core player loop before adding enemies, combat damage, UI, or narrative progression.

This prototype is successful when a player can spawn on the Level map, understand the controls without instructions, move through a short test route, and see the correct Axion motion for each action.

## Scenario: First Sortie

### Opening state

- Map: `/Game/Level/NewMap`
- Player: Axion Character
- Camera: third-person spring arm camera
- State: standing on the floor, movement enabled
- Objective: reach the far side of the test area

### Beat 1 - Confirm control

The player tests the basic frame response.

- `W`: move forward
- `S`: move backward
- `A/D`: rotate left/right
- `Space`: jump

Pass condition: Axion remains grounded, faces the expected direction, and does not drift sideways.

### Beat 2 - Break contact

The player performs short evasive actions.

- `Left Shift`: forward dash
- `Q`: left dodge
- `E`: right dodge

Pass condition: each action produces a visible burst of movement and its matching animation without permanently interrupting normal movement.

### Beat 3 - Arm response

The player tests the combat motion set without damage or target logic.

- `F`: blade deploy
- `Left Mouse`: attack combo
- `1`: left slash
- `2`: right slash
- `R`: counter

Pass condition: each action plays once, returns to idle or movement, and does not leave the character frozen.

### Beat 4 - Repeatability

The player repeats the route once while alternating movement and action inputs.

Pass condition: no action causes an animation lock, loss of input, floor penetration, or camera failure.

## Prototype boundaries

Included:

- Axion mesh and imported animation playback
- W/S movement and A/D tank rotation
- Jump, dash, dodge, blade deploy, attack, slash, and counter input
- Grounding, camera follow, and repeatable action playback

Excluded for this pass:

- Enemy AI and damage
- Boss encounter
- Health, victory, and defeat UI
- Inventory, narrative dialogue, and save data
- Final combat timing or balance

## Evaluation checklist

- [ ] Axion spawns on the floor in `/Game/Level/NewMap`
- [ ] W/S moves forward and backward
- [ ] A/D rotates instead of strafing
- [ ] Movement animation returns to idle when stopped
- [ ] Dash and dodge visibly move the character
- [ ] Attack, slash, blade, and counter animations play once
- [ ] Inputs remain responsive after every action
- [ ] No mesh burial, sliding, or permanent animation lock

## Exit criteria

The prototype is ready for the next slice when all checklist items pass in one uninterrupted PIE run. Only then should target actors, hit detection, and encounter scripting be added.

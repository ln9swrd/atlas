# Part Library

ParaModel part assets referenced by `part_id` in mecha metadata.

## Path rule

```
data/parts/{part_id}.json
```

Optional mesh:
```
data/parts/meshes/{part_id}.glb
data/parts/meshes/{part_id}.blend
```

## Part metadata schema (minimal)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Y | Same as filename |
| name | string | Y | Display name |
| slot_types | string[] | Y | Compatible slot ids (e.g. arm_l, head) |
| category | string | N | body / weapon / accessory |
| mesh | string\|null | N | Relative path to mesh file (`meshes/{part_id}.glb`) |
| placeholder | object | N | size [x,y,z] for cube placeholder |

## Registered parts

| ID | Mesh |
|----|------|
| arm_basic_01 | meshes/arm_basic_01.glb |
| head_basic_01 | meshes/head_basic_01.glb |
| leg_basic_01 | meshes/leg_basic_01.glb |
| torso_upper_basic_01 | meshes/torso_upper_basic_01.glb |
| torso_lower_basic_01 | meshes/torso_lower_basic_01.glb |

See individual JSON files in this directory.

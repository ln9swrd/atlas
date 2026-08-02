# Part Library

ParaModel part assets referenced by `part_id` in mecha metadata.

## Path rule

```
data/parts/{part_id}.json
```

Optional mesh (later):
```
data/parts/meshes/{part_id}.blend
data/parts/meshes/{part_id}.glb
```

## Part metadata schema (minimal)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Y | Same as filename |
| name | string | Y | Display name |
| slot_types | string[] | Y | Compatible slot ids (e.g. arm_l, head) |
| category | string | N | body / weapon / accessory |
| mesh | string\|null | N | Relative path to mesh file |
| placeholder | object | N | size [x,y,z] for cube placeholder |

## Registered parts

See individual JSON files in this directory.

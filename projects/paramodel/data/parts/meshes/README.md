# Part Meshes

Place mesh files here referenced by `part.mesh`.

## Naming convention (canonical)

```
meshes/{part_id}.glb
```

Examples:
- `meshes/arm_basic_01.glb`
- `meshes/head_basic_01.glb`
- `meshes/leg_basic_01.glb`
- `meshes/torso_upper_basic_01.glb`
- `meshes/torso_lower_basic_01.glb`

Supported: `.glb`, `.gltf`, `.obj`, `.fbx`, `.blend`

Parts are reusable across slots (e.g. `arm_basic_01` for both `arm_l` and `arm_r`).
Do **not** embed slot names in the mesh filename.

Example part JSON:
```json
{
  "id": "head_basic_01",
  "mesh": "meshes/head_basic_01.glb",
  "placeholder": { "size": [0.35, 0.4, 0.35] }
}
```

If the mesh file is missing, the addon falls back to a placeholder cube.

## Current status (2026-08-03)

All existing `*.glb` files are **identical placeholder cubes** (same file size / content).
No real exported mecha meshes yet. Replace with actual models when available.

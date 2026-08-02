# Part Meshes

Place mesh files here referenced by `part.mesh` or auto-resolved as `{part_id}.glb` / `{part_id}.blend`.

Supported: `.glb`, `.gltf`, `.obj`, `.fbx`, `.blend`

Example part JSON:
```json
{
  "id": "head_basic_01",
  "mesh": "meshes/head_basic_01.glb",
  "placeholder": { "size": [0.35, 0.4, 0.35] }
}
```

If mesh file is missing, addon falls back to placeholder cube.

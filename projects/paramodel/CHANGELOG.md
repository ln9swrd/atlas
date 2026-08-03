# ParaModel CHANGELOG

## v0.7.0 — 2026-08-02

- mesh_io: glb/gltf/obj/fbx/blend import
- attach_parts: resolve `part.mesh` + auto-fallback `meshes/{part_id}.*`
- missing/fail → placeholder cube; report mesh vs placeholder counts
- mesh path convention: `{part_id}.glb`

## v0.6.2 — 2026-08-02

- bones.json (meters) for unit-aware SuperRobotRig
- operators unit-aware restore

## v0.6.0 — 2026-08-02

- SuperRobotRig procedural (bone table in code / bones.json)
- no blend dependency for armature
- PM-1..PM-8 base pipeline

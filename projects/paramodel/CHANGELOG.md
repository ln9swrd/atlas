# ParaModel CHANGELOG

## v0.7.2 — 2026-08-03

- **Working scale** (default 0.01 = 1:100) on root — rig, slots, parts all inherit
- 25 m mecha → ~0.30 m viewport (was ~30 m / 29845 mm)
- Scene prop `working_scale` (0.01 = model, 1.0 = real meters)
- Load raises 3D view `clip_end` when needed

## v0.7.1 — 2026-08-03

- **Structure:** Identity → Archetype → Size → Traits → Visual → Body
- `archetype` + `size.{scale_class,primary,value}` in mecha schema
- `schema/templates/humanoid.json` — reference height 2.0 m
- Scale: `sf = size.value / template.reference_value` (no more height/25)
- Loader stores archetype/size props on root; load report includes sf
- Other archetypes (quadruped, aircraft, vessel, …) planned only

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

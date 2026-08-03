# ParaModel CHANGELOG

## v0.7.4 — 2026-08-03

- **Fix:** zip install missing schema → all slots at origin (cubes piled at world origin)
- Bundle `schema/` into addon zip
- Resolve schema/parts via package dir, project root, or data_path parent
- Parent with identity matrix_parent_inverse so local coords respect root scale

## v0.7.3 — 2026-08-03

- **PM-14 Axis unify:** slots → Blender Z-up `[x, y_forward, z_up]`
- Slot origin = ground (feet); head z=1.8 at 2 m reference
- SuperRobotRig ground-aligned (lowest bone → z=0)

## v0.7.2 — 2026-08-03

- **Working scale** (default 0.01 = 1:100) on root — rig, slots, parts all inherit
- 25 m mecha → ~0.30 m viewport (was ~30 m / 29845 mm)
- Scene prop `working_scale` (0.01 = model, 1.0 = real meters)
- Load raises 3D view `clip_end` when needed

## v0.7.1 — 2026-08-03

- **Structure:** Identity → Archetype → Size → Traits → Visual → Body
- `archetype` + `size.{scale_class,primary,value}` in mecha schema
- `schema/templates/humanoid.json` — reference height 2.0 m
- Scale: `sf = size.value / template.reference_value`

## v0.7.0 — 2026-08-02

- mesh_io + attach_parts mesh import

## v0.6.2 — 2026-08-02

- bones.json (meters), unit-aware scale

## v0.6.0 — 2026-08-02

- SuperRobotRig procedural; PM-1..PM-8 base pipeline

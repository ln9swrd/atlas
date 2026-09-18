# Body templates

Selected by `mecha.archetype` / `base_body.template`.

| id | primary | reference | status |
|----|---------|-----------|--------|
| humanoid | height | 2.0 m | active |
| quadruped | height or length | TBD | planned |
| multiped | height or span | TBD | planned |
| aircraft | length or wingspan | TBD | planned |
| vessel | length | TBD | planned |

Each active template JSON provides:

- `size.primary` / `size.reference_value` — scale contract
- `rig` — armature id or null
- `slots_def` — slot definition file under `schema/`

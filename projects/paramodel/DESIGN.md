# ParaModel Design

## Unit design flow

```
Identity → Archetype → Size → Traits → Visual → Body
```

| Layer | Fields | Drives |
|-------|--------|--------|
| Identity | id, name, codename, category, tags, status | naming, filters |
| **Archetype** | archetype | template → slots set, rig, size primary |
| **Size** | size.scale_class, size.primary, size.value | **sf = value / template.reference_value** |
| Traits | parameters (mass, mobility, output, armor, …) | custom props; later bias |
| Visual | visual.* | materials (planned) |
| Body | base_body.template, base_body.slots | empties, mesh/placeholder |

Not only humanoid: quadruped, multiped, aircraft, vessel, … each has its own template.

## Size contract

1. Template defines `size.primary` + `size.reference_value` (authored geometry scale).
2. Mecha defines target `size.primary` + `size.value` (real-world meters).
3. `sf = value / reference_value` applied on root (children inherit).
4. `scale_class` is a label / default-value hint — **not** the scale divisor.

| Archetype | primary (typical) | humanoid ref (current) |
|-----------|-------------------|------------------------|
| humanoid | height | 2.0 m |
| quadruped | height or length | planned |
| multiped | height or span | planned |
| aircraft | length or wingspan | planned |
| vessel | length | planned |

Example: humanoid, value=25, reference=2.0 → **sf=12.5**.

## Archetype → template

| archetype | template file | status |
|-----------|---------------|--------|
| humanoid | `schema/templates/humanoid.json` | active |
| quadruped | — | planned |
| multiped | — | planned |
| aircraft | — | planned |
| vessel | — | planned |

`base_body.template` should match `archetype` (or resolve via template id).

## Implementation (v0.7.1)

| Layer | Status |
|-------|--------|
| Schema archetype + size | Done |
| humanoid template + reference 2.0 | Done |
| Loader scale via size + reference | Done |
| Other archetypes data/rig | planned |
| Axis unify (slots Y vs bones Z) | open |
| visual materials | open |
| slot→bone parent | open |

## Do not

- Use `height/25` as scale (removed)
- Treat scale_class as numeric divisor
- Dual-write product paths into excelion mono

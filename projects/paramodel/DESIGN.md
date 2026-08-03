# ParaModel Design

## Intended flow (character-design style)

```
Identity → Size → Traits → Visual → Body composition
```

| Layer | Data fields | Should drive |
|-------|-------------|--------------|
| Identity | id, name, codename, category, tags, status | root naming, filters |
| Size | scale_class, parameters.height | **global scale** of slots, armature, parts |
| Traits | mass, mobility, output, armor_thickness | custom props; later proportion/weight bias |
| Visual | primary/secondary/accent color, style_tags | materials / viewport color |
| Body | base_body.slots + part library | empties, mesh/placeholder attach |

## Current implementation (v0.7.0)

| Layer | What code does |
|-------|----------------|
| Identity | root name `root_{id}`; custom props |
| Size | `root.scale = height / 25.0` only |
| Traits | stored on root as custom props only |
| Visual | **not applied** |
| Body | slots from schema defaults + mecha assignment; mesh_io or cube |

## Known mismatches (must fix)

### 1. Size / reference scale

- Authored geometry is ~human scale:
  - `base-body-slots.json`: head @ y≈1.8 m (Y-up style)
  - `bones.json`: ~1–2 m humanoid (Z-up from metarig)
  - part placeholders: 0.3–0.7 m
- Mecha data claims `scale_class: 25m`, `height: 25.0`
- Code: `sf = height / 25.0` → **sf=1.0** → result is ~2 m figure labeled 25 m

**Correct approach (proposed):**

- Treat slots/bones/placeholders as proportions at **reference height** `H_ref` (e.g. 2.0 m, or derived from bones).
- `sf = height / H_ref` (e.g. 25/2 = 12.5).
- `scale_class` sets default height when height omitted (15/25/50), not the divisor 25 alone.

### 2. Axis / space inconsistency

- Slots: positions look Y-up `[x, y_up, z]`
- Bones: Z-up metarig coordinates
- Not aligned; slot empties and SuperRobotRig do not share the same up-axis convention.

### 3. Top-level attributes underused

- `scale_class`: unread by addon
- `visual.*`: unread (no material/color application)
- traits: props only, no structural effect (acceptable for v0.7; document as future)

### 4. Armature ↔ slots

- Slots are not parented to bones; both parent to root independently.
- Props description says "parent slots to bones" but code does not.

## Fix priority (suggested)

1. **P0 Scale contract** — define `H_ref`, fix `create_root` scale formula; document in schema
2. **P0 Axis** — pick one up-axis; convert slots or bones so they match
3. **P1 Visual** — apply primary_color to part materials (simple viewport)
4. **P1 scale_class** — default height map when height missing
5. **P2** — optional trait → proportion hooks; slot→bone parenting

## Do not

- Dual-write product paths into excelion mono
- Treat current GLB cubes as real mecha mesh

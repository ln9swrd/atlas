# ParaModel

Parametric mecha model system for Atlas / Excelion.

## Structure

```
projects/paramodel/
├── addon/                 # Blender addon v0.3.0
├── schema/
├── data/
│   ├── mecha/
│   └── parts/
│       └── meshes/        # optional .glb/.blend assets
├── scripts/
│   └── package_addon.sh   # zip for Blender Install
└── dist/                  # package output (generated)
```

## Status

- [x] PM-1 slots + position/rotation
- [x] PM-2 mecha-metadata.schema.json
- [x] PM-3 part library
- [x] PM-4 placeholders
- [x] PM-5 state registration
- [x] PM-6 mesh import (glb/gltf/obj/fbx/blend, fallback placeholder)
- [x] PM-7 parameters → root scale + custom props
- [x] PM-8 package_addon.sh

## Blender 설치

```bash
bash projects/paramodel/scripts/package_addon.sh
# → projects/paramodel/dist/paramodel_addon_v0.3.0.zip
```

Blender → Preferences → Add-ons → Install → 해당 zip  
N패널 → **ParaModel** → Data Path = `.../data/mecha` → Load Mecha

## Load 동작

1. Root empty (`root_{id}`) — height 기준 scale, mass/mobility/output props
2. Slot empties — schema position/rotation, parented to root
3. Parts — `part.mesh` 파일이 있으면 import, 없으면 placeholder 큐브

## Registered Units

| ID | Name | Status |
|----|------|--------|
| brave-001 | Brave | concept |

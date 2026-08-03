# Part meshes

```
data/parts/meshes/{part_id}.glb
```

## Generate basic silhouettes

Identical placeholder cubes can be replaced with distinct low-poly parts:

```bash
pip install trimesh numpy
python3 projects/paramodel/scripts/generate_basic_meshes.py
```

Then reload mecha in Blender (Clear All → Load Mecha).

## Notes

- Units: meters, Z-up, origin = slot center
- Scale inherits from root (working scale × size factor)
- For production mecha art: author in Blender and overwrite these GLBs

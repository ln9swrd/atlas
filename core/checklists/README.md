# Checklists Layer

The **Checklists Layer** provides concrete, step-by-step verification lists that are easily parsed by both humans and AI agents before pushing assets or code downstream.

## 1. 3D Mesh Verification Checklist (Blender)

- [ ] **Normal Consistency**: Face normals are pointing outwards. No double faces or non-manifold geometry.
- [ ] **UV Space Optimization**: UV islands are packed efficiently. Overlapping is allowed only where mirrored texture is intended. No stretched mapping.
- [ ] **Scale & Transforms**: Rotation is set to `(0, 0, 0)` and Scale is set to `(1, 1, 1)`. All transforms applied.
- [ ] **Origin Alignment**: Pivot point/Origin is positioned correctly at the base or functional center of the object.
- [ ] **Material Names**: Material slots are named clearly using lowercase snake_case or standard naming convention (e.g., `mat_[asset_name]`). No default names (e.g., `Material.001`).
- [ ] **Collision Geometry**: Collision setup is clean and utilizes simple primitives where possible (UCX/UBX/UCP prefixes).
- [ ] **Export Integrity**: Successfully exported to FBX and checked in a viewer or re-imported to verify there are no missing faces or deformed skinning.

## 2. Unreal Engine Import/Asset Checklist

- [ ] **Import Settings**: Correct import options selected (e.g., Import Normals/Tangents, Create Physics Asset if skeletal).
- [ ] **Material Instance Binding**: The asset uses a material instance (`MI_...`) derived from a parent master material, not raw materials.
- [ ] **LODs Configured**: Auto-LOD or custom LODs are properly configured to prevent performance issues.
- [ ] **Data Validation**: Asset passes the Unreal Engine built-in Data Validation check without errors or warnings.

## 3. Rigging & Skin Weight Verification Checklist (Blender)

- [ ] **Bone Naming Standards**: All bones conform to the project naming convention (e.g., prefix `b_` or standard Unreal skeleton matching, suffix `_L` / `_R` for symmetry).
- [ ] **Range of Motion (ROM) Test**: Key deformation areas (shoulders, elbows, knees, hips) tested through extreme ranges of motion. No unnatural volume loss or extreme clipping.
- [ ] **Weight Symmetry**: Vertex weights are symmetrical across the mirror axis where the mesh is symmetrical.
- [ ] **Max Influence Limit**: No vertex is influenced by more than 4 bones (standard mobile/performance constraint) or 8 bones (high-end PC), unless specifically approved.
- [ ] **Clean Vertices**: No unweighted (0.0 weight) vertices in the deformable mesh. No dangling bones without weights unless helper/socket bones.
- [ ] **Transform Application**: The armature object scale is set to `(1, 1, 1)` and rotation to `(0, 0, 0)`.


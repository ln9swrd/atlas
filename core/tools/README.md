# core/tools — Product automation (HOLD)

> **P3-1a:** This directory is **product-coupled** (Blender / Unreal).  
> ACTIVE_TARGET = platform → do not expand; do not auto-load in platform sessions.

Canonical product work lives under `projects/excelion*` / `projects/excelion-forge` when ACTIVE_TARGET reopens.

---

## Automation Target Register (legacy inventory)

| Pipeline Stage | Automation Task | Status | Tool / Script |
| :--- | :--- | :--- | :--- |
| **Blender (DCC)** | Batch Export to FBX | Implemented | [blender_export.py](blender_export.py) |
| | Collision Hull Auto-generation | Implemented | [blender_collision.py](blender_collision.py) |
| | UV Overlap & Scale Validation | Implemented | [blender_uv_check.py](blender_uv_check.py) |
| **Unreal Engine** | Auto Import & Material Assignment | Planned | Python / Editor Utility |
| | Naming/Directory Validation | Implemented | [ue_validation.py](ue_validation.py) |
| **Git & Version Control** | Auto Changelog Generation | Planned | Git Hook / Node |
| | Commit Linting | Planned | Git Hook |
| — | visual_perception.py | Present | Vision non-goal for platform |

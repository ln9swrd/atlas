# Automation Layer

The **Automation Layer** contains scripts, pipelines, and continuous integration setups designed to eliminate repetitive manual work across Blender, Unreal Engine, and Git.

## Automation Target Register

| Pipeline Stage | Automation Task | Status | Tool / Script |
| :--- | :--- | :--- | :--- |
| **Blender (DCC)** | Batch Export to FBX | Implemented | [blender_export.py](blender_export.py) |
| | Collision Hull Auto-generation | Implemented | [blender_collision.py](blender_collision.py) |
| | UV Overlap & Scale Validation | Implemented | [blender_uv_check.py](blender_uv_check.py) |
| **Unreal Engine** | Auto Import & Material Assignment | Planned | Python / Editor Utility |
| | Naming/Directory Validation | Implemented | [ue_validation.py](ue_validation.py) |
| **Git & Version Control** | Auto Changelog Generation | Planned | Git Hook / Node |
| | Commit Linting | Planned | Git Hook |

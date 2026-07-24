# Forge Roadmap

## 1. Purpose

This document defines the implementation roadmap for Forge.

Forge development follows an incremental approach:

* Build the minimum production pipeline first.
* Validate through Excelion.
* Expand automation capabilities.
* Integrate AI assistance progressively.

Forge is developed as a reusable production framework, not a single-project tool.

---

# 2. Development Strategy

Forge development follows this order:

```text
Foundation

↓

Asset Pipeline

↓

Tool Integration

↓

Validation

↓

AI Assisted Production

↓

Automation Expansion
```

---

# 3. Phase 0 — Foundation Alignment

## Goal

Prepare Forge to work with Atlas architecture.

## Tasks

* Define Forge execution contracts.
* Connect Forge with Atlas Runner.
* Establish evidence recording.
* Define capability requirements.

## Output

* Forge Core skeleton
* Plugin interface
* Validation interface

Status:

Planned

---

# 4. Phase 1 — Blender Production Pipeline

## Goal

Create the first usable production workflow.

## Target

Blender Add-on

## Tasks

### Asset Structure

* Naming rules
* Collection rules
* Object validation

### Modeling Support

* Asset inspection
* Metadata generation

### Rig Support

* Armature validation
* Bone hierarchy checking

### Export

* FBX export workflow
* Export validation

## Excelion Usage

Initial target:

* Brave Frame
* Mecha parts
* Weapon assets

Status:

Priority

---

# 5. Phase 2 — Unreal Integration Pipeline

## Goal

Connect generated assets to the game engine.

## Target

Unreal Plugin

## Tasks

* FBX import validation
* Skeleton verification
* Material verification
* Animation setup assistance
* Blueprint validation

## Excelion Usage

Target:

* Mecha prototype
* Combat test environment

Status:

Planned

---

# 6. Phase 3 — MCP Integration

## Goal

Allow controlled communication with external tools.

## Tasks

* MCP adapter implementation
* External tool discovery
* Command execution interface

Possible targets:

* Blender
* Unreal
* Development utilities

Status:

Planned

---

# 7. Phase 4 — AI Assisted Production

## Goal

Use SERA and AI providers to improve production workflows.

## Capabilities

### Design Assistance

* Suggest asset structures
* Review designs
* Recommend improvements

### Production Assistance

* Analyze errors
* Suggest fixes
* Generate workflow steps

### Optimization Assistance

* Performance analysis
* Asset improvement suggestions

AI output requires validation.

Status:

Future

---

# 8. Phase 5 — Production Automation Platform

## Goal

Transform Forge into a general production framework.

Possible features:

* Automated asset generation
* Multi-project support
* Cloud execution
* Team workflows
* Production analytics

Status:

Long Term

---

# 9. Current Priority

Based on current Atlas state:

## Highest Priority

1. Atlas/SERA context stability
2. Forge document baseline completion
3. Blender integration design
4. Excelion asset workflow validation

## Medium Priority

5. Unreal plugin planning
6. MCP integration

## Future Priority

7. Cloud AI production pipeline
8. Automated generation systems

---

# 10. Implementation Rules

Forge development must follow:

## Rule 1

Do not create project-specific hacks inside Forge Core.

## Rule 2

Every automation feature must produce evidence.

## Rule 3

Every external integration must use a defined interface.

## Rule 4

AI assistance must remain separate from execution authority.

---

# Summary

Forge development proceeds from reliable production foundations toward advanced AI-assisted automation.

The implementation path is:

```text
Atlas Foundation

↓

Forge Core

↓

Blender Pipeline

↓

Unreal Pipeline

↓

MCP Integration

↓

AI Production Automation
```

Excelion serves as the first validation environment for Forge capabilities.

# ADR-007: Forge as Production Framework

## Status

Accepted

## Context

Atlas was designed to support practical development projects, not only abstract planning and execution management.

To validate Atlas capabilities, Excelion requires real production workflows involving:

* 3D asset creation
* Blender automation
* Unreal Engine integration
* Asset validation
* Development pipeline management

Initially, Forge was considered as a project-specific tool for Excelion.

However, limiting Forge to a single project would reduce:

* Reusability
* Extensibility
* Long-term value of the system

Atlas requires a production framework layer that can support multiple creative projects.

---

# Decision

Forge is defined as an Application Framework built on top of Atlas.

Forge is responsible for production automation workflows and tool integrations.

The architecture is:

```text id="1a3x5r"
Atlas Core

↓

Forge Framework

↓

Production Tools

↓

Projects
```

---

# Forge Responsibilities

Forge provides:

## Asset Production Pipeline

Examples:

* 3D asset generation
* Export workflow
* Naming validation
* Asset verification

---

## Tool Integration

Supported integrations may include:

### Blender

* Add-on integration
* Modeling workflow support
* Rig validation
* Export automation

### Unreal Engine

* Plugin integration
* Asset import workflow
* Blueprint assistance
* Validation support

### MCP

* External tool communication
* AI tool access
* Workflow automation

---

## Production Validation

Forge provides:

* Automated checks
* Pipeline validation
* Output verification
* Evidence generation

---

# Relationship with Excelion

Excelion is the first validation project using Forge.

Relationship:

```text id="y3j6ph"
Forge

↓

Excelion Development

↓

Production Evidence

↓

Framework Improvement
```

Excelion requirements may influence Forge development, but Excelion-specific logic must remain inside the project layer.

---

# Core Separation Rules

Forge must not:

* Modify Atlas Core directly.
* Own global project state.
* Replace SERA reasoning.
* Contain Excelion-only assumptions.

Forge should:

* Use Atlas execution contracts.
* Use plugin interfaces.
* Produce evidence.
* Remain reusable.

---

# Cloud AI and Local AI Integration

Forge may use AI capabilities through Atlas interfaces.

Possible flow:

```text id="5n4g7m"
SERA

↓

Atlas AI Interface

↓

Cloud AI / Local AI

↓

Forge Workflow

↓

Production Tool
```

AI assistance improves workflows but does not replace validation.

---

# Consequences

Positive:

* Forge becomes reusable beyond Excelion.
* Production automation is separated from Core.
* New tools can be added independently.
* Creative workflows become measurable and repeatable.

Trade-offs:

* Framework design requires more abstraction.
* Project-specific features need clear boundaries.
* Integration maintenance becomes necessary.

---

# Summary

Forge is the production automation framework of Atlas DevOS.

It transforms Atlas capabilities into practical development workflows while maintaining separation between:

* Platform infrastructure
* AI intelligence
* Production automation
* Individual projects

Excelion serves as the first project proving Forge's capability.

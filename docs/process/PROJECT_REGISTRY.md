# Project Registry

This registry defines the known projects and platform components in Atlas and their current lifecycle status.

The registry separates:

* Platform systems
* Intelligence systems
* Production frameworks
* Product projects

to maintain clear ownership and execution boundaries.

---

# Projects

| Name     | Status         | Type                 | Priority | Owner | Description                                             |
| :------- | :------------- | :------------------- | :------- | :---- | :------------------------------------------------------ |
| Atlas    | maintenance    | platform             | high     | Atlas | AI-based development operating system                   |
| Sera     | implementation | ai_agent             | critical | Sera  | AI design and planning intelligence layer               |
| Forge    | planning       | production_framework | critical | Atlas | AI-assisted production automation framework             |
| Excelion | active         | game_ip              | critical | Atlas | Main product project and first Forge validation project |
| Coin-S   | planning       | software             | low      | Atlas | Future analysis-oriented software project               |

---

# Project Intent

## Atlas

Build and maintain the operating system that coordinates:

* Context
* Rules
* Execution
* State
* Review

Atlas provides the foundation for all projects.

---

## Sera

Implement the intelligence layer responsible for:

* Design assistance
* Planning support
* Architecture discussion
* Decision assistance

Sera operates as the primary AI interaction layer.

---

## Forge

Build a reusable production automation framework.

Forge responsibilities:

* Asset workflow automation
* Blender integration
* Unreal integration
* MCP connectivity
* Production validation
* Evidence recording
* AI-assisted production support

Forge is not limited to Excelion.

Excelion is the first project used to validate Forge capabilities.

---

## Excelion

Develop the main game/IP product.

Excelion responsibilities:

* Game design
* Mecha production
* Gameplay implementation
* Final product validation

Excelion uses Forge as a production framework.

Reference:

`projects/excelion/PROJECT_CHARTER.md`

---

## Coin-S

Prepare a future software project for analysis-oriented workflows.

Current status:

Planning

---

# Lifecycle Reference

All projects follow:

`PROJECT_LIFECYCLE.md`

Lifecycle stages:

1. Idea
2. Planning
3. Prototype
4. Active Development
5. Validation
6. Release
7. Maintenance
8. Archive

---

# Relationship Model

Atlas ecosystem:

```text
Atlas DevOS

├── Sera
│
├── Forge
│   ├── Blender Add-on
│   ├── Unreal Plugin
│   ├── MCP Integration
│   └── Production Database
│
└── Excelion
    └── First Forge Validation Project
```

---

# Current Strategic Priority

Priority order:

1. Sera implementation
2. Forge foundation
3. Excelion production validation
4. Future projects

This ordering ensures that intelligence and production infrastructure mature before large-scale project expansion.

# Forge Architecture

## 1. Purpose

Forge is an AI-assisted production automation framework built on top of Atlas DevOS.

The purpose of Forge is to convert development decisions into repeatable production workflows.

Forge connects:

* AI planning
* Production tools
* Asset workflows
* Validation systems
* Execution records

Forge is designed as a reusable framework.

Excelion is the first project used to validate Forge capabilities.

---

# 2. Position Within Atlas

Atlas ecosystem:

```text
Atlas DevOS

├── Sera
│   Intelligence Layer
│
├── Forge
│   Production Automation Framework
│
└── Excelion
    Product Validation Project
```

Responsibilities:

## Atlas

Coordinates:

* Context
* State
* Rules
* Execution

## Sera

Provides:

* Analysis
* Planning
* Design assistance

## Forge

Provides:

* Production execution
* Tool integration
* Validation

## Excelion

Provides:

* Real production requirements
* Validation environment

---

# 3. Core Philosophy

## Human Directed

Forge does not replace creative decisions.

Human defines:

* Design goals
* Artistic direction
* Final approval

Forge assists with:

* Repetition
* Validation
* Workflow automation

---

## Evidence Based Production

Every production action should generate evidence.

Examples:

* Generated asset metadata
* Validation result
* Execution log
* Version information

---

## Tool Independent Architecture

Forge should not depend on one production tool.

Initial integrations:

```text
Forge

├── Blender
│
├── Unreal Engine
│
└── MCP
```

Future integrations may be added.

---

# 4. High Level Architecture

```text
                Sera

                 |

                 |

             Forge Core

                 |

     ------------------------

     |          |           |

 Blender     Unreal       MCP

 Plugin      Plugin     Interface

     |          |           |

 Asset      Runtime      External

 Data       Data         Tools
```

---

# 5. Forge Core

Forge Core provides common services.

Responsibilities:

## Task Management

* Receive production requests
* Track execution

## Context Integration

Uses Atlas RuntimeContext.

## Validation

* Check results
* Record evidence

## Metadata Management

Store:

* Asset information
* Version
* Dependencies

---

# 6. Integration Model

## Atlas Integration

Forge receives:

* Project context
* Current goal
* Task priority
* Environment capability

Flow:

```text
Atlas

↓

RuntimeContext

↓

Forge Task

↓

Execution

↓

Evidence
```

---

## Sera Integration

Sera provides:

* Production planning
* Requirement interpretation
* Design discussion

Flow:

```text
Sera

↓

Production Intent

↓

Forge Execution Plan
```

---

## Tool Integration

Forge communicates with tools through adapters.

Example:

```text
Forge Core

↓

Blender Adapter

↓

Blender


Forge Core

↓

Unreal Adapter

↓

Unreal Engine
```

---

# 7. Component Overview

Forge consists of:

## Forge Core

Central execution framework.

## Blender Add-on

Purpose:

* Asset generation support
* Rigging assistance
* Validation

## Unreal Plugin

Purpose:

* Import automation
* Runtime validation
* Integration support

## MCP Interface

Purpose:

* Connect AI agents and external tools

## Data Layer

Purpose:

* Store production information

---

# 8. Execution Flow

Typical workflow:

```text
Request

↓

Context Analysis

↓

Task Generation

↓

Tool Execution

↓

Validation

↓

Evidence Storage

↓

State Update
```

---

# 9. Future Expansion

Possible capabilities:

* Automated asset pipeline
* AI-assisted modeling
* Batch validation
* Build automation
* Cloud production nodes

---

# Summary

Forge is the production execution layer of the Atlas ecosystem.

The complete relationship:

```text
Human

↓

Sera

↓

Atlas

↓

Forge

↓

Production Tools

↓

Product
```

Forge transforms structured intent into validated production results.

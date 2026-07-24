# Forge Components

## 1. Overview

Forge is composed of independent components that cooperate to execute production workflows.

The component architecture follows Atlas design principles:

* Separation of responsibility
* Evidence-based execution
* Tool-independent integration
* Expandable architecture

---

# 2. Component Architecture

```text
Forge

├── Forge Core

├── Context Adapter

├── Task Executor

├── Validation Engine

├── Metadata System

├── Tool Adapters

│   ├── Blender Adapter

│   ├── Unreal Adapter

│   └── MCP Interface

└── Storage Layer
```

---

# 3. Forge Core

## Purpose

The central runtime of Forge.

## Responsibilities

* Receive production tasks
* Manage execution flow
* Coordinate components
* Communicate with Atlas

## Does Not Handle

* Direct modeling
* Engine-specific operations
* Artistic decisions

---

# 4. Context Adapter

## Purpose

Connect Forge with Atlas RuntimeContext.

## Input

From Atlas:

* Project
* Goal
* Environment
* Task
* Priority

## Output

Forge execution context:

```text
ProductionContext
```

---

# 5. Task Executor

## Purpose

Execute defined production operations.

Responsibilities:

* Start tasks
* Monitor execution
* Handle results

Example tasks:

* Generate asset
* Validate mesh
* Export file
* Import test

---

# 6. Validation Engine

## Purpose

Verify production results.

Validation types:

## Asset Validation

Examples:

* File exists
* Naming rule
* Mesh structure
* Material assignment

## Pipeline Validation

Examples:

* Export success
* Import success
* Runtime check

## Evidence Creation

Produces:

* Validation report
* Error information
* Execution record

---

# 7. Metadata System

## Purpose

Maintain production knowledge.

Stores:

* Asset identity
* Version
* Source
* Dependencies
* Validation history

Example:

```json
{
  "asset": "Brave_Frame",
  "type": "Mech",
  "version": "0.1",
  "status": "validated"
}
```

---

# 8. Tool Adapters

Forge communicates with external tools through adapters.

---

# Blender Adapter

Purpose:

* Modeling workflow support
* Rigging workflow support
* Export automation

Possible functions:

* Generate mesh
* Check rig
* Export FBX

---

# Unreal Adapter

Purpose:

* Import validation
* Runtime verification
* Build support

Possible functions:

* Import asset
* Validate blueprint
* Run test

---

# MCP Interface

Purpose:

Connect Forge with AI agents and external applications.

Example:

```text
Sera

↓

MCP

↓

Forge

↓

Blender
```

---

# 9. Storage Layer

## Purpose

Maintain Forge execution information.

Possible storage:

## File Based

Initial stage:

* JSON
* Markdown
* Git history

## Database

Expansion stage:

* PostgreSQL
* Asset database
* Execution history

---

# 10. Component Dependency

Dependency direction:

```text
Forge Core

↓

Context Adapter

↓

Task Executor

↓

Tool Adapter

↓

External Tool
```

Validation and Metadata observe execution results.

---

# 11. Initial Implementation Priority

Implementation order:

## Phase 1

Forge Core

* Context loading
* Task execution model
* Result recording

## Phase 2

Blender Integration

* Asset validation
* Export workflow

## Phase 3

Unreal Integration

* Import validation
* Runtime checks

## Phase 4

MCP Integration

* AI agent connection

---

# Summary

Forge components are designed around a simple principle:

```text
Intent

↓

Execution

↓

Validation

↓

Evidence
```

Each component has a clear responsibility and can evolve independently.

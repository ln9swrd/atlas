# Atlas Architecture

## Purpose

This document defines the overall architecture of Atlas DevOS.

Atlas is designed as a context-aware development operating platform that coordinates:

* Project knowledge
* AI agents
* Development tools
* Execution workflows
* Evidence-based state management

---

# System Overview

Atlas consists of multiple layers.

```text
Atlas DevOS

├── Core Platform
│
├── AI Agent Layer
│
├── Application Framework Layer
│
├── Tool Integration Layer
│
└── Project Layer
```

---

# Layered Architecture

# Layer 0 — Core Platform

The foundation layer responsible for state, context, and system rules.

Components:

* RuntimeContext
* State Management
* Event System
* Goal Management
* Registry
* Rule Definition

Responsibilities:

* Maintain system truth
* Provide structured information
* Preserve execution history

---

# Layer 1 — Context Resolution Layer

Collects required information without making final decisions.

Components:

* EnvironmentResolver
* ProjectResolver
* ResourceResolver
* UserResolver
* TimeResolver

Responsibilities:

* Collect available context
* Validate environment capability
* Prepare execution information

Rule:

Resolvers provide information only.

Decision logic must not exist inside this layer.

---

# Layer 2 — Decision Layer

Evaluates available information and recommends actions.

Components:

* Priority Rules
* Priority Engine
* Recommendation Engine

Responsibilities:

* Task prioritization
* Goal alignment
* Execution recommendation

Decision principle:

Evidence is preferred over assumption.

---

# Layer 3 — Execution Layer

Responsible for performing approved actions.

Components:

* Runner
* Executor
* Scheduler
* Plugin Host

Responsibilities:

* Execute workflows
* Update state
* Generate execution records

---

# Layer 4 — Interface Layer

Provides interaction methods.

Components:

* CLI
* VS Code Integration
* Web Interface
* REST API

Responsibilities:

* User interaction
* Agent interaction
* External system access

---

# Layer 5 — AI Agent Layer

Provides intelligence and collaboration capability.

## SERA

SERA is the primary AI agent layer of Atlas.

Responsibilities:

* Planning assistance
* Architecture analysis
* Context interpretation
* Creative decision support
* Development coordination

SERA uses Atlas Core services but does not replace Core responsibilities.

---

# Layer 6 — Application Framework Layer

## Forge

Forge is the production automation framework built on Atlas.

Purpose:

Support practical development workflows.

Components:

* Blender Add-on
* Unreal Engine Plugin
* MCP Integration
* Asset Pipeline Tools
* Validation Tools

Forge converts Atlas capabilities into production workflows.

---

# Layer 7 — Project Layer

## Excelion

Excelion is the first validation project for Atlas.

Purpose:

Validate:

* AI-assisted game development
* Production automation
* Asset workflow
* Creative development process

Future projects may use the same Atlas foundation.

---

# External Integration Layer

Atlas may connect with external systems through controlled interfaces.

## MCP

Model Context Protocol integration provides:

* Tool communication
* External application control
* Development environment access

Examples:

* Blender integration
* Unreal integration
* Other production tools

---

## Cloud AI Integration

Atlas supports hybrid AI architecture.

Possible configuration:

```text
Local AI Model

+

Cloud AI Service

+

SERA Agent Layer

+

Atlas Runtime
```

Purpose:

* Use local models for private execution
* Use cloud models for advanced reasoning
* Maintain consistent project context

---

# Dependency Direction

The dependency direction is:

```text
Registry

↓

Resolver

↓

RuntimeContext

↓

Decision

↓

Execution

↓

Interface
```

Extended dependency:

```text
Atlas Core

↓

SERA

↓

Forge

↓

Excelion
```

Rules:

* Upper layers may depend on lower layers.
* Lower layers must not depend on upper layers.
* Projects must not directly modify Atlas Core.
* External tools must communicate through defined interfaces.

---

# Runtime Flow

The complete execution flow:

```text
User Request

      ↓

SERA / Agent Layer

      ↓

RuntimeContext Creation

      ↓

Context Resolution

      ↓

Environment Capability Check

      ↓

Decision Engine

      ↓

Execution Selection

      ↓

Forge / Tool / Application

      ↓

Evidence Collection

      ↓

State Update

      ↓

Knowledge Preservation
```

---

# Architecture Principles

## Context First

No execution should occur without sufficient context.

## Evidence First

State changes require evidence.

## Separation of Concerns

Platform, agents, tools, and projects must remain independent.

## Extensibility

New agents, tools, and projects should be added without changing the Core architecture.

---

# Summary

Atlas DevOS is structured as a layered AI-assisted development platform.

The architecture separates:

* Core execution infrastructure
* AI intelligence
* Production automation
* External tools
* Creative projects

This separation allows Atlas to evolve while preserving reliability, context, and development history.

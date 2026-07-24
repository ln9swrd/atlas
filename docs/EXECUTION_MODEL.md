# Atlas Execution Model

## Purpose

This document defines how Atlas executes development workflows.

The execution model describes the relationship between:

* Context
* AI Agents
* Decision System
* Execution System
* External Tools
* Evidence and State Management

Atlas execution is based on controlled, repeatable workflows rather than direct action execution.

---

# Runtime Loop

Atlas runtime operates as a continuous execution cycle.

```text
User Request

      ↓

Context Collection

      ↓

RuntimeContext Creation

      ↓

Decision Evaluation

      ↓

Execution Planning

      ↓

Task Execution

      ↓

Validation

      ↓

Evidence Recording

      ↓

State Update

      ↓

Next Cycle
```

---

# Execution Stages

## 1. Context Collection

Purpose:

Gather information required for execution.

Sources:

* Project Registry
* Environment Registry
* Goal Registry
* Runtime State
* Existing Documentation

Output:

```text
Raw Context
```

---

## 2. RuntimeContext Creation

RuntimeContext combines collected information into an execution context.

Contains:

* Active project
* Current goal
* Current task
* Available environment
* Available tools
* Applicable rules
* Previous evidence

RuntimeContext should represent the execution situation at a specific moment.

---

## 3. Context Resolution

Resolvers collect and normalize information.

Examples:

* ProjectResolver
* EnvironmentResolver
* ResourceResolver
* UserResolver
* TimeResolver

Rule:

Resolvers provide information only.

Resolvers do not decide actions.

---

## 4. Decision Evaluation

The decision layer evaluates the RuntimeContext.

Components:

* Priority Engine
* Rule Engine
* Recommendation Engine

Responsibilities:

* Select appropriate task
* Evaluate priority
* Check constraints

Decision output:

```text
Recommended Action
```

---

## 5. Execution Planning

Before execution, Atlas creates an execution plan.

The plan defines:

* Required capability
* Target environment
* Required tools
* Expected output
* Validation method

Example:

```text
Task:

Forge Blender Export


Requirements:

Blender
FBX Export
Validation


Target:

DEV_HOME_MAIN
```

---

# Execution Contract

Every automated action should have an execution contract.

Structure:

```text
Task

↓

Input

↓

Requirements

↓

Execution

↓

Expected Output

↓

Validation

↓

Evidence
```

Example:

```text
Task:
Validate Active Rig


Input:
Active Blender Asset


Requirements:
Blender Available


Output:
Validation Report


Evidence:
Log + Result File
```

---

# Runner Responsibilities

The Runner is an execution orchestrator.

Responsibilities:

* Start execution workflow
* Invoke plugins
* Manage execution order
* Update runtime state
* Record execution events

The Runner must not contain:

* Business decisions
* Project-specific logic
* Creative decisions

Decision responsibility belongs to:

* Rule Engine
* Priority Engine
* AI Agent Layer

---

# Plugin Structure

Plugins extend Atlas execution capabilities.

## Core Plugins

### RecommendationPlugin

Purpose:

* Generate recommended actions
* Connect with Priority Engine

---

### ExecutionPlugin

Purpose:

* Execute approved actions
* Connect with external tools

---

### ValidationPlugin

Purpose:

* Verify execution results
* Generate validation evidence

---

### StatePlugin

Purpose:

* Update runtime state
* Maintain consistency

---

### LoggingPlugin

Purpose:

* Record execution history
* Preserve evidence

---

### NotificationPlugin

Purpose:

* Report results
* Notify users or agents

---

# AI Agent Integration

SERA operates above the execution runtime.

Flow:

```text
User

 ↓

SERA

 ↓

Atlas Runtime

 ↓

Decision System

 ↓

Runner

 ↓

Plugin

 ↓

Tool
```

SERA assists with:

* Planning
* Analysis
* Interpretation
* Coordination

Atlas Core remains responsible for:

* State
* Rules
* Execution control

---

# External Tool Execution

External tools are accessed through controlled interfaces.

Examples:

* Blender
* Unreal Engine
* MCP Tools
* Cloud AI Services

Flow:

```text
Atlas

 ↓

Plugin Interface

 ↓

Tool Adapter

 ↓

External Tool

 ↓

Result

 ↓

Evidence
```

---

# Human Approval Boundary

The following actions require human confirmation:

* Architecture changes
* Destructive operations
* Major project direction changes
* Final release decisions

Automation should assist decision making, not remove human responsibility.

---

# Evidence and State Management

Every execution should produce evidence.

Evidence examples:

* Logs
* Test results
* Generated assets
* Review reports
* Commit history

State updates must reference available evidence.

---

# Summary

Atlas execution is a controlled runtime loop:

```text
Context

↓

Decision

↓

Execution

↓

Validation

↓

Evidence

↓

State
```

This model allows Atlas to support AI-assisted development while maintaining reliability, traceability, and human control.

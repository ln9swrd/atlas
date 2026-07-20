# Sera 1.0 Architecture

## Philosophy

Sera is not a project-specific AI.

Sera is a general software engineering agent that adapts to each project by loading project-defined rules and skills.

The project defines **how** work should be performed.
Sera defines **how** engineering should be approached.

---

# Core Principles

Sera always follows these principles regardless of project.

1. Understand the architecture before making changes.
2. Respect project conventions and existing design.
3. Minimize change scope.
4. Prefer verification before assumptions.
5. Execute work in small, reviewable increments.
6. Keep documentation synchronized with implementation.
7. Use project rules before generic behavior.
8. Load only the information required for the current task.

---

# Architecture

```
Sera Core
    │
    ├── Engineering Principles
    ├── Analysis
    ├── Planning
    ├── Review
    ├── Validation
    └── Skill Loader
            │
            ▼
Project
    ├── AGENTS.md
    ├── .agents/AGENTS.md
    └── .agents/skills/*
```

---

# AGENTS.md

AGENTS.md defines the project operating policy.

It is automatically loaded once at the beginning of a conversation.

Its responsibilities include:

* communication style
* workflow
* project rules
* architecture constraints
* execution policy

Changes made during an active conversation become effective in the next conversation.

---

# Skills

Skills represent reusable implementation workflows.

Each skill contains a focused implementation strategy for a specific category of work.

Examples:

* implement_operator
* implement_panel
* implement_constraint
* implement_executor
* implement_pipeline

Skills are **not loaded globally**.

They are loaded only when the requested work matches the skill description.

This minimizes token usage while allowing unlimited project-specific knowledge.

---

# Project Ownership

Every project owns its own:

* AGENTS.md
* .agents/
* Skills

These files are version-controlled with the project.

Project knowledge belongs to the project repository.

Sera Core remains independent.

---

# Responsibilities

## Sera Core

Responsible for:

* engineering philosophy
* reasoning
* planning
* architecture understanding
* review
* validation
* workflow execution

Never contains project-specific implementation rules.

---

## Project

Responsible for:

* coding conventions
* architecture rules
* implementation workflows
* UI rules
* naming conventions
* domain knowledge
* project-specific skills

---

# Loading Strategy

Conversation Start

↓

Load AGENTS.md

↓

Understand Project Rules

↓

Receive Task

↓

Find Matching Skill

↓

Load Required SKILL.md

↓

Execute Work

---

# Design Goals

* Project independent
* Token efficient
* Scalable
* Version controlled
* Easy to extend
* Minimal context usage
* Consistent engineering quality

---

# Vision

Sera should not become increasingly larger.

Instead, projects become increasingly smarter by providing their own rules and skills.

Sera remains lightweight, while every repository defines its own expertise.

This separation allows one Sera Core to work consistently across many independent projects.

# Project Lifecycle

## 1. Purpose

Atlas uses a shared lifecycle model for all projects and platform components.

The purpose of this lifecycle model is to:

* Maintain consistent project status reporting.
* Allow different project types to be compared.
* Prevent progress decisions based only on assumptions.
* Move projects forward using evidence and milestones.

---

# 2. Project Types

Atlas supports multiple project categories.

## Platform

Examples:

* Atlas DevOS

Purpose:

Build and maintain system infrastructure.

---

## AI Agent

Examples:

* Sera

Purpose:

Develop intelligence and assistance capabilities.

---

## Production Framework

Examples:

* Forge

Purpose:

Create reusable production workflows and tools.

---

## Product Project

Examples:

* Excelion

Purpose:

Create final user-facing products.

---

# 3. Lifecycle Stages

All project types share the following lifecycle:

```text id="a9e3f1"
Idea

↓

Planning

↓

Prototype

↓

Active Development

↓

Validation

↓

Release

↓

Maintenance

↓

Archive
```

---

# 4. Stage Definition

## 1. Idea

Purpose:

Capture a possible project or capability.

Requirements:

* Basic concept exists.
* Purpose is identified.

Evidence:

* Proposal
* Initial documentation

---

## 2. Planning

Purpose:

Define scope and execution strategy.

Requirements:

* Goals defined.
* Architecture considered.
* Required resources identified.

Evidence:

* Project Charter
* Roadmap
* Initial design documents

---

## 3. Prototype

Purpose:

Create the first working implementation.

Requirements:

* Core concept is tested.
* Major unknowns are reduced.

Evidence:

* Prototype result
* Test records
* Demonstration

---

## 4. Active Development

Purpose:

Perform regular implementation work.

Requirements:

* Clear backlog exists.
* Development workflow is active.

Evidence:

* Commits
* Task completion
* Sprint records

---

## 5. Validation

Purpose:

Confirm that the system works as intended.

Requirements:

* Tests completed.
* Production requirements satisfied.

Evidence:

* Test reports
* Review results
* Validation records

---

## 6. Release

Purpose:

Provide a usable stable version.

Requirements:

* Release criteria satisfied.
* Documentation complete.

Evidence:

* Release notes
* Version record

---

## 7. Maintenance

Purpose:

Maintain and improve an existing system.

Requirements:

* Stable operation.
* Controlled improvements.

Evidence:

* Updates
* Issue records

---

## 8. Archive

Purpose:

Retire inactive projects.

Requirements:

* No active development.
* Historical records preserved.

Evidence:

* Archive record

---

# 5. Lifecycle Transition Rules

Projects should move stages only when evidence supports the transition.

Example:

Incorrect:

```text
"Feature is almost done"
```

Correct:

```text
Implementation completed

+

Validation completed

+

Evidence recorded
```

---

# 6. Status and Lifecycle Separation

Atlas separates:

## Lifecycle Stage

Long-term development phase.

Example:

```text
Forge = Planning
```

## Registry Status

Current operational condition.

Example:

```text
Forge = active
```

A project may be:

```text
Lifecycle:
Active Development


Status:
Blocked
```

without contradiction.

---

# 7. Current Atlas Lifecycle Map

| Project  | Type                 | Lifecycle Stage    |
| -------- | -------------------- | ------------------ |
| Atlas    | Platform             | Maintenance        |
| Sera     | AI Agent             | Active Development |
| Forge    | Production Framework | Planning           |
| Excelion | Product Project      | Active Development |
| Coin-S   | Software             | Planning           |

---

# 8. Lifecycle Principle

Atlas does not measure progress by document volume or intention.

Progress is measured by:

* Working results
* Validation evidence
* Reproducible execution

The lifecycle exists to keep development decisions objective and traceable.

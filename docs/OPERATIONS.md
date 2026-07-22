# Atlas Operations Manual

## Purpose

This document defines how Atlas is operated in daily practice. It turns Atlas from a collection of architecture documents into a repeatable operating process for real development work.

## Operating Principle

Atlas should be used as a daily operating system for execution, not as a passive repository of ideas. Every workday should follow the same basic rhythm:

1. Understand the current context.
2. Recommend the next best work.
3. Execute the selected task.
4. Update state and evidence.
5. Prepare the next cycle.

## Daily Cycle

```text
Start Day
  ↓
Resolve Context
  ↓
Recommend Work
  ↓
Execute Task
  ↓
Update State
  ↓
Record Event
  ↓
Commit
  ↓
End Day
```

## Day Start Procedure

### 1. Review the system entry point

Start by reviewing [SYSTEM_MANIFEST.md](process/SYSTEM_MANIFEST.md) so the current release posture, architecture focus, and operating principles are clear.

### 2. Resolve runtime context

Create or refresh the runtime context for the current environment, project, time, and active goal.

### 3. Run the recommendation layer

Use the priority engine to evaluate the current backlog and select the next most relevant action.

### 4. Select the operational target

For the current release cycle, Excelion is the primary validation project. The preferred flow is:

```text
SYSTEM_MANIFEST
  ↓
RuntimeContext
  ↓
PriorityEngine
  ↓
Excelion Goal
  ↓
Sprint
  ↓
Task
  ↓
Commit
```

## During the Workday

When a task is completed:

1. Mark the task state as complete.
2. Update the relevant sprint or goal state.
3. Record an event or evidence entry.
4. Re-evaluate the runner and recommend the next task.

This keeps Atlas aligned with real progress rather than static planning.

## Day End Procedure

At the end of the day:

1. Commit the work that is ready.
2. Save sprint state.
3. Save Atlas state.
4. Generate the next recommended task set.

## Expected Outcome

When this procedure is followed consistently, Atlas becomes a practical DevOS for daily execution rather than only a design framework.

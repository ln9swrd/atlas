# ATLAS Beta-001 TaskBroker Design Proposal

## Current State
### TaskBroker Responsibilities
- Task lifecycle management (create/start/complete/fail)
- Event publishing via AtlasEventBus
- History recording to JSONL file
- DecisionEngine integration for priority/recommendation

### atlas_runner.py Responsibilities
- Runtime initialization
- Command dispatch
- Basic task orchestration

## Problems Identified
1. **Lifecycle Ownership Ambiguity**
   - Task creation/transition logic scattered between TaskBroker and runner
   - No clear separation of state mutation vs orchestration

2. **Event Model Inconsistencies**
   - Current events lack cancellation tracking
   - No standardized lifecycle event naming convention

3. **Priority/Assignment Flows**
   - DecisionEngine and TaskBroker have overlapping responsibilities
   - Duplicate task recommendation logic in multiple locations

4. **Runner Overload**
   - atlas_runner.py handles both orchestration and lifecycle management
   - History management and state mutation mixed with runtime logic

## Target Architecture
### TaskBroker Ownership
- **Exclusive Lifecycle Control**
  - Create → Start → Complete/Fail → Cancel
  - Centralized state transition validation

- **Event Bus Integration**
  - Standardized events:
    ```python
    task_created
    task_started
    task_completed
    task_failed
    task_cancelled
    ```
  - Event payload normalization

- **Decision Separation**
  - Rule-based priority calculation in DecisionEngine
  - TaskBroker handles agent assignment based on engine output

### Runner System
- **Core Responsibilities**
  - Runtime boundary initialization
  - High-level orchestration of task groups
  - Command dispatch to worker systems

- **Removed Responsibilities**
  - All lifecycle state management
  - Direct history recording
  - Decision execution details

## Migration Steps
1. **Architecture Definition**
   - Finalize lifecycle event naming and payload structure
   - Define clear ownership boundaries between systems

2. **Code Refactoring**
   - Move all state mutation logic to TaskBroker
   - Extract event publishing to dedicated module
   - Create task lifecycle validation service

3. **Testing Strategy**
   - Maintain existing audit tests
   - Add boundary condition tests for:
     - Failed task recovery
     - Cancelled task cleanup
     - Priority recalculations

4. **Runtime Integration**
   - Update atlas_runner.py to use TaskBroker APIs
   - Implement graceful degradation for Beta-001

## Risk Assessment
| Risk | Mitigation |
|------|------------|
| Event bus overload | Implement batching for history events |
| Priority calculation breaks | Maintain parallel DecisionEngine until stable |
| Runner downtime during migration | Use feature flags for gradual transition |
| Audit log gaps | Implement validation checks during migration |
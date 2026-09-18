# ATLAS Runtime Boundary Refinement: Responsibility Mapping for `atlas_runner.py`

---

## **1. Runtime Context Management**
- **Responsibilities**:
  - Builds and merges runtime context from environment, project, and override settings.
  - Manages resources (available minutes, energy, focus), constraints, and user configurations.
- **Key Functions**:
  - `build_runtime_context()`
  - `build_start_report()` (context initialization)
- **Dependencies**:
  - `resolve_context()` (from `core/execution`)

---

## **2. Decision Making Engine**
- **Responsibilities**:
  - Executes rule-based decisions using `RuleDecisionStrategy`.
  - Prioritizes tasks based on goals, constraints, and knowledge.
- **Key Functions**:
  - `build_start_report()` (decision generation)
  - `DecisionEngine.make_decision()`
- **Dependencies**:
  - `core/decision/decision_engine.py`
  - `core/decision/strategies/rule_decision_strategy.py`

---

## **3. Task Scheduling & Initialization**
- **Responsibilities**:
  - Recommends tasks from backlog and sprint plans.
  - Initializes task states and updates the system state file (`ATLAS_STATE.json`).
- **Key Functions**:
  - `build_start_report()` (task recommendations)
  - `initialize_task_state()`
  - `advance_task()`
- **Dependencies**:
  - `core/task/task_broker.py` (for task prioritization)

---

## **4. Audit & Compliance Validation**
- **Responsibilities**:
  - Validates system state against rules and constraints.
  - Runs pre-flight checks and quality reviews.
- **Key Functions**:
  - `run_audit()`
  - `run_script()` (for `rule_engine.py` and `review_engine.py`)
- **Dependencies**:
  - `core/rules/rule_engine.py`
  - `core/review/review_engine.py`

---

## **5. Feedback Logging & Analysis**
- **Responsibilities**:
  - Logs task feedback (selected, completed, overrides).
  - Replays and evaluates feedback to derive metrics (accuracy, completion rates).
- **Key Functions**:
  - `log_feedback()`
  - `replay_feedback()`
  - `evaluate_feedback()`
- **Dependencies**:
  - `logs/feedback_log.jsonl`

---

## **6. State & Lifecycle Management**
- **Responsibilities**:
  - Tracks task progress (TODO → IN_PROGRESS → DONE).
  - Updates system state (`ATLAS_STATE.json`) and logs events.
- **Key Functions**:
  - `initialize_task_state()`
  - `complete_current_task()`
  - `end_day()`, `finish_day()`
- **Dependencies**:
  - `logs/atlas_events.jsonl`

---

## **7. Execution Simulation & Control**
- **Responsibilities**:
  - Simulates daily operations (start, next, end, finish).
  - Manages command-line interface (CLI) for user interaction.
- **Key Functions**:
  - `start_day()`, `end_day()`, `finish_day()`
  - `main()` (CLI entry point)
- **Dependencies**:
  - `core/execution/README.md` (execution log updates)

---

## **8. Reporting & Metrics Generation**
- **Responsibilities**:
  - Generates audit reports, sprint summaries, and performance metrics.
  - Updates documentation with execution logs and task statuses.
- **Key Functions**:
  - `generate_audit_markdown()`
  - `generate_project_status_markdown()`
  - `compare_versions()`, `evaluate_feedback()`
- **Dependencies**:
  - `docs/ATLAS_STATE_SUMMARY.md`
  - `core/execution/README.md`
# Atlas Constitution

This document defines the enduring principles that govern Atlas as a development operating system.

## Core Principles

1. Atlas is a development operating system, not a single project.
2. ROI and measurable impact take priority over feature volume.
3. Automation is introduced only after a repeated workflow has been validated.
4. The sequence Rule -> Review -> Metrics must be preserved.
5. Projects are not owned by Atlas; Atlas supports them through structured operations.
6. Every agent must be defined through the registry and follow its role contract.
7. Atlas core components should remain stable and reusable.
8. Atlas should avoid frequent structural changes; major structural changes should be introduced only when validated by real project needs.
9. Atlas Core must prioritize stability and maintain a conservative evolution path; new features should be added only when their necessity and ROI are validated through real project usage.

## Operating Rules

- Prefer evidence over assumption.
- Keep lifecycle states explicit for projects.
- Separate platform maintenance from active product development.
- Use the registry as the canonical source for project and agent context.
- Use [ATLAS_STATE.json](../../ATLAS_STATE.json) as the current runtime state source for mode, active project, and active agents.
- Favor improvements that reduce friction, cost, or risk in execution.

## Review Context

Atlas documents should be reviewed through the shared lens captured in [docs/process/ATLAS_REVIEW_CONTEXT.md](../process/ATLAS_REVIEW_CONTEXT.md). This review context preserves the system's emphasis on evidence-first reasoning, reproducibility, automation readiness, traceability, and stability over unnecessary churn.

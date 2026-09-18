# Atlas Review Context

This document captures the shared review context for Atlas documentation and implementation review.

## Purpose
Use this context whenever reviewing Atlas documents to keep changes aligned with the system's operating model, governance principles, and automation expectations.

## Review Lens

1. Evidence-first
   - Claims and conclusions should be traceable to observations, verification, or documented evidence.
   - Avoid unsupported assertions or speculative language.

2. Deterministic and reproducible behavior
   - Workflows should remain consistent across runs and environments.
   - Validation and review steps should not depend on hidden state.

3. Automation readiness
   - Processes should be executable, observable, and safe to automate.
   - Changes should be introduced only after the workflow has been validated in practice.

4. Stability over churn
   - Preserve core architecture and conventions unless there is clear operational need.
   - Avoid unnecessary structural reshaping of the platform.

5. Traceability and auditability
   - Decisions should remain connected to the evidence and supporting artifacts that justify them.
   - Runtime state, goals, and task execution should remain consistent and inspectable.

6. Operational value over volume
   - Favor improvements that reduce friction, risk, cost, or ambiguity.
   - Prefer measurable impact over adding more features without evidence.

## Review Checklist

- Does the document preserve the Rule -> Review -> Metrics flow?
- Does it remain consistent with the Atlas Constitution and runtime model?
- Does it clarify the decision, the evidence, and the implications?
- Does it avoid contradictions across architecture, runtime, and operations docs?
- Does it support future automation rather than creating additional manual maintenance burden?

## Expected Outcome
A reviewed Atlas document should be:
- evidence-based,
- structurally consistent,
- operationally useful,
- and aligned with Atlas as a development operating system rather than a single-project artifact.

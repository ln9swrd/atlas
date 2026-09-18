# 01_CORE

## Knowledge vs Runtime

| Layer | Role |
|-------|------|
| Knowledge | Goals, rules, ADR, docs — stable, Git-managed |
| Runtime | Current task, session state — disposable |

Runtime **reads** Knowledge; Knowledge must not depend on Runtime.

## Constitution (summary)

- EvidenceGraph / rules treated as durable knowledge
- Validation is deterministic evaluation, not mutation of knowledge
- Fail closed when evidence is missing
- Observe → Infer → Decide

## Canonical archive refs

005, 006, 007, 016, 017

## Status

Design decisions archived; **no core code changes** on rebuild branch.

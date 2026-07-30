# 05_AGENTS

| Actor | Role |
|-------|------|
| **Atlas** | Context, task, decision, audit, provider policy (DevOS) |
| **Cline** (primary) | Local agent + tools; reads Git `state/` |
| **Cloud AI (mode)** | Optional cloud-side analysis / design review — **not a project** (legacy name SERA retired as project, D19) |
| **Kraken** | Local execution assistance (layer name; path TBD — issue #5) |
| **Continue** | Optional autocomplete only |
| **Human (Master)** | Goals, final approval, direction |

Work modes on shared project state: `cline` | `cloud` | `both` — see `docs/process/PROJECT_STATE_SCHEMA.md`.

Atlas must not depend on a single model vendor.

Archive refs: 018, 048, 080, 085 (historical SERA→Atlas transition).

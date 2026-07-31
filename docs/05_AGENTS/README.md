# 05_AGENTS

| Actor | Role |
|-------|------|
| **Atlas** | Context, task, decision, audit, provider policy (DevOS) |
| **Cline** (primary agent) | Local agent + tools; reads Git `state/` |
| **Cloud AI (mode)** | Design / review drafts — **not a project** (SERA project retired, D19) |
| **Kraken** | Local execution layer name; path TBD — issue #5 |
| **Continue** | Optional autocomplete only |
| **마스터 (Master)** | Goals, final approval, Done; **simple commands & shell scripts** (D21) |

Work modes: `cline` | `cloud` | `both` — `docs/process/PROJECT_STATE_SCHEMA.md`.

**Role detail:** [`ROLE_SPLIT.md`](ROLE_SPLIT.md)

Atlas must not depend on a single model vendor.

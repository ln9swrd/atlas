# 05_AGENTS

| Actor | Role |
|-------|------|
| **Atlas** | Context, task, decision, audit, provider policy (DevOS) |
| **마스터 (Master)** | Goals, final approval, Done; **simple commands & shell scripts** (D21) |
| **Cloud AI (mode)** | Design / review drafts — **not a project** (SERA project retired, D19) |
| **Local agent** | Optional only — **not primary** (D30). Cline surface 미사용 |
| **Kraken** | Local execution layer name; path TBD — issue #5 |
| **Continue** | Optional autocomplete only |

Work modes: `cloud` | `local-agent` | `both` — `cline` mode **retired** under D30.  
See `docs/process/PROJECT_STATE_SCHEMA.md` (schema may still list legacy `cline` until updated).

**Role detail:** [`ROLE_SPLIT.md`](ROLE_SPLIT.md)  
**Decision:** D30 in `docs/DECISIONS.md`

Atlas must not depend on a single model vendor.

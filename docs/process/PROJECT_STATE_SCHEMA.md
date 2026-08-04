# Project State Schema

Status: **Active** (G2, 2026-07-30 · D30 update 2026-08-04)  
Applies to: every domain project under `projects/<name>/`  
Does **not** replace Atlas root `state/` (that is DevOS-only).

---

## 1. Separation

| Layer | Path | Owns |
|-------|------|------|
| **Atlas (DevOS)** | `/state/` | Platform progress, L-*, G-*, rebuild |
| **Domain project** | `projects/<name>/state/` | That project's only status, tasks, context |

- Atlas ≠ product project (D02, D19).
- Project SERA is **deprecated** — do not create `projects/sera`.
- AI modes share the **same Git files**; tools differ, truth does not.

---

## 2. AI work modes (same state files)

| Mode | Who runs tools | State files |
|------|----------------|-------------|
| `cloud` | Cloud AI (chat / Git API) | Same paths; explicit edit or PR |
| `local-agent` | Optional local agent when Master enables | Read/write project `state/` via Git |
| `both` | Local agent executes; cloud designs/reviews | `TASK_MAP` rows may set `assignee` |
| ~~`cline`~~ | **Retired (D30)** | Treat legacy `ACTIVE_MODE: cline` as `cloud` or `local-agent` |

Do not keep a second copy of status in chat-only memory.  
Cline surface 미사용 — 재도입 금지(명시 지시 전).

---

## 3. Required files per project

```
projects/<name>/
  state/
    CURRENT_STATE.md   # required
    TASK_MAP.md        # required
    CONTEXT_INDEX.md   # required
  docs/                # per PROJECT_DOC_STANDARD when active
```

Template: `projects/_template/state/` (G3).

---

## 4. CURRENT_STATE.md (minimum fields)

```markdown
# CURRENT_STATE — <project name>

ACTIVE_TARGET: <one line>
ACTIVE_MODE: cloud | local-agent | both
ACTIVE_BRANCH: <branch or n/a>
STATUS: <one line>

## Next one thing
1. <single next task id or one sentence>

## Blockers
- None | <list>

## Do not
- <project-specific bans>
```

Rules:
- One **Next one thing** only.
- Update on every meaningful session end (or after each G/L-style unit).

---

## 5. TASK_MAP.md (minimum)

| Column | Meaning |
|--------|--------|
| ID | Stable id (e.g. T-1, FEAT-3) |
| Task | One actionable line |
| Status | Pending / In progress / Done / Blocked |
| Assignee | `human` / `local-agent` / `cloud` / `both` (optional; legacy `cline` → `local-agent`) |
| Evidence | Path, commit, or CLI note when Done |

- Prefer small rows over large epics.
- Done requires evidence (D01).

---

## 6. CONTEXT_INDEX.md (minimum)

| Section | Content |
|---------|--------|
| Always | 1–5 paths for this project |
| By task type | Optional short lists |
| Forbidden | Do not load `archive/`, `obsidian/`, other projects' full trees |

Token discipline: open only listed paths for the current Next item.

---

## 7. Agent load order (all modes)

1. `projects/<name>/state/CURRENT_STATE.md`
2. `projects/<name>/state/TASK_MAP.md` (next open row only)
3. `projects/<name>/state/CONTEXT_INDEX.md` → listed files only
4. Atlas `AGENTS.md` + root `state/` only if work touches DevOS itself

Never auto-dump Atlas `archive/` or `obsidian/` into project work context.

---

## 8. Relation to Atlas root state

| Root `state/` | Project `state/` |
|---------------|------------------|
| Platform L-*, G-*, IMP-* | Product/feature tasks |
| D19, rebuild, surface policy | App-specific NEXT |

When both change in one session, update **both** maps (rule: status on Git).

---

## 9. Out of scope for this schema

- Runtime DB, camera pipeline
- Reintroducing Cline without Master (D30)
- Implementing cloud provider APIs as platform product
- Replacing Evidence-First with chat claims

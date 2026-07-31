# Decision Log Discipline (P2-5)

SoR: **`docs/DECISIONS.md`** only (chat ≠ Decision).  
Related: D01, D21 · `docs/05_AGENTS/ROLE_SPLIT.md`

---

## Flow

```text
Cloud/Cline draft  →  Master confirm  →  DECISIONS.md entry  →  (optional) implement
```

| Step | Who | Output |
|------|-----|--------|
| 1. Draft | Cloud (Sera) or Cline | `docs/06_OPERATIONS/*_DRAFT*.md` or issue comment |
| 2. Confirm | **Master** | Explicit yes / edit |
| 3. Log | Cline or Master | New/updated row in `docs/DECISIONS.md` |
| 4. Implement | Cline + Master Evidence | Separate task in TASK_MAP |

**Rule:** No silent Decision. No “Done” on policy without Master confirm.  
**Rule:** Implementation Evidence ≠ Decision confirm (both required when both apply).

---

## Entry template (append to DECISIONS.md)

```markdown
| Dxx | **Short title** | Date. Context one line. Status: Confirmed / Implemented. |
```

Long rationale → short design doc under `docs/07_ROADMAP/` or `docs/adr/`, link from Notes.

---

## Commit

```bash
git add docs/DECISIONS.md
git commit -m "decision: Dxx short title"
git push github main
```

---

## Open drafts

- Historical G6: `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md` (Confirmed 2026-07-31)
- New drafts: one file under `docs/06_OPERATIONS/` or issue; do not put unconfirmed text into DECISIONS.md

---

## Checklist (each Decision)

- [ ] Draft exists and is dated
- [ ] Master confirmed (chat or commit message / state note)
- [ ] `docs/DECISIONS.md` updated
- [ ] If implement needed → TASK_MAP row + Evidence later

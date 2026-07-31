# S4 Extract / Sync Playbook

Date: 2026-07-31  
Prerequisite: S1 tag `pre-split-atlas`, S3 repos exist  
**Run on Master/Cline local machine** (API cannot bulk-copy large blobs).

---

## Inventory (atlas main)

| Path | Scale | Notes |
|------|-------|-------|
| `projects/excelion/` | ~23 files | docs, goals, sprints, state — **no large binaries** |
| `projects/excelion-forge/` | ~248 paths | code + **large** `.blend` / audio under `blender/` |

Standalone `ln9swrd/excelion-forge` already has `excelion_forge/`, `docs/`, `tests/`, etc. Some blobs share SHA with mono (e.g. `AGENTS.md`). **Do not force-push overwrite.**

---

## S4-A — excelion (fill empty repo)

Recommended: **file copy without rewriting atlas history** (simple; history stays on atlas until optional later subtree).

```bash
cd /mnt/d
git clone https://github.com/ln9swrd/excelion.git
cd excelion
# copy tree (exclude nothing critical)
rsync -a --delete --exclude .git /mnt/d/Atlas/projects/excelion/ ./
git add -A
git status
git commit -m "chore: import projects/excelion from atlas @ pre-split-atlas"
git push origin main
```

Optional history-preserving (harder):

```bash
cd /mnt/d/Atlas
git subtree split -P projects/excelion -b split/excelion
# then push split/excelion to ln9swrd/excelion
```

**Evidence:** clone excelion fresh; tree matches mono path file count.

---

## S4-B — excelion-forge (sync, no blind overwrite)

1. **Canonical = standalone repo** if it is the day-to-day working copy.  
2. Diff mono vs standalone:

```bash
cd /mnt/d
git clone https://github.com/ln9swrd/excelion-forge.git excelion-forge-standalone
# compare (read-only)
diff -rq Atlas/projects/excelion-forge excelion-forge-standalone \
  --exclude .git --exclude __pycache__ --exclude .aider* | head -100
```

3. Decisions from diff:
   - **Only in mono** → cherry-pick/copy into standalone PR  
   - **Only in standalone** → keep; mono is stale  
   - **Conflict** → Master picks; document in forge `state/`

4. Large media: follow `BINARY_ASSET_POLICY` (LFS/external); do not re-upload duplicates if already in standalone.

**Evidence:** written `docs` or `state` note listing diff summary + chosen canonical.

---

## S4-C — after both verified

- Update product READMEs: “source of truth = this repo; atlas path deprecated pending S5”  
- **Do not** delete `projects/excelion*` from atlas until S5 Master confirm  
- atlas PROJECT_MAP already links GitHub URLs

---

## Non-goals for S4

- Removing paths from atlas (S5)  
- filter-repo on atlas main  
- Merging forge + excelion into one repo

# Residue cleanup R1–R4 / R5 policy / R9 — 2026-08-11

Based on `STRUCTURAL_RESIDUE_AUDIT_2026-08-11.md`.

## Start HEAD
`8336ff5438c72778eb43a071251bce2d83df64e2`

## Executed

### R1 — REMOVE
- `pyproject.toml.draft` (SUPERSEDED)

### R2 — REMOVE
- `scripts/master_l8_l10.sh` (D22 exit-only)

### R3 — HYGIENE
- Untracked from git: `logs/atlas_events.jsonl`, `logs/atlas_status.txt`, `logs/decision_history.jsonl`
- `.gitignore` already has `logs/` — no ignore change needed

### R4 — DOC SYNC
- `coin-s`: path absent — updated maps/registry

### R5 — POLICY (no delete)
- Unregistered projects HOLD: 3GUpbit, aws-mcp, blender-mcp-main, blender-open-mcp

### R9 — ARCHIVE MOVE
- ATLAS_ALPHA_*/BETA_* → archive/process-alpha-beta-snapshots/

## Not in this commit scope leftovers
- R6–R8, R10

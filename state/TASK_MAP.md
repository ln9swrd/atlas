# TASK_MAP

> Documentation rebuild track is closed except optional local tag. Implementation work uses issue + branch.
> **Owner local** rows are actions only the human can run on their machine (no GitHub API).

## Docs rebuild (RB-*)

| ID | Task | Status |
|----|------|--------|
| RB-A | Tag / branch for rebuild | Done |
| RB-B | Isolate summary under `archive/` | **Done** (`archive/summary/` 000–086) |
| RB-C | `docs/00`–`07` skeleton + specs | Done |
| RB-D | `state/` CURRENT / CONTEXT / TASK / PROJECT | Done |
| RB-E | README charter for 3 requirements | Done |
| RB-F | Merge to `main` | **Done** (PR #1) |
| RB-F2 | Tag `atlas-docs-rebuild-v1` | **Pending — owner local** |
| RB-G | Bulk path move summary → `archive/summary/` | **Done** |
| RB-H | Clean root / ignore tracked junk | Policy Done (`.gitignore`); **untrack still owner local** |

## Analysis follow-up (2026-07-30)

| ID | Task | Status |
|----|------|--------|
| AF-1 | `docs/DECISIONS.md` (D01–D18) | **Done** |
| AF-2 | `docs/GLOSSARY.md` | **Done** |
| AF-3 | `docs/process/DUPLICATE_POLICY.md` | **Done** |
| AF-4 | Exact duplicate delete (061/062/063/065/066 Named + Original + summary) | **Done** |
| AF-5 | `docs/process/CORE_INDEX.md` + CONTEXT_INDEX sync | **Done** |
| AF-6 | Open Questions → GitHub issues | **Done** — [#4](https://github.com/ln9swrd/atlas/issues/4) Q01 VERIFY · [#5](https://github.com/ln9swrd/atlas/issues/5) Q03 SERA/Kraken · [#6](https://github.com/ln9swrd/atlas/issues/6) Q02 SPRINT · [#7](https://github.com/ln9swrd/atlas/issues/7) Q04 Forge |

## Implementation (repo)

| ID | Task | Status |
|----|------|--------|
| IMP-1 | Extension formal track | **Open** — [issue #2](https://github.com/ln9swrd/atlas/issues/2) · branch `impl/atlas-extension` · draft [PR #3](https://github.com/ln9swrd/atlas/pull/3) |
| — | Camera / vision pipeline code | **Out of scope** |
| — | AI Runtime / Plugin Host / Knowledge services | **Out of scope** until separate issues |

## Owner local TODO (must do on your PC)

Priority order. Check off in this file or in issue #2 comments when done.

| ID | Task | Status | How |
|----|------|--------|-----|
| L-1 | Ollama model with large context | Pending | Modelfile `PARAMETER num_ctx 32768` (or 65536) → e.g. `ollama create qwen3-atlas -f Modelfile` from `qwen3:14b` |
| L-2 | Cline + Ollama wire-up | Pending | VS Code Cline → provider Ollama → host `http://192.168.219.254:11434` (or local) → model = L-1 name |
| L-3 | Cline harden for local | Pending | Disable parallel tool calls / subagents; do not auto-approve write/terminal |
| L-4 | Atlas rules into Cline | Pending | Custom instructions: Evidence-First; prefer `state/CURRENT_STATE.md`, `TASK_MAP.md`, `CONTEXT_INDEX.md`, `AGENTS.md`; never dump `archive/`, `obsidian/`, `node_modules/`; one tool at a time |
| L-5 | Smoke test Cline | Pending | (1) `git status` (2) read `state/CURRENT_STATE.md` only (3) one small edit with approval — no infinite loop |
| L-6 | Untrack extension junk | Pending | On `impl/atlas-extension`: `git rm -r --cached projects/atlas-extension/node_modules` and `*.vsix` → commit → push |
| L-7 | Merge main into impl branch | Pending | `git checkout impl/atlas-extension && git merge main` then push |
| L-8 | F5 checklist (optional) | Pending | If keeping custom extension: `docs/04_IDE_EXTENSION/F5_CHECKLIST.md` |
| L-9 | Tag docs rebuild | Pending | `git tag -a atlas-docs-rebuild-v1 -m "docs rebuild closed" && git push origin atlas-docs-rebuild-v1` |
| L-10 | PR #3 | Pending | After L-5~L-7: mark draft PR ready or close if Cline replaces custom extension as primary surface |

### Decision (owner)

- **Primary work surface:** Cline (or Roo if L-5 fails) + local Ollama — not Continue as main agent; not growing custom extension into a full agent.
- **Continue:** optional autocomplete only.
- **Custom `projects/atlas-extension`:** secondary until L-5 proves Cline stable; then deprecate or keep as thin panel only.

## Out of scope (do not start without new issue)

- Forking Cline/Continue at scale
- Camera / vision pipeline
- Full AI Runtime / Plugin Host / Knowledge services

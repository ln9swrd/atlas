# D23 VERIFY CWD Jail — Design Draft (P2-1)

> Status: **Draft** (2026-07-31)  
> Owner: Cloud draft → Master confirm → Cline implement  
> Related: D17, D18, D23 · F1/F2/F4 Done · `tools/domain_policy.py`

---

## 1. Goal

D23 Acceptance: VERIFY·도구 실행의 파일/코드 접근을

1. **활성 도메인** (`projects/<active>/` when ACTIVE_TARGET is a product), **or**
2. **Atlas system paths** (`state/`, `tools/`, `docs/` read, `AGENTS.md`, `core/` as needed for runner),

으로 제한한다. 호스트 임의 경로·BLACK·workspace 밖 금지. 메타(DevOS 코어 수정) 우회는 **Master 명시 승인**만.

Min-scope 현재 ACTIVE_TARGET = platform → 제품 `projects/*` 쓰기/실행은 **기본 거부** (read 정책은 아래).

---

## 2. Current vs gap

| Layer | Today | Gap |
|-------|--------|-----|
| BLACK deny | Done (`domain_policy`) | — |
| Outside workspace deny | Done (resolve + relative_to) | — |
| Runner `run_script` | `assert_path_allowed` | only script path; not all I/O |
| Orchestrator read/write | BLACK check | no `workspace=` on some calls; no allowlist |
| Orchestrator CLI | `command_mentions_black`; `cwd=WORKSPACE_ROOT` | shell can still use absolute paths / `cd` |
| Active target allowlist | **Missing** | D23 core |
| CWD hard jail | Soft (cwd=repo) | subprocess env / absolute path |

---

## 3. Policy model (proposed)

### 3.1 Modes from `state/CURRENT_STATE.md`

| ACTIVE_TARGET pattern | Allow write/exec under | Allow read under |
|----------------------|------------------------|------------------|
| `idle` / `platform*` / `F3*` | `state/`, `tools/` (policy+smoke), `docs/` (docs commits) | system + `AGENTS.md`; product trees **default no** |
| `projects/<name>` or product id | `projects/<name>/` + system | same + that project |
| Master override flag | explicit list in state | explicit |

Parse rule (simple, Evidence-friendly):

- If ACTIVE_TARGET contains `projects/` path segment or known product id → that project is active domain.
- Else → **platform mode**: no product write/exec.

### 3.2 System allow prefixes (always, relative to workspace)

```
state/
tools/
docs/
AGENTS.md
README.md
.clineignore
core/          # runner imports; prefer read; write = Master meta
atlas-runtime/ # same
tests/         # smoke / unit
logs/          # append-only preferred
```

BLACK always wins over allow.

### 3.3 API shape (extend `domain_policy.py`)

```text
path_is_blacklisted(path, workspace=...)           # existing
path_is_allowed(path, workspace=..., active=...)   # NEW: allowlist
assert_path_allowed(...)                           # existing; call path_is_allowed
assert_command_allowed(cmd, workspace=..., active) # NEW: parse rough paths in CLI
get_active_domain(state_text or path) -> str|None  # NEW
```

`assert_path_allowed` behavior change:

1. BLACK or outside WS → deny  
2. Else if not under allow prefixes for current mode → deny  
3. Else allow

### 3.4 CWD / subprocess jail

| Control | Spec |
|---------|------|
| Default cwd | `WORKSPACE_ROOT` only |
| Forbid | `cwd=` outside WS; absolute paths outside allow |
| CLI | Reject if token looks like absolute path outside WS or under BLACK |
| No network side-effect claim | Document only for now (no full network sandbox in min) |

Phased: **path + cwd first**; network isolation = later (P3+).

---

## 4. Implementation phases (code later)

| Phase | Work | Acceptance |
|-------|------|------------|
| **A** | `get_active_domain` + `path_is_allowed` + tests | unit tests green |
| **B** | Wire runner all script entry points | existing smoke + new cases |
| **C** | Orchestrator use `path_is_allowed` + `assert_command_allowed` | deny product write in platform mode |
| **D** | Smoke script cases in `check_domain_policy.py` | Master local Evidence |

**Not in this draft:** rewriting Cline itself; full OS container; product feature work.

---

## 5. Acceptance checklist (D23)

- [ ] Platform mode: write to `projects/excelion-forge/...` denied by policy API  
- [ ] BLACK still denied  
- [ ] Outside workspace denied  
- [ ] `state/` / `tools/check_domain_policy.py` allowed  
- [ ] Active product mode: only that `projects/<name>/` + system  
- [ ] Meta core write: documented as Master-only (no silent auto-allow)  
- [ ] Evidence: extended smoke + optional unit test under `tests/`

---

## 6. Non-goals

- Product pipeline work  
- Reviving extension  
- Camera / network full sandbox  
- Changing D23 decision text without Master

---

## 7. Next step after Master confirm

1. Master: approve this draft (or edit constraints)  
2. Cline: Phase A only (API + tests), small commit  
3. Evidence in `state/TASK_MAP.md`

---

*Draft only. No production behavior change until Phase A lands with Evidence.*

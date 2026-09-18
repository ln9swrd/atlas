# D23 VERIFY CWD Jail — Design (P2-1)

> Status: **Done** (Phase A–D, Evidence 2026-07-31)  
> Owner: Cloud draft → Master confirm → Cline implement  
> Related: D17, D18, D23 · F1/F2/F4 Done · `tools/domain_policy.py`

---

## 1. Goal

D23 Acceptance: VERIFY·도구 실행의 파일/코드 접근을

1. **활성 도메인** (`projects/<active>/` when ACTIVE_TARGET is a product), **or**
2. **Atlas system paths** (`state/`, `tools/`, `docs/` read, `AGENTS.md`, `core/` as needed for runner),

으로 제한한다. 호스트 임의 경로·BLACK·workspace 밖 금지. 메타(DevOS 코어 수정) 우회는 **Master 명시 승인**만.

Min-scope 현재 ACTIVE_TARGET = platform → 제품 `projects/*` 쓰기/실행은 **기본 거부**.

---

## 2. Current vs gap

| Layer | Status |
|-------|--------|
| BLACK deny | **Done** (`domain_policy`) |
| Outside workspace deny | **Done** (resolve + relative_to) |
| Active target allowlist | **Done** (Phase A `path_is_allowed`) |
| Runner `run_script` | **Done** (Phase B → `assert_path_allowed`) |
| Orchestrator read/write | **Done** (Phase C → `path_is_allowed`) |
| Orchestrator CLI | **Done** (Phase C → `command_is_allowed`) |
| Smoke Evidence | **Done** (Phase D `check_domain_policy.py` 25/25) |
| CWD hard jail / network sandbox | Soft only (cwd=WS); full jail = later P3+ |

---

## 3. Policy model

### 3.1 Modes from `state/CURRENT_STATE.md`

| ACTIVE_TARGET pattern | Allow write/exec under | Allow read under |
|----------------------|------------------------|------------------|
| `idle` / `platform*` / `F3*` | `state/`, `tools/`, `docs/` | system + `AGENTS.md`; product trees **default no** |
| `projects/<name>` or product id | `projects/<name>/` + system | same + that project |
| Master override flag | explicit list in state | explicit |

### 3.2 System allow prefixes

```
state/  tools/  docs/  core/  atlas-runtime/  tests/  logs/  config/  scripts/
AGENTS.md  README.md  .clineignore  requirements-dev.txt  .gitignore
```

BLACK always wins over allow.

### 3.3 API (`tools/domain_policy.py`)

```text
path_is_blacklisted(path, workspace=...)
path_is_allowed(path, workspace=..., active=...)
assert_path_allowed(...)
command_is_allowed(cmd, workspace=..., active=...)
assert_command_allowed(...)
get_active_domain(state_text or path) -> str|None
extract_path_tokens(command) -> list[str]
```

### 3.4 CWD / subprocess

| Control | Spec |
|---------|------|
| Default cwd | `WORKSPACE_ROOT` only |
| CLI path tokens | Reject if outside allowlist or BLACK |
| Network isolation | Document only (P3+) |

---

## 4. Implementation phases

| Phase | Work | Status |
|-------|------|--------|
| **A** | `get_active_domain` + `path_is_allowed` + tests | **Done** |
| **B** | Wire runner script entry points | **Done** |
| **C** | Orchestrator + `command_is_allowed` | **Done** |
| **D** | Smoke polish + this doc status | **Done** (Evidence 2026-07-31) |

**Not in scope:** rewriting Cline; full OS container; product feature work.

---

## 5. Acceptance checklist (D23)

- [x] Platform mode: write to `projects/excelion-forge/...` denied by policy API  
- [x] BLACK still denied  
- [x] Outside workspace denied  
- [x] `state/` / `tools/check_domain_policy.py` allowed  
- [x] Active product mode: only that `projects/<name>/` + system  
- [x] Meta core write: documented as Master-only (no silent auto-allow)  
- [x] Evidence: extended smoke + unit tests under `tests/`

---

## 6. Non-goals

- Product pipeline work  
- Reviving extension  
- Camera / network full sandbox  
- Changing D23 decision text without Master

---

## 7. Evidence commands

```bash
python3 tools/check_domain_policy.py   # 25/25 OK PASS
python3 -m unittest tests.test_domain_policy -v  # 15 OK
```

---

*P2-1 path/CLI allowlist complete.*

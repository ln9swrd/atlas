# Cloud AI 리뷰 및 실행 가이드 (L-8 ~ L-10)

Status: **Draft from cloud mode** — Human/Cline 실행 대기  
Date: 2026-07-31  
Source: Cloud AI session (mode: cloud)  
Plan: `docs/07_ROADMAP/CLOUD_AI_VSCODE_EXEC_PLAN.md`  
Roles: `docs/05_AGENTS/ROLE_SPLIT.md`  
Evidence: 본 문서 = CA-3 partial (설계·리뷰 Git 반영). L-8…L-10 **Done 아님**.

**Executor note (2026-07-31):** Human **can run simple commands and shell scripts**. L-8 / L-9 (and npm compile if Node is available) do **not** require Cline. L-10 F5 still needs VS Code + Ollama on a suitable machine.

---

## 산출물 (필수)

### 1. L-8 / L-9 / L-10 실행 체크리스트

복사/붙여넣기 후 **Human 또는 Cline**이 실행.

#### [L-8] Rebase 및 Merge 준비 — Human shell OK

- [ ] `main` 기준으로 `impl/atlas-extension` rebase 상태가 깨끗한지(충돌 없음) 확인

```bash
git fetch origin
git checkout impl/atlas-extension
git rebase origin/main
# 충돌 시 해결 후: git add … && git rebase --continue
```

#### [L-9] Packaging Untrack (node_modules, vsix) — Human shell OK

- [ ] 아래 명령으로 인덱스에서 제거 후 커밋 (파일 자체는 디스크에 남겨도 됨)

```bash
git checkout impl/atlas-extension
git rm -r --cached projects/atlas-extension/node_modules
git rm --cached projects/atlas-extension/*.vsix 2>/dev/null || true
git commit -m "chore(extension): stop tracking node_modules and vsix"
git push origin impl/atlas-extension
```

참고: `docs/04_IDE_EXTENSION/PACKAGING.md` (impl 브랜치)

#### [L-10] F5 Smoke 및 PR #3 Merge 전 확인

- [ ] `projects/atlas-extension/` 에서 `npm install` 후 `npm run compile` (node_modules 커밋 금지) — Human if Node available
- [ ] VS Code F5 (Extension Development Host) 후 점검 — **dev PC** (Cline optional):

| # | Check | Pass? |
|---|--------|-------|
| 1 | Activity bar Atlas 컨테이너 / sidebar webview | |
| 2 | `Atlas: Open Agent Panel` UI 오픈 | |
| 3 | 단순 프롬프트 → 스트리밍 토큰 (hang 없음) | |
| 4 | Domain isolation: `archive/` / `obsidian/` 자동 덤프 없음 | |
| 5 | host/model 설정 변경 → reload 후 반영 | |
| 6 | camera/mic 권한 팝업 없음 (camera = 0) | |

- [ ] Smoke 통과 후 PR #3 → `main` merge + tag — **Human** 승인

참고: `docs/04_IDE_EXTENSION/F5_CHECKLIST.md` (impl 브랜치)

---

### 2. PR #3 리뷰 포인트

| 항목 | 확인할 것 |
|------|-----------|
| **Domain Isolation (BOUNDARY)** | Extension이 archive 배제 등을 재구현하지 않고 `tools/atlas_qwen_orchestrator.py`에 위임하는지 |
| **Packaging** | Diff에 `node_modules` / `*.vsix` 가 다시 들어가지 않았는지 |
| **Orchestrator spawn** | 하드코딩 절대경로가 아니라 `ATLAS_ROOT` 또는 repo root CWD 기준인지 |

참고: `docs/04_IDE_EXTENSION/BOUNDARY.md` (impl 브랜치)

---

### 3. 리스크 · 주의 (3줄)

1. Extension에 Cloud-only API 강제 또는 채팅-only 상태 의존 → D15 / SoR 위반.
2. `projects/sera` 생성 또는 타 프로젝트 전체 트리 로드 → 컨텍스트 오염 (D19).
3. Evidence(파일/CLI) 없이 Done 선언 금지 (D01).

---

## 산출물 (선택) — G6 Decision 초안

> Human 승인 전 Decision Log 확정 금지. 초안만.

| Issue | 초안 한 줄 |
|-------|------------|
| **#4 VERIFY** | VERIFY의 코드/파일 접근 범위는 타겟 프로젝트 샌드박스로 제한하고, 호스트·외부 네트워크 부작용을 차단하는 쪽으로 범위를 문서로 확정한다. |
| **#5 Kraken** | Kraken은 제품 프로젝트가 아닌 실행·자동화 **계층** → `projects/`가 아닌 `tools/` 등 시스템 경로 후보로 둔다 (이름 keep/rename은 별도 한 줄 결정). |
| **#6 SPRINT-009~029** | 과거 스프린트는 활성 TASK가 아니라 Knowledge → 상태표 스캔 후 archive/보관·폐기 후보 구분. |
| **#7 Forge Phase 1→2** | Canonical path = `projects/excelion-forge/` only (D20). Phase 전환 체크리스트는 해당 경로 기준으로 작성. |

### CA-1 문구 초안

도메인 프로젝트 `state/CURRENT_STATE.md`:

```markdown
ACTIVE_MODE: both
```

(Cloud = 설계·리뷰 / Cline = 에이전트 루프 / Human = 승인·단순 쉘)

---

## 실행 후 Git에 넣을 것

- [ ] PR #3 merge → `main` (`projects/atlas-extension/` 등) — Human
- [ ] `state/CURRENT_STATE.md` — L-8…L-10 Done, Next = CA-1 또는 Forge T-1
- [ ] `state/TASK_MAP.md` — L-8…L-10 Status Done + Evidence
- [ ] (선택) `projects/<domain>/state/CURRENT_STATE.md` — `ACTIVE_MODE: both`
- [ ] (선택) G6 초안을 `docs/DECISIONS.md` 또는 issue 코멘트로 확정

---

## 상태 메모

- 본 문서는 **Cloud 설계 산출물**이다.
- L-8/L-9 쉘: **Human 실행 가능** (Cline 불필수).
- L-10 F5: Extension Host + Ollama 있는 머신 필요.
- 원격 전용 환경에서는 F5를 대신 통과 처리할 수 없다.

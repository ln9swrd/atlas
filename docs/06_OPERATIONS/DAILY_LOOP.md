# Daily / Session Loop (실운용)

Primary surface: **Git `state/` + agent (Grok 등)**  
SoR: **Git `state/`** (대화창 아님)  
Min scope: `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md`  
Domain: `tools/domain_policy.py` (P2-1 Done)  
Decisions: `docs/06_OPERATIONS/DECISION_PROCESS.md` (P2-5)

---

## Start

```bash
cd /path/to/atlas
git pull github main
bash tools/atlas_status.sh
```

`atlas_status.sh`가 하는 일:

- git short status + 최근 커밋
- `CURRENT_STATE` ACTIVE_TARGET / Next
- `python3 tools/check_domain_policy.py` (25/25 기대)

읽기 (이 순서):

1. `state/CURRENT_STATE.md` — ACTIVE_TARGET + **Next one thing**
2. `state/TASK_MAP.md` — 열린 항목
3. `state/CONTEXT_INDEX.md` — 오늘 열 파일만
4. `AGENTS.md` — 도메인·Evidence

---

## Work

- **한 세션 = CURRENT_STATE의 Next one thing 하나**
- platform mode: `projects/*` 전체 로드·쓰기 금지 (ACTIVE_TARGET 변경 전)
- Forbidden: `archive/`, `obsidian/`, `node_modules/`, `.git/` 자동 주입 (D17/D23)
- 코드/설정 변경 시 작은 단위 + 로컬 실행 Evidence
- 새 정책/Decision: draft만 작성 → Master 확인 전 `DECISIONS.md`에 넣지 않음

마스터 쉘: 명시된 한 줄·짧은 스크립트 (D21).

---

## End

1. `state/TASK_MAP.md` — Status / Evidence 갱신  
2. `state/CURRENT_STATE.md` — Next one thing 갱신  
3. 필요 시 `CONTEXT_INDEX.md`  
4. Decision 확정 시 `docs/DECISIONS.md` + `decision:` commit  
5. Commit + push

```bash
git add state/ docs/ tools/   # 실제 바꾼 경로만
git status
git commit -m "state: …"   # or docs: / fix: / chore: / decision:
git push github main
```

**Done 금지:** Evidence 없는 완료 주장 (D01).

---

## Commit 접두

| Prefix | 용도 |
|--------|------|
| `docs:` | 문서 |
| `state:` | CURRENT_STATE / TASK_MAP |
| `fix:` | 버그·충돌 제거 |
| `chore:` | archive 이동, hygiene |
| `decision:` | DECISIONS.md |

---

## 빠른 체크

- [ ] `git pull` 했는가
- [ ] `bash tools/atlas_status.sh` PASS 했는가
- [ ] CURRENT_STATE Next 하나만 했는가 / Evidence 있는가
- [ ] Decision이면 Master 확인 후 DECISIONS.md 갱신했는가
- [ ] state 갱신 + push 했는가

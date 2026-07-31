# Daily / Session Loop (실운용)

Primary surface: **Cline + Ollama** (D15)  
SoR: **Git `state/`** (대화창 아님)  
Min scope: `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md`

---

## Start

```bash
cd /path/to/atlas
git pull github main   # remote 이름에 맞게
bash tools/atlas_status.sh   # optional smoke
```

읽기 (이 순서):

1. `state/CURRENT_STATE.md` — ACTIVE_TARGET
2. `state/TASK_MAP.md` — 열린 M-*
3. `state/CONTEXT_INDEX.md` — 오늘 열 파일만
4. `AGENTS.md` — 도메인·Evidence

Cline: Custom instructions / .clinerules가 AGENTS 핵심을 가리키는지 확인.

---

## Work

- **한 세션 = CURRENT_STATE의 Next one thing 하나**
- 제품 `projects/*` 전체 로드 금지 (min scope 중)
- Forbidden: `archive/`, `obsidian/`, `node_modules/`, `.git/` 자동 주입 (D17)
- 코드/설정 변경 시 가능하면 작은 단위 + 로컬 실행 Evidence

마스터 쉘 가능 작업: 명시된 한 줄·짧은 스크립트 (D21).

---

## End

1. `state/TASK_MAP.md` — Status / Evidence 갱신  
2. `state/CURRENT_STATE.md` — Next one thing 갱신  
3. 필요 시 `CONTEXT_INDEX.md`  
4. Commit + push

```bash
git add state/ docs/   # 실제 바꾼 경로만
git status
git commit -m "state: …"   # or docs: / fix: / chore:
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

- [ ] pull 했는가
- [ ] CURRENT_STATE 읽었는가
- [ ] 작업 하나가 끝났는가 / Evidence 있는가
- [ ] state 갱신 + push 했는가

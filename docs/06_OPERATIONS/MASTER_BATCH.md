# 마스터 배치 커맨드 (L-8 ~ L-10)

Date: 2026-07-31  
Script: `scripts/master_l8_l10.sh`  
Roles: `docs/05_AGENTS/ROLE_SPLIT.md`

---

## 한 번에 (권장)

Repo 루트(또는 아무 곳에서):

```bash
bash scripts/master_l8_l10.sh status    # 현재 상태
bash scripts/master_l8_l10.sh l8-l9     # L-8 rebase + L-9 untrack/push
```

Node 있는 머신:

```bash
bash scripts/master_l8_l10.sh l10-npm   # install + compile only
```

그 다음 **수동**: VS Code F5 → 체크리스트 → PR #3 merge.

---

## 명령 표

| Command | 하는 일 | 자동화 |
|---------|---------|--------|
| `status` | fetch 정보, node_modules 추적 여부 | ✅ |
| `l8` | `impl/atlas-extension` ← rebase `origin/main` | ✅ |
| `l9` | untrack node_modules/vsix → commit → push | ✅ |
| `l8-l9` | l8 후 l9 | ✅ |
| `l10-npm` | `npm install` + `npm run compile` | ✅ |
| F5 smoke | Extension Host UI | ❌ 수동 |
| PR merge/tag | GitHub | ❌ 마스터 |
| G6 승인 | Decision 확정 | ❌ 마스터 |
| state Evidence | TASK_MAP 한 줄 | ❌ 마스터 |

---

## Evidence 템플릿 (실행 후 복붙)

```markdown
Evidence: L-8 rebase + L-9 untrack/push (<short-hash>)
```

L-10:

```markdown
Evidence: L-10 npm compile ok; F5 checklist pass YYYY-MM-DD; PR #3 merged
```

---

## 주의

- working tree dirty면 스크립트가 확인 후 진행
- rebase 충돌 시 스크립트 중단 → 해결 후 `git rebase --continue` → 다시 `l9`
- `node_modules` / `*.vsix` **커밋 금지**
- F5·Ollama 없는 회사 PC에서는 `l8-l9`까지만

---

## Done 조건

| ID | Done when |
|----|-----------|
| L-8 | rebase 성공, conflict 없음 |
| L-9 | index에 node_modules/vsix 없음 + push |
| L-10 | F5 표 통과 + PR #3 merge (마스터) |

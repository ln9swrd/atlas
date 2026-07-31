# 마스터 배치 커맨드 (L-8 ~ L-10)

Date: 2026-07-31  
Script: `scripts/master_l8_l10.sh`

---

## 이 머신에서 먼저

```bash
git remote -v
bash scripts/master_l8_l10.sh status
```

원격 이름이 `origin`이 아니면 (예: `github`):

```bash
export GIT_REMOTE=github   # 또는 실제 이름
bash scripts/master_l8_l10.sh status
bash scripts/master_l8_l10.sh l8-l9
```

원격이 **아예 없으면** `l9` untrack 커밋만 로컬에 남고 push는 건너뛴다. 나중에:

```bash
git remote add github https://github.com/ln9swrd/atlas.git   # URL은 본인 것
git push -u github impl/atlas-extension
git push github main
```

---

## 명령

| Command | 내용 |
|---------|------|
| `status` | remote, tracked node_modules, npm 유무 |
| `l8` | impl ← rebase main (remote 우선, 없으면 local main) |
| `l9` | untrack + commit + push(가능 시) |
| `l8-l9` | 둘 다 |
| `l10-npm` | npm 있을 때만 |

```bash
bash scripts/master_l8_l10.sh l8-l9
```

---

## 지금 로그 해석 (2026-07-31)

| 증상 | 원인 | 조치 |
|------|------|------|
| no origin/main | remote 이름 ≠ origin 또는 remote 없음 | `git remote -v` → `GIT_REMOTE=…` |
| fetch origin failed | 위와 동일 | 원격 추가/이름 지정 |
| npm not found | 이 PC에 Node 없음 | l10-npm 스킵; dev PC에서 |
| node_modules tracked | L-9 미실행 | `l9` 또는 `l8-l9` |

---

## Evidence

```text
Evidence: L-8 rebase + L-9 untrack (<hash>)
```

→ `state/TASK_MAP.md`

F5 / PR merge / G6 승인 = 스크립트 밖 수동.

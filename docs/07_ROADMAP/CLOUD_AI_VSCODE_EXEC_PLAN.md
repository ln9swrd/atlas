# Cloud AI + VS Code 실행계획

Status: **Active**  
Date: 2026-07-31  
Owner: human + cloud mode  
Related: D15, D19, Issue #2, PR #3, L-8…L-10

---

## 1. 원칙 (고정)

| 항목 | 내용 |
|------|------|
| Cloud AI | **모드** (`cloud` / `both`), 프로젝트 아님 (D19) |
| VS Code Primary | **Cline** + 로컬 Ollama (D15) |
| Cloud 역할 | 설계 · 분석 · 리뷰 |
| Cline 역할 | 도구 실행 · 파일 · 터미널 · Evidence |
| System of Record | Git `state/` (채팅 메모리 금지) |
| Extension | 로컬 LLM work surface — cloud-only 강제 **금지** |

Modes share the **same** project state files (`docs/process/PROJECT_STATE_SCHEMA.md`).

---

## 2. 모드 정의

| Mode | 도구 실행 | VS Code 형태 |
|------|-----------|--------------|
| `cline` | Local Cline + Ollama | Cline 확장으로 실행 |
| `cloud` | Cloud AI (chat / PR 제안) | 파일 열어 두고 설계·리뷰 → PR 또는 명시적 편집 |
| `both` | Cline 실행, Cloud 설계/리뷰 | `TASK_MAP` row에 `assignee` 구분 |

프로젝트 `state/CURRENT_STATE.md` 필수 필드:

```text
ACTIVE_MODE: cline | cloud | both
```

---

## 3. 실행 단계

### Phase A — 로컬 기반 마무리 (선행)

| ID | Task | Status | Evidence |
|----|------|--------|----------|
| L-1…L-7 | Ollama + Cline + rules + untrack + rebase | **Done** | state commits 2026-07-30 |
| L-8 | `impl/atlas-extension` → merge 준비 (rebase 확인) | **Pending** | |
| L-9 | Packaging: `node_modules` / `*.vsix` untrack + commit | **Pending** | `docs/04_IDE_EXTENSION/PACKAGING.md` |
| L-10 | F5 checklist pass → PR #3 merge / tag | **Pending** | `docs/04_IDE_EXTENSION/F5_CHECKLIST.md` |

### Phase B — Cloud / both 모드 운영 루프

| ID | Task | Status | Assignee |
|----|------|--------|----------|
| CA-1 | 작업 프로젝트 `ACTIVE_MODE` 설정 (`cloud` 또는 `both`) | Pending | human |
| CA-2 | `TASK_MAP`에 assignee 컬럼 사용 (`cloud` / `cline` / `both`) | Pending | human |
| CA-3 | Cloud 세션 종료 시 결과를 PR 또는 명시적 파일 편집으로 Git 반영 | Pending | cloud |
| CA-4 | Cline 세션에서 도구 실행 + Evidence (경로/commit/CLI) 기록 | Pending | cline |
| CA-5 | 세션 끝 `CURRENT_STATE` + `TASK_MAP` 갱신 후 commit | Pending | both |

### Phase C — 컨텍스트 로드 규칙 (모든 모드)

1. `projects/<name>/state/CURRENT_STATE.md`
2. `TASK_MAP.md` — **다음 open row만**
3. `CONTEXT_INDEX.md`에 적힌 경로만
4. DevOS 작업일 때만 루트 `AGENTS.md` + `state/`

**금지**

- `archive/`, `obsidian/` 자동 주입
- 다른 프로젝트 전체 트리 로드
- 채팅에만 상태 보관
- SERA를 프로젝트로 취급 (D19)

---

## 4. 권장 워크플로 (`both`)

```
[Cloud AI]
  설계 / 아키텍처 / 리뷰 / 초안 문서
       ↓  PR 또는 명시적 편집
[Git state/]
  CURRENT_STATE · TASK_MAP · CONTEXT_INDEX
       ↓
[VS Code + Cline]
  도구 실행, 파일 수정, CLI 검증, Evidence
       ↓
[Human]
  최종 승인 · ACTIVE_TARGET 전환
```

---

## 5. Non-goals (이 계획 범위 밖)

- Extension에 클라우드 API 기본 연동 구현
- Camera / vision
- `core/`, `atlas-runtime/` 대규모 수정
- SERA 프로젝트 재생성
- 채팅 claim만으로 Done 처리

---

## 6. Next one thing

**L-8…L-10** — `impl/atlas-extension` packaging untrack → F5 checklist → PR #3 merge.

이후 도메인 작업 시 Phase B (CA-1부터) 적용.

---

## 7. Refs

- `docs/process/PROJECT_STATE_SCHEMA.md`
- `docs/05_AGENTS/README.md`
- `docs/04_IDE_EXTENSION/SPEC.md` · `BOUNDARY.md` · `PACKAGING.md` · `F5_CHECKLIST.md`
- `docs/DECISIONS.md` — D15, D19
- Issue [#2](https://github.com/ln9swrd/atlas/issues/2) · PR [#3](https://github.com/ln9swrd/atlas/pull/3)
- `state/CURRENT_STATE.md` · `state/TASK_MAP.md`

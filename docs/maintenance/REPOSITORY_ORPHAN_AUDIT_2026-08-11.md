# Repository Orphan / Placeholder Audit

**조사일:** 2026-08-11  
**시작 SHA:** `1f661bba8292512337eefdc927bdd440af875f2e`  
**대상:** `ln9swrd/atlas` (main)  
**목적:** 빈 디렉터리 · 고아 gitlink · placeholder/stub · orphan artifact 조사 (삭제·이동 없음)

---

## 1. 조사 기준

- 조사 시점 working tree = origin/main (clean)
- Git은 빈 디렉터리를 추적하지 않으므로 `find` 기준
- gitlink = mode `160000`
- Placeholder/Stub: size < 1k, archive 제외
- 보호 영역: `projects/excelion/`, `projects/_template/`, `archive/`, `docs/`, `state/`, `AGENTS.md`, `core/`, Unreal 관련, atlas-runtime legacy

---

## 2. 빈 디렉터리

| 경로 | 유형 | 판단 |
|------|------|------|
| (없음) | — | **없음** |

`find . -type d -empty -not -path './.git/*' -not -path './.git'` → 결과 0건.

의도적 placeholder 디렉터리도 현재 비어 있지 않음 (.gitkeep으로 추적).

---

## 3. Gitlink / Submodule

| 경로 | SHA | .gitmodules | 참조 | 판단 |
|------|-----|-------------|------|------|
| (없음) | — | 없음 | — | **없음** |

- `git ls-files -s | awk '$1 == "160000"'` → 0건
- `.gitmodules` → **NO .gitmodules**
- 이전 engram / wafermap-converter 고아 gitlink는 이미 제거된 상태 (과거 maintenance 문서 확인)

### Submodule 관련 검색

`git grep -E "submodule|gitlink|gitmodules"` 결과는 역사 문서·감사 문서·로드맵 언급뿐.  
실제 런타임/CI/스크립트 의존성 없음.

---

## 4. Placeholder / Stub

| 경로 | 크기 | 내용 | 참조 | 판단 |
|------|------|------|------|------|
| `core/context/__init__.py` | 0 | 빈 파일 | Python package | **KEEP** |
| `core/decision/__init__.py` | 0 | 빈 파일 | Python package | **KEEP** |
| `core/registry/__init__.py` | 0 | 빈 파일 | Python package | **KEEP** |
| `core/state/__init__.py` | 0 | 빈 파일 | Python package | **KEEP** |
| `projects/excelion/design/**/threeview/.gitkeep` (다수) | 0 | 빈 marker | design 구조 유지 | **KEEP** |
| `projects/excelion/design/env/**/props/.gitkeep` (다수) | 0 | 빈 marker | design 구조 유지 | **KEEP** |
| `projects/excelion/game/Excelion/Config/DefaultEditor.ini` | 0 | 빈 파일 | Unreal 표준 config placeholder | **KEEP** |

총 26개 (archive 제외, size < 1k).  
모두 의도적 marker 또는 표준 빈 패키지/설정 파일.  
REMOVE/ARCHIVE 후보 없음.

---

## 5. Orphan Artifact

주요 디렉터리 점검:

| 영역 | 참조/사용 | 판단 |
|------|-----------|------|
| `projects/excelion/` | SoR, 보호 | **KEEP** |
| `projects/_template/` | 온보딩 템플릿 | **KEEP** |
| `projects/blender/` | HOLD (PROJECT_MAP) | **KEEP** |
| `projects/paramodel/` | HOLD | **KEEP** |
| `projects/printguard/` | planning / registry | **KEEP** |
| `projects/makerfac-needs-research/` | HOLD | **KEEP** |
| `core/` | 테스트·런타임 참조 | **KEEP** |
| `docs/` | 운영 문서 | **KEEP** |
| `state/` | 운영 상태 | **KEEP** |
| `scripts/` | daily_start/end | **KEEP** |
| `tools/` | atlas_runner 등 | **KEEP** |
| `tests/` | CI 대상 | **KEEP** |
| `scratch/` | README only | **KEEP** (의도적 작업 공간) |
| `archive/*` | 역사 보존 | **KEEP** (정책) |
| `atlas-runtime` | archive/atlas-runtime-legacy 로만 존재 | **KEEP** (archive) |

- Git 추적 파일 vs working tree: 불일치 없음
- 미추적 이상 artifact: 없음
- `git status` clean
- mode 이상 (symlink/gitlink): 없음 (전부 100644)

---

## 6. 최종 후보

### REMOVE CANDIDATE
- (없음)

### ARCHIVE CANDIDATE
- (없음)

### KEEP
- 모든 현재 추적 파일 및 디렉터리
- 빈 `__init__.py`, `.gitkeep`, `DefaultEditor.ini`
- HOLD 프로젝트들 (blender, paramodel, printguard, makerfac-needs-research)
- archive 전체

### INVESTIGATE
- (없음)

---

## 7. 결론

이번 감사에서 **실제 cleanup 가능한 잔여물(빈 디렉터리, 고아 gitlink, 무의미 stub, orphan artifact)은 발견되지 않았다.**

이전 단계(engram/wafermap-converter gitlink 제거, process 문서 archive, residue cleanup)가 이미 반영된 상태이며, 저장소는 구조적으로 정리되어 있다.

보호 영역(Excelion, _template, archive, docs, state, core, Unreal)은 모두 정상 유지.

**이번 단계는 조사·문서화만 수행. 삭제/이동은 수행하지 않음.**

---

## 검증

| 항목 | 결과 |
|------|------|
| 빈 디렉터리 조사 | PASS (0) |
| gitlink 조사 | PASS (0) |
| placeholder 조사 | PASS (의도적만) |
| 참조 조사 | PASS |
| Git 상태 | CLEAN |

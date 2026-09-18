# Engram Submodule Review — 2026-08-11

## 조사 목적

`engram/` gitlink(submodule)이 현재 Atlas 운용에 필요한지 객관적으로 판단한다.

## 작업 시작 상태 (조사 시점)

| 항목 | 값 |
|------|-----|
| 작업 시작 HEAD | `787aacbc00454d057ef92b64ccd14b00fd25ca6f` |
| Branch | `main` |
| Working tree | clean |
| engram gitlink SHA | `b5496c3e856fa10aa6cd41ae66700debc6c4cf55` |
| `.gitmodules` | **없음** |
| `git submodule status` | `fatal: no submodule mapping found in .gitmodules for path 'engram'` |
| `engram/` 디렉터리 내용 | 비어 있음 (체크아웃 안 됨) |

## .gitmodules

- 파일 자체 없음.
- submodule 경로/URL/branch 등록 없음.
- gitlink(mode `160000`)만 index에 존재했음 → **고아(orphaned) gitlink**.

## Engram 원격 저장소

| 항목 | 값 |
|------|-----|
| 저장소 | `https://github.com/ln9swrd/engram` (public) |
| 당시 HEAD | `b5496c3e856fa10aa6cd41ae66700debc6c4cf55` |
| 성격 | AI 대화 기억용 **브라우저 확장 + API proxy** (TypeScript monorepo) |
| Atlas와의 관계 | **제품적으로 무관** (DevOS/Excelion/게임 파이프라인과 연결 없음) |

## Atlas 참조 검색 결과

**결과: 운영 참조 0건.** (조사 문서 외)

| 영역 | 결과 |
|------|------|
| `projects/` | 참조 없음 |
| `docs/` (maintenance 제외) | 참조 없음 |
| `state/` | 참조 없음 |
| `scripts/` / `tools/` | 참조 없음 |
| `.github/workflows/ci.yml` | submodule 미사용 |
| `README.md` / `AGENTS.md` / `pyproject.toml` | 참조 없음 |

## 판단

### **REMOVE CANDIDATE** → **REMOVED**

Reason: 운영 미사용, 고아 gitlink, 외부 별도 제품, Excelion/CI 무의존.

Risk: **Low**

---

## 제거 실행 결과 (2026-08-11)

| 항목 | 값 |
|------|-----|
| 제거 전 HEAD | `0a85358830b9dd9674004809acf72806e7c8e255` |
| 제거 커밋 | `e498de05f509610af89c523706d13f3ccc568260` |
| 명령 | gitlink `engram` 삭제 |
| `.gitmodules` | 원래 없음 → 변경 없음 |
| 외부 `ln9swrd/engram` | **변경 없음** |
| 운영 코드 / Excelion / CI | **변경 없음** |

검증:

- `git ls-tree HEAD engram` → 없음
- 운영 영역 신규 참조 없음
- 본 문서의 engram 문자열은 역사 기록으로 유지

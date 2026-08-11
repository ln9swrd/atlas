# Engram Submodule Review — 2026-08-11

## 조사 목적

`engram/` gitlink(submodule)이 현재 Atlas 운용에 필요한지 객관적으로 판단한다.  
이번 작업에서는 **삭제하지 않는다**.

## 작업 시작 상태

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
- gitlink(mode `160000`)만 index에 존재 → **고아(orphaned) gitlink**.

## Engram 원격 저장소

| 항목 | 값 |
|------|-----|
| 저장소 | `https://github.com/ln9swrd/engram` (public) |
| 현재 HEAD | `b5496c3e856fa10aa6cd41ae66700debc6c4cf55` (Atlas gitlink와 일치) |
| 최신 커밋 | `chore: update package-lock.json dependencies` |
| 성격 | AI 대화 기억용 **브라우저 확장 + API proxy** (TypeScript monorepo) |
| 목적 | Claude/ChatGPT/Gemini 대화를 Markdown으로 정리·Git/Drive 동기화 |
| Atlas와의 관계 | **제품적으로 무관** (DevOS/Excelion/게임 파이프라인과 연결 없음) |

원본 계열 표기: README 배지가 `Sufian-Abu/engram` CI를 가리킴 → 외부 Engram 계열 포크/미러로 보임.

## Atlas 참조 검색 결과

검색:

```text
git grep -n "engram" -- .
git grep -n "Engram" -- .
rg -ni engram (working tree)
git grep SHA b5496c3e…
```

**결과: 텍스트 참조 0건.**

집중 조사 영역:

| 영역 | 결과 |
|------|------|
| `projects/` | 참조 없음 |
| `docs/` | 참조 없음 |
| `state/` | 참조 없음 |
| `scripts/` | 참조 없음 |
| `tools/` | 참조 없음 |
| `.github/workflows/ci.yml` | submodule 미사용, engram 미언급 |
| `README.md` / `AGENTS.md` | 참조 없음 |
| `pyproject.toml` | 참조 없음 |
| `.gitignore` / `.gitattributes` | engram 관련 항목 없음 |

## 프로젝트 참조 (Excelion / _template)

- `projects/excelion/`: engram 의존성·경로·문서 요구 없음.
- Excelion 활성 파이프라인: Meshy → Blender → FBX → UE.
- `projects/_template/`: 관련 없음.
- EP01 소설/감사 문서들은 스토리 작업물이지 Engram 제품과 무관.

## 도입 이력

| 커밋 | 내용 |
|------|------|
| `248d1c0` (2026-08-07) | `feat: engram 추가 및 EP01 신규 파일 생성` — `engram` gitlink 생성 + Excelion novel EP01 파일 추가 |

이후 `.gitmodules` 등록·submodule init·Atlas 문서화·런타임 연동 흔적 없음.

## 판단

### **REMOVE CANDIDATE**

Reason:

- 현재 코드/문서/스크립트/CI에서 **사용하지 않음** (참조 0)
- `.gitmodules` 없음 → 정상 submodule이 아님 (고아 gitlink)
- `engram/` 내용 미체크아웃 → 로컬에서도 비어 있음
- Engram은 Atlas 외부의 **별도 제품**(AI 대화 아카이빙 확장)
- Excelion·플랫폼 개발계획에 필수 구성요소로 정의되지 않음
- 제거해도 현재 Atlas 운용에 영향 없음

Risk: **Low**

- 런타임/빌드/CI 의존 없음
- 문서상 “현재 구성요소” 요구 없음
- 단, git history에 gitlink가 남아 있고, 외부 `ln9swrd/engram` 자체는 별도 저장소로 유지됨 (Atlas에서 링크만 제거)

Required removal (다음 작업용, **이번 미실행**):

1. `git rm engram` (gitlink 제거)
2. `.gitmodules` 항목은 원래 없으므로 해당 작업 불필요
3. 관련 문서 참조는 현재 없으므로 문서 정리 최소
4. 선택: 왜 들어왔는지 한 줄 기록을 maintenance에 유지 (본 문서)

## 예상 제거 영향

| 영향 | 평가 |
|------|------|
| CI | 없음 |
| Excelion | 없음 |
| Atlas runtime/core | 없음 |
| 클론 UX | 개선 (깨진 submodule 경고 제거) |
| 외부 `ln9swrd/engram` 저장소 | 영향 없음 (독립 유지) |

## 다음 작업

1. Master 승인 후 `git rm engram` + 단일 chore 커밋
2. push (force 금지)
3. 본 문서를 근거로 남김
4. Engram 제품 자체 개발/삭제는 Atlas 범위 밖

## 절대 금지 준수 (이번 작업)

- engram gitlink 삭제 안 함
- `.gitmodules` 수정 안 함
- Engram 원격 저장소 수정 안 함
- Excelion / Unreal / 코드 리팩터링 없음
- force push / reset / clean 없음

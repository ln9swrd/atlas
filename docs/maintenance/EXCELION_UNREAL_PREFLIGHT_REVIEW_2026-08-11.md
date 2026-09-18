# Excelion Unreal Preflight Review (Git Protection & Structure)

**조사일:** 2026-08-11  
**시작 SHA:** `68ab2210ae4e302088036bc52794893d927b6cf8`  
**대상:** `projects/excelion/game/Excelion/`  
**목적:** UE 5.4.4 Editor 개방 전 Git 보호 · 구조 정합성 · BLOCKER 식별  
**금지 준수:** uproject / Source / Config / Content / state / excelion docs **미수정** · UE 미실행

---

## 1. Scope

- Git ignore 정책 · 생성물 추적 여부
- `.uproject` / Source / Config **읽기 전용** 사전점검
- UE 5.4.4 개방 리스크
- **EngineAssociation 변경 금지** · M6 HOLD 미해제

---

## 2. Current Git Ignore Policy

| 위치 | 상태 |
|------|------|
| 저장소 루트 `.gitignore` | 존재 · **Unreal/Binaries/Intermediate/Saved 규칙 없음** |
| `projects/excelion/game/Excelion/.gitignore` | **main HEAD에 없음** |
| `git check-ignore` (Binaries/Intermediate/Saved/DDC/.vs/Build) | **전부 미매칭** (exit 1) |

현재 **main 정책만으로는 UE 생성물이 보호되지 않음.**

---

## 3. Unreal Generated Files

보호 대상 대비 현재:

| 경로/패턴 | 현재 보호 |
|-----------|-----------|
| Binaries/ | **NO** |
| Intermediate/ | **NO** |
| Saved/ | **NO** |
| DerivedDataCache/ | **NO** |
| Build/ | **NO** |
| .vs/ | **NO** |
| *.sln / *.vcxproj* | **NO** (루트도 미포함) |

---

## 4. Git History

| 항목 | 내용 |
|------|------|
| 과거 정책 | 커밋 `58817b1` *chore(excelion): ignore Unreal and VS generated artifacts* 에 `projects/excelion/game/Excelion/.gitignore` 추가 |
| 내용 요약 | `.vs/` · `*.sln` · `*.vcxproj*` · `Binaries/` · `DerivedDataCache/` · `Intermediate/` · `Saved/` · `Build/` · `*.pdb`/`*.dll`/`*.exe` 등 |
| main 포함 여부 | `58817b1`은 **main 조상 아님** (`git merge-base --is-ancestor` = no) |
| 브랜치 | `remotes/origin/agent/excelion-axion-v01` 등에 존재 |
| main에서의 삭제 이력 | main 경로에 파일이 올라온 적 없음 → “삭제 커밋”이 아니라 **미머지** |

**복원 필요 여부: YES (main에 동일 정책 도입 권고)**  
이번 단계에서는 **파일을 추가·수정하지 않음** — 후보만 기록.

---

## 5. Tracked Generated Artifacts

| 검사 | 결과 |
|------|------|
| `Binaries/**` | 추적 **0** |
| `Intermediate/**` | 추적 **0** |
| `Saved/**` | 추적 **0** |
| `DerivedDataCache/**` | 추적 **0** |
| `.vs/**` | 추적 **0** |
| `*.sln` under Excelion | 추적 **0** |

이미 유입된 생성물 **없음** → 삭제/untrack 불필요.

---

## 6. .uproject Preflight (읽기 전용)

| 필드 | 값 |
|------|-----|
| FileVersion | 3 |
| **EngineAssociation** | **5.3** |
| Modules | Excelion · Runtime · Default |
| Plugins | ModelingToolsEditorMode (Editor only) |

5.4.4 개방 시:

- 엔진이 버전 불일치 경고/업그레이드 프롬프트를 낼 수 있음
- **EngineAssociation 변경은 Master 승인 전 금지** (본 문서도 미변경)

---

## 7. Source / Config Preflight

**Source**

| 파일 | 상태 |
|------|------|
| Excelion.Build.cs | 존재 · Core/CoreUObject/Engine/InputCore |
| Excelion.Target.cs | Game · IncludeOrder **Unreal5_3** |
| ExcelionEditor.Target.cs | Editor · Unreal5_3 |
| Excelion.cpp/h | 기본 IMPLEMENT_PRIMARY_GAME_MODULE |

**Config**

| 파일 | 크기 | 비고 |
|------|------|------|
| DefaultEngine.ini | ~2 KB | GameDefaultMap=엔진 OpenWorld 템플릿 · DX12 |
| DefaultInput.ini | ~9 KB | Enhanced Input 클래스 기본값 |
| DefaultGame.ini | 소량 | 존재 |
| DefaultEditor.ini | **0 byte** | 빈 파일 · UE 관례상 허용 가능 |

Content/ · Plugins/ 디렉터리 없음 · C++ 게임플레이 클래스 없음 (스켈레톤).

---

## 8. UE 5.4.4 Opening Risks

| 항목 | 상태 | 근거 |
|------|------|------|
| Git ignore | **BLOCKED** | main에 UE ignore 없음 · 개방 시 생성물 커밋 위험 |
| Generated files (tracked) | **PASS** | 추적 0 |
| EngineAssociation | **DECISION REQUIRED** | 5.3 vs 권고 5.4.4 · 승인 전 미변경 |
| Source | **PASS** | 최소 모듈 완전 |
| Config | **PASS** | 필수 ini 존재 · Editor 0-byte는 비차단 |
| Plugins | **PASS** | 엔진 기본 계열 1개 |
| UE 5.4.4 compatibility | **PASS (구조)** / **DECISION (버전 필드)** | 스켈레톤은 이전 가능 · Association 정합 필요 |

---

## 9. Git Protection Recommendation

**판정: B. Unreal ignore 보완 필요**

- 현재 정책만으로 생성물 **비보호**
- 후보: `58817b1`과 동일 내용의 `projects/excelion/game/Excelion/.gitignore` 를 **main에 추가** (별도 승인·커밋)
- 루트 `.gitignore`에 전역 Unreal 규칙을 넣지 않아도 됨 (프로젝트 로컬로 충분)
- 이번 작업에서는 **ignore 파일 미작성**

개방 전 권고 순서:

1. (승인 후) Excelion `.gitignore` 복원/추가  
2. Master: EngineAssociation → 5.4 (또는 5.4.4 정책 문구)  
3. 개발 PC UE 5.4.4 + VS2022  
4. Generate / Build / Editor  

---

## 10. M6 Impact

| 항목 | 내용 |
|------|------|
| HOLD | **유지** (미변경) |
| Impact | Preflight만으로는 M6 해제 불가 |
| Required before release | Git 보호 · 버전 정합 승인 · UE/툴체인 · Master HOLD 해제 |

---

## 11. Final Verdict

**DECISION REQUIRED** (EngineAssociation 5.3→5.4.4)  
**+ READY WITH CONDITIONS** (Git ignore 보완 후 개방 가능)

| 조건 | 개방 전 |
|------|---------|
| `.gitignore` 도입 | **필수 권고** (미적용 시 생성물 유입 위험) |
| EngineAssociation | **Master 결정** |
| M6 HOLD | **Master 결정** |
| 구조/추적 생성물 | 추가 BLOCKER 없음 |

---

## Changes

| 영역 | 변경 |
|------|------|
| uproject / Source / Config / Content / Plugins | 0 |
| Design / Novel / State | 0 |
| Documentation | **1** (본 파일) |

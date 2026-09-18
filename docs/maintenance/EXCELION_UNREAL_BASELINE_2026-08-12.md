# Excelion Unreal Baseline Checkpoint

**조사 시각:** 2026-08-12 11:15 KST  
**목적:** UE 5.4.4 개발 착수 전 기준점 확정 (조사·기록만)  
**금지 준수:** 코드/설정 수정 없음 · PR #101 미merge · reset/rebase/force push 없음

---

## 1. 현재 기준점 (Git)

| 항목 | 값 |
|------|-----|
| Branch (작업 기준) | main |
| main HEAD | `4f6ee956e89ba701572b364a906ba3a9aea84c0b` |
| Excelion 관련 작업 브랜치 | `chore/excelion-unreal-gitignore` (PR #101 OPEN) |
| divergence | PR #101: main 대비 +1 commit (`.gitignore`만) |
| 최근 Excelion commit | docs audit / preflight / environment (2026-08-11~12) |
| PR #101 영향 | **미merge** → main에는 아직 Excelion `.gitignore` **없음** |

PR #101은 그대로 OPEN 유지. 본 조사에 merge하지 않음.

---

## 2. Unreal 프로젝트 구조

경로: `projects/excelion/game/Excelion/`

| 항목 | 존재 | Git 추적 | 비고 |
|------|------|----------|------|
| Excelion.uproject | 예 | 예 | EngineAssociation **5.3** |
| Source/ | 예 | 예 | Target + 모듈 기본 |
| Config/ | 예 | 예 | Default*.ini 4개 |
| Plugins/ | **없음** | — | 스켈레톤 |
| Content/ | **없음** | — | 스켈레톤 |
| .vsconfig | 예 | 예 | VS NativeGame 등 |
| .gitignore | **main 없음** | PR #101에만 존재 | 생성물 보호 대기 |
| *.sln | 없음 | 해당 없음 | 생성 파일 · 정상 |

---

## 3. Unreal Engine 정합성

**목표:** UE 5.4.4 + Visual Studio 2022

### .uproject

- FileVersion: 3
- **EngineAssociation: `"5.3"`**
- Modules: Excelion (Runtime, Default)
- Plugins: ModelingToolsEditorMode (Editor only)

### Target / Build

| 파일 | 내용 |
|------|------|
| Excelion.Target.cs | Game · BuildSettings V4 · **IncludeOrderVersion Unreal5_3** |
| ExcelionEditor.Target.cs | Editor · 동일 Unreal5_3 |
| Excelion.Build.cs | Core, CoreUObject, Engine, InputCore |

### 개방 리스크 (구조)

| 항목 | 상태 |
|------|------|
| 모듈/Target 최소 구조 | 정상 (스켈레톤) |
| Plugin 의존성 | 엔진 기본 1개 · 치명 의존 없음 |
| EngineAssociation 불일치 | **5.3 vs 목표 5.4.4** → 개방 시 업그레이드 프롬프트 가능 |
| IncludeOrderVersion | Unreal5_3 · 5.4 개방 시 엔진이 조정할 수 있음 |
| VS 2022 생성 | `.vsconfig`에 NativeGame/NativeDesktop 포함 · Generate Project Files로 `.sln` 로컬 생성 가능 |
| .sln Git 부재 | **정상** (생성 파일) |

---

## 4. 생성물 보호

| 패턴 | main | PR #101 브랜치 |
|------|------|----------------|
| `*.sln` `*.vcxproj*` `.vs/` `Binaries/` `Intermediate/` `Saved/` | **미보호** | 보호됨 |
| Source / Config / Plugins / uproject / .vsconfig | 추적 유지 | 추적 유지 (제외 안 함) |

추적 중인 생성 파일: **0**.  
PR #101 merge 전까지 main에서 UE 개방 시 생성물이 실수로 커밋될 위험 있음.

---

## 5. 실제 실행 검증

| 항목 | 결과 |
|------|------|
| UE 5.4.4 Editor 실행 | **검증 불가** |
| 사유 | 본 환경(원격 API 조사)에 Unreal Engine / VS 미설치 · 로컬 빌드 머신 아님 |
| 추측 | 하지 않음 |

구조상 스켈레톤 로드·Generate는 일반적이지만, **실기 개방은 로컬 UE 5.4.4에서만 확정 가능**.

---

## 6. 판정

**B — 수정 후 개방 가능**

근거:

1. **EngineAssociation `5.3`** → 목표 5.4.4와 불일치 (Master 승인 후 변경 필요)
2. **main에 `.gitignore` 없음** → PR #101 merge로 생성물 보호 선행 권고
3. 프로젝트 구조(Source/Config/uproject)는 스켈레톤으로서 정상
4. `.sln` 부재는 정상
5. 실기 UE 개방은 본 환경에서 미검증

**변경 필요 — Master 승인 대기** (임의 수정 없음)

권고 순서 (승인 후):

1. PR #101 merge (`.gitignore`)
2. EngineAssociation → 5.4 (또는 정책 문구) + Target IncludeOrder 필요 시 정리
3. 로컬 UE 5.4.4 + VS 2022에서 Generate Project Files → Build → Editor 개방

---

## 7. 변경 파일 (본 조사)

- 게임/Unreal 파일: **0**
- 문서만: `docs/maintenance/EXCELION_UNREAL_BASELINE_2026-08-12.md`

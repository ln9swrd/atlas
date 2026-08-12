# Excelion Unreal Solution Audit

**조사 목적:** main에서 Excelion Unreal 프로젝트 Visual Studio 솔루션(*.sln) 소실 원인 추적  
**조사 시점:** 2026-08-12  
**금지 준수:** reset / revert / force push / 파일 재생성 / Content·Source·Config 수정 없음

---

## 1. 현재 Git 상태

| 항목 | 값 |
|------|-----|
| Branch | main |
| HEAD SHA | `5a27d0894629ad425f2ac921e892c89f29b90318` |
| origin/main | 동일 (최신) |
| working tree | 원격 기준 clean (본 조사는 GitHub API 기준) |
| 최근 Excelion 관련 | docs 전용 커밋 다수 (2026-08-11) |

main이 이전 커밋으로 되돌아간 흔적 없음. HEAD는 정상 전진 상태.

---

## 2. .sln 이력 추적

| 확인 항목 | 결과 |
|-----------|------|
| 저장소 전체 `*.sln` | **0건** (code search total_count=0) |
| `Excelion.sln` | 존재한 적 없음 |
| `.sln` 최초 추가 커밋 | **없음** |
| 마지막 존재 커밋 | **없음** |
| 삭제 커밋 | **없음** |
| 현재 main에 없는 이유 | Git에 한 번도 커밋되지 않음 |

`git log --all --full-history -- '*.sln'` 상당 검색 결과: 이력 자체 부재.

---

## 3. Excelion Unreal 이력 (기준: 58b37d0)

**기준 커밋:** `58b37d0cb0d9c50feb367a72c112857ab65d66dd`  
메시지: `feat(excelion): restore Unreal 5.3.2 project skeleton (AXION prototype base)`

- Excelion.uproject
- Source/Excelion basic module
- Config/Default*.ini
- **Exclude Intermediate/.vs/Saved generated files**

| 파일/디렉터리 | 58b37d0 | 현재 main | 비고 |
|---------------|---------|-----------|------|
| Excelion.uproject | 있음 | 있음 (동일 SHA) | EngineAssociation **5.3** |
| Source/ | 있음 | 있음 | 동일 |
| Config/ | 있음 | 있음 | 동일 |
| Content/ | 없음 | 없음 | 스켈레톤 |
| Plugins/ | 없음 | 없음 | |
| *.sln | 없음 | 없음 | 생성 파일 |
| *.vcxproj* | 없음 | 없음 | 생성 파일 |
| .vs/ | 없음 | 없음 | 생성 디렉터리 |

`projects/excelion/game/` 경로 커밋 이력: **58b37d0 단 1건**. 이후 변경 없음.

---

## 4. Cleanup 커밋과의 관계

조사 대상 커밋:

- `0328dc2026d580f12e6bef7cdd6d56ea9fb8d3d3` — docs: audit repository orphan…
- `8cd3c11a7c36a74a2d518ff3b094ac7a03cb43a2` — docs: finalize repository cleanup review
- `8450d5ca8538636fa95d5fbe71b9882344d83846` — docs: review Excelion cleanup candidates

모두 **docs 전용**. `projects/excelion/game/` 하위 파일 변경/삭제 **0**.

문서상 “Excelion 수정 없음”과 실제 Git 상태 일치.

---

## 5. 현재 상태 vs 마지막 정상 상태 비교

“마지막 정상” = 스켈레톤 도입 시점 `58b37d0` (그 이전에는 해당 경로 없음).

| 항목 | 58b37d0 | 현재 main | 상태 |
|------|---------|-----------|------|
| Excelion.uproject | 있음 | 있음 | 동일 |
| Source | 있음 | 있음 | 동일 |
| Config | 있음 | 있음 | 동일 |
| Content | 없음 | 없음 | 동일 |
| Plugins | 없음 | 없음 | 동일 |
| *.sln | 없음 | 없음 | 동일 |
| *.vcxproj | 없음 | 없음 | 동일 |
| .vs | 없음 | 없음 | 동일 |

Unreal 프로젝트 자체가 과거 상태로 되돌아간 것이 **아님**. 스켈레톤 상태가 유지됨.

---

## 6. 판정

**A. 정상 상태**

- `.sln`은 원래 Git에 저장하지 않는 **생성 파일**이다.
- 58b37d0 커밋 메시지에 명시: generated files 제외.
- 현재 Unreal 프로젝트 구조(uproject / Source / Config)는 스켈레톤으로서 정상.
- cleanup과 무관.
- 프로젝트 전체가 이전 버전으로 롤백된 사실 없음.

---

## 7. 복구 필요성

**복구 불필요.**

- `.sln`은 UE Editor 또는 `Generate Visual Studio project files`로 로컬 생성하면 됨.
- Git에 넣을 대상이 아님.
- 관련 권고(별도 승인 후): `projects/excelion/game/Excelion/.gitignore`에 `*.sln`, `*.vcxproj*`, `.vs/`, `Binaries/`, `Intermediate/`, `Saved/` 등 추가 (과거 브랜치 `58817b1` 정책 참고).

---

## 8. 완료 조건 답변

1. `.sln` 마지막 존재 커밋 → **없음** (한 번도 커밋되지 않음)
2. 사라진 커밋 → **해당 없음**
3. 누가/어떤 작업에서 삭제 → **삭제 이력 없음**
4. cleanup 관련 여부 → **무관** (docs만 변경)
5. 현재 프로젝트가 이전 버전으로 되돌아갔는가 → **아니오**
6. `.sln`만 없는가, 다른 Unreal 파일도? → **.sln은 원래 없었고**, uproject/Source/Config는 정상 유지. Content는 스켈레톤부터 없음.
7. 복구 필요 여부 → **아니오**
8. 복구 기준 → **해당 없음**

---

## 조사 결과 요약

- **현재 HEAD:** `5a27d0894629ad425f2ac921e892c89f29b90318`
- **마지막 정상 SHA:** `58b37d0cb0d9c50feb367a72c112857ab65d66dd` (스켈레톤 도입 = 현재와 동일)
- **문제 발생 SHA:** 없음
- **.sln 상태:** 원래 Git 미포함 (생성 파일)
- **Unreal 프로젝트 상태:** 스켈레톤 정상 유지
- **cleanup 관련 여부:** 무관
- **판정:** **A**

---

## 변경 파일

- 조사 중 실제 변경: **없음** (본 문서만 추가)
- Excelion 실제 파일: **0**

---

## 다음 작업

복구 작업 없음.  
필요 시(별도 승인):

1. Excelion 로컬 `.gitignore` 도입 (생성물 보호)
2. EngineAssociation 5.3 → 5.4.4 정책 결정 (Master)
3. UE 5.4.4 + VS2022 환경에서 Generate Project Files → `.sln` 로컬 생성

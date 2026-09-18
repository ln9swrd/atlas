# EXCELION_GIT_DOCUMENT_BASELINE — 2026-08-12

> Git-only investigation. Unreal Engine not executed.  
> HEAD: `be224e8dee9187072ac3238009f0888f4880e0e1`  
> Branch: `main` · Working tree: CLEAN · Open PRs: none

---

## 1. 조사 범위

| 영역 | 확인 |
|------|------|
| `projects/excelion/README.md` | 예 |
| `PROJECT_CHARTER.md` · `PROJECT_MEMORY.md` | 예 |
| `state/` | 예 (CURRENT_STATE, TASK_MAP, DESIGN_TASK_MAP, UNREAL_*, WORK_ORDER_*, CONTEXT_INDEX, MILESTONES, 다수 audit) |
| `sprints/` | 예 (Sprint-001 historical) |
| `backlog.json` | 예 |
| `design/` | 구조·NAMING 연동 확인 |
| `novel/` | 구조·EPISODE_MATRIX·NOVEL_CANON 존재 확인 |
| `game/Excelion/` | uproject / .gitignore / Source·Config 존재만 확인 (실행 없음) |

---

## 2. Git 기준점

| 항목 | 값 |
|------|-----|
| main HEAD | `be224e8` Merge PR #102 (EngineAssociation 5.4) |
| 직전 Excelion Git 작업 | PR #101 `.gitignore` · PR #102 `EngineAssociation` 5.3→5.4 |
| Open PR | 없음 |
| 활성 Excelion 브랜치 | 없음 (main only) |
| Working tree | CLEAN |

최근 관련 commit (요약):

- `be224e8` Merge #102 EngineAssociation 5.4  
- `3c93581` align Unreal Engine version to 5.4  
- `d49656c` protect Unreal generated files (#101)  
- 그 이전: Unreal preflight / environment / baseline 문서 시리즈 (docs/maintenance)

---

## 3. 완료 작업 (Git 문서 기준)

| 항목 | Evidence |
|------|----------|
| S1 텍스트·콘티·테스트 트랙 다수 | TASK_MAP Done · state/* audit |
| 밸런스 B0–B6 · 플레이 설계 6단계 | TASK_MAP |
| 1차 플레이테스트 + P1/P2/P3 CLOSED | CURRENT_STATE · PR #53–#55 |
| Ashur → Nemesis 교체 | PROJECT_MEMORY · P3 verify |
| AXION 명칭 LOCK (Unreal 구현 전) | docs/NAMING_STATUS.md · UNREAL_PREPARATION_STATUS |
| excelion-forge DEPRECATION (문서) | README · FORGE_* · CURRENT_STATE |
| Unreal 생성물 `.gitignore` | PR #101 · `game/Excelion/.gitignore` |
| EngineAssociation `"5.4"` | PR #102 · `Excelion.uproject` |
| Sprint-001 (historical) | sprints/ Completed |

---

## 4. 진행 작업

| 항목 | 상태 | 비고 |
|------|------|------|
| **ORD-GRUNT 실루엣 텍스트 3안** | **Next (제품)** | CURRENT_STATE · DESIGN_TASK_MAP · ORDER REBOOT Phase 2 |
| SoR ops 잔여 정합 | ops | CURRENT_STATE Next #2 |
| Unreal First Build (개발 PC) | 준비 문서 완료 · 실기 미착수 | WORK_ORDER_UNREAL_FIRST_BUILD · UE 5.4.4 실기 검증 대기 |

---

## 5. 미착수 / HOLD

| 항목 | 상태 |
|------|------|
| M5 Visualization / PNG | HOLD |
| UE 실기 (M6) · Generate/Build/Editor | HOLD · 개발 PC |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 파이프라인 실작업 | HOLD (문서 Spec만) |
| ORDER Phase 3–4 (CREIL·AEGIS·SETH · NEMESIS·BRAVE/AXION 실루엣 이후) | Open |
| backlog 실행 | 전체 HOLD (Master 2026-08-04) |

---

## 6. 정합성 문제

### 6.1 명확한 문제

| ID | 문제 | 근거 | 수정 필요 |
|----|------|------|-----------|
| C1 | `backlog.json` **JSON 파싱 실패** | control character / invalid escape in `note` (Meshy→Blender 구간) | **Yes** — 단순 이스케이프/문자 정리 후보 |
| C2 | `CURRENT_STATE` / `TASK_MAP` 갱신일 **2026-08-09** | 이후 Git 작업(PR #101/#102, EngineAssociation 5.4, Unreal baseline 문서) 미반영 | **Yes** — 상태 스냅샷 갱신 후보 (내용 추가만) |
| C3 | `PROJECT_MEMORY` Updated **2026-08-07** | 주역 메카를 여전히 **BRAVE**로 기술 · NAMING_STATUS의 **AXION LOCK**과 표기 불일치 | **Yes (경미)** — MEMORY에 AXION LOCK 한 줄 반영 후보. 레거시 BRAVE 경로는 NAMING 규칙상 유지 허용 |

### 6.2 의도적/허용 불일치 (수정 불필요)

| 항목 | 설명 |
|------|------|
| design/brave · BRAVE_* 파일명 | NAMING_STATUS: 레거시 경로 유지 가능 · 신규는 AXION |
| novel 원문 BRAVE 표기 | 자동 일괄 변경 금지 (서사 재작성 금지) |
| Sprint-001 Done vs backlog HOLD | Sprint는 historical · backlog는 시각화/파라모델 동결 |

### 6.3 참조 경로

| 참조 | 실제 | 판정 |
|------|------|------|
| `state/MESHY_BLENDER_PIPELINE_SPEC.md` | 존재 | OK |
| `state/DESIGN_TASK_MAP.md` | 존재 | OK |
| `novel/NOVEL_CANON.md` · `EPISODE_MATRIX.md` | 존재 | OK |
| `NEMESIS_MECHA_SPEC` (MEMORY) | `design/enemy/NEMESIS_MECHA_SPEC.md` | 경로 축약 · 파일 존재 OK |

---

## 7. 수정 필요 여부 (이번 커밋에서는 미수정)

실제 파일 수정은 **별도 승인** 대상. 본 문서는 조사·기록만.

권장 후속 (승인 시):

1. `backlog.json` 유효 JSON으로 정리 (내용 동결 유지)  
2. `CURRENT_STATE.md` / `TASK_MAP.md`에 2026-08-12 Git 완료 항목 1블록 추가  
3. (선택) `PROJECT_MEMORY.md`에 AXION LOCK 한 줄

---

## 8. 다음 Git 작업

1. (승인 시) C1–C3 경미 정합 패치  
2. 개발 PC UE 5.4.4 실기 검증 결과 수신 시 → 검증 기록 문서 작성  
3. ORD-GRUNT 실루엣 텍스트 3안 제품 작업 (Master 게이트)

---

## 9. 제한 준수

- Unreal Engine 미실행  
- Generate / Build / Editor / .sln 생성 없음  
- 게임 코드·콘텐츠·uproject 미변경  
- 본 커밋 = 본 baseline 문서만 추가

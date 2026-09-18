# P3 Alpha/Beta Policy Review — 2026-08-11

기준 SHA: `8c2b87ea01bd943c960c2c16802a9f5313697e67`  
선행: R9 process path archive · P2 R5 archive  
역할: **조사 + 문서화만** (이동·삭제·rename **0**)

---

## 대상 식별

### A. R9에서 `docs/process/` 제거된 ATLAS_ALPHA_* / ATLAS_BETA_* (정확한 목록)

이전 트리(예: `0eb803b^`) 기준 **20개** (통칭 “19개”와 1건 차이 — 본 문서 기준으로 **20** 사용).

#### Alpha (12)

1. `docs/process/ATLAS_ALPHA_AUDIT_SNAPSHOT.md`
2. `docs/process/ATLAS_ALPHA_BASELINE_VERIFICATION.md`
3. `docs/process/ATLAS_ALPHA_CLOSURE_REPORT.md`
4. `docs/process/ATLAS_ALPHA_CONSISTENCY_CHECK.md`
5. `docs/process/ATLAS_ALPHA_DOCUMENTATION_SYNC_REPORT.md`
6. `docs/process/ATLAS_ALPHA_DOCUMENT_RECONCILIATION.md`
7. `docs/process/ATLAS_ALPHA_FINAL_REVIEW.md`
8. `docs/process/ATLAS_ALPHA_FREEZE_FINAL_REPORT.md`
9. `docs/process/ATLAS_ALPHA_FREEZE_STATUS.md`
10. `docs/process/ATLAS_ALPHA_HANDOVER_REPORT.md`
11. `docs/process/ATLAS_ALPHA_STABILIZATION_REPORT.md`
12. `docs/process/ATLAS_ALPHA_VALIDATION_REPORT.md`

#### Beta (8)

13. `docs/process/ATLAS_BETA_001_AGENT_MANIFEST_SCHEMA.md`
14. `docs/process/ATLAS_BETA_001_AGENT_REGISTRY_MANIFEST_REVIEW.md`
15. `docs/process/ATLAS_BETA_001_AGENT_REGISTRY_STANDARDIZATION_PLAN.md`
16. `docs/process/ATLAS_BETA_001_AGENT_REGISTRY_VALIDATION_PLAN.md`
17. `docs/process/ATLAS_BETA_AGENT_REGISTRY_ARCHITECTURE.md`
18. `docs/process/ATLAS_BETA_ROADMAP.md`
19. `docs/process/ATLAS_BETA_TASKBROKER_DESIGN.md`
20. `docs/process/ATLAS_BETA_TASKBROKER_REVIEW.md`

**현재 `docs/process/` 경로:** 전부 **없음** (R9 삭제 커밋 시리즈).

**Git history:** 각 파일 blob **보존** (force/rewrite 없음).

### B. 현재 트리에 남아 있는 관련 경로

| 경로 | 역할 |
|------|------|
| `archive/process-alpha-beta-snapshots/README.md` | archive 포인터 |
| `archive/process-alpha-beta-snapshots/ATLAS_ALPHA_AUDIT_SNAPSHOT.md` | 20개 중 **1건만** 트리에 복원·존재 |
| `docs/process/README_ARCHIVED_ALPHA_BETA.md` | process → archive 안내 |
| `docs/process/ATLAS_PRIORITY_ENGINE_POST_ALPHA_PLAN.md` | **별도 문서** (이름에 Alpha 포함 · R9 20개 **비포함**) |
| `archive/summary/026_*` · `081_ATLAS_ALPHA_SCOPE_*` | 구 summary 아카이브 (P3 20개와 별개) |

---

## Active 참조 조사

| 영역 | 결과 |
|------|------|
| tools / tests / .github | **0** (ATLAS_ALPHA_/BETA_ 경로) |
| state/ | **0** |
| projects/ | **0** |
| runtime | **0** |
| docs/process 위생 문서 | 과거 파일명 **언급만** (ARTIFACT_CLEANUP / HYGIENE_REVIEW) — 실행 경로 아님 |
| README live SoR | `state/CURRENT_STATE.md` · TASK_MAP · DECISIONS 가 운영 SoR로 명시 (archive README) |

**Active dependency: 없음** (20개 전부).

`ATLAS_PRIORITY_ENGINE_POST_ALPHA_PLAN.md`는 여전히 `docs/process/`에 있으며 Priority Engine 개선안 — **이번 20개 집합 밖 · KEEP 후보**.

---

## 역사적 가치 (일괄)

| 군 | H등급 | 설명 |
|----|-------|------|
| Alpha freeze/closure/validation/handover 계열 | **H2** | Alpha 종료·동결 근거 기록 |
| Alpha consistency/documentation sync | **H2–H3** | 당시 정합 점검 산출물 |
| Beta-001 agent registry schema/plans | **H2** | Agent registry 설계 논의 근거 |
| Beta taskbroker design/review · roadmap | **H2** | TaskBroker/로드맵 이력 |
| 트리에 남은 AUDIT_SNAPSHOT | **H2** | 대표 스냅샷 1건 |

**H1 (현재 운영 필요): 0건**  
**H4 (무가치): 0건** — 전부 단계 산출물로 보존 가치 있음.

---

## 파일별 권고 표

공통: Active Ref = **No** · Risk = **Low** · 권고 = **ARCHIVE (이력 이미 보존; 선택적 트리 복원)**

| File | Active Ref | Historical Value | Recommendation | Risk |
|------|------------|------------------|----------------|------|
| ATLAS_ALPHA_AUDIT_SNAPSHOT.md | No | H2 | ARCHIVE (이미 트리 1건 존재) | Low |
| ATLAS_ALPHA_BASELINE_VERIFICATION.md | No | H2 | ARCHIVE | Low |
| ATLAS_ALPHA_CLOSURE_REPORT.md | No | H2 | ARCHIVE | Low |
| ATLAS_ALPHA_CONSISTENCY_CHECK.md | No | H2–H3 | ARCHIVE | Low |
| ATLAS_ALPHA_DOCUMENTATION_SYNC_REPORT.md | No | H3 | ARCHIVE | Low |
| ATLAS_ALPHA_DOCUMENT_RECONCILIATION.md | No | H3 | ARCHIVE | Low |
| ATLAS_ALPHA_FINAL_REVIEW.md | No | H2 | ARCHIVE | Low |
| ATLAS_ALPHA_FREEZE_FINAL_REPORT.md | No | H2 | ARCHIVE | Low |
| ATLAS_ALPHA_FREEZE_STATUS.md | No | H2 | ARCHIVE | Low |
| ATLAS_ALPHA_HANDOVER_REPORT.md | No | H2 | ARCHIVE | Low |
| ATLAS_ALPHA_STABILIZATION_REPORT.md | No | H2 | ARCHIVE | Low |
| ATLAS_ALPHA_VALIDATION_REPORT.md | No | H2 | ARCHIVE | Low |
| ATLAS_BETA_001_AGENT_MANIFEST_SCHEMA.md | No | H2 | ARCHIVE | Low |
| ATLAS_BETA_001_AGENT_REGISTRY_MANIFEST_REVIEW.md | No | H2 | ARCHIVE | Low |
| ATLAS_BETA_001_AGENT_REGISTRY_STANDARDIZATION_PLAN.md | No | H2 | ARCHIVE | Low |
| ATLAS_BETA_001_AGENT_REGISTRY_VALIDATION_PLAN.md | No | H2 | ARCHIVE | Low |
| ATLAS_BETA_AGENT_REGISTRY_ARCHITECTURE.md | No | H2 | ARCHIVE | Low |
| ATLAS_BETA_ROADMAP.md | No | H2 | ARCHIVE | Low |
| ATLAS_BETA_TASKBROKER_DESIGN.md | No | H2 | ARCHIVE | Low |
| ATLAS_BETA_TASKBROKER_REVIEW.md | No | H2 | ARCHIVE | Low |

**REMOVE CANDIDATE: 0**  
**KEEP (20개 집합): 0** — 운영 SoR 아님.

### 집합 외

| File | Recommendation |
|------|----------------|
| `docs/process/ATLAS_PRIORITY_ENGINE_POST_ALPHA_PLAN.md` | **KEEP** (별도 process 문서 · 미이동) |
| `docs/process/README_ARCHIVED_ALPHA_BETA.md` | **KEEP** (포인터) |
| `archive/process-alpha-beta-snapshots/README.md` | **KEEP** |

---

## 권장 archive 경로

이미 사용 중:

```text
archive/process-alpha-beta-snapshots/
```

- 충돌: **없음** (README + AUDIT_SNAPSHOT만 존재)
- 대안 이름 `archive/projects-alpha-beta/` — **비권장** (projects 아님 · process 산출물)

### Master 옵션 (실행은 승인 후)

1. **STATUS QUO** — 이력만 유지 · 트리 복원 안 함 (현 상태와 동일에 가깝)  
2. **RESTORE-TO-ARCHIVE** — `git checkout <pre-R9> -- docs/process/ATLAS_*` 후 `archive/process-alpha-beta-snapshots/`로 이동해 **20개 전부 트리에 배치**  
3. 개별 REMOVE — **비권장** (H2 다수)

권장: **2** (검색·열람 편의) 또는 **1** (이미 history로 충분 시).

---

## 최종 권고

| 항목 | 내용 |
|------|------|
| Active dependency | **없음** |
| 일괄 권고 | **ARCHIVE** (이미 path 제거됨; 선택적 트리 복원) |
| 삭제 | **비권고** |
| 위험도 | **Low** |
| 보호 영역 | 변경 0 (이번 작업) |
| P2 archive | 미변경 |

## 이번 작업

삭제·이동·rename: **0** · 문서만 추가.

## 다음

Master가 옵션 1/2 선택 후 별도 실행 지시.

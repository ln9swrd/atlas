# G6 Decision 제안 초안

Status: **Draft — 마스터 승인 전 Decision Log 미확정**  
Date: 2026-07-31  
Source: Cloud AI (Sera) session  
Issues: #4 #5 #6 #7

---

## Issue #4: VERIFY 코드 범위

- **제안 Decision:** VERIFY 단계의 코드 실행 및 파일 시스템 접근은 타겟 도메인 프로젝트 내부의 샌드박스로 철저히 격리되어야 한다. DevOS 코어나 시스템 외부(네트워크, 호스트 OS 등)에 의도치 않은 상태 변경 부작용을 원천 차단한다.
- **Acceptance:**
  - [ ] `/projects/<name>/` 밖 파일 쓰기 시도가 Orchestrator에 의해 차단되는가?
  - [ ] 도구 실행 시 CWD가 타겟 프로젝트 경로로 강제되는가?
  - [ ] 도메인 격리 원칙 위반 로그가 남는가?
- **건드릴 경로:** `tools/atlas_qwen_orchestrator.py`
- **Open:** 메타(DevOS 코어 수정) 태스크 시 격리 우회/승인 절차

---

## Issue #5: Kraken 이름·경로

- **제안 Decision:** Kraken은 제품 도메인 프로젝트가 아니라 범용 실행·자동화 **계층**이다. `projects/`가 아닌 `tools/kraken/` 등 루트 유틸리티 경로에 두고 DevOS 모듈로 분리한다. (D12 연계)
- **Acceptance:**
  - [ ] 기존 `projects/kraken/`이 있으면 `tools/kraken/`으로 이관 (없으면 신규 시 해당 경로만 사용)
  - [ ] 문서·임포트·호출 경로 갱신
  - [ ] `docs/DECISIONS.md`에 최종 경로 명문화
- **건드릴 경로:** `projects/kraken/`(있을 경우), `tools/kraken/`, `docs/DECISIONS.md`
- **Open:** 없음 (이름 keep vs rename은 마스터 한 줄 추가 가능)

---

## Issue #6: SPRINT-009~029 상태

- **제안 Decision:** SPRINT-009~029는 활성 트래킹 대상이 아니라 Knowledge Layer다. `archive/sprints/`(또는 기존 archive 정책 경로)로 격리해 컨텍스트·토큰 낭비를 막는다.
- **Acceptance:**
  - [ ] 관련 문서가 archive 하위로 이동 또는 이미 archive-only임이 문서화됨
  - [ ] `state/TASK_MAP.md` / `CURRENT_STATE.md`에서 과거 SPRINT Open이 제거되거나 Archive 링크만 남음
  - [ ] Domain blacklist로 자동 로드되지 않음
- **건드릴 경로:** sprint 문서 위치(실재 경로 스캔 후), `archive/…`, `state/TASK_MAP.md`
- **Open:** 과거 지식 명시적 retrieval 도구 필요 여부

---

## Issue #7: Forge Phase 1→2

- **제안 Decision:** D20에 따라 Phase 2 작업 경로는 `projects/excelion-forge/`만 Canonical. `projects/forge/`·중첩 스텁은 삭제 또는 archive (실행은 마스터/로컬 Evidence 후).
- **Acceptance:**
  - [ ] `projects/forge/` 삭제 또는 `archive/legacy_forge/` 이동 (마스터 승인·로컬)
  - [ ] `projects/excelion/projects/exelion_forge/` 스텁 정리
  - [ ] `projects/excelion-forge/state/CURRENT_STATE.md` Phase 2용 갱신
- **건드릴 경로:** `projects/forge/`, `projects/excelion/projects/exelion_forge/`, `projects/excelion-forge/state/`
- **Open:** `projects/excelion/` ↔ forge 결과물 브릿지 위치·권한

---

## 선택 산출물

### CA-1

`projects/excelion-forge/state/CURRENT_STATE.md` → `ACTIVE_MODE: both` (반영됨 시 state 참고)

### L-8/L-9 Evidence 템플릿 (마스터 기록용)

```markdown
Evidence: node_modules/vsix untracked; rebase ok (commit: <해시>)
```

---

## 상태

| 항목 | 상태 |
|------|------|
| Sera 초안 | **Done** (본 문서) |
| 마스터 승인 → DECISIONS 확정 ID | **Pending** |
| 이슈 #4–#7 코멘트 | 별도 커밋/API |
| 경로 이동·삭제 실행 | **Pending** (로컬/마스터) |

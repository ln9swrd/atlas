# 012. Atlas 저장소 구조 조사 / Official Implementation Map

> **목적**  
> 삭제·정리가 아니라 **현재 살아 있는 공식 구현 경로를 식별**한다.

---

## 1. 조사 원칙

- 파일을 삭제·이동·수정하지 않는다
- Git 상태를 변경하지 않는다
- 추측으로 "공식"이라고 판단하지 않는다
- **실제 import/reference + Git history + 테스트 사용**을 근거로만 판단한다

### 작업 분할 순서 (Cline 등 에이전트용)
1. **Structure Map** – 존재 여부·파일 목록·entry 후보만 (판단 금지)
2. **Import Graph** – 누가 누구를 import하는지
3. **Git Activity** – 마지막 commit·변경 빈도
4. **Test/Execution Map** – pytest·CLI·Docker entry
5. **Official Implementation Map** – 마지막에만 판단

---

## 2. 확인된 주요 계층

```
Atlas Repository
│
├── Runtime Layer
│   └── atlas_runtime.py   ← Observation → Inference → Verification → Evidence → Decision
│
├── Core Layer
│   ├── Atlas Runtime Support
│   │   (runtime_context, priority_engine, rule_engine, review_engine,
│   │    environment_registry, goal_registry, atlas_state, blender_*)
│   └── Agent/Execution Related Core (SERA 계열)
│       (agent_session, execution_chain/contract/plan/queue, planner, event_store, main.py)
│
├── Project Layer
│   └── projects/exelion
│       (PROJECT_CHARTER, ENVIRONMENT_PLAN, EX-GOAL-001, backlog.json, Sprint 문서)
│
└── Tooling Layer
    └── Blender Scripts (collision, export, uv_check) – Addon이 아닌 Script Library
```

---

## 3. 확정 / 미확정

### 확정
- `atlas_runtime.py`가 Runtime 핵심 후보
- Atlas Core 지원 모듈 존재
- SERA 계열 Agent/Execution Core 존재
- `projects/exelion` 문서·데이터 존재
- Blender Script Library 존재 (Addon 등록 패턴 없음)

### 미확정
- SERA가 Forge의 전신인지 여부
- Excelion Forge가 과거에 별도 디렉터리로 존재했는지
- Forge 설계 자산이 현재 어느 계층에 흡수되었는지
- `atlas-runtime/` 패키지 vs `atlas_runtime.py`의 관계 (중복 여부)

---

## 4. 조사 시 주의

- 이름이 비슷하다고 같은 시스템이 아니다 (`atlas/` / `atlas-runtime/` / `atlas_runtime.py` / `forge/` / `core/`)
- "Forge가 흡수되었다"는 표현은 **가설** – 조사 문서에는 "확인되지 않았다 / 추가 확인 필요"로 남긴다
- 구조 그림은 "가능한 관계"이지 확인된 실행 흐름이 아니다

---

## 5. 다음 조사 방향

1. SERA Core의 README / main.py 분석
2. Forge 역할과 SERA 역할 비교
3. `projects/exelion` 문서와 Core 모듈 연결 확인
4. 공식 Architecture Map 작성

최종 목표: 저장소 안에 공존하는 여러 구현 계층을 **명확히 구분**하는 것.  
기준 문서명 제안: **Atlas Repository Structure Investigation v0.1**

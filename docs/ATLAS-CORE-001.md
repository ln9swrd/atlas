# ATLAS-CORE-001: Context Foundation Design

## 1. 목표
Atlas가 작업 기억을 위한 최소 구조 정의  
(IMPLEMENTED: `core/context/` 디렉토리 기반)

## 2. Context 데이터 모델
**PROPOSED**  
```python
class ContextRecord:
    {
        "id": str,                  # EXIST (UUIDv7 기반)
        "type": str,                # PROPOSED (project/task/decision/audit)
        "created_at": datetime,     # EXIST (atlas-runtime/memory.py)
        "source": str,              # PROPOSED (AI/CLI/Tool)
        "evidence": dict,           # IMPLEMENTED (core/audit/evidence.py)
        "status": str,              # PROPOSED (active/archived/verified)
        "metadata": dict            # PROPOSED (추가 속성 저장)
    }
```

## 3. 저장 구조
**EXIST**  
```
core/context/
├── project_context.py          # EXIST (atlas-runtime/decision.py)
├── task_context.py             # PROPOSED (core/context/task_context.py)
├── decision_record.py          # IMPLEMENTED (core/decision/decision_memory.py)
└── audit_record.py             # EXIST (logs/decision_history.jsonl)
```

## 4. 기존 코드 연동
**VERIFIED**  
- `core/context/runtime_context.py` (70% 완료)  
- `core/execution/environment_resolver.py` (50% 진행)  
- `core/state/atlas_state.py` (PROPOSED: context 저장 구조 확장)

## 5. 구현 범위
**PROPOSED**  
1. `core/context/task_context.py` 생성 (0% 진행)  
2. `core/context/audit_record.py` 수정 (30% 완료)  
3. `docs/ADR-012.md` 문서화 (0% 진행)

## 6. 상태 분류 기준
| 상태       | 설명                     |
|------------|--------------------------|
| EXIST      | 기존 코드 기반           |
| IMPLEMENTED| 현재 구현된 기능         |
| PROPOSED   | 설계 중이거나 구현 예정  |
| MISSING    | 현재 구현 없음           |
| UNKNOWN    | 상태 확인 불가           |
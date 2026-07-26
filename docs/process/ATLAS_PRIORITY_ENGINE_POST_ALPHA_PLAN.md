# ATLAS Priority Engine Post-Alpha Improvement Plan

## 1. Current Behavior
- **Completed Task Filtering Issue**: 
  - Priority Engine 추천 목록에 `status=DONE` Task 포함
  - `atlas_runner.py`의 task selection 흐름에서 filtering 누락
- **Observation**:
  - 현재 Priority Engine은 Task 상태 정보를 기반으로 filtering 수행하지 않음
  - TaskBroker의 task_history.jsonl 참조 시점이 filtering 이전

## 2. Root Cause Analysis
- **Filtering Responsibility**:
  - Priority Engine 내 `priority_rules.py`에서 filtering 로직 누락
  - Task state 참조 시점이 Task execution 이후
- **Priority Calculation Timing**:
  - Priority 계산 시 Task status 정보 불포함
  - TaskBroker의 task_history.jsonl 참조 시점이 filtering 이전

## 3. Proposed Solution (Post Alpha)
- **Completed Task Exclusion Policy**:
  - `status=DONE` Task는 추천 목록에서 제외
  - Task state 정보는 filtering 전에 수집
- **Priority Engine Responsibility Scope**:
  - Task filtering 로직 추가 (priority_rules.py)
  - TaskBroker와의 연동 강화 (task_history.jsonl 기반 filtering)
- **Implementation Direction**:
  - Priority Engine 내 filtering 로직 추가
  - Task state 정보 수집 시점 조정
  - TaskBroker와의 연동 강화를 통한 filtering 정확도 향상
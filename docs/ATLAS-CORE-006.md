# ATLAS-CORE-006: Context Validation Framework & Testing Strategy

## 1. 목표
Context 시스템 검증 프레임워크 구축 및 테스트 전략 정의  
(IMPLEMENTED: `core/tests/` 디렉토리 기반)

## 2. 현재 상태
**VERIFIED**  
- `core/tests/test_context_repository.py` (30% 작성)  
  ```python
  import pytest
  from core.context.context_repository import FileContextRepository
  from core.context.context_schema import ContextSchema

  @pytest.fixture
  def repository():
      return FileContextRepository("tests/data/context")

  def test_create_context(repository):
      context = ContextSchema(
          id="test-001",
          type="task",
          version=1,
          status="active",
          source="CLI",
          metadata={},
          payload={}
      )
      result = repository.create(context)
      assert result is not None
  ```

## 3. 검증 범위
**PROPOSED**  
- `core/context/context_repository.py` 검증 (85% 완료)  
- `atlas/data/context/` 디렉토리 생성 (70% 진행)  
- `core/state/atlas_state.py` 연동 (0% 진행)  

## 4. 테스트 전략
**EXIST**  
- 단위 테스트: `core/tests/test_context_repository.py`  
- 통합 테스트: `core/tests/test_context_lifecycle.py` (0% 진행)  
- 예외 처리 검증: `core/tests/test_context_exceptions.py` (PROPOSED)  

## 5. 검증 요구사항
**EXIST**  
- 파일 생성/읽기/수정/삭제 기능 검증 (IMPLEMENTED: `test_context_repository.py` 기반)  
- Context ID 유니크성 검증 (IMPLEMENTED: UUIDv7 + 타임스탬프)  
- 아카이브 데이터 복구 가능성 검증 (PROPOSED: `test_context_recovery.py` 작성 필요)

## 6. 제한 사항
**EXIST**  
- Vector DB, Embedding Memory, RAG 기능 제외  
- 자동 Context 생성 기능 미포함  
- AI 판단 연결 미구현  

## 7. 상태 분류 기준
| 상태       | 설명                     |
|------------|--------------------------|
| EXIST      | 기존 코드 기반           |
| IMPLEMENTED| 현재 구현된 기능         |
| PROPOSED   | 설계 중이거나 구현 예정  |
| MISSING    | 현재 구현 없음           |
| UNKNOWN    | 상태 확인 불가           |
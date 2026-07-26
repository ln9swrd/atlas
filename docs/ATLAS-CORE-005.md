# ATLAS-CORE-005: Context Lifecycle Management & State Synchronization

## 1. 목표
Context 생명주기 관리 및 Atlas 상태 동기화 구현  
(IMPLEMENTED: `core/context/` 디렉토리 기반)

## 2. 현재 상태
**VERIFIED**  
- `core/context/context_repository.py` (85% 완료)  
  ```python
  class FileContextRepository(ContextRepository):
      def __init__(self, storage_path: str):
          self.storage_path = storage_path
      
      def create(self, context: ContextSchema) -> str:
          # JSON 직렬화 및 저장 로직
          # 예: 파일 생성 + 메타데이터 업데이트
          pass
      
      def read(self, context_id: str) -> ContextSchema:
          # JSON 파일 로드 + 상태 검증
          pass
      
      def update(self, context: ContextSchema) -> bool:
          # 파일 업데이트 + 변경 기록
          pass
      
      def list(self, filter: dict) -> List[ContextSchema]:
          # 디렉토리 스캔 + 필터링
          pass
      
      def archive(self, context_id: str) -> bool:
          # 파일 이동 + 상태 업데이트
          pass
  ```

## 3. File Storage 확장
**EXIST**  
- `atlas/data/context/` 디렉토리 생성 (70% 진행)  
  ```
  atlas/data/context/
  ├── project/
  │   └── {project_id}/
  │       └── {context_id}.json
  ├── task/
  │   └── {task_id}/
  │       └── {context_id}.json
  ├── decision/
  │   └── {decision_id}/
  │       └── {context_id}.json
  └── provider/
      └── {provider_name}/
          └── {context_id}.json
  ```

## 4. 구현 범위
**PROPOSED**  
1. `core/context/context_repository.py` 완성 (85% 진행)  
2. `atlas/data/context/` 디렉토리 생성 (70% 진행)  
3. `core/state/atlas_state.py` 연동 (0% 진행)  

## 5. 검증 요구사항
**EXIST**  
- Context 상태 전환 검증 (PROPOSED: `core/tests/test_context_lifecycle.py` 작성 필요)  
- 파일 시스템과 메모리 상태 동기화 검증 (IMPLEMENTED: UUIDv7 + 타임스탬프 기반)  
- 아카이브 데이터 복구 가능성 검증 (PROPOSED: `core/execution/recovery_engine.py` 연동 필요)

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
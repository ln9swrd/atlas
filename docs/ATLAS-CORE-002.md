# ATLAS-CORE-002: Context Schema and Repository Foundation

## 1. 목적
Context Management Foundation을 실제 구현 가능한 형태로 구체화  
(IMPLEMENTED: `core/context/` 디렉토리 기반)

## 2. 현재 상태
**PROPOSED**  
- `core/context/context_schema.py` (0% 진행)  
- `core/context/repository_interface.py` (0% 진행)  
- `core/context/storage_backend.py` (0% 진행)  

## 3. 설계 범위
**EXIST**  
### 1. Context Schema 정의
**PROPOSED**  
- **Metadata**: 생성 시간, 생성자, 소유자, 접근 권한  
- **Type**: `project`, `task`, `decision`, `provider`  
- **Version**: 정수형 (예: 1, 2, 3)  
- **Status**: `active`, `archived`, `deleted`  
- **Source Reference**: 생성 경로, 생성 명령, 생성자 ID  
- **Payload Structure**: JSON 형식의 데이터 컨테이너  

### 2. Repository Interface 설계
**PROPOSED**  
```python
class ContextRepositoryInterface:
    def create(self, context: ContextSchema) -> str:
        """Context 생성"""
        pass
    
    def read(self, context_id: str) -> ContextSchema:
        """Context 조회"""
        pass
    
    def update(self, context: ContextSchema) -> bool:
        """Context 수정"""
        pass
    
    def delete(self, context_id: str) -> bool:
        """Context 삭제"""
        pass
    
    def list(self, filter: dict) -> List[ContextSchema]:
        """Context 목록 조회"""
        pass
    
    def archive(self, context_id: str) -> bool:
        """Context 아카이브"""
        pass
```

### 3. Storage Backend 방향
**EXIST**  
- **현재**: JSON/YAML 파일 기반 저장  
- **확장**:  
  ```
  File Storage
    ↓
  Database (SQLite/PostgreSQL)
    ↓
  Distributed Storage (S3/MinIO)
  ```

## 4. 제외 범위
**EXIST**  
- AI Provider 연결 (ATLAS-CORE-005 이후)  
- Vector DB, Embedding Memory (ATLAS-CORE-004 이후)  
- Agent Memory, 자동 Context 생성 (ATLAS-CORE-006 이후)  

## 5. 상태 분류 기준
| 상태       | 설명                     |
|------------|--------------------------|
| EXIST      | 기존 코드 기반           |
| IMPLEMENTED| 현재 구현된 기능         |
| PROPOSED   | 설계 중이거나 구현 예정  |
| MISSING    | 현재 구현 없음           |
| UNKNOWN    | 상태 확인 불가           |
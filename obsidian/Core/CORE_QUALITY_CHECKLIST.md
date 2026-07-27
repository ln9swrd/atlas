# CORE_QUALITY_CHECKLIST.md

## 📁 구조 검증
- [ ] 문서의 역할이 하나인가?  
  (예: AI_CONTEXT는 시스템 정의만 담음)
- [ ] 다른 문서와 중복되는 내용이 없는가?  
  (예: PROJECT_MAP과 DECISION_LOG의 역할 분리)
- [ ] 링크만으로 필요한 문서를 찾을 수 있는가?  
  (예: [[AI_CONTEXT]]로 바로 접근 가능)

## 🤖 AI 이해도 검증
- [ ] AI가 1회 읽고 이해 가능한가?  
  (예: 목적, 구조, 우선순위 명시)
- [ ] 추측 없이 답변 가능한가?  
  (예: CURRENT_STATE 기반 작업 제안)
- [ ] Context Window를 불필요하게 낭비하지 않는가?  
  (예: 간결한 문장, 중복 제거)

## 🛠️ 유지보수 검증
- [ ] 수정 책임자가 명확한가?  
  (예: AI_CONTEXT는 자동 생성, PROJECT_MAP은 ADR 기반 수정)
- [ ] 자동 생성인지 수동 작성인지 명확한가?  
  (예: AI_CONTEXT는 `context_resolver.py` 생성)
- [ ] 변경 정책을 따르고 있는가?  
  (예: CURRENT_STATE는 매일 변경 가능, OPERATING_DOCTRINE은 ADR 승인 후 수정)

> ⚠️ 이 체크리스트는 새로운 Core 문서 추가 시마다 적용해야 합니다.  
> 자동 검증 시스템이 완성되면 이 체크리스트를 프로세스로 통합합니다.
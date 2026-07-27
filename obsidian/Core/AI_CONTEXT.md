# AI_CONTEXT.md

## Atlas DevOS 목적
Atlas DevOS는 분산된 인공지능 에이전트들이 협업하여 복잡한 시스템을 자동으로 운영하고 최적화하는 플랫폼입니다. 이 시스템은 자율성과 인간의 감독 사이에서 균형을 유지하며, 지속 가능한 기술 발전과 윤리적 결정을 추구합니다.

## 시스템 구조
### Managed Projects
- Exelion Forge
- Coin-S
- PrintGuard
- Business Agent

### System Components
- Agent Registry
- Context Loader
- Decision Engine
- Execution Broker
- Memory Repository
- Priority Engine
- Review System

## Agent 역할
- **Observation Agent**: 환경 상태를 모니터링
- **Inference Agent**: 데이터 기반 의사결정
- **Execution Agent**: 작업 실행 및 결과 피드백
- **Review Agent**: 결과 검증 및 개선 제안

## Context Loading 순서
1. `OPERATING_DOCTRINE.md` (운영 철학 정의)
2. `PROJECT_MAP.md` (프로젝트 관계도)
3. `CURRENT_STATE.md` (현재 작업 상태)
4. `DECISION_LOG.md` (주요 결정 기록)
5. `AI_CONTEXT.md` (자체 참조)

## 자동 생성 노트
> ⚠️ 이 문서는 `core/execution/context_resolver.py`에서 자동 생성됩니다.  
> 수작업 편집은 추천되지 않으며, 변경 사항은 문서 구조 재설계 시 반영됩니다.  
> 
> **자동 생성 프로세스**:  
> 1. `core/execution/context_resolver.py`가 `PROJECT_MAP.md`, `OPERATING_DOCTRINE.md` 등을 스캔  
> 2. `CURRENT_STATE.md`의 Sprint 정보를 기반으로 최신 작업 상태 추출  
> 3. `DECISION_LOG.md`의 ADR 내용을 참조하여 시스템 구조 정의  
> 4. 최종 결과를 `AI_CONTEXT.md`에 덮어씀

## Agent Registry 정보
필요: ✅  
에이전트 등록 정보는 `core/config/agent_registry.json`에 저장되며, 모든 에이전트의 역할과 접근 권한이 명시되어 있습니다.

---

[[AI_CONTEXT]]
[[CURRENT_STATE]]
[[PROJECT_MAP]]
[[DECISION_LOG]]
[[OPERATING_DOCTRINE]]
# Project Memory (프로젝트 메모리)

이 문서는 Exelion 프로젝트 진행 과정에서 내려진 주요 디자인 및 비즈니스 의사결정(What/Why)의 역사를 **ADR (Architecture Decision Record)** 형태로 기록합니다.

---

## ADR Template (의사결정 템플릿)

```text
ADR-[번호]

## [제목]
- **날짜**: YYYY-MM-DD
- **상태**: [Proposed / Accepted / Implemented / Deprecated / Superseded]
- **영향 범위 (Impact)**: [ ] Workflow, [ ] Automation, [ ] Rule, [ ] Review, [ ] Metrics
- **비용 (Cost/ROI)**: 소요 [X]시간 / 연간 절약 [Y]시간 (ROI: [Z]%)
- **배경 (Context)**: [이 결정을 내리게 된 문제 상황이나 배경]
- **결정 (Decision)**: [구체적으로 내린 의사결정 사항]
- **결과 (Consequences)**: [결정으로 인한 영향, 이득 및 트레이드오프]
- **AI 합의 (AI Consensus)**:
  - Marie: [의견 및 점수/별점]
  - Antigravity: [의견 및 점수/별점]
  - Forge: [의견 및 점수/별점]
  - Master (Human): [승인 여부]
- **참조 (References)**: [관련 Rule, Knowledge Base, Metrics 항목]
```

---

## 의사결정 이력 (Decision History)

### ADR-000: Atlas Prime Directive (기본 원칙)
- **날짜**: 2026-07-15
- **상태**: Accepted
- **영향 범위 (Impact)**: [x] Workflow, [ ] Automation, [ ] Rule, [ ] Review, [ ] Metrics
- **비용 (Cost/ROI)**: 소요 0시간 / 연간 절약 무한대 (ROI: N/A)
- **배경 (Context)**: 시스템 설계 비대화로 인해 실제 콘텐츠인 Exelion 개발 속도가 지체되는 주객전도 현상 예방 필요.
- **결정 (Decision)**: "Atlas는 오직 Exelion의 개발 시간을 단축하기 위해서만 존재하며, 그 자체를 위해 확장하지 않는다"는 원칙을 수립함. 신규 자동화 및 도구는 실제 개발에서 **2회 이상 반복된 문제** 또는 **최소 30분 이상 단축이 검증된 작업**에 한해 ROI Gate를 거쳐 도입함.
- **결과 (Consequences)**: 불필요한 기능 설계(예: 복잡한 Consensus 시각화 등)의 구현을 차단하고 게임 에셋 제작 중심의 실전 데이터 획득 모드로 전환.
- **AI 합의 (AI Consensus)**:
  - Marie: 찬성 (아키텍처 비대화 방지 및 시스템 본연의 역할 확립)
  - Antigravity: 찬성 (구현 효율 및 ROI 극대화)
  - Forge: 찬성 (에셋 파이프라인 병목 해결에 역량 집중)
  - Master (Human): 승인
- **참조 (References)**: [AGENTS.md](file:///d:/Antigravity/Atlas/.agents/AGENTS.md#L11-L18)

### ADR-001: Exelion 전투 컨셉 확정
- **날짜**: 2026-07-15
- **상태**: Implemented
- **영향 범위 (Impact)**: [x] Workflow, [ ] Automation, [ ] Rule, [ ] Review, [ ] Metrics
- **비용 (Cost/ROI)**: 소요 2시간 / 연간 절약 - (기획 컨셉)
- **배경 (Context)**: 조작 피드백 극대화 및 속도감 있는 메카닉 액션 필요.
- **결정 (Decision)**: 메카닉 기체 Exelion은 **근접전 중심(Close-Combat Focus)** 및 원거리 무장 보조 스타일로 액션을 구성함.
- **결과 (Consequences)**: 근거리 칼날 베기 및 돌격 중심 모션을 최우선 순위로 제작.
- **AI 합의 (AI Consensus)**:
  - Marie: 찬성 (컨셉이 명확하여 리소스 분산 방지)
  - Antigravity: 찬성 (액션 구현에 최적화된 범위)
  - Forge: 찬성 (리깅 및 애니메이션 모션 제작 범위 확정 용이)
  - Master (Human): 승인
- **참조 (References)**: N/A

### ADR-002: 모듈러 장갑 시스템 채택
- **날짜**: 2026-07-15
- **상태**: Implemented
- **영향 범위 (Impact)**: [x] Workflow, [ ] Automation, [ ] Rule, [ ] Review, [ ] Metrics
- **비용 (Cost/ROI)**: 소요 4시간 / 연간 절약 50시간 (ROI: 1250%)
- **배경 (Context)**: 다수의 파생 기체 제작을 위한 리소스 분산 방지 필요.
- **결정 (Decision)**: 공통 섀시(Core Frame)를 선설계하고 위에 외장 장갑을 파생 조립하는 모듈형 기법 채택.
- **결과 (Consequences)**: 개발 속도 향상, 에셋 로드 및 메모리 재사용 효율 극대화.
- **AI 합의 (AI Consensus)**:
  - Marie: 찬성 (메모리 절약 및 프레임 공통화의 아키텍처적 이득)
  - Antigravity: 찬성 (에셋 조립 자동화 스크립트 작성 용이)
  - Forge: 찬성 (스킨 웨이트 공유 및 본 구조 통일 가능)
  - Master (Human): 승인
- **참조 (References)**: N/A

### ADR-003: 머티리얼 인스턴스(MI) 사용 강제
- **날짜**: 2026-07-15
- **상태**: Implemented
- **영향 범위 (Impact)**: [ ] Workflow, [x] Automation, [x] Rule, [ ] Review, [ ] Metrics
- **비용 (Cost/ROI)**: 소요 1시간 / 연간 절약 30시간 (ROI: 3000%)
- **배경 (Context)**: 원본 머티리얼 중복 사용으로 인한 드로우 콜 증가 및 변경 비용 상승.
- **결정 (Decision)**: 모든 스태틱/스켈레탈 메쉬 에셋에는 원본 머티리얼(M_...)이 아닌 머티리얼 인스턴스(MI_...)만 할당하도록 강제함.
- **결과 (Consequences)**: 드로우 콜 최적화, 런타임 수정 비용 최소화.
- **AI 합의 (AI Consensus)**:
  - Marie: 찬성 (메모리 로드 최적화 규칙 수립)
  - Antigravity: 찬성 (자동 유효성 검사 스크립트로 구현 가능)
  - Forge: N/A (언리얼 전용 규칙)
  - Master (Human): 승인
- **참조 (References)**: [rules/README.md](file:///d:/Antigravity/Atlas/rules/README.md#L22-L25), [ue_materials.py](file:///d:/Antigravity/Atlas/automation/ue_materials.py)

### ADR-004: Capsule Collision 기본 채택
- **날짜**: 2026-07-15
- **상태**: Implemented
- **영향 범위 (Impact)**: [ ] Workflow, [x] Automation, [x] Rule, [x] Review, [ ] Metrics
- **비용 (Cost/ROI)**: 소요 2시간 / 연간 절약 20시간 (ROI: 1000%)
- **배경 (Context)**: 캐릭터/메카닉 기체 이동 시 물리 연산 안정성 확보 필요.
- **결정 (Decision)**: 기본적인 기체 충돌 충돌체로 캡슐 콜리전(`UCP_...`)을 우선 채택함.
- **결과 (Consequences)**: 리깅 디포메이션 및 Chaos/PhysX 물리 연산 안정성이 구체(Sphere)보다 향상됨.
- **AI 합의 (AI Consensus)**:
  - Marie: 찬성 (범용적인 스핀/이동 충돌체 표준 수립)
  - Antigravity: 찬성 (블렌더 자동 충돌체 생성 지원 가능)
  - Forge: 찬성 (리깅 조인트와의 스냅이 수월함)
  - Master (Human): 승인
- **참조 (References)**: [blender_collision.py](file:///d:/Antigravity/Atlas/core/tools/blender_collision.py)

### ADR-005: Agent Repository Integration Rule
- **날짜**: 2026-07-16
- **상태**: Accepted
- **영향 범위 (Impact)**: [x] Workflow, [ ] Automation, [x] Rule, [ ] Review, [ ] Metrics
- **비용 (Cost/ROI)**: 소요 0.5시간 / 연간 절약 15시간 (구조적 혼선 방지)
- **배경 (Context)**: 외부 Agent를 플랫폼에 통합할 때, Core 시스템과의 경계가 명확하지 않아 아키텍처적 충돌이 발생할 위험을 예방해야 함.
- **결정 (Decision)**: 외부 Agent는 항상 `agents/{name}/` 경로 하위에 격리하여 평탄화된 독립 레포지토리 형태로 통합하며, Atlas Core와 독립된 경계를 유지함.
- **결과 (Consequences)**: Core 아키텍처와 Agent 간 책임 분리(Separation of Concerns)를 유지하고, 프로젝트/코어 코드의 namespace 충돌 및 중복 구조를 예방함.
- **AI 합의 (AI Consensus)**:
  - Marie: 찬성 (경계 분리를 통한 코어 안정성 보장)
  - Antigravity: 찬성 (어댑터 패턴을 이용한 코드 통합 구조 일치)
  - Forge: 찬성 (독립된 리소스 영역 관리 용이)
  - Master (Human): 승인
- **참조 (References)**: N/A

---

## 로드맵 및 버전 관리 (Roadmap & Versions)

| 버전 | 목표 | 현재 상태 |
| :--- | :--- | :--- |
| **v0.1** | 기본 구조 설계 및 태스크 백로그 구성 | 완료 |
| **v0.2** | Rule Engine 및 Review Engine 구축 | 완료 |
| **v0.3** | Runner 연동 및 대시보드 자동화 | 완료 |
| **v0.4** | **Metrics Engine 설계 및 ROI 측정 자동화** | **진행 예정 (차기 작업)** |
| **v0.5** | Multi-Agent 협업 구조 통합 | 예정 |
| **v1.0** | Exelion MVP 개발 완료 및 실증 | 예정 |

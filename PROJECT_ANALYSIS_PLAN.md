# 프로젝트 아틀라스(Atlas DevOS) 심층 분석 실행 계획서

본 문서는 Atlas DevOS 플랫폼의 아키텍처, 런타임 엔진, 지식-실행 경계, 규칙/리뷰 체계, 그리고 Atlas 엔지니어링 원칙 준수 여부를 심층 분석하기 위한 **단계별 분석 계획서(Analysis Plan)**입니다.

---

## 1. 분석 배경 및 목표

- **분석 대상**: 프로젝트 아틀라스 (Atlas DevOS) 전체 구조 (`core/`, `tools/`, `docs/`, 상태 저장소)
- **분석 목표**:
  1. Atlas DevOS의 설계 아키텍처와 실제 구현 간의 정합성 검증
  2. Knowledge Layer(지식)와 Runtime Layer(실행) 간의 완전한 분리 구조 평가
  3. Priority Engine, Rule Engine, Review Engine의 자동화 효율성 및 확장성 분석
  4. Atlas 엔지니어링 원칙(ROI Gate, Evidence-First)의 이행 수준 및 개선 필요 항목 식별

---

## 2. 단계별 심층 분석 상세 계획

### Phase 1: 아키텍처 및 모듈 계층 구조 분석
- **분석 범위**: `core/` 하위 모듈 (`execution`, `rules`, `review`, `state`, `workflow`, `registry`)
- **주요 분석 항목**:
  - 모듈 간 단방향 의존성 유지 여부 검토
  - `agents/` 디렉터리 제거 이후 코어 모듈 내 잔재 의존성 유무 점검
  - 계층 구조(`ADR-002-layer-architecture.md`) 가이드라인 준수 상태 확인
- **분석 방법**:
  - `core/` 내 모든 Python 파일 대상 정적 분석 및 임포트 구조 추적
- **산출물**: `docs/analysis/PHASE1_ARCHITECTURE_ANALYSIS.md`

### Phase 2: 실행 런타임 및 상태 동기화 분석
- **분석 범위**: `tools/atlas_runner.py`, `ATLAS_STATE.json`, `GOAL_REGISTRY.json`, `projects/exelion/backlog.json`
- **주요 분석 항목**:
  - `atlas_runner.py start` 실행 시 `RuntimeContext` 수집 및 우선순위(`PriorityEngine`) 계산 정확도 평가
  - `ATLAS_STATE.json`과 프로젝트별 `backlog.json` 간 상태 동기화 및 락(Lock)/경합 관리 체계 평가
  - 환경(`DEV_WORK` vs `DEV_HOME`) 제약 조건 분리 및 ContextResolver 작동 방식 심층 분석
- **분석 방법**:
  - 상태 파일 구조 갭 분석 및 런타임 상태 전환 시뮬레이션
- **산출물**: `docs/analysis/PHASE2_RUNTIME_STATE_ANALYSIS.md`

### Phase 3: 룰 엔진 및 리뷰 평가 체계 분석
- **분석 범위**: `core/rules/` (`rule_engine.py`), `core/review/` (`review_engine.py`), `core/checklists/`
- **주요 분석 항목**:
  - Pre-flight 검증 룰(Collision, Export, UV, UE 등)의 커버리지 및 확장성 평가
  - Review Engine의 품질 점수화 산출 공식 및 스코어카드(`scorecard_Exelion_Arm.md`) 생성 로직 정밀도 평가
  - Rule $\rightarrow$ Review $\rightarrow$ Metrics 순차 흐름 준수 상태 및 자동화 피드백 루프 분석
- **분석 방법**:
  - 검증 시나리오별 Rule Pass/Fail 테스트 및 스코어 산출 알고리즘 검토
- **산출물**: `docs/analysis/PHASE3_RULE_REVIEW_ANALYSIS.md`

### Phase 4: 지식(Knowledge) - 런타임(Runtime) 경계 분석
- **분석 범위**: `docs/atlas/` 내 아키텍처 문서군, `docs/process/` 프로세스 문서군, `ATLAS_CONSTITUTION.md`
- **주요 분석 항목**:
  - "Runtime reads Knowledge only, Knowledge is not affected by Runtime" 원칙 준수 여부 점검
  - 문서 내 불필요한 중복/파편화 상태 분석 및 지식 베이스 단일 출처(Single Source of Truth) 유지 평가
- **분석 방법**:
  - 전체 문서 참조 관계 그래프 구성 및 상호 링크 정합성 검사
- **산출물**: `docs/analysis/PHASE4_KNOWLEDGE_BOUNDARY_ANALYSIS.md`

### Phase 5: Atlas 엔지니어링 원칙 및 ROI Gate 분석
- **분석 범위**: `AGENTS.md` (Atlas Engineering Principles 1~7), `core/workflow/bottleneck_analysis.md`
- **주요 분석 항목**:
  - 실제 개발 과정에서 2회 이상 반복되거나 30분 이상 단축이 검증된 작업만 자동화에 추가되었는지 ROI Gate 평가
  - 수동 개입이 빈번한 작업(Bottlenecks)을 식별하고 개선 우선순위 도출
- **분석 방법**:
  - 일일 운영 로그(`logs/`) 및 깃 커밋 이력 기반 작업 시간/병목 데이터 분석
- **산출물**: `docs/analysis/PHASE5_ROI_BOTTLENECK_ANALYSIS.md`

---

## 3. 종합 분석 마일스톤 및 향후 일정

| 단계 | 분석 내용 | 예상 기간 | 결과 보고서 |
| :--- | :--- | :--- | :--- |
| **Phase 1** | 모듈 및 아키텍처 계층 정적 분석 | 1일 | Phase 1 분석 리포트 |
| **Phase 2** | 런타임 실행기 및 상태 동기화 분석 | 1일 | Phase 2 분석 리포트 |
| **Phase 3** | 룰/리뷰 엔진 및 스코어카드 분석 | 1일 | Phase 3 분석 리포트 |
| **Phase 4** | 지식-런타임 경계 및 문서 정합성 분석 | 1일 | Phase 4 분석 리포트 |
| **Phase 5** | ROI Gate 및 병목 분석 / 최종 종합 보고 | 1일 | Atlas DevOS 종합 분석 보고서 |

---

## 4. 요약

본 분석 계획서는 Atlas DevOS 플랫폼 전반을 객관적이고 체계적으로 분석하기 위한 표준 이행 가이드라인입니다. 계획서 승인 후 정의된 Phase 1부터 순차적으로 분석을 진행합니다.

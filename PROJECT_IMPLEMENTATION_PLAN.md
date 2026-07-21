# 프로젝트 아틀라스(Atlas DevOS) 코어 플랫폼 구현 계획서 (Implementation Plan)

- **대상 범위**: Atlas DevOS 자체 플랫폼 코어 (`core/`, `tools/`, `docs/`, `ATLAS_STATE.json`)
- **제외 범위**: 서브프로젝트 (`projects/exelion`, `projects/coin-s` 등)
- **작성 일자**: 2026-07-21

---

## 1. 개요 및 구현 배경

Atlas DevOS는 서브프로젝트 운영체제이자 자율 개발 운영 플랫폼입니다. 서브프로젝트 독립성을 유지하면서 Atlas 플랫폼 자체의 완성도, 자동 검증 체계, 품질 평가 및 실행 유연성을 확보하기 위해 다음 5대 영역 구현을 추진합니다.

---

## 2. 5대 핵심 구현 영역

### 1) 플랫폼 전용 Pre-flight 룰 엔진 (`core/rules/platform_rules.py`)
- **구현 내용**: `ATLAS_STATE.json` 스키마 검증, `core/` 및 `tools/` Python 파이썬 코드 정적 검증, 마크다운 상대 링크의 유효성 검증 모듈 추가
- **적용 방식**: `rule_engine.py`가 활성 프로젝트 `Atlas` 선택 시 플랫폼 검증 모듈을 자동 수행

### 2) 플랫폼 전용 품질 리뷰 엔진 (`core/review/platform_review_engine.py`)
- **구현 내용**: 스키마 정합성(25점), 모듈 결합도(25점), 코드 품질(25점), 문서 링크 상태(25점)를 합산하여 100점 만점 코어 품질 평가
- **산출물**: [scorecard_Atlas_Platform.md](file:///mnt/d/Antigravity/Atlas/core/review/scorecard_Atlas_Platform.md) 마크다운 자동 생성

### 3) Atlas 자체 백로그 및 활성 라이프사이클 전환
- **구현 내용**:
  - `core/config/project_lifecycle.json` 내 `Atlas` 상태를 `active`로 변경
  - `core/execution/atlas_backlog.json`에 코어 태스크(`ATL-CORE-001`~`005`) 등록
  - `GOAL_REGISTRY.json`에 `ATL-GOAL-001` (Atlas DevOS Self-Platform Completeness) 등록

### 4) `tools/atlas_runner.py` 실행 경로 자동 등록 (`sys.path`)
- **구현 내용**: `atlas_runner.py` 시작 부분에 `sys.path.insert(0, repo_root)` 로직을 추가하여 외부 `PYTHONPATH=.` 환경변수 입력 없이도 터미널에서 즉시 실행 가능하도록 보강

### 5) 프로젝트 상태 문서 자동 동기화 (`docs/PROJECT_STATUS.md`)
- **구현 내용**: `atlas_runner.py finish` 수행 시 런타임 완료 태스크 및 상태 데이터를 기반으로 [docs/PROJECT_STATUS.md](file:///mnt/d/Antigravity/Atlas/docs/PROJECT_STATUS.md)를 자동 업데이트하는 파이프라인 연동

---

## 3. 세부 파일 변경 계획

```
[NEW]    core/rules/platform_rules.py             (DevOS 전용 검증 룰)
[NEW]    core/review/platform_review_engine.py    (DevOS 품질 리뷰 엔진)
[NEW]    tests/test_platform_rules.py            (플랫폼 룰 유닛 테스트)
[NEW]    tests/test_platform_review.py           (플랫폼 리뷰 유닛 테스트)
[MODIFY] core/config/project_lifecycle.json       (Atlas: active 전환)
[MODIFY] core/execution/atlas_backlog.json        (ATL-CORE-001~005 백로그 등록)
[MODIFY] GOAL_REGISTRY.json                       (ATL-GOAL-001 목표 등록)
[MODIFY] core/rules/rule_engine.py                (Atlas 프로젝트 검증 분기)
[MODIFY] core/review/review_engine.py            (Atlas 플랫폼 리뷰 분기)
[MODIFY] tools/atlas_runner.py                    (sys.path 자동주입 및 상태문서 자동 동기화)
```

---

## 4. 구현 검증 계획 (Verification Plan)

1. **단위 테스트**: `python3 -m unittest discover -s tests` 통과 검증
2. **Runner 실행 테스트**: `python3 tools/atlas_runner.py start` (환경변수 없이 단독 실행 확인)
3. **Review & Doc Sync 검증**: `python3 tools/atlas_runner.py finish` (Platform Scorecard 및 `PROJECT_STATUS.md` 자동 생성/동기화 확인)

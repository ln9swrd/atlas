# 055 Agent Context 및 문서표준지침

## 원칙
Atlas = 여러 프로젝트를 관리하는 DevOS. 각 프로젝트는 동일한 문서 규칙, Atlas는 전체 상태·규칙 관리.

## 프로젝트 공통 문서 템플릿
- README.md — 소개
- VISION.md — 왜 만드는가
- PROJECT_CHARTER.md — 목표/범위/제약
- ARCHITECTURE.md — 시스템 구조
- ROADMAP.md — 단계별 계획
- TASKS.md — 현재 작업
- DECISION_LOG.md — 결정 기록
- CHANGELOG.md — 변경 기록
- **AGENT_CONTEXT.md** — AI 작업 기억 (Current State, Rules, Known Issues, Next Priority, Forbidden Changes)

## 문서 역할 분리
- VISION → 인간 방향성
- PROJECT_CHARTER → 프로젝트 계약서
- ARCHITECTURE → 기술 구조
- TASKS → 현재 행동
- AGENT_CONTEXT → AI 작업 기억
- DECISION_LOG → 과거 판단 근거

## Atlas 철학
프로젝트를 관리한다 → 프로젝트는 자기 문서를 가진다 → AI Agent가 문서를 기준으로 작업한다.

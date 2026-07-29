# 048 ATLAS Project Brief 요약

## 핵심 구조 (정정된 기준선)
```
ATLAS (Stage / Control Layer)
  ├── SERA (Cloud AI — 사고·분석·판단)
  └── KRAKEN (Development Agent — 실행·코드·테스트)
        └── PROJECTS (EXCELION Forge, EXCELION Game)
```

## 역할 정의
- **ATLAS**: 전체 프로젝트 조율 Stage. 상태 관리, 논의 기록, 방향 결정, 결과 검토.
- **SERA**: 클라우드 AI 기반 사고·분석 파트너. 아키텍처 분석, 설계 검토, 전략 수립.
- **KRAKEN**: 실제 개발 수행 Agent. 코드 수정, 파일 생성, 테스트, Git 작업.

## 작업 흐름
ATLAS(자료 취합) → SERA(분석·판단) → KRAKEN(문서/코드 생성) → ATLAS 저장

## 문서화 원칙
- 대화 요약이 아니라 **결정된 사실 + 현재 상태**를 저장.
- 프로젝트별 지식 문서 구조 권장 (PROJECT_SUMMARY, ARCHITECTURE, DECISION_LOG, CURRENT_STATUS).
- 마스터가 임시 ATLAS 운영자 역할 수행 중 → 반드시 문서화 후 SERA 전달.

## SERA 전달용 Brief 형식
1. System Overview (ATLAS / SERA / KRAKEN)
2. Projects (목적, 현재 상태, 결정사항, 미해결 문제)
3. Architecture Decisions (ADR)
4. Questions for SERA

## 핵심 통찰
AI 시대 핵심 역할 = "무엇을 만들고 싶은지 명확히 하고, AI들이 제대로 움직이도록 방향을 잡는다".
코드보다 **AI와 함께 개발하는 운영 체계**가 우선.

# 047 Atlas Conversation Archive 구조화

## 핵심 원칙
대화 기록 = 단순 로그가 아닌 **설계 결정·프로젝트 지식·개발 히스토리 저장소**.
원문(증거) / 정리본(지식) / ADR(결정) 역할 분리.

## Atlas Knowledge System 4층 구조
1. **Raw Memory** — conversations/raw (대화 원본)
2. **Project Knowledge** — conversations/{project} (프로젝트별 정리)
3. **Engineering Knowledge** — architecture, decisions, lessons
4. **Permanent Decisions** — ADR (변경 불가능한 기준)

## 권장 docs 구조
```
Atlas/docs/
├─ architecture/ (system_overview, sera_forge_relationship, ai_provider_architecture)
├─ ADR/ (ADR-001~004)
├─ projects/ (sera, excelion-forge, excelion-game)
├─ conversations/ (INDEX + 프로젝트별 기록)
└─ knowledge/ (lessons_learned, known_failures, development_principles)
```

## 확정 ADR 후보
- **ADR-001**: Atlas = Root Repository (Sera / Forge / Game 상위)
- **ADR-002**: Sera = 독립 AI Development Platform 우선 개발, Forge는 Sera 위에서 개발
- **ADR-003**: Forge 자체 AI 개발 중단 → Sera 기반 제작 시스템으로 방향 변경
- **ADR-004**: Hybrid AI Provider Architecture (Local LLM + Cloud AI, 모델 교체 가능)

## 관계 계층
Atlas → Sera → EXCELION Forge → EXCELION Game

## Lessons Learned 핵심 원칙
1. AI는 기억하지 않는다. 문서가 기억한다.
2. 실행되지 않은 코드는 완료가 아니다.
3. 결정은 ADR로 남긴다.
4. 실패 경험은 다음 개발의 자산이다.
5. Context 관리가 AI 개발의 핵심이다.

## AI Agent 작업 전 필수 순서
1. ADR 확인
2. Architecture 확인
3. Project README 확인
4. Conversation History 확인

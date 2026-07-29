# Project Documentation Standard (docs 표준화)

## 구조 원칙
- **Atlas** = 운영체제 (전체 기준점)
- **projects/** = 앱 (독립 실행 가능)
- **docs/** = 각 앱의 설계 문서

## 문서 규칙
- 파일명: 영어 (대문자 Snake Case, 예: GAME_DESIGN.md)
- 본문: 한국어 (기술 용어는 영어 병기 가능)
- 형식: Markdown
- 변경사항: CHANGELOG 기록

## 모든 프로젝트 필수 문서
| 파일 | 역할 |
|------|------|
| README.md | 개요, 상태, 실행 방법, 관련 프로젝트 |
| VISION.md | 존재 이유, 해결 문제, 장기 목표 |
| ROADMAP.md | 현재 단계, 다음 목표, 완료 조건 |
| CHANGELOG.md | 날짜·변경 내용·주요 결정 |

## 프로젝트별 확장 문서 예시

### excelion (게임)
VISION, GAME_DESIGN, WORLD_SETTING, CHARACTER_DESIGN, GAMEPLAY_SYSTEM, TECH_ARCHITECTURE, DEVELOPMENT_ROADMAP, ASSET_PIPELINE, CHANGELOG

### excelion-forge (제작 도구)
VISION, PURPOSE, WORKFLOW, BLENDER_PIPELINE, CHARACTER_GENERATOR, PARAMETER_SYSTEM, MODEL_RULES, ROADMAP

### coin-s (분석)
VISION, ARCHITECTURE, DATA_MODEL, STRATEGY, TRADING_RULES, BACKTEST_GUIDE, API_REFERENCE, ROADMAP

## README 연동 정보 (필수 포함)
```
Parent System: Atlas DevOS
Project Type: Game / Tool / Analysis
Related Agents: Marie, Sera, Forge
Status: Development
```

## Atlas 역할
프로젝트 등록 · 상태·목표 관리 · Agent 연결 · 개발 흐름 관리.
프로젝트 내부 구현은 각 프로젝트가 담당.

## 다음 단계
DOCUMENT_INIT_TASK로 Agent가 docs 폴더 생성·초안 작성을 수행하도록 지시.

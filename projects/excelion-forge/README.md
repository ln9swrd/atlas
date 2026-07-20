# EXCELION Forge

EXCELION Forge는 EXCELION 프로젝트의 3D 액션 게임 개발을 위한 블렌더 애드온입니다.

## 프로젝트 구조

```
excelion-forge/
├── src/
│   └── forge/
│       ├── __init__.py
│       ├── main.py              # 메인 진입점
│       ├── core/
│       │   ├── __init__.py
│       │   ├── factory.py       # 팩토리 클래스 (컴포넌트 생성)
│       │   ├── runtime.py       # 런타임 환경 관리
│       │   ├── contracts.py     # 실행 계약 정의
│       │   ├── registry.py      # 실행자 레지스트리
│       │   └── executors/       # 실행자 모듈
│       │       └── python_executor.py  # 파이썬 실행자
├── tests/
├── pyproject.toml               # 프로젝트 설정 및 의존성
└── README.md                    # 이 파일
```

## 핵심 컴포넌트

1. **main.py**: EXCELION Forge의 진입점입니다.
   - Forge 시스템 초기화
   - 팩토리 및 런타임 구성

2. **factory.py**: 팩토리 클래스로, 모든 핵심 컴포넌트를 생성하고 초기화합니다.
   - `initialize()` 메서드로 컴포넌트 초기화
   - `get_component()` 메서드로 컴포넌트 접근

3. **runtime.py**: 런타임 환경을 관리합니다.
   - 실행 환경 초기화
   - 작업 실행 메서드 (`execute`)

4. **contracts.py**: 실행 계약을 정의합니다.
   - `ExecutionContract`: 실행 계약 프로토콜
   - `ComponentContract`: 컴포넌트 계약 프로토콜

5. **registry.py**: 실행자 레지스트리를 관리합니다.
   - 등록된 실행자 접근
   - 실행자 등록/조회 기능

6. **executors/python_executor.py**: 파이썬 코드 실행자입니다.
   - `execute()` 메서드로 작업 실행
   - 실행 결과 반환

## 개발 원칙

EXCELION Forge는 다음과 같은 설계 원칙을 따릅니다:

1. 1인 개발을 기준으로 설계한다.
2. 메카가 게임의 주인공이다.
3. Mission-Based 3D Action.
4. 보스전이 핵심 콘텐츠이다.
5. 진화는 최고의 보상이다.
6. 연출은 시스템만큼 중요하다.
7. 개발 범위를 통제한다.
8. 반복 가능한 제작 방식을 만든다.
9. IP를 만든다.
10. 완성하는 것이 가장 중요하다.

## EXCELION Development Model

EXCELION 개발은 다음과 같은 계층으로 구성된다.

```text
MASTER
최종 방향 / 의사결정
        │
        ▼
MARIE
아키텍처 / 검토
        │
        ▼
SERA
기획 / 설계 / 계획
        │
        ▼
ATLAS
프로젝트 운영 / 작업 조정 / 실행 관리
        │
        ├──────────────────┐
        ▼                  ▼
FORGE              IMPLEMENTATION
3D 에셋 제작        게임 코드 / 시스템 구현
        │                  │
        └────────┬─────────┘
                 ▼
              UNREAL
          게임 통합 / 실행
                 │
                 ▼
           VALIDATION
           검증 / 테스트
                 │
                 ▼
              BUILD
           패키징 / 컴파일
                 │
                 ▼
              STEAM
              배포
```

## 버전 정보

- 현재 버전: 0.2.0
- 마지막 커밋: 15de899 (현재 작업 저장)
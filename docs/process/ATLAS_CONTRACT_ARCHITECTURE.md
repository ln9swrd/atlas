# Atlas Contract Architecture

## 목적

Atlas는 개별 기능 구현보다 먼저 Contract System을 명확히 정의하는 방식으로 발전해야 합니다.

이 문서는 Atlas가 향후 확장될 때 공통적으로 따라야 할 계약 체계를 정리합니다.

## 1. Contract System 개요

Atlas는 다음 순서로 개발되어야 합니다.

```text
Specification
  -> Contract
  -> Interface
  -> Implementation
  -> Test
  -> Audit
```

이 순서는 Atlas의 기본 개발 원칙으로 사용합니다.

## 2. Contract 카테고리

Atlas의 핵심 Contract는 다음과 같습니다.

- Runtime Contract
- SDK Contract
- Decision Contract
- Plugin Contract
- Connector Contract
- Knowledge Contract
- Memory Contract
- Event Contract
- Workflow Contract

## 3. Contract Registry 개념

각 Contract는 개별 구현체가 아니라 Contract Registry 안에서 관리됩니다.

```text
Atlas
  -> Contract Registry
      -> Runtime Contract
      -> SDK Contract
      -> Decision Contract
      -> Plugin Contract
      -> Connector Contract
      -> Knowledge Contract
      -> Memory Contract
      -> Event Contract
      -> Workflow Contract
```

이 구조를 통해 Forge, Mission Editor, Sound Studio 등 다양한 애플리케이션이 동일한 계약 체계를 따라가게 할 수 있습니다.

## 4. Contract 의존성 원칙

Contract는 다음 원칙을 따라 설계합니다.

- 상위 계층은 하위 Contract에 의존할 수 있다.
- 하위 계층은 상위 계층에 의존하지 않는다.
- 각 Contract는 독립적으로 검증 가능해야 한다.
- 구현체는 Contract를 준수해야 한다.

## 5. Contract Versioning 정책

각 Contract는 버전 관리가 필요합니다.

### Version 형식

```text
<Area> Contract v<major>.<minor>
```

예:
- Decision Contract v1.0
- Decision Contract v1.1
- Decision Contract v2.0

### 변경 정책

- Non-breaking change: 기존 소비자와 호환되는 변경
- Breaking change: 기존 인터페이스를 변경하는 변경

### 정책

- Minor 업데이트는 Non-breaking으로 처리한다.
- Major 업데이트는 Breaking change로 취급하고, migration plan을 반드시 동반한다.

## 6. Contract Lifecycle

각 Contract는 다음 단계로 관리합니다.

1. Specification
2. Draft Contract
3. Review
4. Stable Contract
5. Deprecation

## 7. 구현 순서

Atlas는 다음 순서로 Contract 기반 개발을 진행합니다.

1. Specification 작성
2. Contract 정의
3. Interface 정의
4. Reference Implementation 작성
5. Tests 작성
6. Audit/Verification 수행

## 8. 기대 효과

이 구조를 확립하면 Atlas는 다음과 같은 장점을 얻습니다.

- AI Runtime이 바뀌어도 Contract는 유지된다.
- Forge, SERA, Plugin 등 다양한 애플리케이션이 동일한 규칙을 따른다.
- Contract 기반으로 테스트와 감사가 쉬워진다.
- 구현체가 바뀌어도 외부 소비자와의 호환성을 유지하기 쉽다.

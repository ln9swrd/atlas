# Excelion Multi-Agent Operating Model

기록일: 2026-08-17

Excelion은 구현과 검증을 분리하는 멀티 에이전트 운영 모델을 기본으로 한다.

## 역할 요약

| Agent | Role | 핵심 책임 |
|-------|------|-----------|
| Cline | IMPLEMENTER | 코드 조사·승인된 C++ 구현·Build 검증·원인 분석·결과 보고 |
| Antigravity | VERIFIER | Editor/PIE/Runtime 검증·실제 입력 검증·독립 검증·로그 수집 |
| Copilot | REVIEWER | C++ 코드 리뷰·API/구조 검토·부작용 분석·독립 의견 |
| Git Agent | GIT | status/diff·staging·commit·기록·handoff 문서 관리 |

상세 역할은 `roles/` 폴더를 참조한다.

## 핵심 운영 원칙

구현과 검증을 분리한다.

```text
Cline
  ↓
IMPLEMENT
  ↓
BUILD
  ↓
Handoff
  ↓
Antigravity
  ↓
PIE / Runtime
  ↓
FUNCTION VERIFIED
```

구현 Agent는 최종 기능 VERIFIED를 단독 판정하지 않는다.

### 검증 단계 구분

```text
BUILD PASS
= 컴파일/빌드 성공

RUNTIME VERIFIED
= 실행 환경에서 동작 확인

FUNCTION VERIFIED
= 실제 기능 입력/결과 확인

FINAL VERIFIED
= 독립 검증까지 완료
```

## WASD 사건에서 얻은 교훈

- C++ Build는 성공했으나 기능은 정상 동작하지 않았음.
- 초기 PIE 자동화 검증도 실제 물리 입력/이동 방향을 충분히 검증하지 못해 PASS가 잘못 판정됨.
- 이후 Runtime 로그를 통해 Legacy Input 중복 및 Enhanced Input 설정 문제를 단계적으로 발견함.
- 따라서 **Build PASS ≠ Game Function PASS**임을 명확히 확인함.

향후 기능 검증은 가능한 경우 실제 Runtime evidence를 요구한다.

## Handoff 상태 개념

장기 작업에서 Agent 간 전달 상태를 남긴다.

```text
IMPLEMENTATION
BUILD
RUNTIME
FUNCTION
REVIEW
FINAL
```

각 단계에서 다음을 기록할 수 있어야 한다.

- 완료
- 진행 중
- 보류
- 발견된 문제
- Master 결정 필요
- 다음 작업
- 검증 필요

## 공통 제한

- 승인 없이 Canon / Blueprint / Asset / Config / 프로젝트 구조를 변경하지 않는다.
- Push는 Master의 별도 승인 없이는 수행하지 않는다.
- 단순 Asset 존재나 코드 존재만으로 기능 PASS를 판정하지 않는다.

# 016. Atlas 프로젝트 대화 정리 (고수준 현황)

> 기간: 2026-07-16 ~ 2026-07-21 기준 요약

---

## 1. 프로젝트 목표

Atlas = AI가 **Evidence에 기반**하여 판단·작업하는 Runtime 및 Knowledge Platform.  
장기적으로 **개인의 디지털 작업 기반(Atlas Base)** 구축.

### 핵심 방향
- Knowledge와 Runtime의 완전한 분리
- Evidence-Grounded Verification
- Rule 기반 감사(Audit)
- AI Agent Runtime

---

## 2. 아키텍처 요약

| 계층 | 역할 |
|------|------|
| **Runtime** | MVP, Verification Engine, Auditor, Rule Engine – 추측 금지, Evidence 기반, Fail Closed |
| **Knowledge** | 문서·규칙·설계·Sprint·ADR·Evidence – Runtime은 소비만 |
| **Verification** | Claim 검증, Evidence 수집, Rule 평가, 감사 로그 – No Evidence → No Decision |
| **Auditor** | Jurisdiction Validation, Claim Evaluation, Audit Report |

---

## 3. Sprint 하이라이트

| Sprint | 내용 |
|--------|------|
| **019** | Jurisdiction Validation – Specification 없으면 Abort |
| **021** | Knowledge ↔ Runtime 완전 분리 확정 |

---

## 4. 개발 환경

Windows · WSL2 · Docker · VS Code · Continue · Cline · Ollama (Qwen3 Coder)

### 이슈 요약
- **Continue**: 반복 실패, Context 이상, 설정 손상 의심 → 재설치·`.continue` 구조 검토
- **Cline**: Subagents / Native Tool Call / Parallel Tool Calling – 디버깅 시 비활성화
- **Ollama**: model not found, serve timeout, API 연결, GPU·환경변수 확인
- **WSL/Docker**: 계층 복잡하나 AI 생태계 사실상 표준

---

## 5. 핵심 원칙 (8)

1. Evidence First  
2. Fail Closed  
3. Runtime / Knowledge Separation  
4. Auditability  
5. Rule Driven  
6. No Hallucination  
7. Documentation First  
8. Long-term Maintainability  

---

## 6. 당시 상태

**진행 중**  
Runtime 구조 정리 · Verification Engine 개선 · 문서 재편 · 개발환경 안정화 · AI Agent 설정 최적화

**미완료**  
Runtime 완성 · Forge 구현 · SERA 구조 확정 · Atlas Base 구축

**장기**  
Atlas Runtime/Knowledge 완성 · AI Agent 생태계 · 개인 디지털 작업 플랫폼 · 수익·지속 가능성

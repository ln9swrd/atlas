# 018. Cline / Qwen 안정 운용 및 Phase 전환 (Audit → Core)

---

## 1. AI 역할 분담 (운영 패턴)

| 역할 | 담당 |
|------|------|
| **ChatGPT** | 아키텍처 설계, 시스템 일관성, 문서화, 요구사항 정제 |
| **Claude (클라겐)** | 실제 구현·코드 작성·리팩터링·구현 검증 |
| **로컬 LLM (Qwen 등)** | 반복 작업, 빠른 실험, 오프라인 개발 |

하나의 AI에 모든 것을 맡기지 않고 역할별로 활용.

---

## 2. 계층 책임 (성숙된 그림)

| 계층 | 책임 |
|------|------|
| **Runtime** | 실행 |
| **Core** | 공통 기반 |
| **Forge** | 생성·조립 (분석 → 설계 → 문서/코드/테스트 생성 → 검증 → 패키징) |
| **Auditor/Verify** | 검증 |

Forge가 완성되면 Atlas는 "AI를 하나 만드는 것"이 아니라 **AI가 새 프로젝트를 일관된 절차로 생산하는 플랫폼**이 된다.

---

## 3. Git 동기화 기본과 한계

```
PC A: add → commit → push
PC B: pull
```

코드는 동기화되지만 다음은 Git 밖:
- `.env`, `venv`, `node_modules`
- VS Code 사용자 설정
- Continue / Cline 내부 데이터
- Docker 이미지, Ollama 모델

→ 개발 환경 재현은 `settings.json` / `.vscode/` / `devcontainer` / `docker-compose` 등을 저장소에 포함하거나 별도 관리.

---

## 4. Phase 전환

### Phase 1 — Audit (완료)
- 저장소 상태 확인, 구현 검증, UNKNOWN 식별, 문서↔실제 비교
- 결과: 기준선 문서 · 감사 프로토콜 · 검증 방식 · AI 작업 흐름 한계 확인
- 발견: Context 지속성 부족, Cline은 실행 계층이지 프로젝트 기억 계층이 아님

### Phase 2 — Atlas Core Development (시작)

**ATLAS-CORE-001: Context Management Foundation**

목표: Atlas가 프로젝트 상태를 기억할 수 있는 기반.

```
project_context  (architecture, decisions, constraints, current_state, baseline)
task_context     (objective, investigation, changes, verification, result)
audit_record     (Evidence → Decision → Future Task 연결)
```

아직 하지 않을 것: Cline 대체 · 자동 코드 수정 · AI Router · Agent 실행 엔진 · 거대 프레임워크화.

---

## 5. Agent Architecture 상태 분류

`ATLAS_AGENT_ARCHITECTURE_001.md`:
- **EXIST** / **IMPLEMENTED** / **PROPOSED** 로 분리
- 존재하는 것과 제안 사항을 혼동하지 않음

역할 분리:
| 주체 | 역할 |
|------|------|
| **Atlas** | Context · Task · Decision · Audit · AI Provider 관리 |
| **Kraken** | Local 실행 AI, 코드 조사·구현 지원 |
| **SERA** | Cloud AI, 고급 분석·설계 검토 |
| **Cline** | Execution Tool Layer (파일/터미널/Tool 실행) |

---

## 6. 대화방 전환 권장

- 이전 방: **Atlas Audit History** (감사·구조 분석 기록)
- 새 방: **Atlas Core Development Log** (구현 중심)

새 대화 시작 시 붙일 요약: 현재 상태(감사·Architecture 문서 완료) + 핵심 결정(역할 분리) + 다음 목표(ATLAS-CORE-001 Context Foundation) + 주의(EXIST/IMPLEMENTED/PROPOSED 유지, 대규모 구현 금지).

> 수확: "Qwen을 더 강하게"가 아니라 **AI가 바뀌어도 유지되는 작업 기억 계층이 필요하다**는 것을 실제 과정으로 확인한 것.

# Original Conversations — 단계적 분석 보고서

- **대상**: `obsidian/Archive/Original Conversations/` 내 `0.md` ~ `86.md` (87개)
- **범위**: MD 파일만 (obsidian.zip 제외)
- **분석일**: 2026-07-29
- **방법**: Phase 0 → 5 단계적 분석

---

## Phase 0 — 인벤토리·중복 식별

| 항목 | 값 |
|------|-----|
| MD 파일 수 | 87 (`0.md` ~ `86.md`) |
| Unique (Exact 중복 제거 시) | ≈ 82 |
| 최대 파일 | `5.md` (56,111 bytes) |
| 최소 파일 | `45.md` (805 bytes) |

### Exact Duplicate (SHA 동일)

| 그룹 | 파일 | 크기 |
|------|------|------|
| D1 | 55.md = 61.md | 9,544 |
| D2 | 56.md = 62.md | 2,774 |
| D3 | 57.md = 63.md | 10,593 |
| D4 | 59.md = 65.md | 4,374 |
| D5 | 60.md = 66.md | 5,461 |

### Near-Duplicate

- `58.md` ≈ `64.md` (크기 15,890 vs 15,883, 끝부분 truncation 차이)

---

## Phase 1 — 구조·형식 분석

### 형식 유형

| 유형 | 특징 | 대표 |
|------|------|------|
| A. 날짜 헤더형 | 첫 줄 날짜·시간 | 0, 45 |
| B. 중간 대화 이어형 | 날짜 없이 시작 | 1, 10, 20 |
| C. 설계 문서 혼합형 | 대화 내 긴 MD 설계안 | 5, 58, 64 |
| D. 도구 실행 로그 혼합형 | Read/Replacing/Ran 등 | 0, 1 |
| E. 짧은 아이디어형 | 1~2턴 | 34, 45 |
| F. 이미지 참조형 | 이미지 URL/첨부 | 45 |

- 호칭: **마스터** (사용자), **마리** (AI)
- 언어: 한국어 본문 + 영어 기술 용어
- 날짜 헤더: 소수 → 번호 순서 = 완전 시간순은 아님

---

## Phase 2 — 구간별 주제·내용 분류

| 구간 | 파일 | 주요 주제 | Atlas 관련도 |
|------|------|-----------|--------------|
| A 0~9 | 0,1,5 등 | 창설, DevOS, Environment, Runner, VERIFY | High |
| B 10~19 | 10,15 등 | WSL/Cline/Ollama, Tool Call 디버깅 | High~Mid |
| C 20~29 | 20,25 등 | 문서 체계, Self-Improvement, Enterprise 설계 | High |
| D 30~39 | 34 등 | Coin-S 매매 패턴 | Low~Mid |
| E 40~49 | 40,45 등 | Antigravity, 프롬프트, Gelgoog | Mid/Low |
| F 50~59 | 50,58 등 | Forge 하이브리드, docs 표준 | High |
| G 60~69 | 64 등 | F와 중복 | High (중복) |
| H 70~79 | 70 등 | .blend Git/LFS, Blender AI 조사 | High~Mid |
| I 80~86 | 80,86 등 | SERA/Kraken/Projects, Obsidian | High |

### 주제 클러스터

1. Atlas Core / DevOS
2. 검증·자기개선 (VERIFY / Sprint)
3. 로컬 AI 인프라
4. Forge / Blender 파이프라인
5. 프로젝트 문서·지식 관리
6. 하위 프로젝트 (Exelion, Coin-S, PrintGuard 등)
7. 비Atlas·잡담

관련도 추정: High ≈55% · Mid ≈25% · Low ≈20%

---

## Phase 3 — 핵심 지식 추출

### Decision Log (후보)

| ID | 결정 |
|----|------|
| D01 | Claim ≠ Evidence (Evidence-First) |
| D02 | Build the system that builds the game |
| D03 | Knowledge Layer ↔ Runtime Layer 분리 |
| D04 | Environment 분리·등록 (Registry) |
| D05 | 기능 추가보다 실제 운영 시나리오 검증 우선 |
| D06 | 가상 Task보다 실제 Exelion Task로 운영 |
| D07 | Cline 문제 추적 중 Subagents / Native / Parallel Tool Call OFF |
| D08 | 로컬 AI는 WSL 내부 배치 권장 |
| D09 | Forge = Core(뇌) + Blender Add-on(손발) 하이브리드 |
| D10 | 프로젝트 docs: 파일명 영어, 본문 한국어, 필수 VISION/ROADMAP/CHANGELOG |
| D11 | SERA = 프로젝트 목록이 아니라 Atlas 지능 계층 |
| D12 | Kraken = 실행·자동화 계층 |
| D13 | .blend는 Git, 대용량은 LFS, .blend1 등은 gitignore |
| D14 | 급할수록 돌아간다 — 제작 도구·파이프라인 우선 |
| D15 | 대화 기록 → 문서 → 프로젝트 자산 |

### Concept Glossary (후보)

Atlas, Knowledge Layer, Runtime Layer / RuntimeContext, Evidence-First / VERIFY, Priority Engine, Runner, Environment Registry, Forge, SERA, Kraken, Exelion, Coin-S, PrintGuard, Self-Improvement (SPRINT-009), Enterprise Intelligence (SPRINT-029), PROJECT_DOC_STANDARD, Antigravity

### Open Questions (후보)

| ID | 질문 |
|----|------|
| Q01 | VERIFY 실제 코드 구현 범위는? |
| Q02 | SPRINT-009~029 설계의 구현·폐기·보관 상태는? |
| Q03 | SERA / Kraken 코드·디렉터리 경계는? |
| Q04 | Forge Phase 1→2 전환 기준은? |
| Q05 | Coin-S의 Atlas 연동 수준은? |
| Q06 | PrintGuard MVP 범위는? |
| Q07 | Named Conversations / Core 승격 기준은? |
| Q08 | 중복 아카이브 정책(유지/삭제/링크)은? |
| Q09 | 날짜 기반 타임라인 재구성이 필요한가? |
| Q10 | 로컬 LLM vs Cloud(SERA) 역할 분담 규칙은? |

---

## Phase 4 — 가치·우선순위 평가

### 구간 종합

| 구간 | 우선순위 |
|------|----------|
| A, C(선별), F, I | **P1** |
| B, H | **P2** |
| D, E | **P3** |
| G (중복) | **P4** |

### Core 승격 후보

| 등급 | 파일 |
|------|------|
| Core | 0, 1, 5, 50, 58, 80, 86 |
| 선별 Core | 20, 25 |
| 참고 | 10, 15, 70 |
| 중복 정리 | 55=61, 56=62, 57=63, 59=65, 60=66, 64≈58 |

---

## Phase 5 — 종합·후속 제안

### 전체 흐름

```
창설·원칙 (A) → 인프라 안정화 (B) → 설계 확장 (C)
  → 부수·잡담 (D~E) → Forge·문서 표준 (F/G)
  → 에셋·우회 전략 (H) → 계층·현황 정리 (I)
```

### 권장 액션

**즉시**
1. Exact/Near 중복 정책 적용 (낮은 번호 1본 유지)
2. 본 보고서 및 Core 목록을 인덱스에 기록

**단기**
3. Decision Log → `docs/DECISIONS.md` (또는 ADR)
4. Concept Glossary → `docs/GLOSSARY.md`
5. Core 파일 → Named Conversations 또는 Core 문서로 승격·요약

**중기**
6. SERA / Kraken / Projects 계층을 디렉터리·README에 반영
7. Forge 하이브리드를 `excelion-forge/docs`에 고정
8. Open Questions를 Task/Issue로 등록

**선택**
9. C 구간 SPRINT 문서는 실행 범위 확정 후 선별 유지
10. 날짜 헤더 파일로 대략 타임라인 재구성

---

## 메타

- 본 문서는 Original Conversations MD에 대한 **단계적 분석만** 반영한다.
- 저장소 다른 경로의 코드 구현 여부·최신성은 검증하지 않았다.
- Decision / Concept / Open Questions는 샘플·구간 스캔 기준 **후보**이며, 전수 정독 후 확정하는 것을 권장한다.

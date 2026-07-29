# Atlas Git Rebuild Plan

> **문서만. 프로그램 개발 및 수정 금지.**
>
> 작성일: 2026-07-29  
> 저장소: `ln9swrd/atlas`  
> 목적: 세 가지 고정 요구를 기준으로 Git 위에 Atlas 지식·상태·스펙을 다시 앉힌다.

---

## 0. 고정 요구사항 (재구축의 헌장)

| # | 요구 | 의미 (코드 없이) |
|---|------|------------------|
| **1** | VS Code + **로컬 LLM** 연결 익스텐션 제공 | Atlas의 “작업 창구”는 IDE 확장. 실행 모델은 로컬(Ollama 등). 클라우드 AI는 선택·보조 |
| **2** | **Git으로 상태·컨텍스트 참조** | 진행·결정·현재 작업은 대화창이 아니라 **저장소 문서/메타**가 단일 출처 |
| **3** | **코드 전체 인식** + **화면·이미지 인식** / **카메라 = 0** | Perception: Code → Runtime/로그 → Screen → Image. 카메라·실세계 영상은 범위 밖 |

- **금지**: 구현, 리팩터, 기능 추가 코딩.
- **허용**: 폴더 이동 계획, 문서 역할 정의, 브랜치/커밋 전략, “무엇을 공식으로 남길지” 목록.

---

## 1. 재구축 목표 한 줄

> **Git = Atlas의 기억·상태·컨텍스트 OS**  
> **VS Code 확장(계획상) = 그 기억에 붙는 로컬 LLM 작업 창구**  
> **인식 범위 = 저장소 코드 + 화면/이미지 산출물 (카메라 제외)**

---

## 2. 목표 저장소 골격 (문서·지식만)

```
atlas/                          # 루트 = Atlas DevOS 지식 본체
├── README.md                   # 진입점: 무엇/왜/3요구/디렉터리 지도
├── AGENTS.md 또는 AI_CONTEXT.md # 에이전트·로컬 LLM 작업 규칙 (읽기 전용 기준)
│
├── docs/
│   ├── 00_VISION/              # 비전, 공존, “system that builds the game”
│   ├── 01_CORE/                # Knowledge↔Runtime, Constitution, Evidence
│   ├── 02_CONTEXT_STATE/       # Git으로 참조할 상태·컨텍스트 스키마 (문서)
│   ├── 03_PERCEPTION/          # Code/Screen/Image 인식 범위 (카메라 제외 명시)
│   ├── 04_IDE_EXTENSION/       # VS Code + 로컬 LLM 확장 **스펙만** (구현 X)
│   ├── 05_AGENTS/              # SERA / Kraken / Cline 역할
│   ├── 06_OPERATIONS/          # start/next/end, 일일 루프, 문서 갱신 절차
│   ├── 07_ROADMAP/             # Alpha scope, 재구축 단계 (본 문서 위치)
│   └── adr/                    # ADR-001~ 확정 결정만
│
├── state/                      # Git이 추적하는 “현재” (텍스트/JSON 문서)
│   ├── CURRENT_STATE.md
│   ├── PROJECT_MAP.md
│   ├── TASK_MAP.md 또는 backlog 요약
│   └── CONTEXT_INDEX.md        # “지금 읽을 문서 목록” (토큰 절감용 지도)
│
├── projects/                   # 앱 단위 (문서만 우선)
│   ├── excelion/docs/
│   ├── excelion-forge/docs/
│   ├── printguard/docs/
│   └── …
│
├── archive/                    # 과거·대화 요약·중복·코인 등
│   ├── summary/                # 기존 000~086 통째 이동
│   ├── recovered/
│   └── conversations/
│
└── (legacy 코드 폴더)          # core/, src/ 등은 “스냅샷”으로만 표기, 이번 계획에서 수정 금지
```

원칙: **살아 있는 기준은 `docs/` + `state/`**, 역사는 `archive/`.

---

## 3. 요구사항 → 문서 산출물 매핑

### 요구 1 — VS Code + 로컬 LLM 확장

| 산출물 (문서) | 내용 |
|---------------|------|
| `docs/04_IDE_EXTENSION/SPEC.md` | 확장의 **역할**: 로컬 LLM 연결, Atlas `state/`·`docs/` 읽기, 작업 지시 템플릿 |
| `docs/04_IDE_EXTENSION/NON_GOALS.md` | 구현하지 않을 것: 카메라, 클라우드 강제, Atlas Core 대체 |
| `docs/04_IDE_EXTENSION/CONTEXT_LOADING.md` | Git에서 무엇을 열어 LLM에 넣을지 (`CONTEXT_INDEX.md` 기반) |
| `AGENTS.md` | 로컬 LLM/에이전트 공통 규칙 (Evidence First, 범위 작게 등) |

이번 단계에서는 **스펙·경계만** Git에 고정. 확장 코드 작성은 계획 밖.

### 요구 2 — Git으로 상태·컨텍스트

| 산출물 | 내용 |
|--------|------|
| `state/CURRENT_STATE.md` | 지금 단계, 막힌 점, 다음 한 가지 |
| `state/TASK_MAP.md` | 진행/대기/완료 (또는 projects별 요약 링크) |
| `state/CONTEXT_INDEX.md` | “이 작업 시 읽을 파일 목록” — 대화창 대신 Git이 컨텍스트 |
| `docs/02_CONTEXT_STATE/SCHEMA.md` | 필드 정의 (status, environment, estimate 개념을 **문서 수준**으로) |
| `docs/06_OPERATIONS/DAILY_LOOP.md` | 작업 전후: state 갱신 → commit 메시지 규칙 |
| `docs/adr/` | 왜 이렇게 했는지 (변경 불가에 가까운 결정) |

운영 규칙(문서):

```
작업 시작 → state/CONTEXT_INDEX + CURRENT_STATE 읽기
작업 중   → (구현은 하지 않음; 계획 단계에서는 문서만)
작업 끝   → CURRENT_STATE / TASK_MAP 갱신 → git commit
```

### 요구 3 — 코드·화면·이미지 인식 / 카메라 0

| 산출물 | 내용 |
|--------|------|
| `docs/03_PERCEPTION/SCOPE.md` | **포함**: 저장소 트리, 파일 내용, 터미널/로그, 스크린샷, 디자인·메쉬 이미지. **제외**: 카메라, 실시간 웹캠, 실세계 영상 스트림 |
| `docs/03_PERCEPTION/LAYERS.md` | Code Vision → Runtime/로그 → Screen → Image |
| `docs/03_PERCEPTION/NON_GOALS.md` | 카메라 = 0 명시 |

“인식”을 이번 재구축에서 의미하는 것 = **Git에 올라온 코드·산출물·스크린샷을 문서/인덱스로 참조 가능하게 정리**하는 것. 비전 모델 구현은 금지.

---

## 4. 단계별 재구축 계획 (개발 없이)

### Phase A — 동결·백업

1. `main`에서 태그: `pre-rebuild-atlas-docs`
2. 브랜치: `docs/rebuild-structure`
3. 코드·기존 경로 **수정 없이** 복사/이동만 할 목록 작성

### Phase B — Archive 분리

1. `obsidian/Archive/summary` (000~086) → `archive/summary/`
2. `*_RECOVERED*`, 중복 061~066, 코인·주식 축 → `archive/` 하위
3. 커밋 예: `chore: isolate conversation summaries into archive/`

### Phase C — 살아 있는 docs 골격

1. `docs/00`~`07`, `docs/adr` 폴더 생성
2. summary·기존 docs에서 **공식 1본만** 골라 배치 (이동 또는 짧은 인덱스 + 링크)
   - 비전: 000, 038, 020
   - Core: 005, 006, 007, Constitution
   - Context/State: 013, 019, 047, 052, 055, 069
   - Perception: 037 + 카메라 제외 문구
   - IDE/로컬 LLM: 003, 018, 039, 040, 079 → 스펙 문서로 재작성(복붙 요약 수준, 신규 코드 없음)
   - Agents: 048, 080, 085
   - Operations: 001, 002, 016
   - Roadmap/Alpha: 026, 027, 081
3. ADR 내용을 `docs/adr/`에 **결정만** 남기기 (구현 상태 주장과 코드 검증은 이번 범위에서 재검증하지 않음 — 문서상 “설계 결정”으로 표기)

### Phase D — state/ 도입 (Git 컨텍스트의 심장)

1. `CURRENT_STATE.md`, `CONTEXT_INDEX.md`, `TASK_MAP.md`, `PROJECT_MAP.md` 초안
2. README에 “작업 전 이 파일들을 본다” 명시
3. 커밋: `docs: introduce git-tracked state and context index`

### Phase E — 3요구를 README에 헌장으로 고정

README 상단:

- Atlas가 제공할 것: (1) VS Code+로컬 LLM 확장 **계획/스펙** (2) Git 기반 상태·컨텍스트 (3) 코드·화면·이미지 인식 범위 / 카메라 제외
- 지금 저장소 역할: **지식·상태·스펙의 단일 출처**
- 하지 않는 것: 이 단계에서 프로그램 개발·수정

### Phase F — 병합·태그

1. 리뷰 후 `main` 병합
2. 태그: `atlas-docs-rebuild-v1`
3. (선택) 이후 구현 브랜치는 `feat/vscode-extension` 등으로 **분리** — 지금 계획에 코드 없음

---

## 5. 커밋 단위 제안 (이력 깨끗하게)

1. `chore: tag and branch for docs rebuild`
2. `chore: move summary and recovered materials to archive/`
3. `docs: create docs/ skeleton 00–07 and adr/`
4. `docs: place canonical vision/core/context documents`
5. `docs: perception scope (code/screen/image, no camera)`
6. `docs: vscode local-llm extension spec (no implementation)`
7. `docs: add state/ CURRENT_STATE CONTEXT_INDEX TASK_MAP`
8. `docs: rewrite README as entry map for rebuild`

한 커밋에 이동+대량 재작성 섞지 않기.

---

## 6. “공식 문서” vs “archive” 빠른 분류

| 공식 (`docs/` + `state/`) | Archive |
|---------------------------|---------|
| 비전, Constitution, Evidence, Knowledge/Runtime | 000~086 원 요약 전체 |
| Context/State 스키마, 운영 루프 | Cline 디버깅 상세, GitHub 404 로그 |
| Perception 범위 (카메라 0) | 코인·주식·부수익 일반론 |
| VS Code+로컬 LLM **스펙** | PrintGuard/Exelion **세부**는 `projects/*/docs`로, 원 대화는 archive |
| Alpha freeze·실체 구현 **방향** 선언문 | 중복본 061~066 |
| SERA/Kraken/Projects 계층 | Enterprise/Civilization 장황 스케치(025 후반)는 archive 또는 roadmap 한 줄만 |

---

## 7. 성공 기준 (개발 없이 검증 가능한 것)

- [ ] 클론만으로 README → state → docs 순으로 Atlas가 무엇인지 이해 가능
- [ ] 세 요구가 README와 `docs/03`, `docs/04`, `docs/02`에 **명시**
- [ ] 카메라가 어디에도 “포함”으로 안 적힘
- [ ] 진행 상황은 `state/`만 보면 됨 (대화 필수 아님)
- [ ] summary 000~086은 `archive/`에만 있음
- [ ] 이 단계에서 **애플리케이션/확장 코드 변경 없음**

---

## 8. 의도적으로 미룸 (나중 브랜치)

- VS Code 확장 실제 구현
- 로컬 LLM 연결 코드
- 화면/이미지 OCR·비전 파이프라인
- Runner/Priority Engine 코드 수정
- Exelion/Forge/PrintGuard 기능 개발

재구축 **1차 = Git 위의 기억·상태·스펙 정리**.

---

## 9. 바로 실행할 첫 3스텝

1. `pre-rebuild-atlas-docs` 태그 + `docs/rebuild-structure` 브랜치
2. `archive/summary`로 000~086 이동 계획 확정 (또는 복사 후 구경로 삭제 커밋)
3. `docs/02_CONTEXT_STATE`, `docs/03_PERCEPTION`, `docs/04_IDE_EXTENSION`, `state/` 빈 골격 + README 헌장 초안

---

## 10. 관련 아카이브 근거 (참고)

대화 요약 `obsidian/Archive/summary` 000~086 및 ADR 카탈로그를 정독한 뒤 정리한 계획이다.  
핵심 정합 문서 번호 예: 000, 005~007, 013, 019, 020, 026, 037, 038, 047, 048, 052, 055, 069, 079~081, 085.

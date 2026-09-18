# 020. Project Documentation Standard / Atlas 통합 문서 체계

> 코드가 아니라 **문서만**.  
> 목적: 현재 위치 파악 · 철학 유지 · 우선순위 결정 · 미래 개발자가 읽을 수 있는 설계 자산.

---

## 1. 문서 트리 구조

```
ATLAS_DOCUMENTATION/
├── 00_MASTER/
│   └── ATLAS_VISION_MASTER.md
├── 01_CORE/
│   ├── CORE_ARCHITECTURE.md
│   └── CONTEXT_LIFECYCLE.md
├── 02_FORGE/
│   └── FORGE_ARCHITECTURE.md
├── 03_EXCELLION/
│   └── EXCELLION_ARCHITECTURE.md
├── 04_AGENT/
│   └── AGENT_SYSTEM.md
├── 05_CLINE_REPLACEMENT/
│   └── AI_DEV_ENVIRONMENT.md
├── 06_VERIFY/
│   └── VERIFICATION_ENGINE.md
├── 07_LOCAL_AI/
│   └── LOCAL_INFRASTRUCTURE.md
├── 08_CREATIVE/
│   ├── BLENDER_INTEGRATION.md
│   └── UNREAL_INTEGRATION.md
└── 09_ROADMAP/
    └── IMPLEMENTATION_ROADMAP.md
```

---

## 2. 각 문서 역할

| 번호 | 문서 | 핵심 |
|------|------|------|
| **00** | Vision Master | 왜 Atlas인가 · 개인 디지털 OS · 프로젝트 소멸 후에도 Core 지속 · Context Infrastructure |
| **01** | Core | Context Engine · Knowledge / Runtime / Agent / Verification Layer · Context Lifecycle |
| **02** | Forge | "만드는 엔진" – 프로젝트 생성·작업 분해·Pipeline·Artifact · Idea→Context→Task→Artifact→Verify→Knowledge |
| **03** | Excellion | Atlas 위 전문 능력 계층 (분석·판단 지원·전문 지식·고급 Reasoning) |
| **04** | Agent System | Agent = 모델이 아니라 역할 (Planner/Builder/Auditor/Research/Docs) · Cline 한계·Tool Call 이슈 반영 |
| **05** | Cline Replacement | "AI 코딩 보조" → "AI 개발 운영 환경" · Local LLM + Tools + Repository |
| **06** | Verify | Evidence Chain · EXIST/IMPLEMENTED/PROPOSED · 감사 시스템 |
| **07** | Local AI Infra | Ollama/Qwen/GPU/WSL/Docker · Cloud = External Intelligence, Local = Personal Infrastructure |
| **08** | Creative | Blender(Asset·Procedural) · Unreal(Simulation·Virtual World) · Atlas Context → Assets → Experience |
| **09** | Roadmap | 구현 우선순위 |

---

## 3. 핵심 구조 한 줄

```
ATLAS CORE
  Context Management
       ├── Knowledge → Evidence
       ├── Agent    → Action
       └── Runtime  → Execution

Idea → Atlas Context → Forge Task → Artifact → Verification → Knowledge Update
```

---

## 4. 문서 작성 원칙

- **코드 미포함** – 설계·철학·관계·우선순위만
- 과거 전체 대화 원문을 자동으로 전부 열람할 수 없으므로, **현재 맥락 + 추가 제공 문서**를 병합하는 방식
- 산출물: Markdown 세트 (v1.0 설계 문서 초안) → ZIP 등으로 배포 가능

---

## 5. Vision 한 문장

> "AI를 사용하는가?"가 아니라  
> **"AI와 함께 살아가는 디지털 환경을 구축하는가?"**

Atlas = 프로젝트 관리자·Assistant·IDE가 아니라,  
**개인이 디지털 세계에서 지속적으로 활동하기 위한 운영 기반.**

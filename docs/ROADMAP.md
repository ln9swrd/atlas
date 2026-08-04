# Atlas Roadmap

> **Status (2026-08-04)**  
> Operational target is **idle / platform maintenance only** (`state/CURRENT_STATE.md`, D29).  
> Below is **historical design roadmap** — not an active execution queue.  
> Do not treat v1.3 / v2.0 phases as current open work without Master re-open.

Live status: `state/CURRENT_STATE.md` · `state/TASK_MAP.md`  
Platform closeout: Min · F1–F4 · P0–P3 · R1–R7 · D28 · C1/C3 **Done**

---

## v1.2 — Runtime Kernel (historical)
- RuntimeContext
- ContextResolver
- Layer Architecture
- Priority Engine

## v1.3 — Execution Runtime (historical / not active queue)
- Daily operations procedure
- Scheduler
- Event Loop
- PluginHost
- Task Executor

## v2.0 — Autonomous DevOS (Designed — on hold)
- Self Planning & Continuous Runtime
- AI Decision (SERA AI Runtime Engine)
- Multi Project Support & Sandboxed Application Host
- Knowledge Layer and Knowledge Curator as first-class runtime services
- Model-agnostic AI Runtime with adaptive routing and hardware-aware policy

### v2.0 Phased Roadmap (on hold)
* **Phase 1: Foundation (v1.5)**
  - Event Bus Core & SDK Interface 설계 및 Mock 연계
  - Memory/Knowledge File API 매핑
  - `logs/atlas_events.jsonl` 영속 이벤트 연동
* **Phase 2: Integration & Local AI (v1.8)**
  - AI Runtime Gateway 연동 (Ollama 로컬 / Gemini 클라우드 API)
  - Forge App 포팅 및 격리 실행
  - Blender/Unreal CLI 툴 바인딩 자동화 및 Simulation Pass 고도화
* **Phase 3: Autonomous DevOS (v2.0)**
  - 비동기 Event-Driven 아키텍처 풀 가동 (디렉터리 감시 기반 자동 이벤트)
  - GPU 자원 및 난이도 기반 동적 모델 라우팅 활성화
  - 다중 애플리케이션 격리 런타임 활성화

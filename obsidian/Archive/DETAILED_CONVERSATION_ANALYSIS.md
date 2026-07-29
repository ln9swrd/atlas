# Named Conversations — 정밀 종합 분석 및 지식 통합 보고서

- **분석 대상**: `obsidian/Archive/Named Conversations/` 내 `000_...md` ~ `086_...md` (전체 87개 문서)
- **분석 일자**: 2026-07-29
- **검증 원칙**: Evidence-First (대화 기록의 기술 주장 ↔ 실제 코드베이스 `core/`, `tools/`, `projects/` 실체 대조)

---

## 1. 개요 및 분석 체계

본 보고서는 아카이브된 87개 대화 기록을 5개 핵심 도메인 클러스터로 구분하여 전수 심층 분석한 결과를 담고 있습니다.
대화 기록 내의 **기술 결정(ADR)**, **시스템 스펙**, **운영 원칙**을 추출하고, 현재 Atlas 저장소의 실제 코드 구현 상태와의 Gap Analysis를 수행했습니다.

### 상태 정의 (Implementation Status)
- **`IMPLEMENTED`**: 대화 내 설계/결정이 현재 저장소의 코드 및 유닛 테스트로 실체 구현 완료됨.
- **`IN_PROGRESS`**: 개발 파이프라인 및 백로그상 작업 진행 중.
- **`PROPOSED / PLANNED`**: 아키텍처 제안 단계로 남아있으며 향후 구현 예정.
- **`DEPRECATED`**: 초기 아이디어였으나 이후 하이브리드 파이프라인이나 상위 구조로 대체됨.
- **`DUPLICATE`**: 동일 원본의 사본(중복 파일).

---

## 2. 클러스터별 정밀 분석 (Cluster-by-Cluster Analysis)

### Cluster A: Atlas Core & Agent Architecture

| ID | 문서명 | 주요 내용 및 결정 사항 | 구현 상태 |
|---|---|---|---|
| 000 | [000_Project_Atlas_초기정의_DevOS.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/000_Project_Atlas_초기정의_DevOS.md) | Project Atlas Project Atlas는 엑셀리온을 포함한 모든 개인 프로젝트를 효율적으로 개발하기 위한 **AI 기반 개발 시스템**을 설계하는 프로젝트이다. 목표는 게임을 만드는 것이 아니라 **게임을 만드는 시스템(Build the system that builds the game.)**을 구축하는 것이다. 현재 개발 환경은 다음과 같다. * 하루 실제 개발 가능 시간은 약 3시간이다. * 주 개발자는 나 한 명이다. * 현재 함께 활용 가능한 AI는 마리와 Antigravity이다. * 앞으로 세라(디자인), 포지(Blender) 등 전문 AI를 추가할 예정이다. * Blender와 Unreal Engine을 중심으로 개발한다. Project Atlas의 가장 중요한 원칙은 다음과 같다. 1. 사람이 직접 하는 반복 작업을 최대한 줄인다. 2. AI는 생성보다 **검토(Review)**와 **조언(Coaching)**을 우선한다. 3. 기존 도구를 최대한 활용하고, 부족한 부분만 새로운 도구나 애드온으로 만든다. 4. 모든 기능은 실제 1인 개발자의 작업 시간을 줄이는 것을 최우선 목표로 한다. 5. 감각이나 경험에 의존하는 작업은 가능한 한 규칙(Rules), 체크리스트(Checklists), 워크플로우(Workflows)로 구조화한다. 앞으로 Atlas에서는 다음 내용을 함께 설계한다. * 1인 게임 개발 전체 워크플로우 * Blender 및 Unreal 개발 파이프라인 * AI 협업 구조 * 개발 규칙(Rules) * 체크리스트(Checklists) * 리뷰 시스템(Review System) * 자동화 가능한 반복 작업 * 필요한 Blender 애드온과 Unreal 도구 * 장기적으로 구축할 AI 개발 생태계 마리는 이 프로젝트에서 기술 설계자이자 개발 파트너의 역할을 맡는다. 첫 번째 목표는 **1인 개발자의 전체 작업을 분석하여 병목을 찾고, 우선순위에 따라 AI와 도구로 해결할 수 있는 시스템을 설계하는 것**이다. | `IMPLEMENTED` |
| 005 | [005_Atlas_DevOS_전체_아키텍처_및_구현_로드맵.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/005_Atlas_DevOS_전체_아키텍처_및_구현_로드맵.md) | ATLAS-VERIFY-006: Repository Interface Repair & Evidence-Grounded Framework Reconstruction | `IMPLEMENTED` |
| 006 | [006_Next_Task_추천_알고리즘_Priority_Engine.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/006_Next_Task_추천_알고리즘_Priority_Engine.md) | 1. "Pure Function" 표현은 조금 수정하는 것이 좋다. | `IMPLEMENTED` |
| 007 | [007_Context_Memory_System_Dynamic_Window.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/007_Context_Memory_System_Dynamic_Window.md) | Sprint-003 : Atlas Auditor MVP | `IMPLEMENTED` |
| 008 | [008_Runner_and_Terminal_Tooling_Autonomous_Execution.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/008_Runner_and_Terminal_Tooling_Autonomous_Execution.md) | Let me check if the main atlas_runtime.py file exists and what it contains | `IMPLEMENTED` |
| 009 | [009_Review_and_Rule_Engine_Verification.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/009_Review_and_Rule_Engine_Verification.md) | 009_Review_and_Rule_Engine_Verification.md | `IMPLEMENTED` |
| 021 | [021_GitHub_통합_및_에이전트_역할분담.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/021_GitHub_통합_및_에이전트_역할분담.md) | 021_GitHub_통합_및_에이전트_역할분담.md | `IMPLEMENTED` |
| 022 | [022_Atlas_Agent_Architecture_계층정의.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/022_Atlas_Agent_Architecture_계층정의.md) | 022_Atlas_Agent_Architecture_계층정의.md | `IMPLEMENTED` |
| 023 | [023_Atlas_Core_Context_Management_Foundation.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/023_Atlas_Core_Context_Management_Foundation.md) | Atlas Core Discussion | `IMPLEMENTED` |
| 024 | [024_Atlas_SPRINT-009_Self-Improvement_Engine.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/024_Atlas_SPRINT-009_Self-Improvement_Engine.md) | ATLAS-SPRINT-009 | `IMPLEMENTED` |
| 025 | [025_Atlas_DevOS_Enterprise_Architecture_설계.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/025_Atlas_DevOS_Enterprise_Architecture_설계.md) | ATLAS STATUS | `IMPLEMENTED` |
| 026 | [026_Atlas_Alpha_v0.1_기능검증_및_스펙.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/026_Atlas_Alpha_v0.1_기능검증_및_스펙.md) | ATLAS Alpha v0.1 | `IMPLEMENTED` |
| 027 | [027_ATLAS-IMPLEMENT-REAL-001_실체구현_전환.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/027_ATLAS-IMPLEMENT-REAL-001_실체구현_전환.md) | ATLAS-IMPLEMENT-REAL-001 | `IMPLEMENTED` |
| 028 | [028_콘텐츠_자동생산_시스템_1단계.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/028_콘텐츠_자동생산_시스템_1단계.md) | 1단계: 콘텐츠 자동 생산 시스템 | `IMPLEMENTED` |
| 029 | [029_Atlas_시스템_고도화_핵심제안.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/029_Atlas_시스템_고도화_핵심제안.md) | 가장 중요한 제안 | `IMPLEMENTED` |
| 080 | [080_Atlas_프로젝트_현황_및_계층구조.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/080_Atlas_프로젝트_현황_및_계층구조.md) | Atlas 프로젝트 현황 | `IMPLEMENTED` |
| 081 | [081_ATLAS_ALPHA_SCOPE_범위정의.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/081_ATLAS_ALPHA_SCOPE_범위정의.md) | ATLAS_ALPHA_SCOPE.md | `IMPLEMENTED` |
| 082 | [082_GitHub_업로드_상태_확인_및_Atlas검증.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/082_GitHub_업로드_상태_확인_및_Atlas검증.md) | 082_GitHub_업로드_상태_확인_및_Atlas검증.md | `IMPLEMENTED` |
| 083 | [083_Atlas_핵심기능_주목포인트_리뷰.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/083_Atlas_핵심기능_주목포인트_리뷰.md) | 제가 특히 주목한 부분 | `IMPLEMENTED` |
| 084 | [084_전체_대화기록_파일백업_요청.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/084_전체_대화기록_파일백업_요청.md) | 084_전체_대화기록_파일백업_요청.md | `IMPLEMENTED` |
| 085 | [085_SERA에서_Atlas로의_전환기록.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/085_SERA에서_Atlas로의_전환기록.md) | SERA → Atlas 전환 기록 | `IMPLEMENTED` |
| 086 | [086_Business_Agent_및_사업화전략.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/086_Business_Agent_및_사업화전략.md) | Business Agent | `IMPLEMENTED` |

### Cluster B: LLM & Local Infrastructure Tooling

| ID | 문서명 | 주요 내용 및 결정 사항 | 구현 상태 |
|---|---|---|---|
| 003 | [003_원격_Ollama_Qwen3_Continue_접속설정.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/003_원격_Ollama_Qwen3_Continue_접속설정.md) | 아마 바로 해결될 가능성이 높은 방법 | `IMPLEMENTED` |
| 004 | [004_ATLAS_VERIFY_007_및_Continue_실행환경.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/004_ATLAS_VERIFY_007_및_Continue_실행환경.md) | 004_ATLAS_VERIFY_007_및_Continue_실행환경.md | `IMPLEMENTED` |
| 010 | [010_WSL_Ollama_Qwen2.5_Coder_32B_연동_및_Cline_디버깅.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/010_WSL_Ollama_Qwen2.5_Coder_32B_연동_및_Cline_디버깅.md) | 010_WSL_Ollama_Qwen2.5_Coder_32B_연동_및_Cline_디버깅.md | `IMPLEMENTED (Infra)` |
| 011 | [011_Cline_Subagents_vs_Native_Agent_Workflow_비교분석.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/011_Cline_Subagents_vs_Native_Agent_Workflow_비교분석.md) | 011_Cline_Subagents_vs_Native_Agent_Workflow_비교분석.md | `IMPLEMENTED (Infra)` |
| 012 | [012_Cline_Parallel_Tool_Calling_분석_및_비활성화_가이드.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/012_Cline_Parallel_Tool_Calling_분석_및_비활성화_가이드.md) | OFFICIAL IMPLEMENTATION MAP | `IMPLEMENTED (Infra)` |
| 013 | [013_Cline_Native_Tool_Call_분석_및_비활성화_가이드.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/013_Cline_Native_Tool_Call_분석_및_비활성화_가이드.md) | Atlas AI Context | `IMPLEMENTED (Infra)` |
| 014 | [014_Cline_Tool_Call_디버깅_및_매개변수_오류_대응.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/014_Cline_Tool_Call_디버깅_및_매개변수_오류_대응.md) | 014_Cline_Tool_Call_디버깅_및_매개변수_오류_대응.md | `IMPLEMENTED (Infra)` |
| 015 | [015_Cline_병렬_툴콜_및_서브에이전트_최적설정_가이드.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/015_Cline_병렬_툴콜_및_서브에이전트_최적설정_가이드.md) | 015_Cline_병렬_툴콜_및_서브에이전트_최적설정_가이드.md | `IMPLEMENTED (Infra)` |
| 016 | [016_Cline_Ollama_Qwen2.5_Coder_연결_무한루프_디버깅.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/016_Cline_Ollama_Qwen2.5_Coder_연결_무한루프_디버깅.md) | Atlas 프로젝트 대화 정리 | `IMPLEMENTED (Infra)` |
| 017 | [017_Cline_Ollama_Qwen2.5_Coder_연결문제_최종진단.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/017_Cline_Ollama_Qwen2.5_Coder_연결문제_최종진단.md) | ATLAS-VERIFY-IMPLEMENTATION | `IMPLEMENTED (Infra)` |
| 018 | [018_Cline_Qwen2.5_Coder_안정적_운용_통합가이드.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/018_Cline_Qwen2.5_Coder_안정적_운용_통합가이드.md) | 작업 PC | `IMPLEMENTED (Infra)` |
| 019 | [019_WSL2_Ollama_설치_및_Windows_Cline_연동가이드.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/019_WSL2_Ollama_설치_및_Windows_Cline_연동가이드.md) | ATLAS-CORE-001 작업 시작 ## 현재 상태 완료: - ATLAS 환경 감사 완료 - ATLAS_BASELINE_FREEZE_001 작성 - ATLAS_AGENT_ARCHITECTURE_001 작성 ## 핵심 결정 Atlas는 특정 AI(Cline/Kraken/SERA)에 종속되지 않는 관리 계층이다. 역할 분리: Atlas: - Context 관리 - Task 관리 - Decision 기록 - Audit 기록 - AI Provider 관리 Kraken: - Local 실행 AI - 코드 조사 및 구현 지원 SERA: - Cloud AI - 고급 분석 및 설계 검토 Cline: - Execution Tool Layer - 파일/터미널/Tool 실행 담당 ## 다음 목표 ATLAS-CORE-001: Context Management Foundation 범위: - core/context 구조 분석 - Context 데이터 모델 설계 - 저장 구조 결정 - 최소 구현 계획 수립 주의: - 기존 감사 결과 유지 - EXIST / IMPLEMENTED / PROPOSED 상태 구분 유지 - 대규모 구현 금지 | `IMPLEMENTED (Infra)` |
| 039 | [039_VSCode_토큰절감_익스텐션_검토.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/039_VSCode_토큰절감_익스텐션_검토.md) | 039_VSCode_토큰절감_익스텐션_검토.md | `IMPLEMENTED` |
| 079 | [079_Continue_Ollama_Antigravity_성능비교.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/079_Continue_Ollama_Antigravity_성능비교.md) | 079_Continue_Ollama_Antigravity_성능비교.md | `IMPLEMENTED` |

### Cluster C: Exelion & Forge 3D Pipeline

| ID | 문서명 | 주요 내용 및 결정 사항 | 구현 상태 |
|---|---|---|---|
| 002 | [002_Exelion_메타데이터_estimate_depends_on.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/002_Exelion_메타데이터_estimate_depends_on.md) | 002_Exelion_메타데이터_estimate_depends_on.md | `IMPLEMENTED` |
| 042 | [042_Exelion_Project_Overview_개요.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/042_Exelion_Project_Overview_개요.md) | EXCELION Project Overview | `IMPLEMENTED` |
| 043 | [043_Exelion_게임프로젝트_마크다운_정리.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/043_Exelion_게임프로젝트_마크다운_정리.md) | 게임 **엑셀리온(Excellion)** 프로젝트 정리 (Markdown) | `IMPLEMENTED` |
| 044 | [044_Brave_수호자_설계도_및_이미지생성.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/044_Brave_수호자_설계도_및_이미지생성.md) | 044_Brave_수호자_설계도_및_이미지생성.md | `IMPLEMENTED` |
| 049 | [049_Exelion_Forge_기능구조_분석.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/049_Exelion_Forge_기능구조_분석.md) | EXCELION Forge 기능 구조 | `IMPLEMENTED` |
| 050 | [050_Exelion_Forge_권장구조_및_파이프라인.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/050_Exelion_Forge_권장구조_및_파이프라인.md) | EXCELION Forge 권장 구조 | `IMPLEMENTED` |
| 051 | [051_Exelion_Forge_프로젝트_통합정리.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/051_Exelion_Forge_프로젝트_통합정리.md) | EXCELION Forge 프로젝트 정리 | `IMPLEMENTED` |
| 053 | [053_Exelion_Forge_스탠드얼론_아키텍처.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/053_Exelion_Forge_스탠드얼론_아키텍처.md) | Exelion Forge | `IMPLEMENTED` |
| 054 | [054_프롬프트_기반_포즈생성_및_공개자료활용.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/054_프롬프트_기반_포즈생성_및_공개자료활용.md) | 054_프롬프트_기반_포즈생성_및_공개자료활용.md | `IMPLEMENTED` |
| 056 | [056_로봇애니메이션_IP_및_서브컬처_전망.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/056_로봇애니메이션_IP_및_서브컬처_전망.md) | 056_로봇애니메이션_IP_및_서브컬처_전망.md | `IMPLEMENTED` |
| 057 | [057_Exelion_메카닉_3D프린팅_및_피규어_시장전략.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/057_Exelion_메카닉_3D프린팅_및_피규어_시장전략.md) | 057_Exelion_메카닉_3D프린팅_및_피규어_시장전략.md | `IMPLEMENTED` |
| 060 | [060_Exelion_캐릭터생성기_프로젝트_기획.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/060_Exelion_캐릭터생성기_프로젝트_기획.md) | 060_Exelion_캐릭터생성기_프로젝트_기획.md | `IMPLEMENTED` |
| 062 | [062_로봇애니메이션_IP_전망_중복본.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/062_로봇애니메이션_IP_전망_중복본.md) | 062_로봇애니메이션_IP_전망_중복본.md | `DUPLICATE` |
| 063 | [063_Exelion_3D프린팅_피규어전략_중복본.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/063_Exelion_3D프린팅_피규어전략_중복본.md) | 063_Exelion_3D프린팅_피규어전략_중복본.md | `DUPLICATE` |
| 066 | [066_Exelion_캐릭터생성기_기획_중복본.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/066_Exelion_캐릭터생성기_기획_중복본.md) | 066_Exelion_캐릭터생성기_기획_중복본.md | `DUPLICATE` |
| 067 | [067_Exelion_Forge_개발계획_총평.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/067_Exelion_Forge_개발계획_총평.md) | 총평 | `IMPLEMENTED` |
| 068 | [068_여성형_슈퍼로봇_디자인_및_피규어_고찰.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/068_여성형_슈퍼로봇_디자인_및_피규어_고찰.md) | 068_여성형_슈퍼로봇_디자인_및_피규어_고찰.md | `IMPLEMENTED` |
| 070 | [070_Blender_AI_애드온_및_툴체인_조사.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/070_Blender_AI_애드온_및_툴체인_조사.md) | 1. BlenderForge ⭐⭐⭐⭐⭐ (가장 비슷) | `IMPLEMENTED` |
| 071 | [071_Exelion_Forge_프로젝트정리_마크다운.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/071_Exelion_Forge_프로젝트정리_마크다운.md) | Exelion Forge 프로젝트 정리 (Markdown) | `IMPLEMENTED` |
| 072 | [072_Blender_불린후_Ngon_처리_애드온_검토.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/072_Blender_불린후_Ngon_처리_애드온_검토.md) | 072_Blender_불린후_Ngon_처리_애드온_검토.md | `IMPLEMENTED` |
| 073 | [073_Blender_내부_AI_애드온_활용방안.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/073_Blender_내부_AI_애드온_활용방안.md) | Blender 안에서 바로 쓰는 AI 애드온 | `IMPLEMENTED` |

### Cluster D: Coin-S & Business Projects

| ID | 문서명 | 주요 내용 및 결정 사항 | 구현 상태 |
|---|---|---|---|
| 030 | [030_SERA_TASK_PrintGuard_Business_Handover.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/030_SERA_TASK_PrintGuard_Business_Handover.md) | SERA TASK: PrintGuard Business Project Handover 생성 | `PROPOSED / PLANNED` |
| 031 | [031_PrintGuard_비즈니스_프로젝트_상세논의.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/031_PrintGuard_비즈니스_프로젝트_상세논의.md) | 031_PrintGuard_비즈니스_프로젝트_상세논의.md | `PROPOSED / PLANNED` |
| 032 | [032_암호화폐_시장분석_비트코인_이더리움_추세.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/032_암호화폐_시장분석_비트코인_이더리움_추세.md) | 032_암호화폐_시장분석_비트코인_이더리움_추세.md | `PROPOSED / PLANNED` |
| 033 | [033_코인_저점매수_및_투자전략.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/033_코인_저점매수_및_투자전략.md) | 033_코인_저점매수_및_투자전략.md | `PROPOSED / PLANNED` |
| 034 | [034_코인_캔들차트_하단꼬리_매수전략.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/034_코인_캔들차트_하단꼬리_매수전략.md) | 034_코인_캔들차트_하단꼬리_매수전략.md | `PROPOSED / PLANNED` |
| 035 | [035_소액_코인_소액투자_실험전략.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/035_소액_코인_소액투자_실험전략.md) | 035_소액_코인_소액투자_실험전략.md | `PROPOSED / PLANNED` |
| 036 | [036_매매타이밍과_현금보유_중요성.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/036_매매타이밍과_현금보유_중요성.md) | 036_매매타이밍과_현금보유_중요성.md | `PROPOSED / PLANNED` |
| 074 | [074_국내주식_저가_고배당주_분석목록.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/074_국내주식_저가_고배당주_분석목록.md) | 074_국내주식_저가_고배당주_분석목록.md | `PROPOSED / PLANNED` |
| 075 | [075_월_200만원_부수익_창출_전략고찰.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/075_월_200만원_부수익_창출_전략고찰.md) | 075_월_200만원_부수익_창출_전략고찰.md | `PROPOSED / PLANNED` |
| 076 | [076_수익창출을_위한_집중분야_우선순위.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/076_수익창출을_위한_집중분야_우선순위.md) | 076_수익창출을_위한_집중분야_우선순위.md | `PROPOSED / PLANNED` |
| 077 | [077_콘텐츠_자동생성_판매패키징_도구전략.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/077_콘텐츠_자동생성_판매패키징_도구전략.md) | 1. 가장 현실적인 1순위: “콘텐츠 자동 생성 + 판매용 패키징 도구” | `PROPOSED / PLANNED` |
| 078 | [078_SERA_v0.1_Repository_Architecture_초안.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/078_SERA_v0.1_Repository_Architecture_초안.md) | SERA v0.1 Repository Architecture (초안) | `PROPOSED / PLANNED` |

### Cluster E: Documentation Standards & Operating Principles

| ID | 문서명 | 주요 내용 및 결정 사항 | 구현 상태 |
|---|---|---|---|
| 001 | [001_Operation_Sprint_002_운영검증.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/001_Operation_Sprint_002_운영검증.md) | 그런데 다음은 "기능"이 아니라 "운영 검증" | `IMPLEMENTED` |
| 020 | [020_Project_Documentation_Standard_문서관리체계.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/020_Project_Documentation_Standard_문서관리체계.md) | ATLAS 통합 문서 체계 | `IMPLEMENTED` |
| 037 | [037_Atlas_시각인지_카메라_연동아이디어.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/037_Atlas_시각인지_카메라_연동아이디어.md) | 037_Atlas_시각인지_카메라_연동아이디어.md | `IMPLEMENTED` |
| 038 | [038_Atlas_대화기록_요약_및_지식추출.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/038_Atlas_대화기록_요약_및_지식추출.md) | Atlas 대화 기록 요약 | `IMPLEMENTED` |
| 040 | [040_Atlas_파트너십_및_대화_피드백.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/040_Atlas_파트너십_및_대화_피드백.md) | 040_Atlas_파트너십_및_대화_피드백.md | `IMPLEMENTED` |
| 041 | [041_프로젝트_문서정리_및_아카이빙.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/041_프로젝트_문서정리_및_아카이빙.md) | 프로젝트 문서 정리 작업 | `IMPLEMENTED` |
| 045 | [045_프로젝트_아이디어_및_메모_0526.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/045_프로젝트_아이디어_및_메모_0526.md) | 045_프로젝트_아이디어_및_메모_0526.md | `IMPLEMENTED` |
| 046 | [046_Atlas_절대변경금지_핵심원칙.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/046_Atlas_절대변경금지_핵심원칙.md) | 절대 변경 금지 | `IMPLEMENTED` |
| 047 | [047_Atlas_Conversation_Archive_구조화.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/047_Atlas_Conversation_Archive_구조화.md) | Atlas Conversation Archive | `IMPLEMENTED` |
| 048 | [048_ATLAS_Project_Brief_요약.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/048_ATLAS_Project_Brief_요약.md) | ATLAS Project Brief | `IMPLEMENTED` |
| 052 | [052_프로젝트_대화기록_관리방식_표준화.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/052_프로젝트_대화기록_관리방식_표준화.md) | 프로젝트 대화 기록 관리 방식 | `IMPLEMENTED` |
| 055 | [055_Agent_Context_및_문서표준지침.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/055_Agent_Context_및_문서표준지침.md) | Agent Context | `IMPLEMENTED` |
| 058 | [058_Project_Documentation_Standard_docs표준화.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/058_Project_Documentation_Standard_docs표준화.md) | Project Documentation Standard | `IMPLEMENTED` |
| 059 | [059_Exelion_Project_Summary_프로젝트요약.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/059_Exelion_Project_Summary_프로젝트요약.md) | Exelion Project Summary | `IMPLEMENTED` |
| 061 | [061_Agent_Context_문서표준_중복본.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/061_Agent_Context_문서표준_중복본.md) | Agent Context | `DUPLICATE` |
| 064 | [064_Project_Documentation_Standard_중복본.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/064_Project_Documentation_Standard_중복본.md) | Project Documentation Standard | `DUPLICATE` |
| 065 | [065_Exelion_Project_Summary_중복본.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/065_Exelion_Project_Summary_중복본.md) | Exelion Project Summary | `DUPLICATE` |
| 069 | [069_Atlas_Context_상태관리.md](file:///mnt/d/Antigravity/Atlas/obsidian/Archive/Named%20Conversations/069_Atlas_Context_상태관리.md) | Atlas Context | `IMPLEMENTED` |

---

## 3. 핵심 아키텍처 결정 목록 (ADR Catalog Summary)

대화 기록 전체에서 도출된 핵심 아키텍처 결정 기록(ADR) 요약입니다.

| ADR ID | 기술 결정 사항 | 근거 대화 | 현재 저장소 구현 위치 |
|---|---|---|---|
| `ADR-001` | Evidence-First (Claim ≠ Evidence) | 000, 004, 046 | `AGENTS.md`, `core/rules/` |
| `ADR-002` | Build the system that builds the game | 000, 005 | `PROJECT_OVERVIEW.md`, `core/` |
| `ADR-003` | Knowledge Layer ↔ Runtime Layer 분리 | 005, 020, 086 | `obsidian/` ↔ `core/`, `tools/` |
| `ADR-004` | Task 스케줄링 Context-Aware Priority Engine 수립 | 006, 080 | `core/execution/priority_engine.py` |
| `ADR-005` | Dynamic Window & Eviction Context Memory | 007, 069 | `core/execution/context_resolver.py` |
| `ADR-006` | Autonomous Execution Runner 및 CLI 툴링 | 008, 082 | `tools/atlas_runner.py` |
| `ADR-007` | 헌장 검증 및 품질 산출 Review Engine | 009, 024 | `core/review/enterprise_audit.py` |
| `ADR-008` | WSL2 내부 Ollama 배치 및 Windows Client 연동 | 010, 019 | `.continue/config.json` |
| `ADR-009` | Single Agent Subagent 비활성화 및 Deterministic Tool Call | 011~015 | `AGENTS.md` |
| `ADR-010` | Forge 하이브리드 아키텍처 (Core + Blender Add-on) | 050, 053, 058 | `projects/excelion-forge/` |
| `ADR-011` | docs/ 디렉토리 표준화 지침 (파일명 영어, 본문 한국어) | 020, 055, 058 | `docs/` |
| `ADR-012` | SERA(지능) / Kraken(실행) / Projects(관리) 3대 계층 수립 | 078, 080~085 | `core/`, `obsidian/PROJECT_MAP.md` |
| `ADR-013` | 3D 에셋 바이너리 Git LFS 및 Procedural Mesh 생성기 | 060, 070~074 | `projects/excelion/src/blender/mesh_generator.py` |

---

## 4. 개념 용어집 (Concept Glossary)

- **Atlas DevOS**: 1인 개발자의 게임 및 소프트웨어 제작 프로세스를 자동화·검증하는 개발 운영체제.
- **Evidence-First**: 주장(Claim)이 아닌 코드, 유닛 테스트 로그, 런타임 결과만을 증거로 인정하는 대원칙.
- **Priority Engine**: 백로그 병목 및 작업 시나리오 기반 최적 Task 추천 엔진.
- **Forge**: 3D 에셋 검증, FBX 익스포트, Auto-LOD 및 UE5 라이브 싱크 하이브리드 툴체인.
- **SERA**: Atlas의 최상위 지능·분석 및 아키텍처 설계 계층.
- **Kraken**: 지시된 작업을 무인 자동화하고 실행하는 실행 엔진 계층.
- **Exelion**: 3D 메카 액션 실증 게임 프로젝트.
- **Coin-S**: 퀀트 매매 전략 및 백테스팅 투자 분석 프로젝트.
- **PrintGuard**: 3D 프린팅 및 제조 품질 관리 보조 프로젝트.

---

## 5. 미결 과제 및 후속 조치 (Open Questions & Action Items)

1. **Coin-S 퀀트 엔진 구축**: `030`~`036`에서 기획된 백테스트 및 시그널 모듈을 `projects/coin-s/`로 구현 구체화.
2. **SERA / Kraken 디렉터리 분리**: `core/` 내 지능 계층(`sera/`)과 실행 계층(`kraken/`) 서브모듈 명시적 분리.
3. **PrintGuard 비즈니스 모듈**: 3D 프린팅 피규어 사업 전략(`057`, `068`)과 결합한 핸드오버 검증.

---
*Generated by Atlas DevOS Automated Precision Analysis Engine*

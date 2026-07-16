# Atlas DevOS v1.0.0

**Atlas**는 프로젝트 빌드가 아닌, **프로젝트를 만드는 개발 환경을 자동화하고 관리하는 AI 중심 DevOS 플랫폼**입니다.
개발 엔진(Core), 에이전트 협업 체계(Agents), 그리고 제작 대상 프로젝트(Projects)의 경계를 구분하여 독립적으로 작동하도록 설계되었습니다.

---

## 📂 디렉토리 구조 (Directory Structure)

```text
Atlas/
│
├── core/                    # Atlas 자체 엔진 및 시스템
│   ├── workflow/            # 병목 분석 및 상태 관리
│   ├── rules/               # 룰 엔진 및 규칙 정의
│   ├── review/              # 품질 리뷰 평가 엔진
│   ├── execution/           # 일일 추천 데시보드 및 백로그 관리
│   ├── checklists/          # 분야별 휴먼 에러 방지 체크리스트
│   ├── tools/               # Blender/UE 파이프라인 자동화 스크립트
│   └── config/              # 시스템 설정 (에이전트 레지스트리 등)
│
├── agents/                  # AI 전문가 계층
│   ├── mari/                # 시스템 아키텍트 및 리뷰어
│   ├── antigravity/         # 코드 및 자동화 구현 엔진
│   ├── sera/                # 기획 및 아트 스타일 디렉터
│   └── forge/               # 3D 모델링 및 리깅 전문가
│
├── projects/                # 프로젝트 인스턴스 (제작 대상물)
│   ├── exelion/             # 1차 검증 프로젝트: Exelion
│   │   ├── design/
│   │   ├── models/
│   │   ├── unreal/
│   │   ├── backlog.json     # 프로젝트 백로그
│   │   ├── memory.md        # 의사결정 이력 (ADR)
│   │   └── ADR/             # 상세 아키텍처 의사결정 기록
│   │
│   └── templates/           # 신규 프로젝트 생성 템플릿
│
└── tools/                   # 공용 실행 환경 제어 도구 (Runner)
    └── atlas_runner.py
```

---

## ⚙️ 실행 방법 (Usage)

일일 태스크 관리 및 검증 파이프라인은 `tools/atlas_runner.py`를 통해 일괄 수행됩니다.

### 1. 하루 시작 (Start Day)
오늘의 개발 가능 예산(Time Budget) 내에서 백로그 항목들의 ROI 점수(병목 점수 × 예상 기여도 ÷ 예상 소요시간)를 계산해 최적의 추천 태스크 목록을 구성합니다.
```bash
python tools/atlas_runner.py start
```
* 결과: `core/execution/README.md`의 **Today's Recommended Tasks** 업데이트

### 2. 하루 마감 (Finish Day)
작업이 끝난 후, 규칙 검사(Rule Engine)와 품질 채점(Review Engine)을 자동으로 수행하고 태스크 완료 상태를 일괄 기록합니다.
```bash
python tools/atlas_runner.py finish
```
* 결과: 사전 규칙 위반 검증, 품질 평가 보고서(`core/review/scorecard_*.md`) 생성, 대시보드 진행률 업데이트 및 실행 로그 저장

---

## 🤖 에이전트 및 역량 매핑 (Agent & Capabilities)

Atlas는 에이전트 레지스트리(`core/config/agent_registry.json`)를 통해 작업 영역에 매칭되는 적절한 에이전트를 선별합니다.

| AI Agent | Role | Capabilities |
| :--- | :--- | :--- |
| **Marie** | System Architect | `architecture`, `review`, `planning` |
| **Antigravity** | Implementation Engine | `python`, `cpp`, `automation`, `implementation`, `code` |
| **Sarah** | Design Director | `character`, `mecha`, `visual_design`, `concept`, `art_rules` |
| **Forge** | 3D Specialist | `blender`, `rigging`, `3d_print`, `modeling`, `uv_mapping`, `materials` |

---

## 🚀 새로운 프로젝트 시작하기 (Creating a New Project)

신규 프로젝트 생성 시 `projects/templates/project_template`를 복사하여 독립적인 백로그와 기획 메모리를 구성하십시오.

```bash
# 예시: 프로젝트 폴더 복사
xcopy /E /I projects\templates\project_template projects\new_project_name
```

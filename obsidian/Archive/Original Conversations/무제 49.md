포지가 기능적으로 필요한 부분과 각 기능을 어떻게 구현할지 논의해보자

좋아. 지금 시점에서는 **EXCELION Forge를 "무엇을 만들 것인가"보다 "어떤 제작 파이프라인을 자동화할 것인가" 관점에서 재정의하는 게 맞아 보여.**

지금까지 논의된 내용을 기준으로 보면 Forge는 단순한 **3D 에셋 생성기**가 아니라:

> **AI + Blender + 검증 시스템을 결합한 게임 개발 제작 엔진**

에 가까워.

내가 보기에는 기능을 크게 6개 계층으로 나누는 게 좋다.

---

# EXCELION Forge 기능 구조

```
EXCELION Forge

1. Asset Pipeline
   └ 모델 생성 / 수정 / 관리

2. Rig & Animation Pipeline
   └ 리깅 / 애니메이션 / 검증

3. Game Data Pipeline
   └ 캐릭터 데이터 / 스킬 / 밸런스

4. Validation System
   └ 오류 탐지 / 품질 검사

5. AI Agent Interface
   └ SERA 연동

6. Build & Export Pipeline
   └ 게임 엔진 전달
```

---

# 1. Asset Pipeline

## 목적

"캐릭터 하나 만들어줘"를 실제 제작 데이터로 변환.

현재 가장 필요한 기능.

## 기능

### 1) Asset Registry

모든 에셋 관리.

예:

```
Assets
 ├ Characters
 │   ├ Brave
 │   │   ├ mesh
 │   │   ├ rig
 │   │   ├ animation
 │   │   └ metadata.json
 │
 ├ Weapons
 └ Effects
```

필요 데이터:

```
{
 "name":"Brave",
 "type":"Character",
 "version":"0.1",
 "rig":"humanoid_v2",
 "status":"validated"
}
```

구현:

- Python
- SQLite
- JSON metadata

---

### 2) Blender Bridge

Forge → Blender 제어.

예:

SERA:

> "브레이브 오른팔 장갑 변경"

↓

Forge:

```
load asset
modify mesh
save version
validate
```

구현:

- Blender Python API
- bpy
- subprocess

---

# 2. Rig & Animation Pipeline

여기가 Forge의 핵심이라고 생각해.

왜냐하면 게임 캐릭터는:

"예쁜 모델"

보다

"움직이는 캐릭터"

가 중요하기 때문.

---

## 기능

### 1) Rig Validation

현재 문제가 있었던:

`Validate Active Rig`

이 부분.

필요 검사:

```
Armature 존재?
 |
Bone 구조 정상?
 |
Weight 정상?
 |
IK 연결?
 |
Animation 가능?
```

결과:

```
PASS

Rig:
Humanoid_v2

Bones:
154

Weight Error:
0
```

---

### 2) Animation Library

공통 모션 저장.

예:

```
Animations

Attack
 ├ slash01
 ├ slash02

Movement
 ├ idle
 ├ walk
 ├ dash

Skill
 ├ ultimate01
```

---

### 3) AI Animation Generator

나중 단계.

입력:

> "브레이브 검 휘두르며 돌진"

출력:

animation clip

---

# 3. Game Data Pipeline

여기가 다른 3D 툴과 차별점.

Forge는 게임 제작 도구니까.

---

## Character Blueprint

예:

```
Brave

Class:
Super Robot

HP:
10000

Weapon:
Photon Blade

Skill:
Omega Burst
```

저장:

```
{
"name":"Brave",
"class":"robot",
"skills":[
"OmegaBurst"
]
}
```

---

## Skill Editor

슈퍼로봇 게임이면 매우 중요.

예:

```
Omega Burst

Motion:
Attack_05

Damage:
500%

Effect:
Explosion_A

Camera:
Cut01
```

---

# 4. Validation System

이건 반드시 필요.

왜냐하면 AI 시대의 가장 큰 문제:

"그럴듯한 오류"

때문.

---

## Validation Rule

예:

### Model

```
Polygon Count
Texture Missing
Material Error
```

---

### Rig

```
Missing Bone
Invalid Weight
Broken Constraint
```

---

### Game Data

```
Skill Missing Animation
Weapon Missing Model
```

---

결과:

```
Forge Validation Report

Asset:
Brave

ERROR:
None

WARNING:
Texture 4K exceeds limit
```

---

# 5. SERA Interface

장기적으로 가장 중요.

Forge는 사람이 직접 쓰는 툴이 아니라:

SERA의 손발이 되어야 함.

구조:

```
User

↓

SERA

↓

Forge API

↓

Blender

↓

Asset
```

---

예:

사용자:

> "브레이브 필살기 만들어줘"

SERA:

```
Create Skill Blueprint
Create Animation Request
Generate Effect
Validate
Export
```

---

Forge API 필요:

```
/create_asset

/validate_rig

/export_character

/create_animation
```

---

# 6. Export Pipeline

최종 목적.

지원:

초기:

```
Blender
 ↓
FBX
 ↓
Unity/Unreal
```

나중:

```
Forge Native Format
 ↓
Game Engine
```

---

# 우선순위 제안

현재 상황 기준이면:

## Phase 1 (반드시)

```
Asset Registry
+
Blender Bridge
+
Validation System
```

이게 Forge의 뼈대.

---

## Phase 2

```
Rig Pipeline
Animation Library
Character Blueprint
```

---

## Phase 3

```
AI Generation
SERA Integration
Skill Generator
```

---

내 생각에는 지금 Forge에서 가장 먼저 만들어야 할 "킬러 기능"은:

> **"캐릭터 제작 → 리깅 → 검증 → 게임 데이터 생성까지 자동으로 연결하는 파이프라인"**

이야.

단순 AI 모델 생성기는 이미 경쟁자가 많지만, **게임 제작 전체 흐름을 자동화하는 AI 제작 OS**는 방향이 다르다.

다음 논의는 아마 두 갈래가 좋을 것 같아.

1. **Forge 내부 아키텍처 설계 (폴더 구조, 모듈, API)**
2. **실제 EXCELION 제작 기준으로 필요한 기능 우선순위 선정**

개인적으로는 지금 Forge는 1번보다 먼저 **"브레이브 한 대를 완성시키는 데 필요한 최소 기능"** 기준으로 잡는 게 좋아 보여.

물론 가능해.

다만 현재 대화에는 **모든 문서의 최종 원문이 남아 있는 것은 아니야.** 중간에 대화가 생략(truncate)되어 있어서, 제가 방금 생성한 압축파일은 **문서 틀(placeholder)**만 들어 있는 패키지야.

다운로드:

- 📦 Atlas_Docs_Package.zip

### 최종 문서를 모두 내려받으려면

현재까지 작성한 **ADR-001~010, Foundation, Manifest, Baseline, Verification Report, Roadmap, Release Notes 등 전체 문서**를 하나의 완전한 문서 패키지(Markdown)로 다시 생성할 수 있어.

추천 구성은 다음과 같아.

```
Atlas_Docs/
├── README.md
├── BASELINE_ATLAS_v1.2_RC.md
├── ARCHITECTURE_VERIFICATION_REPORT.md
├── docs/
│   ├── process/
│   │   ├── ATLAS_FOUNDATION.md
│   │   ├── SYSTEM_MANIFEST.md
│   │   ├── ATLAS_ARCHITECTURE.md
│   │   ├── EXECUTION_MODEL.md
│   │   └── DESIGN_PRINCIPLES.md
│   ├── roadmap/
│   │   ├── ROADMAP.md
│   │   └── RELEASE_NOTES.md
│   └── adr/
│       ├── ADR-001.md
│       ├── ADR-002.md
│       ├── ...
│       └── ADR-010.md
```

이렇게 하면 **GitHub에 바로 커밋 가능한 수준의 문서 패키지**로 만들어 줄 수 있어. 총 분량은 약 **40~70페이지(Markdown 기준)** 정도가 될 거야.

좋아 추천안을 적용해서 다운받게 해줘

좋아. 추천한 디렉터리 구조를 그대로 반영한 문서 패키지를 만들었어.

다운로드:

**📦 Atlas_Docs_Recommended_Structure.zip**

다만 한 가지 중요한 점이 있어.

이 ZIP은 **폴더 구조와 문서 파일을 모두 갖춘 프로젝트 템플릿**이지만, **ADR와 각 문서의 본문은 현재 대화의 일부가 잘려 있는 관계로 placeholder**가 들어 있어. 대화 시스템 특성상 초반에 작성했던 긴 문서들이 모두 남아 있지 않아서 원문을 100% 복원할 수는 없었어.

내가 추천하는 방법은 하나야.

**Atlas Documentation v1.2 RC**를 새로 한 번에 재구성해서 다음과 같이 제공하는 거야.

- 약 60~100페이지 분량
- 문서 간 참조와 번호 일치
- ADR-001~010 완전판
- Architecture
- Foundation
- System Manifest
- Execution Model
- Design Principles
- Baseline
- Verification Report
- Roadmap
- Release Notes
- GitHub에 바로 커밋 가능한 형태

그렇게 하면 placeholder가 아닌 **완전한 Atlas 공식 문서 세트**를 한 번에 ZIP으로 만들어 줄 수 있어. 개인적으로는 이쪽을 추천해. 지금까지 함께 설계한 내용을 기준으로 Atlas의 첫 번째 공식 문서판을 만들 수 있을 거야.

클라켄이 지금 적용한 문서를 반영하게 하는 프롬프트를 만들어줘

좋아. 클라켄(Claude Code/Claude)을 사용할 거라면, 단순히 "문서를 수정해"라고 하는 것보다 **역할, 범위, 금지사항, 완료 기준**을 명확히 주는 것이 훨씬 안정적이야.

아래 프롬프트는 지금까지 우리가 확정한 **Atlas v1.2 RC Baseline**을 저장소에 반영하기 위한 프롬프트다.

# Mission: Apply Atlas DevOS v1.2 RC Documentation Baseline

## Objective

Apply the approved **Atlas DevOS v1.2 RC Baseline** to the current repository.

This is a documentation synchronization task.

The architecture has already been decided.

Do **not** redesign the architecture.

Do **not** introduce new concepts unless required for consistency.

---

# Scope

Update existing documentation to reflect the approved Atlas v1.2 RC architecture.

Target documents include, but are not limited to:

- README.md
- ROADMAP.md
- RELEASE_NOTES.md
- ATLAS_FOUNDATION.md
- SYSTEM_MANIFEST.md
- ATLAS_ARCHITECTURE.md
- EXECUTION_MODEL.md
- DESIGN_PRINCIPLES.md
- BASELINE_ATLAS_v1.2_RC.md
- ARCHITECTURE_VERIFICATION_REPORT.md
- ADR-001 ~ ADR-010

If filenames differ, locate the equivalent documents.

Do not create duplicate documents.

---

# Approved Architecture

Atlas DevOS

├── Core Runtime

├── Intelligence Layer  
│  
└── SERA

├── Production Framework  
│  
└── Forge

└── Validation Project  
└── Excelion

---

# Runtime Flow

Registry

↓

Resolvers

↓

RuntimeContext

↓

Decision Engine

↓

Runner

↓

PluginHost

↓

Plugins

↓

Evidence

↓

State Update

---

# Approved ADR Set

ADR-001 RuntimeContext

ADR-002 Layered Architecture

ADR-003 Registry Pattern

ADR-004 Rule-Based Priority Engine

ADR-005 Plugin-Based Execution Architecture

ADR-006 State and Event Driven Execution Model

ADR-007 Forge as Production Framework

ADR-008 Evidence-First Development Model

ADR-009 Environment Capability Model

ADR-010 Hybrid AI Provider Architecture

Do not renumber ADRs.

Do not replace existing accepted decisions.

---

# Core Principles

Preserve:

- RuntimeContext is immutable.
- Resolvers collect context only.
- Runner is an orchestrator.
- Plugins execute specialized behavior.
- Forge is a reusable production framework.
- SERA is the intelligence layer.
- Atlas Core owns runtime and state.
- Evidence over Assumption.
- Environment capability model.
- Hybrid AI Provider architecture.

---

# Validation Rules

Verify that:

- Layer dependencies remain valid.
- Documentation contains no contradictory architecture.
- Runtime flow is consistent.
- Forge is not described as project-specific.
- SERA is provider-independent.
- Excelion is the validation project.

---

# Constraints

Do NOT:

- redesign Atlas
- rename established components
- invent additional layers
- remove accepted ADRs
- change architectural intent

Update wording only where required for consistency.

---

# Deliverables

1. Update all affected documents.
2. Preserve formatting and Markdown style.
3. Produce a summary listing:

- modified files
- consistency fixes
- unresolved issues (if any)

4. Do not commit automatically.

Wait for user review before any Git commit.

---

# Success Criteria

Atlas documentation is internally consistent.

All documents reflect the Atlas DevOS v1.2 RC Baseline.

No architectural conflicts remain.

Documentation is ready for Git review and commit.

이 프롬프트는 **"문서 동기화"**에 초점을 맞춘 버전이야.

내가 추가로 추천하는 것은 **"Zero Hallucination 모드"**를 앞에 붙이는 거야. 그러면 클라켄이 문서를 추측해서 새로 만드는 일을 크게 줄일 수 있어. 예를 들어 다음 규칙을 프롬프트 맨 앞에 추가하면 돼.

```
Mode: Zero Hallucination

Rules:
1. Use only information present in the repository or this prompt.
2. If information is missing, report it instead of inventing it.
3. Preserve existing architecture unless explicitly instructed otherwise.
4. Never fabricate code, documents, or ADR decisions.
5. Report every modified file before finishing.
```

이 조합이면 저장소의 문서를 현재 확정한 **Atlas v1.2 RC 기준선**에 맞춰 비교적 안정적으로 반영할 수 있어.
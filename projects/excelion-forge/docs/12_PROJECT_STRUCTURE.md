# PROJECT STRUCTURE (프로젝트 구조)

> Status : Draft
> Version : 0.1
> Last Updated : 2026-07-01

---

# 문서의 목적

이 문서는 EXCELION 프로젝트의 저장소 구조와 각 디렉터리의 역할을 정의한다.

프로젝트 규모가 커져도 모든 자료를 일관성 있게 관리할 수 있도록 하는 것을 목표로 한다.

---

# 최상위 디렉터리 구조

```text
excelion-forge/
│
├── .github/
├── addons/
├── blender/
├── docs/
├── marketing/
├── project/
├── references/
├── scripts/
├── tools/
├── unreal/
├── .gitignore
├── LICENSE
└── README.md
```

---

# .github/

GitHub 관리용 파일을 저장한다.

## 포함

* ISSUE_TEMPLATE
* PULL_REQUEST_TEMPLATE
* workflows
* FUNDING
* CODEOWNERS (필요 시)

---

# addons/

Blender 애드온을 관리한다.

예시

```text
addons/
└── exelion_forge/
```

애드온은 Unreal 프로젝트와 독립적으로 개발한다.

---

# blender/

모든 원본 Blender 파일을 저장한다.

예시

```text
blender/
│
├── characters/
├── enemies/
├── weapons/
├── environments/
├── animations/
└── tests/
```

Blend 파일 외의 중간 결과물은 저장하지 않는다.

---

# docs/

프로젝트의 모든 문서를 저장한다.

예시

```text
docs/
│
├── VISION.md
├── 01_DESIGN_PILLARS.md
├── ...
├── 12_PROJECT_STRUCTURE.md
└── archive/
```

완료된 문서는 삭제하지 않는다.

오래된 문서는 archive로 이동한다.

---

# marketing/

홍보 자료를 관리한다.

예시

```text
marketing/
│
├── screenshots/
├── trailers/
├── logos/
├── steam/
└── presskit/
```

---

# project/

프로젝트 관리 자료를 저장한다.

예시

```text
project/
│
├── roadmap/
├── milestones/
├── sprint/
├── meeting_notes/
└── changelog/
```

---

# references/

참고 자료를 저장한다.

예시

```text
references/
│
├── robots/
├── architecture/
├── animation/
├── ui/
└── effects/
```

참고 자료는 수정하지 않는다.

---

# scripts/

자동화 스크립트를 저장한다.

예시

```text
scripts/
│
├── export/
├── import/
├── build/
└── utility/
```

Python 또는 PowerShell 스크립트를 포함한다.

---

# tools/

프로젝트 전용 개발 도구를 저장한다.

예시

```text
tools/
│
├── rig_validator/
├── asset_checker/
└── exporters/
```

독립 실행형 프로그램도 이곳에서 관리한다.

---

# unreal/

Unreal Engine 프로젝트를 저장한다.

예시

```text
unreal/
└── Excelion/
```

프로젝트는 하나만 유지한다.

---

# Git 관리 원칙

Git에서 관리하는 항목

* 문서
* Blender 원본
* Addon
* Script
* Source Code
* 설정 파일

Git에서 제외하는 항목

* DerivedDataCache
* Intermediate
* Saved
* Binaries
* 빌드 결과물
* 임시 파일

.gitignore에서 관리한다.

---

# 폴더 생성 원칙

새로운 폴더는 다음 조건을 만족할 때만 생성한다.

* 명확한 역할이 있다.
* 두 개 이상의 파일이 저장될 가능성이 있다.
* 장기적으로 유지될 필요가 있다.

불필요한 폴더 생성은 지양한다.

---

# 네이밍 규칙

모든 폴더는 다음 규칙을 따른다.

* 영어 사용
* 소문자 사용
* 공백 금지
* 필요 시 snake_case 사용

예시

```text
good

project/
asset_pipeline/
animation/

bad

Project Folder/
Animation Files/
Temp/
```

---

# 프로젝트 원칙

저장소는 단순한 파일 보관소가 아니다.

EXCELION 프로젝트의 모든 자산은

항상 이 구조를 기준으로 관리한다.

# EXCELION FORGE ARCHITECTURE

> Product : Excelion Forge
> Python Package : excelion_forge
> Status : Active
> Version : v0.1
> Last Updated : 2026-07-02

---

# 문서의 목적

이 문서는 Excelion Forge의 현재 구조 흐름을 정의한다.

Blender UI와 검증 로직은 분리한다.

---

# v0.1 구조

```text
UI Panel
    ↓
Operator
    ↓
RigValidator
    ↓
RuleManager
    ↓
ValidationRule
    ↓
ValidationResult
    ↓
ValidationReport
    ↓
Blender Report
```

---

# 책임 분리

| 영역 | 책임 |
| --- | --- |
| core/ | Blender UI와 독립적인 검증 로직 |
| core/manager.py | 등록된 검증 규칙의 순차 실행 |
| core/result.py | 개별 Rule 실행 결과 데이터 |
| core/rules/ | 개별 검증 규칙 |
| operators/ | Blender Operator 실행 흐름 |
| ui/ | 3D View Sidebar 패널 |
| utils/ | Blender context helper |

---

# 원칙

core 모듈은 `bpy.context`에 직접 접근하지 않는다.

Operator와 UI는 context를 받아 필요한 대상만 core에 전달한다.

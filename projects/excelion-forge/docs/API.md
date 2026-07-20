# EXCELION FORGE API

> Product : Excelion Forge
> Python Package : excelion_forge
> Status : Active
> Version : v0.1
> Last Updated : 2026-07-02

---

# 문서의 목적

이 문서는 Excelion Forge v0.1에서 유지할 Python API 기준을 기록한다.

코드 예시는 Python 패키지명인 `excelion_forge`를 사용한다.

---

# v0.1 Public API

```python
from excelion_forge.core import RigValidator
from excelion_forge.core import RuleManager
from excelion_forge.core import ValidationResult
from excelion_forge.core import validate_armature_object
from excelion_forge.core import ValidationReport
from excelion_forge.core import ValidationIssue
from excelion_forge.core import Severity
```

---

# 기본 사용 예

```python
from excelion_forge.core import RigValidator

report = RigValidator().validate(armature)
print(report.summary())
```

```python
from excelion_forge.core import RuleManager

manager = RuleManager()
results = manager.run(armature)
report = manager.validate(armature)
```

---

# 호환성 원칙

공개 API를 변경할 때는 변경 이유와 대체 방법을 문서에 기록한다.

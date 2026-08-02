# ParaModel

Parametric mecha model system for Atlas / Excelion.

## Structure

```
projects/paramodel/
├── addon/                          # Blender addon (v0.2.0)
│   ├── __init__.py
│   ├── operators.py                # Load / Clear / placeholders
│   ├── panels.py
│   └── props.py
├── schema/
│   ├── base-body-slots.json
│   ├── mecha-metadata.schema.json
│   └── mecha-metadata.example.json
└── data/
    ├── mecha/
    │   └── brave-001.json
    └── parts/
        ├── README.md
        ├── head_basic_01.json
        ├── torso_upper_basic_01.json
        ├── torso_lower_basic_01.json
        ├── arm_basic_01.json
        └── leg_basic_01.json
```

## Status

- [x] Base Body slots + position/rotation (PM-1)
- [x] mecha-metadata.schema.json (PM-2)
- [x] Part library + basic parts (PM-3)
- [x] Placeholder cube attach (PM-4, addon v0.2.0)
- [x] state TASK_MAP / CURRENT_STATE (PM-5)

## Blender Addon 설치

1. `projects/paramodel/addon` 폴더를 zip으로 묶어 Install
2. N 패널 → **ParaModel**
3. Data Path = `.../projects/paramodel/data/mecha`
4. Mecha ID = `brave-001` → Load Mecha

## Registered Units

| ID | Name | Codename | Status |
|----|------|----------|--------|
| brave-001 | Brave | EX-BRAVE-001 | concept |

## Notes

- BlenderMCP와 별개
- 슬롯 Empty + part placeholder 큐브까지 지원
- 다음 후보: 실제 mesh import, parameter drivers

# ParaModel

Parametric mecha model system for Atlas / Excelion.

## Structure

```
projects/paramodel/
├── addon/                          # Blender addon (v0.1.0)
│   ├── __init__.py
│   ├── operators.py
│   ├── panels.py
│   └── props.py
├── schema/
│   ├── base-body-slots.json
│   └── mecha-metadata.example.json
└── data/
    └── mecha/
        └── brave-001.json
```

## Status

- [x] Base Body slots definition
- [x] mecha-metadata example
- [x] First real data (brave-001)
- [x] Minimal Blender addon skeleton (v0.1.0)
- [x] Moved under projects/paramodel (2026-08-02)

## Blender Addon 설치

1. Blender → Edit → Preferences → Add-ons → Install
2. `projects/paramodel/addon` 폴더를 zip으로 묶어 설치
3. N 패널 → ParaModel 탭
4. Data Path에 `projects/paramodel/data/mecha` 경로 지정
5. Mecha ID 입력 후 Load Mecha

## Registered Units

| ID | Name | Codename | Status |
|----|------|----------|--------|
| brave-001 | Brave | EX-BRAVE-001 | concept |

## Notes

- BlenderMCP와 별개 프로젝트
- 위치: `projects/paramodel/` (Atlas project domain)
- 현재: 슬롯 Empty 생성만 지원

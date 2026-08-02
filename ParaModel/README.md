# ParaModel

Parametric mecha model system for Atlas / Excelion.

## Structure

```
ParaModel/
├── schema/
│   ├── base-body-slots.json     # Base Body 슬롯/연결점 정의 (v0.1.0)
│   └── mecha-metadata.example.json  # (예정) 전체 메타데이터 예시
└── data/
    └── mecha/
        └── {id}.json            # 실제 기체 데이터
```

## Status

- [x] Base Body slots definition (2026-08-02)
- [ ] mecha-metadata schema finalize
- [ ] First real data registration

## Notes

- Metadata format: JSON
- Scale class baseline: 25m
- Master confirmed slot list 2026-08-02

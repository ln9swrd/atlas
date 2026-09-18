# SoR 잔여 정합 감사 — 2026-08-12

> 범위: `projects/excelion/`의 제품·캐논·운영 문서. 이미지, Meshy, Blender, UE 구현은 HOLD를 유지하며 변경하지 않는다.

## 결론

정본 캐논과 현재 운영 상태는 정합하다. 이 감사에서 확인한 최신 표기 잔여 2건을 수정했다. 나머지 BRAVE·Ashur·구 파일명은 명시된 레거시 또는 분석 이력으로 분류하며, 일괄 변경하지 않는다.

## 판정 기준

1. 실행·상태: `state/CURRENT_STATE.md`, `state/TASK_MAP.md`
2. 명칭: `docs/NAMING_STATUS.md`
3. 스토리·보스: `novel/NOVEL_CANON.md`, `state/BOSS_EP_MAP.md`
4. 기체 스펙: `design/enemy/SEKH_MECHA_SPEC.md`, `design/enemy/WADJET_MECHA_SPEC.md`

## 수정 완료

| 파일 | 발견 | 조치 | 상태 |
|---|---|---|---|
| `PROJECT_MEMORY.md` | 현재 작업·핵심 엔티티가 구 명칭 크레일·아이기스를 사용 | 세크(구 크레일)·와제(구 아이기스)로 정정 | Done |
| `design/character/BOSS_CAST.md` | 이관 완료된 기체 스펙을 "동기화 예정"으로 표기 | `SEKH_MECHA_SPEC.md`·`WADJET_MECHA_SPEC.md` 직접 참조로 정정 | Done |

## 유지 결정

| 항목 | 상태 | 이유 |
|---|---|---|
| AXION / BRAVE | 유지 | Unreal·신규 문서는 AXION LOCK. 기존 소설 원문, 레거시 경로, 기존 설계 본문은 자동 변경 금지 (`NAMING_STATUS`) |
| Ashur 표기 | 유지·분류 | 최종 보스 캐논은 네메시스로 고정. 과거 분석·감사·데이터 ID의 Ashur 표기는 이력이며, 캐논 본문으로 승격하지 않음 |
| `CREIL_*`, `AEGIS_*` 리다이렉트 파일 | 유지 | 정식 스펙 파일로 이관을 안내하는 호환 경로 |
| 시각화·Meshy·Blender·UE | HOLD | `CURRENT_STATE`의 Master Gate 유지 |

## 후속 작업

- P2: `novel/TIMELINE_ANALYSIS.md` 등 과거 분석 문서에 레거시/비정본 헤더가 필요한지 별도 검토한다. 캐논 재서면은 Master 승인 없이는 하지 않는다.
- P2: 소설 본문을 수정하는 별도 작업이 생길 때만 BRAVE 표기를 AXION으로 전환한다. 일괄 치환은 금지한다.

## 검증

- `NAMING_STATUS`의 AXION LOCK, `NOVEL_CANON`의 네메시스·세크·와제, `BOSS_EP_MAP`의 EP15·EP21 배치를 대조했다.
- `CURRENT_STATE`와 `TASK_MAP`의 HOLD 상태를 확인했으며, HOLD 범위의 구현·시각화 변경은 하지 않았다.

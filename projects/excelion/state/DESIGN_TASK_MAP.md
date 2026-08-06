# DESIGN_TASK_MAP — Excelion

> 2026-08-06 · 스토리 SoR 완료 후 디자인 전환  
> Art root: `design/` · 문서 고정: `state/` · `docs/06_MECHA.md`

## 원칙

- 스토리 > 플레이 > 디자인(가변)이나, **식별·제작 가능**이 되면 잠금
- 기존 `design/brave/` · `design/nemesis/` 컨셉 재사용 우선 · 새로 그리기 전 고정 스펙부터
- 1인+AI 운용 가능 단위만 Open

---

## 목록 (우선순)

| ID | 항목 | 상태 | 산출물 | 비고 |
|----|------|------|--------|------|
| **D1** | **BRAVE 프레임 고정** | **Active** | `design/brave/FRAME_SPEC.md` + 참조 이미지 선정 | 기존 컨셉 다수 있음 → 잠금 스펙 |
| D2 | 엑셀리온(EP13) 전개 1단계 | Open | 실루엣 확장 규칙 1장 | BRAVE 동일 골격 |
| D3 | 적 기체 식별 (GRUNT/HEAVY/GUN/MID) | Open | 실루엣 키 4종 | 장식 최소 |
| D4 | 세스기 | Open | 단정·차단 실루엣 | ≠ 아슈르 |
| D5 | 아슈르기 | Open | 위계·길이·원격 | design/nemesis 후보 검토 |
| D6 | 인물 실루엣 시트 (리아·카이·유나·레이) | Open | 4인 식별 테스트 | NAMES 표 기반 |
| D7 | 아슈르·세스 인물 실루엣 | Open | 위계 vs 차단 | 손 안 보임 / 무표정 |
| D8 | 광기 시각 (손·시야·BRAVE 빛) | Open | 단계 0–5 레퍼런스 | MADNESS 연동 |
| D9 | 1차 애니 10컷 썸네일 | Open | ANIME_PASS1 보드 | 제작 검증용 |
| D10 | UI 최소 (동조율·목표·통신) | Open | 3요소만 | 과장 UI 금지 |
| D11 | 맵 무드 (지구 수성/공성 · 달 · 게이트) | Open | 3무드 | 후순위 |

---

## 진행 규칙

1. **한 번에 하나** (Active 1개)
2. 완료 시 Status=Done · CURRENT_STATE·TASK_MAP 갱신
3. 이미지 원본은 `design/` · 스펙 문서는 `design/.../FRAME_SPEC` 또는 `state/`

---

## 현재 Active

**D1 BRAVE 프레임 고정**

다음 작업: 기존 `design/brave/` 컨셉 정리 → 고정 스펙(전면/측면/실루엣/색/금지) 문서화

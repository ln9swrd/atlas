# UNREAL_PREPARATION_STATUS — Excelion

> Updated: 2026-08-10  
> Work order: `state/WORK_ORDER_UNREAL_PREP.md`  
> 기준 커밋 시작점: 99a66cf

---

## 완료

### 조사
- README · PROJECT_CHARTER · VISION · PLAY_BRAVE · COMBAT · mecha FINAL/스펙 · VERTICAL_SLICE_EP1_6_8 · SUPER_ROBOT_DESIGN_LANGUAGE · 파이프라인 스펙 확인
- 장르: Mission-Based 3D Action · 슈퍼로봇 · 소년만화 열혈+광기
- 플레이어: BRAVE (리아) · 적: ORD · 보스: 세스/네메시스 등
- 전투: S-Core · Phase 패턴 · HP% 전환 금지
- 디자인: SUPER ROBOT FIRST · 건담/리얼로봇 금지

### 생성 문서
| 경로 | 내용 |
|------|------|
| docs/UNREAL_DEVELOPMENT_CHARTER.md | 목적·범위·VS·우선순위 |
| docs/UNREAL_ARCHITECTURE.md | C++/BP · Input · UI · Anim · AI · VFX · Data · Save |
| docs/TECHNICAL_REQUIREMENTS.md | 해상도·FPS·액터·성능 (TBD 명시) |
| design/gameplay/CORE_GAMEPLAY.md | 탐색→조우→전투→보상→다음 |
| design/gameplay/COMBAT_SYSTEM.md | 이동~전투종료 · 구현 후보·데이터 |
| design/mecha/MECHA_SYSTEM.md | Base/Player/Enemy/Boss · 공유 구조 |
| design/mecha/MECHA_DATA_SCHEMA.md | Data Asset 주 경로 · 필드 |
| design/art/ART_DIRECTION.md | 슈퍼로봇 아트 방향 |
| design/art/MECHA_MODELING_GUIDELINE.md | 모델링·토폴로지·체크 |
| design/art/MATERIAL_GUIDELINE.md | 3톤·MI |
| design/art/VFX_GUIDELINE.md | 피드백 VFX |
| docs/ASSET_REGISTER.md | 확정 에셋만 등록 |
| docs/VERTICAL_SLICE.md | Unreal VS 범위 (기존 EP 잠금 우선) |
| state/UNREAL_PREPARATION_STATUS.md | 본 문서 |

### Git
- 작업지시 등록 및 본 문서 세트 커밋 완료 (상세 SHA는 최종 보고 참조)

---

## 진행 중

- 없음 (문서 세트 1차 완료)

---

## 미착수

- Unreal 프로젝트 생성
- C++/Blueprint 코드 구현
- 메쉬·애니 실제작
- Meshy/Blender 실작업 (파이프라인 TBD 해소 전)

---

## 결정 필요

| # | 항목 | 비고 |
|---|------|------|
| 1 | UE 버전 (5.x 세부) | 파이프라인 G2와 동일 |
| 2 | VS 보스 선택 (세스 vs 몬투) | docs/VERTICAL_SLICE |
| 3 | 목표 해상도/FPS 최종 | TECHNICAL_REQUIREMENTS |
| 4 | Root motion A/B · 애니 fps · 본 이름 | MESHY_BLENDER_PIPELINE_SPEC G3–G6 |
| 5 | 카메라 수치 | TBD |
| 6 | 동시 액터·VFX 상한 | 측정 후 |
| 7 | GAS(Attribute) 도입 여부 | 1차 단순 컴포넌트 권장 |

---

## 다음 작업

1. Master 검토 (충돌·구현 가능성·과설계·확장성·VS 현실성·문서 일관성)
2. 결정 필요 항목 중 VS 직전 필수분 확정
3. (승인 후) Unreal 프로젝트 생성 · 최소 골격 (이동·히트·S-Core)
4. ASSET_REGISTER 상태 갱신과 병행

---

## 연속 작업 메모

- 기존 TEXT-LOCK·SUPER_ROBOT·EP1/6/8 잠금 **변경하지 않음**
- 수치 확정은 임의로 하지 않고 TBD 유지
- 중단 시 본 문서의 완료/미착수/결정 필요만 보면 이어갈 수 있음

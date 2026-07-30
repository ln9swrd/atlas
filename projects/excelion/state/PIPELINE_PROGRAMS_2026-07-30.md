# 엑셀리온 전체 파이프라인 프로그램 구체화

> Date: 2026-07-30  
> Source: Chat 구체화 요청 (파이프라인을 모두 소화할 수 있게)  
> Status: Reference / Implementation guide  
> Related: `AI_PIPELINE_TOOLS_2026-07-30.md`

---

## 목적

Blender 제작 → 검증 → Export → Unreal 임포트 → 게임플레이 → 콘텐츠 운영  
전 구간을 실제 운용 가능한 프로그램으로 정의한다.

원칙:
- 도구 = 초안·검사·반복·규칙 강제
- 사람 = 결정·품질 통과·직접 수정
- 모든 실행은 증거를 남긴다

---

## 1. Excelion Forge (Blender Add-on) — 핵심 제작 플랫폼

| 모듈 | 구체 기능 | 출력 |
|------|-----------|------|
| **Parametric Generator** | 파라미터(키/어깨/팔 길이, 장갑 두께 등)로 기본 메쉬 + 본 생성 | `.blend` + 기본 Armature |
| **Rig Validator** | 본 구조·네이밍·스케일·피벗·루트 본·L/R 대칭 검사 | Issue 리스트 + HTML 리포트 |
| **Weight Assist** | 자동 웨이트 초안 + 문제 부위 하이라이트 | Weight 수정 대상 표시 |
| **Animation Draft** | Idle / Walk / Boost / Landing / Fire 기본 Action 생성 | Action 목록 |
| **Export Guard** | Apply Transform, Export Collection만 선택, FBX 설정 강제 | 규칙 통과 FBX |
| **Evidence Logger** | 모든 검사·Export 결과를 JSON + 로그로 기록 | 실행 증거 파일 |

**구현 우선 순서**
1. Rig Validator
2. Export Guard
3. Parametric Generator (최소 버전)
4. Weight Assist / Animation Draft

위치: `projects/excelion-forge`

---

## 2. Asset Bridge (Unreal Editor Utility / 최소 Plugin)

| 기능 | 구체 동작 |
|------|-----------|
| **Reimport Pipeline** | FBX 경로 감시 → Skeleton 재사용 → Material 슬롯 규칙 적용 |
| **Import Rule Checker** | 스케일·회전·Skeleton 일치·Physics Asset 유무 검사 |
| **Material Slot Enforcer** | Armor / Frame / Energy / Glass 슬롯만 허용 |
| **Naming Validator** | `SK_Excelion_*`, `SK_Enemy_*` 등 네이밍 강제 |
| **Evidence Report** | 임포트 결과 + 오류를 JSON으로 저장 |

---

## 3. Pipeline Runner (독립 CLI / 로컬 앱)

전체 파이프라인을 한 번에 돌리는 실행기.

```text
Blender (.blend)
    ↓ (Forge Export Guard)
FBX
    ↓ (Asset Bridge Reimport)
Unreal Asset
    ↓
검증 리포트 + 증거 로그
```

**필수 기능**
- 단계별 실행 / 실패 시 중단
- 각 단계 증거 파일 생성
- 설정 파일로 경로·규칙 관리
- 배치 처리 (여러 에셋 순차 실행)

---

## 4. Unreal 게임 시스템 도구 (Editor Utility 중심)

| 프로그램 | 역할 |
|----------|------|
| **Mecha Movement Helper** | 부스트·대시·착지·부유 공통 이동 로직 템플릿 |
| **Combat Feel Tuner** | 데미지·경직·히트스탑·카메라 흔들림 수치 실시간 실험 (DataTable 연동) |
| **Mission Layout Assist** | 스폰 포인트·목표 위치·경로 후보 자동 배치 |
| **Heat / Overdrive Debugger** | Heat 수치·Overdrive 발동 조건 시각화 |
| **Enemy Role Template** | Drone / Elite / Boss 역할별 AI·체력·패턴 기본 세트 |

---

## 5. 콘텐츠 · 데이터 관리 도구

| 프로그램 | 역할 |
|----------|------|
| **Asset Registry** | 에셋 버전·검증 통과 여부·사용처 관리 (JSON/DB + 간단한 UI) |
| **Data Asset Generator** | 무기·적·미션 수치를 DataTable / Primary Data Asset으로 생성 |
| **Mission Config Tool** | 미션 목표·보상·실패 조건·난이도를 데이터로 정의 |

---

## 6. AI 연동 레이어 (후순위)

| 프로그램 | 역할 |
|----------|------|
| **AI Task Bridge** | Cline / Ollama → Forge / Unreal 도구 호출 → 결과·증거 반환 |
| **Prompt-to-Pose** | 텍스트 프롬프트로 기본 포즈 초안 생성 (Forge 연동) |

---

## 파이프라인 전체 흐름

```text
[파라미터 입력]
    ↓ Parametric Generator
[메쉬 + 본]
    ↓ Rig Validator + Weight Assist
[리깅 완료]
    ↓ Animation Draft
[기본 애니]
    ↓ Export Guard
[FBX]
    ↓ Pipeline Runner
[Unreal 임포트]
    ↓ Asset Bridge
[검증된 스켈레탈 메시]
    ↓ Mecha Movement Helper + Combat Feel Tuner
[플레이 가능 기체]
    ↓ Mission Layout Assist + Data Asset Generator
[미션 · 적 · 데이터]
```

---

## 구현 우선순위 (실제 운용 기준)

1. **Forge – Rig Validator + Export Guard** (지금 당장 안정화)
2. **Pipeline Runner** (Blender ↔ Unreal 연결)
3. **Asset Bridge** (재임포트 + 규칙 검사)
4. **Parametric Generator** (최소 파라미터 버전)
5. **Mecha Movement Helper + Combat Feel Tuner**
6. 나머지 자동화·AI 도구

---

## 관련 문서

- `projects/excelion/state/AI_PIPELINE_TOOLS_2026-07-30.md` — 이전 요약
- `projects/excelion-forge/README.md`
- `projects/excelion-forge/docs/15_ASSET_PIPELINE.md`
- `projects/excelion-forge/docs/13_UNREAL_ARCHITECTURE.md`
- `projects/excelion/state/PLANNING_GAPS_2026-07-30.md`

---

## Next

- Forge 최소 모듈 스펙 문서화 (Rig Validator + Export Guard)
- 또는 Rig Validator 증거 기준 정의

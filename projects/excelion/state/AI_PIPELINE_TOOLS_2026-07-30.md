# AI 지원 파이프라인 도구 정리

> Date: 2026-07-30  
> Source: Chat 분석 (Blender → Unreal 파이프라인 + AI 보조 프로그램 필요성)  
> Status: Draft / Reference

---

## 목적

엑셀리온 게임 개발 파이프라인 각 단계에서 AI 도움을 받는 프로그램을 정의한다.  
사람은 결정·판단·품질 수정을 담당하고, 도구는 초안·검사·반복 작업을 담당한다.

핵심 원칙:
- AI/도구 = 초안·검사·반복
- 사람 = 수정·선택·품질 통과
- 모든 도구는 실행 증거를 남긴다 (Atlas 원칙)

---

## 1. Blender 쪽 (에셋 제작) — 최우선

| 프로그램 | 형태 | 역할 | 사람 역할 |
|----------|------|------|-----------|
| **Excelion Forge** | Blender Add-on | 핵심. 캐릭터/메카 생성·리깅·검증·Export 규칙 강제 | 최종 형태·웨이트·애니 방향 수정 |
| Rig Validator | Forge 내부 모듈 | 본 구조·네이밍·스케일·피벗 자동 검사 | 오류 보고 보고 수정 |
| Weight Assist | Forge 또는 별도 | 자동 웨이트 초안 + 문제 부위 하이라이트 | 관절 부위 직접 페인팅 |
| Animation Draft | Forge 또는 스크립트 | Idle/Walk/Boost 등 기본 동작 초안 생성 | 임팩트·타이밍 조정 |
| Export Guard | Forge 모듈 | Apply Transform, Collection, FBX 설정 자동 적용 | Export 전 최종 확인 |

기존 방향: `projects/excelion-forge` = Blender Add-on 기반 제작·검증 시스템.

---

## 2. Unreal 쪽 (레벨 · 게임플레이)

| 프로그램 | 형태 | 역할 | 사람 역할 |
|----------|------|------|-----------|
| **Asset Bridge** | Unreal Plugin 또는 Editor Utility | FBX 재임포트, Skeleton 재사용, Material 슬롯 규칙 강제 | 임포트 결과 확인 |
| Mecha Movement Helper | Unreal Plugin / Blueprint 라이브러리 | 부스트·대시·착지 등 공통 이동 로직 템플릿 | 타격감·카메라 최종 조정 |
| Combat Feel Tuner | Editor Utility + DataTable | 데미지·경직·히트스탑 수치 빠르게 실험 | 플레이 후 체감 결정 |
| Mission Layout Assist | Editor Utility | 스폰 포인트·목표 위치 후보 배치 | 동선·난이도 확정 |

---

## 3. 파이프라인 연결 / 독립 앱

| 프로그램 | 형태 | 역할 |
|----------|------|------|
| **Pipeline Runner** | 독립 앱 또는 CLI | Blender → FBX → Unreal 재임포트까지 한 번에 실행 + 로그/증거 기록 |
| Asset Registry | 간단한 DB/JSON + UI | 에셋 버전·검증 통과 여부 관리 |
| AI Task Bridge | 독립 서비스 또는 로컬 API | Cline/Ollama와 Forge·Unreal 도구 연결 (작업 지시 → 결과 → 증거) |

---

## 4. 구현 우선순위

1. **Excelion Forge (Blender Add-on)**  
   - Rig Validation  
   - Export Guard  
   - 기본 캐릭터/메카 생성 파이프라인  

2. **Asset Bridge (Unreal 최소 도구)**  
   - 재임포트 + 규칙 검사  

3. **Pipeline Runner**  
   - 두 도구 연결 + 실행 증거  

4. 이후  
   - Weight Assist, Animation Draft, Combat Feel Tuner 등

---

## 5. 사람이 반드시 하는 일 (파이프라인 공통)

1. 취향·방향 결정 (이게 엑셀리온인가?)
2. 최종 품질 판단 (통과/반려)
3. 플레이 감각 결정 (타격감, 속도, 재미)
4. 우선순위 결정 (지금 무엇을 만들지)
5. 품질을 위한 직접 수정 (웨이트, 타이밍, 밸런스 등)

---

## 6. 관련 문서

- `projects/excelion/README.md` — 엔진·Blender 역할
- `projects/excelion-forge/README.md` — Forge 목표
- `projects/excelion-forge/docs/15_ASSET_PIPELINE.md` — Blender→Unreal 규칙
- `projects/excelion/state/PLANNING_GAPS_2026-07-30.md`
- `projects/excelion/state/DESIGN_REVIEW_2026-07-30.md`

---

## 7. Next

- Forge 최소 모듈 목록 확정 (Rig Validation + Export Guard 우선)
- Unreal은 Plugin보다 Editor Utility로 시작 여부 결정
- 세계관 단일화 작업과 병행 가능 (docs-first)

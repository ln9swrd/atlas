# Excelion Unreal Prototype Readiness

**조사일:** 2026-08-11  
**시작 SHA:** `c4263cbbc297e3dda631ec2915a43fca8d3cb139`  
**대상:** `projects/excelion/game/Excelion/`  
**목적:** 첫 MVP Prototype 착수 가능 여부·최소 범위 확정 (구현·원본 변경 없음)

---

## 1. Current Unreal Project State

| 항목 | 상태 |
|------|------|
| `Excelion.uproject` | **존재** · `EngineAssociation`: **5.3** · Module `Excelion` Runtime |
| `Source/` | **존재** · `Excelion.Build.cs` · `Excelion.cpp/h` · `Excelion.Target.cs` · `ExcelionEditor.Target.cs` |
| `Config/` | **존재** · DefaultEngine/Game/Input (내용 있음) · **DefaultEditor.ini = 0 byte** |
| `Content/` | **없음** |
| `Plugins/` | uproject에 ModelingToolsEditorMode만 · 로컬 Plugins 디렉터리 없음 |
| `Binaries/` · `Intermediate/` · `Saved/` | **없음** (로컬 생성물 · Git 미추적 정상) |
| C++ 모듈 코드 | 기본 `IMPLEMENT_PRIMARY_GAME_MODULE` 만 · GameMode/Pawn/Input 클래스 **미구현** |
| Build.cs 의존성 | Core, CoreUObject, Engine, InputCore |
| `.vsconfig` | VS Native Game workload 구성 명시 (Windows 개발 PC용) |

Git 추적 = 스켈레톤만. Content/빌드 산출물 없음.

---

## 2. Existing Documentation

| 문서 | 요지 |
|------|------|
| `docs/UNREAL_ARCHITECTURE.md` | UE 5.x · C++ 핵심 · Enhanced Input · UMG · 최소 컴포넌트 구조 |
| `docs/UNREAL_DEVELOPMENT_CHARTER.md` | Mission-Based 3D Action · PC Win64 · 세스 P0 · 슈퍼로봇 방향 |
| `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md` | 사전 결정 묶음 |
| `docs/UNREAL_IMPLEMENTATION_READINESS.md` | **READY WITH CONDITIONS** · UE **5.4.x** LOCK · GAS 제외 · 최소 골격 |
| `state/UNREAL_PREPARATION_STATUS.md` | 준비 상태 기록 |
| `state/WORK_ORDER_UNREAL_PREP.md` | 문서/아키텍처 작업지시 |
| `state/WORK_ORDER_UNREAL_FIRST_BUILD.md` | 첫 성공: AXION 스폰→이동→공격/히트→Damage→S-Core · 보스/UI/VFX/스토리 금지 |
| `docs/PLAYBOOKS/Unreal.md` | 실무 노트 (짧음) |
| `state/CURRENT_STATE.md` | **UE 실기 (M6) = HOLD** · Meshy/Blender/UE 구현 HOLD |

---

## 3. Actual vs Documented State

| 문서 기대 | 실제 트리 | 일치 |
|-----------|-----------|------|
| `.uproject` C++ Win64 | 있음 · EngineAssociation **5.3** | 부분 (문서는 **5.4.x** LOCK) |
| GameMode / BaseMecha / Input | **없음** (모듈 스텁만) | 불일치 — 다음 구현 단계 |
| Enhanced Input | DefaultInput.ini에 Enhanced 클래스 기본값 | Config 수준만 |
| Prototype / 테스트 맵 | Content 없음 · DefaultMap = `/Engine/Maps/Templates/OpenWorld` | 엔진 템플릿 의존 |
| 첫 빌드 성공 기준 (AXION 루프) | 코드 미구현 | 미착수 |
| UE 설치·Editor 실행 | **본 조사 환경에 UE 없음** | 실행 검증 불가 |

버전: uproject **5.3** vs readiness 문서 **5.4.x** → 착수 전 **패치 LOCK 정합** 필요.

---

## 4. Build / Editor Readiness (본 환경)

| 질문 | 답 |
|------|----|
| Q1. uproject 존재? | **YES** |
| Q2. Unreal이 프로젝트 인식? | **미검증** — 이 환경에 Unreal Editor/UBT **미설치** |
| Q3. C++ 모듈 빌드? | **BLOCKED** (UBT/UE 없음 · g++/clang만 존재) |
| Q4. Editor 실행? | **BLOCKED** |
| Q5. 빈/기본 레벨 로드? | **BLOCKED** (Editor 불가 · Content 없음) |
| Q6. Prototype map 준비? | **MISSING** |

**본 에이전트/샌드박스 환경: 빌드·PIE 실행 불가 → 실행 검증은 BLOCKED.**

개발 PC에 UE 5.3 또는 5.4 + VS toolchain이 있으면 스켈레톤 개방·생성 단계는 가능 후보.

---

## 5. Prototype Goal

Excelion의 **기본 플레이 루프를 Unreal에서 한 번이라도 실행**할 수 있는지 검증한다.

문서상 첫 성공 기준 (`WORK_ORDER_UNREAL_FIRST_BUILD`):

> 플레이스홀더 기체(AXION) 스폰 → 이동 → 공격/히트 → Damage → S-Core(가칭) 상태 변화

Canon·메카 디자인·스토리 변경 없이, **기술 골격만** 확인한다.

---

## 6. Minimum Prototype Scope

| 기능 | Prototype | 이후 |
|------|-----------|------|
| Boot (모듈 로드·GameMode) | **YES** | |
| Main/Prototype Map | **YES** (최소 테스트 맵) | |
| Player (BaseMecha/AXION placeholder) | **YES** | |
| Camera (3인칭 추적 최소) | **YES** | |
| Input (Move · Look · Attack 최소) | **YES** | |
| Core Gameplay (Hit → Damage → S-Core 게이지) | **YES** (최소) | |
| Enemy | **NO** | 이후 |
| Boss | **NO** | 이후 (세스) |
| UI | **NO** | 이후 |
| Save | **NO** | 이후 |
| Story | **NO** | 제외 |
| Audio | **NO** | 이후 |
| VFX / Niagara | **NO** | 이후 |
| Full Art Assets | **NO** | Meshy/Blender 파이프라인 |

권장 최소 흐름:

```
Boot → Prototype Map → Player spawn → Camera + Input
→ 이동 → (키) 공격/히트 → Damage → S-Core 상태 변화 → PIE 종료
```

---

## 7. Dependencies

| 항목 | 상태 |
|------|------|
| Unreal Engine (문서 5.4.x / uproject 5.3) | **BLOCKED** (본 환경 미설치) · 개발 PC는 **MISSING until install** |
| Engine 버전 LOCK 정합 | **MISSING** (5.3 vs 5.4 불일치) |
| Visual Studio / MSVC (Win64) | **OPTIONAL** 본 환경 · 개발 PC **REQUIRED** |
| C++ module 스켈레톤 | **READY** (최소) |
| Enhanced Input 플러그인/설정 | Config 기본값 **READY** · IA/IMC 에셋 **MISSING** |
| GameMode | **MISSING** |
| PlayerController / Pawn·Character | **MISSING** |
| Camera | **MISSING** |
| Prototype Map (Content) | **MISSING** |
| Damage / S-Core Component | **MISSING** |
| Master HOLD (M6 UE 실기) | **BLOCKED** until Master lifts HOLD |

---

## 8. Excluded Scope (명시)

- 보스 AI · Phase · 세스 전투
- 풀 전투 콤보 · Heat 완성
- UMG HUD · 결과 화면
- Niagara · 완성 메시·애니
- 스토리·시네마틱·세이브
- Canon / novel / design 메카 스펙 변경
- GAS 도입
- repository cleanup · archive

---

## 9. Completion Criteria (첫 Prototype)

- [ ] UE 버전 선정·문서 LOCK (5.3 유지 또는 5.4로 uproject 정합 — **승인 후**)
- [ ] 프로젝트 빌드 성공 (Win64)
- [ ] Unreal Editor 실행
- [ ] Prototype Map 로드
- [ ] PIE/Standalone 게임 실행
- [ ] Player 스폰 · 이동 입력
- [ ] Camera 추적
- [ ] 공격/히트 → Damage → S-Core 상태 변화 (최소)
- [ ] 정상 종료 · 치명 로그 없음
- [ ] Git 기록

---

## 10. Risks / Blockers

| 위험 | 심각도 | 비고 |
|------|--------|------|
| 본 환경 UE 미설치 | **Blocker** (실행 검증) | 추측 빌드 성공 보고 금지 |
| CURRENT_STATE M6 HOLD | **Blocker** (정책) | Master HOLD 해제 전 실기 착수는 DECISION REQUIRED |
| uproject 5.3 vs 문서 5.4.x | Medium | 착수 전 한 버전으로 LOCK |
| Content 전무 | Medium | 맵·입력 에셋 생성 필요 |
| First Build 범위 초과 유혹 | Medium | WORK_ORDER 범위 준수 |

설계(Canon) 충돌: Prototype이 문서 루프를 구현하는 한 **DESIGN BLOCKED 아님**.  
스토리/메카 설정 변경 요구 시 즉시 중단·보고.

---

## 11. Recommendation

### Final Verdict: **BLOCKED** (본 조사 환경 기준)

실행 가능한 근거:

1. Unreal Engine / UBT / Editor **미설치** → Q2–Q5 검증 불가  
2. `state/CURRENT_STATE.md` 상 **UE 실기 (M6) HOLD**

### 개발 PC (UE + VS 보유) 가정 시: **READY WITH CONDITIONS**

조건:

1. Master가 M6 HOLD 해제 또는 Prototype 예외 승인  
2. Engine 버전을 **5.3 또는 5.4.x 중 하나로 LOCK** 하고 uproject·문서 정합  
3. 최소 범위만 (`WORK_ORDER_UNREAL_FIRST_BUILD`) — Enemy/Boss/UI/VFX/Story 제외  
4. Content·GameMode·Player·Input·Damage·S-Core를 **신규 구현** (현재 스켈레톤만 존재)

### 다음 승인 후 작업 (이번 커밋에 포함하지 않음)

1. HOLD/버전 DECISION  
2. UE 설치 · 패치 기록  
3. GameMode + placeholder Pawn + Enhanced Input Move/Look/Attack  
4. 테스트 맵 · Damage/S-Core 최소  
5. Build/Run 증거 · Git

---

## Changes (본 작업)

| 영역 | 변경 |
|------|------|
| Game source | 0 |
| Content | 0 |
| Config | 0 |
| Design / Novel / State | 0 |
| Documentation | **1** (본 파일) |

Excelion 원본·Unreal 프로젝트 파일 미수정.

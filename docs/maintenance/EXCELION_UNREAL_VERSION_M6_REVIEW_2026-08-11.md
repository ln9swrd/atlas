# Excelion Unreal Version & M6 HOLD Review

**조사일:** 2026-08-11  
**시작 SHA:** `0864954810a90e489de828b225059377628492b8`  
**대상:** UE 5.3 vs 5.4.x 충돌 · M6 UE 실기 HOLD 해제 조건  
**금지 준수:** `game/Excelion` · design · novel · state · excelion docs **미수정**

---

## 1. Scope

- 버전 충돌 근거 수집 및 권고
- M6 HOLD 정의·사유·해제 조건 정리
- Prototype 착수 Gate 정의
- **구현·uproject 변경·Content 생성 없음**

---

## 2. Current Version State

| 출처 | 버전 | 성격 |
|------|------|------|
| `Excelion.uproject` `EngineAssociation` | **5.3** | 실제 프로젝트 파일 |
| 커밋 `58b37d0` 메시지 | **Unreal 5.3.2** project skeleton | 스켈레톤 복원 시점 |
| `UNREAL_PRE_IMPLEMENTATION_DECISIONS.md` | **5.4.x** | **P0 LOCK (Master 승인 2026-08-10)** |
| `UNREAL_IMPLEMENTATION_READINESS.md` | **5.4.x** | Readiness LOCK |
| `WORK_ORDER_UNREAL_FIRST_BUILD.md` | **5.4.x** 설치 → 패치 LOCK | 첫 빌드 순서 |
| `UNREAL_DEVELOPMENT_CHARTER.md` | UE 5.4.x 설치 환경 | 다음 단계 |
| `NOVEL_TO_GAMEPLAY_READINESS.md` | UE 5.4.x | P0 요약 |
| `UNREAL_ARCHITECTURE.md` | **5.x (TBD)** | 아키텍처 초안 · 세부 미고정 |
| 본 조사 환경 | UE **미설치** | 실행 검증 불가 |

---

## 3. Version Evidence

### 3.1 프로젝트

- `EngineAssociation`: `"5.3"`
- Target.cs: `EngineIncludeOrderVersion.Unreal5_3`
- Git: `58b37d0` *feat(excelion): restore Unreal 5.3.2 project skeleton (AXION prototype base)* — uproject/Source/Config 일괄 추가
- Content 없음 · 모듈 스텁만 → **버전 종속 게임코드 거의 없음** (마이그레이션 비용 낮음)

### 3.2 문서 LOCK 근거 (`UNREAL_PRE_IMPLEMENTATION_DECISIONS`)

- **결정: UE 5.4.x** · Master 승인 2026-08-10
- 개발 시작 시 **5.4 계열 특정 패치** 선정·전체 동일 버전
- 5.5/5.6 업그레이드는 별도 검토
- 근거: 신규 프로젝트·설계 5.4 기준·EI/Niagara/UMG/BT 충분·고정이 재현성에 유리

### 3.3 이력 순서

1. 문서 P0 LOCK **5.4.x** (`aa69273` 등)
2. 이후 스켈레톤 **5.3.2** 복원 (`58b37d0`) — 문서 LOCK을 덮어쓴 결정 기록 없음

→ **정책 SoR = 문서 LOCK 5.4.x** · **파일 현실 = 5.3 스켈레톤** 불일치.

---

## 4. Version Compatibility Assessment

| 관점 | 5.3 유지 | 5.4.x 정합 |
|------|----------|-----------|
| 문서/P0 LOCK | 위반 | 일치 |
| 현재 uproject | 일치 | 변경 필요 (승인 후) |
| 코드 마이그레이션 | 불필요 | 스켈레톤 수준 → 낮음 |
| First Build 작업지시 | 5.4.x 전제 | 일치 |
| 패치 고정 | 5.3.x 패치도 미기록 | 5.4 패치도 미선정 (개발 PC) |
| Prototype 기능 필요 | 최소 골격은 5.3으로도 가능 | 5.4 LOCK 정책상 불필요 기능 없음 |

5.3을 “최신”이 아니라서 버리는 것이 아니라, **이미 Master LOCK된 5.4.x와 파일이 어긋남**이 핵심.

---

## 5. Recommended Version

**판정: MIGRATE TO 5.4.x** (정책·작업지시 정합)

| 항목 | 내용 |
|------|------|
| 권고 엔진 라인 | **UE 5.4.x** |
| 패치 | 개발 PC 설치 시 **사용 가능한 5.4 패치를 하나 선정·문서 기록** (LOCK 문서 요구) |
| uproject | 승인 후 `EngineAssociation` 및 Target IncludeOrder를 5.4에 맞게 갱신 |
| 5.3 유지 | Master가 LOCK을 **명시적으로 5.3으로 개정**할 때만 |

**이번 작업에서 uproject 미변경.** 실행은 별도 승인.

대안 표현: 파일 변경 전 Master 확인이 필요하면 운영상 **DECISION REQUIRED (실행)** 이나, **근거상 권고는 5.4.x 명확**.

---

## 6. M6 Definition

문서에 **M6 전용 정의 문서는 없음.**

`state/CURRENT_STATE.md` Hold 표:

| 항목 | 상태 |
|------|------|
| UE 실기 (M6) | **HOLD** |
| Meshy/Blender/UE 구현 | HOLD |
| M5 Visualization / PNG | HOLD / Queued |

해석 (문서 교차):

- **M6 ≈ Unreal 실기(코드·Editor·Build/Run) 단계**
- 회사 사전준비는 `UNREAL_PREPARATION_STATUS` 상 **종료** · **미착수 = Unreal 프로젝트 최소 골격·Build/Run** (스켈레톤 복원 이후에도 실기 루프 미완)
- 제품 Next(ORD-GRUNT 실루엣 텍스트)와 **분리된 실기 HOLD**

임의로 M0–M5 전체 로드맵을 창작하지 않음. CURRENT_STATE에 명시된 **UE 실기 (M6)** 만 다룸.

---

## 7. M6 HOLD Reason

문서에 적힌 사유:

1. **개발 PC / UE 환경 대기** — Prep 종료 후 First Build는 개발 PC (`WORK_ORDER_UNREAL_FIRST_BUILD`, `UNREAL_PREPARATION_STATUS`)
2. **실기 미착수** — Build/Run·최소 골격 구현 전
3. **정책 HOLD** — CURRENT_STATE가 UE 실기를 HOLD로 명시 (자동 해제 조건 문장 없음)
4. (연관) Meshy/Blender/UE 구현 HOLD · 파이프라인 TBD 유지

**없는 것:** “M6 해제 체크리스트” 단일 공식 문서.

---

## 8. M6 Release Conditions

문서에 **명시된 것**과 **권고(RECOMMENDED)** 를 분리.

| 조건 | 출처 성격 | 현재 상태 | 필요한 조치 |
|------|-----------|-----------|-------------|
| UE 5.4.x 설치 | 문서 LOCK / First Build | 본 환경 **미설치** · 개발 PC 미확인 | 개발 PC에 5.4.x 설치 · 패치 기록 |
| 패치 버전 LOCK·기록 | PRE_IMPLEMENTATION / Readiness | **미선정** | 선정 후 문서/상태 기록 |
| uproject ↔ 문서 버전 정합 | 본 조사 | **5.3 vs 5.4 불일치** | 승인 후 5.4로 맞춤 **또는** LOCK 개정 |
| Visual Studio / Win64 toolchain | .vsconfig · First Build Win64 | 본 환경 해당 없음 | 개발 PC 준비 |
| 프로젝트 개방·인식 | First Build 전제 | 본 환경 검증 불가 | UE로 uproject 개방 |
| C++ 빌드 성공 | First Build 성공 기준 | 미실시 | UBT 빌드 |
| Editor / PIE | First Build | 미실시 | Editor 실행 |
| Master HOLD 해제 | CURRENT_STATE 정책 | **HOLD 유지** | **Master 승인** (문서상 자동 조건 없음) |
| Prototype Map | First Build 단계 | Content **없음** | 구현 단계 (착수 후) |
| GameMode/Player/Input/Damage/S-Core | First Build 범위 | **미구현** | 구현 단계 (착수 후) |

**RECOMMENDED (문서 직접 문장 아님, 운영상):**

- G0 버전 결정 확정 후 HOLD 해제 논의
- HOLD 해제와 “첫 코드 커밋”을 같은 Master 게이트로 묶을 것

**현재 충족 여부:** M6 실기 해제 조건 **미충족** (환경 + 버전 정합 + Master HOLD).

---

## 9. Development PC Requirements

기존 LOCK/작업지시 기준 최소:

| 항목 | 요구 | 확정 근거 |
|------|------|-----------|
| OS | **Windows · Win64** | PRE_IMPLEMENTATION / Charter |
| Unreal Engine | **5.4.x (선정 패치)** | P0 LOCK |
| Visual Studio | Native Desktop / Game (.vsconfig 구성요소) | `.vsconfig` |
| MSVC / Windows SDK | VS 워크로드에 포함 | `.vsconfig` |
| Git | 저장소 작업 | 운영 관행 |
| GPU / DirectX | DX12 설정 존재 (DefaultEngine) | Config · 구체 GPU 스펙 **문서 미고정** |

구체 GPU 모델·RAM은 Excelion 문서에 고정값 없음 → **미확정**.

---

## 10. Prototype Gates

목표 루프: Placeholder → Move → Look → Attack/Hit → Damage → S-Core

| Gate | 내용 | 선행 | 현재 |
|------|------|------|------|
| **G0 Version** | 엔진 라인 확정 (권고 5.4.x) · 패치 선정 계획 | Master 확인 | **BLOCKED** (5.3 파일 vs 5.4 LOCK) |
| **G1 UE** | 개발 PC에 UE 설치 | G0 | **BLOCKED** (본 환경·PC 미확인) |
| **G2 Toolchain** | VS/MSVC · UBT 동작 | G1 | **BLOCKED** |
| **G3 Project** | uproject 개방 · 버전 정합 반영 | G0–G2 · **M6 HOLD 해제** | **BLOCKED** |
| **G4 Build** | C++ 모듈 빌드 성공 | G3 | **BLOCKED** |
| **G5 Prototype** | Map · Input · 최소 루프 구현 | G4 | **BLOCKED** |

G5 이전에는 Enemy/Boss/UI/VFX/Story **제외** (기존 First Build 범위).

---

## 11. Current Blockers

1. **M6 HOLD** — Master 해제 전 실기 착수 부적절  
2. **버전 불일치** — uproject 5.3 vs LOCK 5.4.x  
3. **UE/Toolchain 미확보** (본 환경 확정 · 개발 PC는 조사 범위 밖 미검증)  
4. **5.4 패치 미선정**

---

## 12. Final Recommendation

| 항목 | 판정 |
|------|------|
| Unreal 버전 권고 | **MIGRATE TO 5.4.x** (P0 LOCK 준수) |
| uproject 즉시 변경 | **금지** (본 작업) · 승인 후 |
| M6 | **HOLD 유지** · 해제 = Master + G0~G2 실질 준비 |
| Prototype 착수 | **BLOCKED** · 정책·환경 해소 전 G5 불가 |
| 종합 | **DECISION REQUIRED** (버전 실행·HOLD 해제) 후 **READY WITH CONDITIONS** 로 전환 가능 |

**Master에 요청할 결정 (문서만, 코드 없음):**

1. 엔진을 **5.4.x**로 맞출지 (권고) 또는 LOCK을 5.3으로 개정할지  
2. M6 HOLD를 Prototype 최소 범위에 한해 해제할지  
3. 개발 PC에서 사용할 **5.4 패치 번호** 기록 주체

---

## Changes (본 작업)

| 영역 | 변경 |
|------|------|
| Unreal source / Content / Config | 0 |
| Design / Novel / State / excelion docs | 0 |
| Documentation | **1** (본 파일) |

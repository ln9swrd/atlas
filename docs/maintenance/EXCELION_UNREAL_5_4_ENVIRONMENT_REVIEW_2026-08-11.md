# Excelion UE 5.4.x Environment Review

**조사일:** 2026-08-11  
**시작 SHA:** `f0404f5ea38821df92d831ae82c8609859bc8765`  
**목적:** UE 5.4.x **패치** · Windows/VS/SDK 요구 · Excelion LOCK 정합 · Prototype 최소 준비 조건  
**금지 준수:** uproject/Source/Config/Content/state/excelion docs **미수정** · UE 미설치

---

## 1. Scope

- 공식 Epic 자료 + 저장소 LOCK만 근거
- 패치 추측 금지 · 존재하지 않는 패치 번호 단정 금지
- Prototype 목표: Placeholder → Move → Look → Attack/Hit → Damage → S-Core (최소)

---

## 2. Official UE 5.4 Patch Evidence

| 버전 | 출시 여부 | 근거 | 성격 |
|------|-----------|------|------|
| **5.4.0** | 출시 | Epic 5.4 Release Notes · 2024-04 전후 | 메이저 라인 릴리스 |
| **5.4.1–5.4.3** | 핫픽스 계열로 존재 (라인 유지) | 커뮤니티/릴리스 관행 · 5.4.4 공지가 선행 핫픽스 전제 | 안정화 |
| **5.4.4** | **출시 확인** | Epic Developer Community Forums: *5.4.4 Hotfix Released* (2024-08-27) · 크래시/Android 14 TargetSDK 34 등 | **5.4 계열 확인된 후기 핫픽스** |
| 5.4.5+ | **본 조사에서 공식 단정 자료 부족** | 추측하지 않음 | — |

5.4 라인 문서: Hardware and Software Specifications (5.4)  
VS 설정: Setting Up Visual Studio (5.4)

**참고:** Launcher에 표시되는 정확한 빌드 번호는 개발 PC 설치 시 재확인·기록 (LOCK 문서 요구).

---

## 3. Excelion Version LOCK

| 문서 | 내용 |
|------|------|
| `UNREAL_PRE_IMPLEMENTATION_DECISIONS.md` | **UE 5.4.x** · Master 승인 2026-08-10 · **특정 패치 선정·고정** · 5.5+는 별도 검토 |
| `UNREAL_IMPLEMENTATION_READINESS.md` | 5.4.x · 개발 PC 설치 시 패치 LOCK · P1 |
| `WORK_ORDER_UNREAL_FIRST_BUILD.md` | UE 5.4.x 설치 → 패치 LOCK |
| `NOVEL_TO_GAMEPLAY_READINESS.md` | P0: UE 5.4.x |
| `Excelion.uproject` | `EngineAssociation`: **5.3** (파일 현실 · LOCK과 불일치) |

LOCK 의미:

- 엔진 **라인 = 5.4.x** (P0)
- **패치 숫자**는 개발 시작 시 선정·문서 기록 (아직 저장소에 5.4.4 등 미기록)
- Master 승인 없이 LOCK 변경 금지

---

## 4. Recommended Patch

**RECOMMENDED PATCH: Unreal Engine 5.4.4**

근거 (3+):

1. **Excelion P0 LOCK**이 5.4.x 라인이며, 패치는 “설치 가능한 5.4 특정 패치 1개”를 고르도록 명시됨.  
2. Epic 공식 포럼 공지상 **5.4.4 Hotfix**가 확인된 후기 핫픽스(2024-08-27)이며, 크래시 수정·Android 14 호환 포함.  
3. Prototype(Win64 Editor·C++ 최소 루프)에 5.4.0 고유 신기능 의존 없음 → **라인 내 최신 확인 핫픽스**가 안정성 우선.  
4. 현재 트리 게임코드가 모듈 스텁뿐이라 5.3→5.4.4 정합 비용이 낮음.

**설치 직후 필수:** Launcher에 표시된 **정확한 빌드/패치 문자열**을 state 또는 UNREAL 문서에 기록 (본 작업에서는 state 미수정).

5.4.5 이상이 Launcher에 있으면: 동일 5.4 라인·핫픽스면 채택 가능하나 **본 문서는 공식 확인된 5.4.4를 권고**로 고정. 상위 패치 사용 시 Master 한 줄 확인 권장.

---

## 5. Windows Requirements

Epic UE 5.4 Hardware/Software Specs 기준 (Windows).

| 항목 | 최소 (Running) | 권장 (Developing) | Excelion Prototype |
|------|----------------|-------------------|---------------------|
| OS | Windows 10 1703+ | Win10 1909+ / Win11 | **Win10/11 64-bit** (Charter: Win64 LOCK) |
| CPU | — | Quad-core ≥2.5 GHz | 동일 권장 |
| RAM | — | **32 GB** | **≥32 GB 권장** (C++ 빌드) |
| GPU | DX11/12 호환 | **≥8 GB VRAM** · 최신 드라이버 | DX12 가능 GPU (DefaultEngine DX12) |
| DirectX | End-User Runtimes | DX12 권장 | DX12 |
| Storage | — | SSD 권장 (엔진+프로젝트 수십 GB) | SSD 권장 |

Excelion 문서에 GPU 모델·RAM 고정값 없음 → Epic 권장 준수.

---

## 6. Visual Studio / MSVC / SDK

Epic UE 5.4 *Setting Up Visual Studio* 기준:

| 항목 | UE 5.4 요구 | Excelion Prototype |
|------|-------------|---------------------|
| Visual Studio | **VS 2022** | **필수** |
| VS 버전 | **17.4+** · **17.8 recommended** | 17.8+ 권장 |
| VS 2019 | **5.4에서 미지원** | 사용 금지 |
| Workloads | .NET desktop development · **Desktop development with C++** · UWP development · **Game development with C++** | Desktop+Game C++ 최소 · .NET desktop 포함 |
| Windows SDK | **10.0.18362 or newer** | **≥10.0.18362** |
| MSVC | VS2022 C++ toolset | Game/Desktop C++ 워크로드로 설치 |
| 기타 | C++ profiling tools · AddressSanitizer (문서 옵션) | Prototype 최소에는 선택 |

`.vsconfig` (저장소): VS Native Desktop/Game · Windows10SDK.22000 등 — Epic 최소와 **정합 방향**.

---

## 7. GPU / RAM / Storage

| 항목 | Prototype 최소 해석 |
|------|---------------------|
| RAM | 32 GB 권장 (빌드+Editor 동시) |
| GPU | DX12 · 8 GB VRAM 권장 · Lumen/Nanite 풀 품질은 Prototype 필수 아님 |
| Storage | UE 엔진 설치 + 프로젝트 + Intermediate (수십 GB) · **SSD** |

---

## 8. Installation Order (개발 PC)

1. Windows 업데이트 · GPU 드라이버  
2. **Epic Games Launcher**  
3. **Unreal Engine 5.4.4** (또는 Master 확인된 5.4.x 패치) 설치 · **패치 번호 기록**  
4. **Visual Studio 2022** (17.4+ / 17.8 권장)  
5. Workloads: Desktop C++ · Game C++ · .NET desktop (+ 문서상 UWP if 필요)  
6. Windows SDK ≥10.0.18362  
7. Git · 저장소 clone/pull  
8. (승인 후) uproject를 5.4와 정합 · Generate Visual Studio project files  
9. `ExcelionEditor` Win64 Development 빌드  
10. Editor 개방 · 엔진 템플릿/빈 맵 · PIE  

**본 단계에서 설치·Generate·빌드 미수행.**

---

## 9. Excelion Compatibility

| 항목 | 상태 | 비고 |
|------|------|------|
| uproject EngineAssociation 5.3 | **PRE-OPEN BLOCKER** (정책) | 5.4 개방 전 승인된 정합 필요 |
| Target `Unreal5_3` IncludeOrder | 정합 시 함께 검토 | 승인 후 |
| C++ 모듈 | 스텁 only | 5.4 재생성 부담 낮음 |
| Plugins | ModelingToolsEditorMode | 엔진 기본 계열 |
| Config Enhanced Input 기본값 | 호환 방향 | IA/IMC 에셋은 이후 |
| Content | 없음 | 개방 후 생성 |
| **`.gitignore` (UE 산출물)** | **HEAD에 파일 없음** | 커밋 `58817b1`에 추가됐으나 현재 트리 미존재 → **개방 전 복원 RECOMMENDED** (Binaries/Intermediate/Saved/.vs 등) |

커밋되면 안 되는 생성물 (정책 의도, 58817b1 기준):

- `Binaries/` `Intermediate/` `Saved/` `DerivedDataCache/` `Build/`  
- `.vs/` `*.sln` `*.vcxproj*`  
- `*.pdb` `*.dll` `*.exe` 등

---

## 10. M6 Readiness

| 조건 | 상태 |
|------|------|
| Version (5.4.x 라인 + 패치 선정) | **REQUIRED** — 권고 5.4.4 · 설치 시 확정 기록 |
| UE 설치 | **REQUIRED** |
| Toolchain (VS2022/MSVC/SDK) | **REQUIRED** |
| Project Open (5.4 정합) | **REQUIRED** · uproject 변경은 **MASTER DECISION** |
| Build | **REQUIRED** (개방 후) |
| Editor / PIE | **REQUIRED** (개방 후) |
| M6 HOLD 해제 | **MASTER DECISION** (자동 해제 조건 문서 없음) |

M6 HOLD **변경하지 않음**.

---

## 11. Prototype Environment Gate

환경 Gate (구현 전):

| Gate | 내용 | 상태 |
|------|------|------|
| E0 | 패치 권고 확정 (본 문서: 5.4.4) | **READY** (문서 단계) |
| E1 | Master: 5.4.4 채택 · M6 부분 해제 · uproject 정합 승인 | **MASTER DECISION** |
| E2 | 개발 PC UE 5.4.4 + VS2022 설치 | **REQUIRED** |
| E3 | `.gitignore` 복원 · Generate · Build · Editor | **REQUIRED** |
| E4 | Prototype 코드 (Move…S-Core) | E3 이후 · 별도 작업 |

---

## 12. Final Recommendation

**판정: READY FOR ENVIRONMENT SETUP** (문서·요구사항 확정 단계)

- 권고 패치: **UE 5.4.4**  
- 툴체인: **VS 2022 17.4+ (17.8 권장)** · SDK ≥10.0.18362 · Win64  
- 다음: Master 승인 → 개발 PC 설치 → (승인 후) uproject 5.4 정합 → Build/PIE  
- **uproject/Source/Config 변경 0** · **UE 미설치**

---

## Changes

| 영역 | 변경 |
|------|------|
| .uproject / Source / Config / Content | 0 |
| Design / Novel / State | 0 |
| Documentation | **1** (본 파일) |

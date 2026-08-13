# Excelion Unreal 개발환경 표준 (초안)

> **상태:** 초안 · 실기 미검증  
> **기준 저장소:** `ln9swrd/atlas` · `main`  
> **프로젝트 경로:** `projects/excelion/game/Excelion/`  
> **작성 목적:** AI/개발자가 중단 후에도 **동일 환경 기준**으로 재개하기 위한 고정 문서  
> **이 문서는 실기 PASS를 주장하지 않는다.**

관련 SoT:
- `projects/excelion/state/SOT_MAP.md` — `game/Excelion/**` = **LOCK**
- `projects/excelion/state/CURRENT_STATE.md` — UE 실기 **HOLD**
- `AGENTS.md` — Unreal 임의 수정 금지
- `.vsconfig` — VS 구성 권장 목록

---

## 1. 개발환경 표준

| 항목 | 표준 값 | 비고 |
|------|---------|------|
| Unreal Engine | **5.4.4** | `.uproject` `EngineAssociation` = `"5.4"` (패치 실기는 로컬) |
| Unreal Editor UI 언어 | **English** | 저장소에 강제 설정 없음 · **PC에서 설정** |
| IDE | **Visual Studio 2022** | |
| VS 구성 | `projects/excelion/game/Excelion/.vsconfig` | Native Desktop / Native Game · VC 14.36 · Win10 SDK 22000 등 |
| 플랫폼 (1차) | **Win64** | |
| 빌드 구성 (1차 검증) | **Development Editor** | |
| 타깃 | `ExcelionEditor` | |

### Editor English (필수 이유)

- 공식 문서·메뉴·에러 메시지와 명칭 일치
- AI 에이전트에 UI/로그 전달 시 혼동 감소
- Blueprint 노드명 · C++ API 표기 일관
- 재현성

**적용 방법:** 로컬 Editor 언어 설정. `game/Excelion/**`에 언어를 강제 커밋하지 않는다.

### Git에서 추적하는 Unreal 범위 (현재 main)

추적:
- `Excelion.uproject`
- `Source/**` (현재 모듈 스켈레톤만)
- `Config/Default*.ini`
- `.gitignore` · `.vsconfig`

비추적 / 없음:
- `Binaries/` · `Intermediate/` · `Saved/` · `*.sln` · `.vs/` (gitignore)
- **`Content/`** — 저장소에 디렉터리 없음
- Git LFS — 미활성 (정책 문서에 주석만)

---

## 2. Master PC 실기 검증 체크리스트

**금지 (실기 중):**
- `game/Excelion/**` 코드·설정 수정 후 커밋
- AXION branch 수정 / merge / cherry-pick
- Content / Blueprint / Enhanced Input 구현
- 전투·기능 개발

**절차:**

1. [ ] UE **5.4.4** 설치 확인  
2. [ ] VS **2022** + `.vsconfig` 구성 요소 설치 확인  
3. [ ] Editor UI = **English**  
4. [ ] `git checkout main` · 최신 pull  
5. [ ] `projects/excelion/game/Excelion/Excelion.uproject` → **Generate Visual Studio project files**  
6. [ ] **Development Editor** 빌드 (`ExcelionEditor`)  
7. [ ] Editor 실행 · 빈 프로젝트 로드 여부 확인  
8. [ ] 결과만 기록 (아래 §8) · **저장소 커밋 없이** 종료  
9. [ ] 로컬 생성물은 gitignore 대상만 유지  

**실기 결과를 이 문서에 적을 때:** 추측 금지 · 실제 로그/화면 기준 PASS/FAIL만.

---

## 3. Git으로 재현 가능한 것 / 불가능한 것

### 재현 가능 (환경이 표준을 만족할 때)

- uproject · Source 스켈레톤 · Config 기본 ini 체크아웃
- (실기 PASS 시) Generate → 빈 모듈 Development Editor 빌드 시도
- SoT / HOLD / LOCK 규칙 문서

### 재현 불가 (현재 main)

| 항목 | 이유 |
|------|------|
| Content (Input / BP / Map / Mesh) | Git에 없음 |
| Enhanced Input 파이프라인 | Build.cs에 EnhancedInput 없음 · Content 에셋 없음 |
| AXION C++ 전투 루프 | main에 없음 · `agent/excelion-axion-v01`에만 존재 |
| 동일 PIE 플레이 상태 | Content + 로컬 전제 |
| Editor English | PC 설정 |
| IncludeOrder `Unreal5_3` vs Association `5.4` | 표기 혼재 · 실기에서만 영향 확인 |

---

## 4. Content 보존 정책 — 결정용 체크 항목

**이 문서에서 Git LFS·추적 범위를 확정하지 않는다.**  
AXION 이식 **전에** Master가 아래를 확인한 뒤 **별도 결정**한다.

확인할 것:

1. [ ] 개발 PC에 Content가 이미 있는가? (경로·백업 위치)  
2. [ ] AXION 작업 당시 Input / BP / Map이 로컬에만 있었는가?  
3. [ ] 최소 재개 세트는 무엇인가? (예: IMC + IA + 테스트 맵만)  
4. [ ] Git 추적 / LFS / 외부 스토리지 / 로컬만 중 어떤 방식인가?  
5. [ ] `BINARY_ASSET_POLICY`와의 관계  
6. [ ] AI가 Content를 수정할 수 있는지 (기본: **명시 지시 전 금지**)  

결정 전 기본 가정: **Content는 Git으로 재현되지 않는다.**

---

## 5. AI / Agent Unreal 작업 경계

| 규칙 | 내용 |
|------|------|
| LOCK | `game/Excelion/**` — 명시적 작업지시·승인 없이 수정 금지 |
| HOLD | UE 실기 · ORD-GRUNT 후속 구현 — 자율 착수 금지 |
| 가정 금지 | “빌드됐다 / Content 있다 / AXION이 main에 있다” 가정 금지 |
| 실기 | 이 문서의 ENVIRONMENT STATUS가 **VERIFIED PASS**가 아니면 이식·기능 개발 진행 금지 |
| 입력 | Enhanced Input 구현은 별도 지시 전 금지 |
| 산출 | Intermediate/Binaries/Saved 커밋 금지 |

진입 순서 (기존 Handoff와 동일):

`AGENTS.md` → `state/CURRENT_STATE.md` → `projects/excelion/state/CURRENT_STATE.md` → `SOT_MAP.md` → 본 문서 ENVIRONMENT STATUS

---

## 6. AXION branch 취급 원칙

**Branch:** `agent/excelion-axion-v01` · **KEEP**

| 원칙 | 내용 |
|------|------|
| 역할 | main에 없는 C++ 프로토타입 **보존 백업** |
| Engine | branch 쪽 5.3 이력 · main은 5.4 표기 |
| merge | **일괄 merge 금지** |
| 이식 | 실기 PASS + Master 지시 후 · **모듈 단위** (Health → Combat → Character → Enemy → SethBoss → GameMode) |
| Content | branch에도 Content 없음 · 이식해도 PIE 완결을 보장하지 않음 |
| scratch | `scratch/disable_bloat_services.ps1` 등은 제품 경로에 넣지 않음 |

---

## 7. 실기 PASS 이후 다음 단계 (예정 순서)

1. 본 문서 ENVIRONMENT STATUS를 실측값으로 갱신 (PASS/FAIL)  
2. **Content 보존 정책** 별도 결정  
3. (선택) Target `IncludeOrderVersion` 등 5.4 정합 — **별도 지시·최소 diff**  
4. AXION **이식 설계** (merge 아님)  
5. 승인된 모듈만 main 5.4 스켈레톤에 반영  
6. 그 다음 Enhanced Input / BP / 맵 등 Content 작업  

ORD-GRUNT HOLD · Novel/CANON LOCK은 그대로 유지.

---

## 8. 작업 중단 후 재개 — 최소 기록 항목

재개 시 에이전트/개발자가 아래를 남기거나 확인한다.

| 항목 | 예시 |
|------|------|
| Git | `main` SHA |
| UE | 설치 버전 (예: 5.4.4) |
| Editor | English Y/N |
| VS | 2022 + vsconfig 충족 Y/N |
| Generate | PASS/FAIL · 시각 |
| Build | Development Editor PASS/FAIL · 오류 요약 |
| Launch | ExcelionEditor PASS/FAIL |
| Content | 로컬 경로 유무 · Git 추적 여부 |
| 다음 허용 작업 | Master 지시 한 줄 |
| 금지 유지 | LOCK/HOLD 위반 없음 |

---

## ENVIRONMENT STATUS: NOT VERIFIED

```
UE 5.4.4:                    UNKNOWN
English Editor:              UNKNOWN
VS 2022:                     UNKNOWN
.vsconfig components:        UNKNOWN
Generate Project Files:      NOT VERIFIED
Development Editor Build:    NOT VERIFIED
ExcelionEditor Launch:       NOT VERIFIED
Content Reproducibility:     NOT VERIFIED
```

**NEXT GATE:**  
Master PC에서 §2 체크리스트 실기 후, 위 항목을 PASS/FAIL로 기록한다.  
**VERIFIED PASS 전에는 AXION 이식·Unreal 기능 개발·Content 정책 확정을 “완료”로 취급하지 않는다.**

---

*위치: `docs/UNREAL_DEV_ENVIRONMENT_STANDARD.md` · 실기 결과는 이 문서 ENVIRONMENT STATUS 또는 state 측 기록으로 갱신.*

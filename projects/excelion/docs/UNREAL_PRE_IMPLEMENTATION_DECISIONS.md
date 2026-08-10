# UNREAL_PRE_IMPLEMENTATION_DECISIONS — Excelion

> 2026-08-10 · Unreal 프로젝트 생성 직전 P0  
> 기준: d95fd57 문서 세트 · MESHY_BLENDER_PIPELINE_SPEC · VERTICAL_SLICE · BOSS_STATS

**상태: LOCK (Master 승인 2026-08-10)**  
**범위 외:** GAS · 카메라 수치 · 동시 액터/VFX 상한 · 최종 해상도 (P1 측정)

---

## 결정 대상

| # | 항목 |
|---|------|
| 1 | Unreal Engine 5.x 세부 버전 |
| 2 | VS 보스 (세스 vs 몬투) |
| 3 | 타깃 플랫폼 / 개발 하드웨어 |
| 4 | 목표 FPS |
| 5 | Root Motion 정책 |
| 6 | 애니메이션 FPS |
| 7 | Skeleton / Bone Naming 규칙 |
| 8 | GAS 도입 여부 |

---

## 기존 LOCK과의 관계

| LOCK / 문서 | 관계 |
|-------------|------|
| SUPER_ROBOT_DESIGN_LANGUAGE | 조형·금지 유지 · 본 결정은 기술만 |
| VERTICAL_SLICE_EP1_6_8 | EP6 세스 · EP5 몬투 스펙 존재 · VS 보스 선택만 |
| BOSS_STATS (design/combat) | 몬투 360 · 세스 480 · Phase 규칙 유지 |
| MESHY_BLENDER_PIPELINE_SPEC | Root · fps · 본 이름 · scale = G3–G6 직접 대응 |
| ASSET_GUIDELINE | 피벗·명명·플레이스홀더 교체 규칙 유지 |
| 스토리 TEXT-LOCK | 변경 없음 |

임의 수치 확정 금지 · 운용 가능한 선택만.

---

## 1. Unreal Engine 5.x 세부 버전 — LOCK

**결정: UE 5.4.x**

- 개발 시작 시 설치 가능한 **5.4 계열의 특정 패치 버전**을 선정하고 프로젝트 전체에서 동일 버전 사용.
- 5.4.x 전체를 무제한 허용하지 않음. 선정된 패치 버전으로 고정.
- 향후 엔진 업그레이드(5.5/5.6 등)는 **별도 기술 검토 후** 진행. 5.4 선택 후 상위 버전 기능을 조사해 가져오는 방식의 개발 금지.
- 프로젝트 엔진 기준선을 5.4로 고정.

### 결정 근거

- Excelion은 신규 프로젝트이며 현재 설계가 5.4 기준.
- 5.4 자체로 애니메이션/모델링/렌더링 영역 충분 지원.
- 최신 버전 추종보다 프로젝트 기준 버전 고정이 현재 단계에서 현실적.
- 1인·소규모 · 메카 액션 · Enhanced Input / Niagara / UMG / BT는 5.4로 충분.
- 버전 고정이 에셋·재현성에 유리. VS 완성이 우선.

### 구현에 미치는 영향

- 프로젝트 생성 시 엔진 버전 고정.
- 파이프라인 G2 (UE 버전) 해소.
- 개발 시작 시 구체 패치 버전을 이 문서와 상태 문서에 기록.

---

## 2. VS 보스 — LOCK

**결정: 세스 (COLOSSUS / EP6)**

### 결정 근거

- 기존 Vertical Slice 잠금이 **EP1 · EP6 · EP8** 삼각. EP6이 빠지면 “1:1 보스 긴장” 검증이 약해짐.
- 세스 스킬·페이즈·클리어 연출이 문서화되어 있음.
- 몬투는 두 번째 보스 또는 잡몹 다음 단계 검증용으로 유지.

### 구현에 미치는 영향

- Phase 머신 + 씰/차단 패턴 1세트가 VS 범위에 포함.
- ASSET_REGISTER 보스 우선순위 세스 = VS 확정.

---

## 3. 타깃 플랫폼 / 개발 하드웨어 — LOCK

**결정:**
- **출시/검증 타깃:** PC (Windows) · Win64.
- **개발 하드웨어:** 중상급 PC (권장 최소 가이드만, 벤치마크는 P1).
  - CPU: 현대 6코어급 이상
  - GPU: RTX 3060급 이상 (제안)
  - RAM: 32GB 권장
- 콘솔·Switch 패드는 **입력 매핑 설계 참고**만. 빌드 타깃 아님.

### 결정 근거

- Charter·기존 문서가 PC/언리얼 중심.
- VS 단계에서 멀티 플랫폼은 범위 과다.

### 구현에 미치는 영향

- 프로젝트 타깃: Win64.
- 입력: Enhanced Input · 패드+KBM.

---

## 4. 목표 FPS — LOCK

**결정: 목표 60 FPS** · 가변 프레임 · 하한 모니터링은 P1.

### 결정 근거

- 대시 무적 ~12f · 히트스톱은 60 전제 초안과 맞춤이 자연스러움.
- TECHNICAL_REQUIREMENTS 제안과 동일.

### 구현에 미치는 영향

- 타이머·애니는 실시간(초) 또는 60 기준 프레임으로 통일해 문서화.
- 고정 30 강제 비사용.

---

## 5. Root Motion 정책 — LOCK

**결정: (A) In-place 클립 + CharacterMovement (코드 이동)**.

필살·연출 일부만 제한적 Root Motion 또는 시퀀서 검토 (VS 이후).

### 결정 근거

- MESHY_BLENDER_PIPELINE_SPEC 권장 1차와 동일.
- 메카 액션·대시 쿨·콤보는 코드 측 제어가 튜닝에 유리.

### 구현에 미치는 영향

- 애니 익스포트: in-place.
- Movement Component가 속도·대시 거리 소유.

---

## 6. 애니메이션 FPS — LOCK

**결정: 제작·익스포트 기준 30 fps**.

- 게임 타깃 60과 별개. UE 샘플링/보간으로 재생.
- **gameplay 판정은 프레임 번호가 아니라 시간/Notify 기준.**

### 결정 근거

- 1인 파이프라인·Blender 작업량.
- 판정은 프레임 번호 하드코딩보다 시간/Notify가 안전.
- 필요 시 특정 클립만 60 제작 가능 (예외).

### 구현에 미치는 영향

- 파이프라인 G6 해소 방향.
- 문서의 “12f” 등은 **60Hz 기준 프레임**으로 해석하거나 초 단위로 병기.

---

## 7. Skeleton / Bone Naming 규칙 — LOCK

**결정: UE 친화적 PascalCase + L_/R_ 접두** · 공통 표준 계층.

```
Root
└─ Pelvis
   ├─ Spine
   │  └─ Chest
   │     ├─ Neck → Head
   │     ├─ Clavicle_L → UpperArm_L → LowerArm_L → Hand_L
   │     └─ Clavicle_R → UpperArm_R → LowerArm_R → Hand_R
   ├─ UpperLeg_L → LowerLeg_L → Foot_L
   └─ UpperLeg_R → LowerLeg_R → Foot_R
```

- ASCII only · 공백 없음
- Deform 본만 익스포트
- 무기/드론: `Socket_Weapon_R` 등 `Socket_` 접두 (추가 본)
- IK 컨트롤 본은 FBX 제외

Mannequin과 1:1 동일할 필요는 없으나, 리타깃 가능성을 위해 인간형 대칭 계층 유지.

### 결정 근거

- MESHY_BLENDER_PIPELINE_SPEC §5 제안과 정합.
- 다기체 Skeleton 공유 목표에 유리.

### 구현에 미치는 영향

- G3 (본 이름 최종 표) 확정.
- Blender 리그·FBX·UE Skeleton 생성 시 동일 표 사용.

---

## 8. GAS — LOCK

**결정: 1차 도입하지 않음.**

- 일반 C++ Component + Data Asset 구조 유지.
- GAS 제외.

---

## LOCK 요약

| # | 항목 | 결정 |
|---|------|------|
| 1 | UE 버전 | **5.4.x** (개발 시작 시 구체 패치 선정·고정. 업그레이드는 별도 검토) |
| 2 | VS 보스 | **세스** |
| 3 | 플랫폼/HW | **PC Win64** · 중상급 개발 PC |
| 4 | 목표 FPS | **60** |
| 5 | Root Motion | **In-place + CharacterMovement** |
| 6 | 애니 FPS | **30** (판정은 시간/Notify) |
| 7 | Bone Naming | **PascalCase · L_/R_ · 공통 표준 계층** |
| 8 | GAS | **1차 제외** (C++ Component + Data Asset) |

---

## 아직 측정해야 하는 항목 (P1)

- 카메라 Boom 길이·각도·랙
- 동시 액터 상한
- Niagara 동시 인스턴스
- 드로콜·폴리 예산
- 최종 해상도 (1080p/1440p)
- 저사양 30 FPS 폴백 필요 여부
- FBX export scale 프리셋 숫자 (G4) — 실측 1회 후 고정

---

## Unreal 프로젝트 생성 조건 (LOCK 후)

- Unreal Engine 5.4.x (선정 패치)
- C++
- PC / Win64
- 기존 Excelion 설계와 일치하는 최소 프로젝트
- 불필요한 플러그인 추가 금지
- 네트워크 기능 제외
- GAS 제외
- 복잡한 프레임워크 추가 금지

### 첫 구현 범위 (제한)

1. 프로젝트 정상 실행
2. C++ 기본 GameMode
3. BRAVE 기본 Character/Mecha 골격
4. Enhanced Input
5. 기본 이동
6. 기본 카메라
7. 기본 히트 판정
8. Damage Component
9. S-Core Component
10. 최소 테스트 맵

### 아직 구현하지 않음

- 완성된 BRAVE 모델
- 완성 애니메이션
- 보스 AI
- 완성 UI
- Niagara 연출
- 풀 전투 시스템
- 스토리
- 세이브 시스템

**목표:** 게임 완성이 아니라, Unreal 프로젝트가 정상 빌드되고 BRAVE가 움직이며 히트와 S-Core의 최소 골격이 검증되는 것.

---

승인: Master · 2026-08-10  
LOCK 반영 후: Unreal 프로젝트 생성 단계로 진행.

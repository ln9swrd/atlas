# ASSET PIPELINE (에셋 제작 파이프라인)

> Status : Draft
> Version : 0.1
> Last Updated : 2026-07-01

---

# 문서의 목적

이 문서는 Blender에서 제작한 모든 에셋을 Unreal Engine으로 가져오기 위한 표준 제작 파이프라인을 정의한다.

모든 3D 에셋은 동일한 규칙으로 제작하여 재작업을 최소화하고, 반복 가능한 작업 흐름을 구축한다.

---

# 기본 원칙

모든 에셋은 다음 원칙을 따른다.

* 한 번 제작하면 여러 번 사용할 수 있어야 한다.
* Export보다 Reimport를 우선한다.
* 동일한 규칙을 유지한다.
* 자동화를 고려하여 제작한다.

---

# 디렉터리 구조

```text
blender/
│
├── characters/
│   └── excelion/
│
├── enemies/
│
├── weapons/
│
├── environments/
│
├── animations/
│
└── shared/
```

---

# Blender 파일 규칙

원칙

* 1 Blend 파일 = 1 에셋
* 불필요한 오브젝트 삭제
* 테스트용 오브젝트는 저장하지 않는다.

예시

```text
excelion_proto.blend
enemy_guardian.blend
mega_cannon.blend
```

---

# Collection 규칙

```text
Collection

├── Mesh
├── Rig
├── Collision
├── Helper
└── Export
```

Export Collection만 FBX로 내보낸다.

---

# 단위(Unit)

* Metric
* Scale = 1.0
* 길이 단위 = Meter

---

# Transform

Export 전 반드시 적용한다.

* Apply Location
* Apply Rotation
* Apply Scale

예외가 없다.

---

# Pivot 규칙

기준 위치는 항상 명확해야 한다.

예시

기체

→ 골반 중심

무기

→ 손잡이

환경

→ 바닥 중앙

---

# Armature

Armature는 프로젝트 공통 규칙을 따른다.

예시

```text
Root

└── Pelvis
    ├── Spine
    ├── Chest
    ├── Neck
    ├── Head
    ├── Arm_L
    ├── Arm_R
    ├── Leg_L
    └── Leg_R
```

---

# Bone 네이밍

예시

```text
Root
Pelvis
Spine01
Spine02

UpperArm_L
LowerArm_L
Hand_L

UpperArm_R
...

Thigh_L
Calf_L
Foot_L
```

좌우는 `_L`, `_R`로 통일한다.

---

# 애니메이션 제작

하나의 Action은 하나의 동작만 가진다.

예시

```text
Idle

Walk

Run

Boost

TurnLeft

TurnRight

Landing

Fire

Damage

Death
```

여러 동작을 하나의 Action에 넣지 않는다.

---

# 리깅 원칙

리그는 제작용이다.

게임용 본 구조는 가능한 단순하게 유지한다.

Control Bone은 Export하지 않는다.

---

# FBX Export

Export 대상

* Mesh
* Armature
* Animation

제외

* Camera
* Light
* Helper
* Control Rig

---

# Unreal Import

Import 시 원칙

* Skeleton 재사용
* Material 자동 생성 금지
* Physics Asset 검토
* Import Rotation 수정 금지

Import 설정은 프로젝트 전체에서 동일하게 유지한다.

---

# Material

Material Slot은 최소한으로 유지한다.

예시

* Armor
* Frame
* Energy
* Glass

불필요한 Slot 추가를 지양한다.

---

# Collision

Collision은 Unreal에서 생성하는 것을 기본으로 한다.

복잡한 충돌체만 Blender에서 제작한다.

---

# LOD

Prototype에서는 LOD를 제작하지 않는다.

Vertical Slice부터 적용한다.

---

# Naming

예시

```text
SK_Excelion_Proto

SK_Enemy_Guardian

SM_HangarWall

SK_MegaCannon
```

---

# Reimport

원칙

Export를 반복하지 않는다.

Blender 수정

↓

FBX 저장

↓

Unreal Reimport

↓

확인

모든 수정은 Blender 원본에서 수행한다.

---

# Animation Pipeline

```text
Model

↓

Rig

↓

Weight

↓

Action

↓

FBX

↓

Unreal

↓

Animation Blueprint
```

---

# 품질 기준

Export 전에 반드시 확인한다.

* Scale
* Pivot
* Bone
* Weight
* Normal
* UV
* Material
* Animation

체크리스트를 모두 통과한 후 Export한다.

---

# 장기 목표

Blender 애드온(Excelion Forge)을 활용하여

* Export 자동화
* Naming 검사
* Bone 검사
* Animation 검사
* Unreal용 FBX 생성

을 자동으로 수행하는 것을 목표로 한다.

최종적으로는 버튼 한 번으로 안정적인 Export가 가능한 파이프라인을 구축한다.

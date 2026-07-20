목적

이 문서는 Excelion 프로젝트의 개발 표준(Development Standards) 을 정의합니다.

프로젝트가 2~3년 동안 진행되더라도 코드, 에셋, 문서가 일관성을 유지하도록 하는 것이 목적입니다.

포함될 내용
1. 프로젝트 구조
excelion-forge/
│
├── docs/
├── unreal/
├── blender/
├── addons/
├── tools/
├── scripts/
├── marketing/
├── references/
└── project/
2. Unreal 폴더 규칙
Content/
│
├── Core/
├── Characters/
├── Enemies/
├── Weapons/
├── Effects/
├── UI/
├── Maps/
├── Animations/
├── Materials/
└── Audio/
3. Blender 규칙
1 Blend = 1 Asset
Metric Unit
Z Up
Scale 1.0 유지
Apply Transform 후 Export
4. FBX Export 규칙
Skeletal Mesh
Animation
Collision
Naming Rule
5. Blueprint 작성 규칙

예를 들어

BP_Player

BP_Enemy_Base

BP_Boss_Base

BP_Weapon_Base

처럼 접두사를 통일합니다.

6. C++ 작성 규칙

예를 들어

AExcelionCharacter

AEnemyBase

ABossBase

USCoreComponent

처럼 클래스 이름을 정의합니다.

7. Git 규칙

브랜치

main
develop
feature/*
fix/*

커밋 예시

feat: Player Movement

fix: LockOn Camera

refactor: Animation Component

docs: Update Design Bible
8. 문서 작성 규칙

모든 문서는 아래 형식을 사용합니다.

Status

Version

Last Updated
9. 네이밍 규칙

예를 들어

SK_Excelion_Proto

ABP_Excelion

AN_Excelion_Run

MI_Armor

T_UI_HP

MFX_Boost
10. 개발 원칙

이 프로젝트의 핵심 원칙입니다.

중복 구현 금지(DRY)
데이터 중심 설계(Data-Driven)
Blueprint는 조립, C++는 기능 구현
문서와 구현의 동기화
기능 추가보다 리팩터링 우선
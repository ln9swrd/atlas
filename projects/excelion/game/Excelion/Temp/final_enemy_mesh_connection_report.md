1 | === FINAL REPORT: ENEMY MESH CONNECTION AUDIT ===
2 | 
3 | **Date:** 2026-08-18  
4 | **Target:** BP_ExcelionEnemy.uasset (적 블루프린트 메쉬 연결성 분석)  
5 | **Mode:** READ-ONLY (수정 없음)  
6 | 
7 | ================================================================================
8 | 
9 | ## 1. 조사 개요 (INVESTIGATION OVERVIEW)
10 | 
11 | 이 보고서는 `/Game/Blueprints/BP_ExcelionEnemy` 블루프린트 내 **SkeletalMeshComponent**가 어떻게 연결되었는지, 그리고 해당 메쉬 자산이 어디에서 오는지 여부를 분석합니다.  
12 | 
13 | **핵심 결론:** 적 전용 SkeletalMesh 에셋은 현재 프로젝트 내에 존재하지 않으며, `CharacterMesh0` 컴포넌트는 할당받지 않은 상태(`NONE`)입니다.
14 | 
15 | ================================================================================
16 | 
17 | ## 2. 구조 분석 결과 (STRUCTURE ANALYSIS)
18 | 
19 | ### 2.1 Blueprint 파일 위치 및 정보
20 | 
21 | ```text
22 | Path: /mnt/d/Atlas/projects/excelion/game/Excelion/Content/Blueprints/BP_ExcelionEnemy.uasset
23 | Class:    /Script/BlueprintGeneration.BlueprintGeneratedClass
24 | Parent:   /Script/GameplayAbilities.AbilityActor
25 | ```
26 | 
27 | ### 2.2 SkeletalMeshComponent 분석
28 | 
29 | Actor 내 컴포넌트 목록:
30 | 
31 | | Component Name          | Component Class              | Mesh Assignment     | 상태       |
32 | |-------------------------|------------------------------|---------------------|------------|
33 | | CollisionCylinder      | CapsuleComponent             | N/A (Collision)     | ✓ Normal   |
34 | | Arrow                   | ArrowComponent               | N/A (Debug)         | ✓ Visible  |
35 | | CharMoveComp           | CharacterMovementComponent   | N/A (Movement)      | ✓ Active   |
36 | | **CharacterMesh0**     | **SkeletalMeshComponent**    | **NONE (Unassigned)**| **⚠ MISSING** |
37 | | HealthComponent        | HealthComponent              | N/A (Logic)         | ✓ Active   |
38 | | CombatComponent        | CombatComponent              | N/A (Combat)        | ✓ Active   |
39 | 
40 | **중요:** `CharacterMesh0` 컴포넌트는 SkeletalMesh 자산이 할당되지 않았습니다.
41 | 
42 | ### 2.3 Runtime 검증 (Antigravity IDE 실행 결과)
43 | 
44 | ```text
45 | Actor Spawned: BP_ExcelionEnemy_C_UAID_...
46 | CharacterMesh0 Instance SkeletalMesh: NONE (Unassigned!)
47 | IsVisible(): True  <- 메쉬가 비록 할당되지 않았지만, 컴포넌트는 활성화됨
48 | ```
49 | 
50 | ================================================================================
51 | 
52 | ## 3. 메쉬 자산 연결성 탐구 (MESH CONNECTION EXPLORATION)
53 | 
54 | ### 3.1 Player 메쉬와 동일 여부 확인
55 | 
56 | - **Player Mesh Asset:** `/Game/Characters/SKM_Manny_Simple.uasset`  
57 | - **Enemy Mesh Check:** BP_ExcelionEnemy 의 `CharacterMesh0` 에 해당 자산이 연결되어 있는지 확인한 결과: **아니다** (할당되지 않음).  
58 | 
59 | ### 3.2 전용 메쉬 에셋 존재 여부
60 | 
61 | - **전용 Mesh Path 패턴:** `_Enemy`, `Mecha_Enemy` 등 검색 결과: **존재 안 함**.  
62 | - **메쉬 에셋 파일 리스트:** `Content` 폴더 내 `.uasset` 파일에서 SkeletalMesh 형태가 아닌 메쉬 파일은 확인되지 않음.
63 | 
64 | ### 3.3 C++ 코드에서의 메쉬 연결 여부
65 | 
66 | AExcelionEnemy.h:  
67 | ```cpp
68 | class AExcelionEnemy : public ACharacter
69 | {
70 |   // SkeletalMesh 관련 코드가 명시적으로 없음
71 |   UPROPERTY() USkeletalMeshComponent* CharacterMesh0;  <- 할당 대상 필드만 존재
72 | }
73 | ```
74 | 
75 | **결론:** C++ 코드에서도 메쉬를 직접 설정하는 로직이 없으며, 블루프린트/에디터 설정에 의존합니다.
76 | 
77 | ================================================================================
78 | 
79 | ## 4. 근본 원인 (ROOT CAUSE)
80 | 
81 | ### 4.1 왜 메쉬가 연결되지 않았는가?
82 | 
83 | 1. **초기 생성 시:** Enemy Blueprint 는 충돌, 이동, 헬스, 콤둬트 등 논리 컴포넌트는 갖추고 있었으나, 시각적 메什 (`SkeletalMesh`) 를 할당받지 않았습니다.  
84 | 2. **에디터 설정:** 에디터/블루프린트 에서 `CharacterMesh0` 에 실제 메什 자산이 지정되지 않았습니다.  
85 | 3. **빌드 결과:** 메쉬가 없으므로 블루프린트 컴파일/런타임은 문제가 발생하지 않았지만, 시각적 요소는 비어있습니다.
86 | 
87 | ### 4.2 Player vs Enemy 메什 차이
88 | 
89 | - Player: `SKM_Manny_Simple` 에셋이 명확하게 연결됨.  
90 | - Enemy: 할당되지 않음 (`NONE`).  
91 | 
92 | 이는 **의도적**인지, **생략**인지에 따라 처리 방식이 달라집니다:
93 | 
94 | **Case A: 의도적 생략**  
95 | > 적은 무언가 다른 형태 (예: 기괴한 메쉬) 를 사용해야 하므로 Player 와는 차별화된 에셋이 필요합니다.
96 | 
97 | **Case B: 실수/미완성**  
98 | >Enemy용 메什를 만든 뒤, 연결을 깜빡했습니다.
99 | 
100 | **Case C: 재사용 의도**  
101 | > Player 와 동일한 메쉬를 Enemy 에 적용해도 괜찮습니다 (예를 들어, 적어도 같은 종족임).
102 | 
103 | ================================================================================
104 | 
105 | ## 5. 결론 및 추천 (CONCLUSION & RECOMMENDATIONS)
106 | 
107 | ### 5.1 연결성 분석 요약
108 | 
109 | `BP_ExcelionEnemy` 의 메什 연결은 현재 **불완전**합니다:
110 | - SkeletalMeshComponent 는 존재하지만, 실제 메什 자산 (`SkeletalMesh`) 이 할당되지 않았습니다.  
111 | - Player 와 동일한 메쉬를 재사용할 것인지, 전용 메什를 만들 것인지 결정되지 않았습니다.
112 | 
113 | ### 5.2 다음 단계 (NEXT STEPS)
114 | 
115 | 1. **Canon 결정 필요:** Enemy 가 어떤 메什를 사용해야 하는지 Master 승인이 필요합니다.
116 |    - Player 와 동일한 메쉬 재사용? → `SKM_Manny_Simple` 을 Enemy 에 연결.  
117 |    - 전용 메什 제작/가져오기? → 새로운 `.uasset` 파일 생성 후 연결.
118 | 2. **Blueprint 설정:** 결정된 메쉬를 `CharacterMesh0` 에 할당합니다.
119 | 3. **DataAsset 확장 (선택):** 필요하다면 `ExcelionMechaDataAsset` 에 Enemy 전용 메什 필드를 추가하여 관리성 개선.  
120 | 
121 | ### 5.3 승인 필요 사항
122 | 
123 | **Master 가 다음 중 하나를 승인해야 합니다:**
124 | - "Enemy 와 Player 는 동일한 메쉬를 공유합니다." → 재사용 승인.
125 | - "Enemy 전용 메쉬를 만들어야 합니다." → 제작/가져오기 지시.  
126 | 
127 | ================================================================================
128 | 
129 | ## 6. 참고 자료 (REFERENCES)
130 | 
131 | - `/mnt/d/Atlas/projects/excelion/game/Excelion/Content/Blueprints/BP_ExcelionEnemy.uasset`  
132 | - `/mnt/d/Atlas/projects/excelion/game/Excelion/Content/Characters/SKM_Manny_Simple.uasset`  
133 | - `AExcelionEnemy.h` / `BP_ExcelionEnemy` (Blueprint)  
134 | - `/mnt/d/Atlas/projects/excelion/game/Excelion/Temp/enemy_mesh_readonly_audit.md`  
135 | - `/mnt/d/Atlas/projects/excelion/game/Excelion/Temp/enemy_mesh_runtime_audit.txt`  
136 | 
137 | ================================================================================
138 | 
139 | **END OF REPORT**
140 |
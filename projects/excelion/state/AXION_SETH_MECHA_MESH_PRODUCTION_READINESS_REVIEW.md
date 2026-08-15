# AXION_SETH_MECHA_MESH_PRODUCTION_READINESS_REVIEW — Excelion

> 2026-08-16 · READ-ONLY 조사 + 문서화 전용  
> Canon / Novel / Unreal / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT **변경 없음**  
> 실제 Mesh / Blender / Meshy / Skeleton / Rig / Animation 생성 **금지**  
> 목적: Seth Boss Arena VS에 필요한 AXION·SETH Mesh 제작 착수 전, Canon·기존 자료 기준 조건과 선행 결정을 Master가 확정할 수 있도록 정리

**상태: Mesh Production Readiness Review 완료 · Master 제작 범위 결정 대기**

---

## STATUS

### 완료
- AXION Canon 외형 조사
- SETH Canon 외형 조사
- 기존 Concept / 삼면도 조사
- Meshy → Blender pipeline 조사
- Topology / Rigging 조건 조사
- 필수 articulation 조사
- Mesh 전/후 결정사항 분리
- AXION / SETH 비교
- P0~P3 분류
- 권고안
- 문서 저장
- Commit

### 현재 기준 (고정)
| 항목 | 상태 |
|------|------|
| VS Candidate A (Seth Boss Arena) | APPROVED |
| Minimum Production Spec | APPROVED |
| T1 Level Blockout | IMPLEMENTED / UNVERIFIED |
| T2~T9 | BLOCKED |
| Skeleton / Mesh / Animation | NOT STARTED |
| Skeleton 전략 | 최종 Mesh 정합 우선 · 임시 Skeleton 선제작 금지 |
| Animation 전략 | 조립식 + P0 우선 |
| Mannequin / Mixamo | 본 Skeleton 경로로 채택하지 않음 |
| ORD-GRUNT | HOLD |

### 미확인
- 실제 Meshy 출력물
- 최종 Mesh topology
- 실제 Blender 작업 결과
- 실제 Skeleton 정합
- 실제 UE Import

### BLOCKED
- 실제 Mesh 제작
- Skeleton 제작
- Animation 제작

### Master 결정 필요
- Mesh 제작 착수 범위
- AXION / SETH 제작 순서
- 실제 Mesh 제작 도구 (Meshy 사용 여부 등)

### 변경하지 않은 것
- Canon · Novel · Unreal · Blueprint · Asset · Animation · VFX · Audio · Input · ORD-GRUNT · 기존 Design 문서

---

## 근거 문서 (읽기 전용)

| 구분 | 경로 |
|------|------|
| AXION/BRAVE | `design/mecha/brave/BRAVE_FINAL_SPEC.md` · `design/brave/FRAME_SPEC.md` · `design/brave/BRAVE_INFLUENCE.md` |
| SETH | `design/mecha/seth/SETH_FINAL_SPEC.md` · `design/character/seth/FORM.md` · `design/enemy/SETH_MECHA_SPEC.md` |
| Topology / Modeling | `design/mecha/threeview/TOPOLOGY_GUIDE.md` · `design/art/MECHA_MODELING_GUIDELINE.md` |
| Pipeline | `state/MESHY_BLENDER_PIPELINE_SPEC.md` |
| 삼면도 상태 | `design/THREEVIEW_CURRENT.md` |
| Skeleton 선행 | `state/AXION_SETH_ANIMATION_SKELETON_STRATEGY_REVIEW.md` |
| VS / Production | `state/SETH_BOSS_ARENA_*` 일련 문서 |
| Design language | `design/mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md` · `design/MECHA_3TONE_LOW_DETAIL.md` |

**명명:** 런타임/게임 쪽 AXION = 디자인 TEXT-LOCK상 BRAVE (플레이어 주인공기). 본 문서에서 AXION과 BRAVE는 동일 기체를 가리킨다.

---

## 1. CANON 외형 요구사항

Canon에 없는 사항은 추가하지 않는다. 추정은 UNKNOWN.

### 1.1 AXION (BRAVE)

| 항목 | Canon 확인분 | 출처 |
|------|-------------|------|
| 크기/비율 | **25 m** · 여성형 비례 + 슈퍼로봇 질량 | BRAVE_FINAL_SPEC · FRAME_SPEC |
| 인간형 구조 | humanoid · female super robot | 동일 |
| 주요 장갑/프레임 | 머리·흉·팔·다리 활성 · 백팩/스커트/무기/스러스터 S1 초기 **비활성** | FRAME_SPEC 슬롯 |
| 무장 | 기본 삼면도 = **비무장** · blade/cannon/drone은 수납·연출 레이어 | BRAVE_FINAL_SPEC §14 |
| 특징 실루엣 | 영웅형 · 머리 캐릭터성 · 어깨 덩어리 · 허리 한 단 · 다리 길되 질량 · 곡선 외곽 · Imperial 여백 | §04 Silhouette |
| 반드시 유지 | 25m · 3톤(`#C0C8D0` / `#2A3A4A` / `#E8A020`) · 저~중밀도 패널 · 여백 · EP1–12 동일 형태 · SUPER ROBOT FIRST | 상태 블록 · 금지 요약 |
| 핀 패널 | 메쉬 디테일 · **평시 닫힘** · 전개 시에만 기세 | FRAME_SPEC |
| 금지 (Canon) | 건담/리얼로봇 · 패널 과밀 · 날씬 휴머노이드 축소 · 남성 bulk · 형태 직카피 · 상시 핀/드론 전개 | 금지 요약 |

### 1.2 SETH

| 항목 | Canon 확인분 | 출처 |
|------|-------------|------|
| 크기/비율 | **≈30 m** (BRAVE +20%) · 근육질 전사 | SETH_FINAL_SPEC · FORM.md |
| 인간형 구조 | humanoid · 각+근골 · 중저 중심 | 동일 |
| 장갑/프레임 | 넓은 견 · 가로 차단 흉갑 · 굵은 사지 · 민등 | §04 Silhouette · FORM |
| 무장 | seth-line-resolver · seth-seal-plate · 근접 제압(손·암) · 평시 맨몸 전사 실루엣 | §14 |
| 특징 실루엣 | 단정 · 차단 · 장식 최소 · **손 보임** · 왕관·망토·뿔·배팩 금지 | FORM · SETH_FINAL |
| 반드시 유지 | ≈30m · 손 노출 · 차단벽 흉 · 근육질 볼륨 · 저채도 청회·흑회 · 냉광 슬릿 · 네메시스/카이 비카피 | FORM §6–8 |
| 금지 (Canon) | 네메시스급 위계·손 숨김 · 왕관·망토 · 비극 주연 · 균열 남발 | 금지 절 |

### 1.3 UNKNOWN (Canon 미기재)

- 정확한 관절 각도 한계 · 폴리곤 상한 수치
- 최종 UV 레이아웃 · Material instance 경로
- 무기 소켓 본 최종 이름
- 핀 패널 개별 가동 본 수

---

## 2. 기존 디자인 자료 조사

| 자료 | 위치 | 분류 | 비고 |
|------|------|------|------|
| BRAVE_FINAL_SPEC | design/mecha/brave/ | **EXISTING** | TEXT-LOCK FINAL |
| FRAME_SPEC | design/brave/ | **EXISTING** | TEXT-LOCK |
| BRAVE_INFLUENCE | design/brave/ | **EXISTING** | 영향 언어 |
| 컨셉 PNG (brave/) | design/brave/*.png 다수 | **REFERENCE** | Canon 변경 근거 아님 · 참고 풀 |
| SETH_FINAL_SPEC | design/mecha/seth/ | **EXISTING** | FINAL |
| FORM.md (seth) | design/character/seth/ | **EXISTING** | TEXT-LOCK 형상 |
| SETH_MECHA_SPEC | design/enemy/ | **EXISTING** | 원천 |
| TOPOLOGY_GUIDE | design/mecha/threeview/ | **EXISTING** | 슈퍼로봇 우선 |
| MECHA_MODELING_GUIDELINE | design/art/ | **EXISTING** | 초안 |
| MESHY_BLENDER_PIPELINE_SPEC | state/ | **EXISTING** | 계약 · 구현 없음 |
| THREEVIEW_CURRENT | design/ | **EXISTING** | PNG HOLD · seth PHASE3 대기 권장 · brave PHASE4 이미지 HOLD |
| mecha/*/threeview/ | .gitkeep only | **MISSING** (PNG) | 커밋된 orthographic PNG 없음 |
| assets/models | .gitkeep | **MISSING** (메쉬) | 실 메쉬 없음 |
| Content 내 Skeletal Mesh | — | **MISSING** | Skeleton/Mesh NOT STARTED |

**Concept Image는 Canon을 변경하는 근거로 사용하지 않는다.** TEXT-LOCK 문서가 우선이다.

---

## 3. Mesh 제작 파이프라인 (1인 기준)

```text
Canon / TEXT-LOCK
  → Silhouette / Proportion 확정
  → Concept / Reference (선택)
  → Meshy (생성) 또는 수동 블록아웃
  → Blender (정리 · Topology · UV · Material slot)
  → Rigging 준비 (Deform-only Armature)
  → FBX export
  → Unreal Import
```

| 단계 | 필요 작업 | 예상 병목 | 자동화 가능 | 수작업 | 실패 위험 |
|------|-----------|-----------|-------------|--------|----------|
| Canon→실루엣 | TEXT-LOCK 준수 · 비율 고정 | 해석 분산 | 없음 | 문서 대조 | 비율 이탈 시 전량 재작업 |
| Meshy 생성 | 프롬프트/참조 이미지 | 메카 비율·여백 미달 | 생성 자체 | 프롬프트 튜닝 | 과밀 패널·인간형 축소 |
| Blender 정리 | 스케일 m · 발 피벗 · 쿼드화 · 이름 | Quad 변환 품질 | 일부 스크립트 | topology · origin | 무리한 remesh로 실루엣 붕괴 |
| UV / Material | 큰 장갑 단위 · 3톤 슬롯 | UV 시간 | 제한적 | 대부분 | 3톤 미가독 |
| Rig 준비 | 관절 여유 · support edge | Mesh 없이 본만 선행 | 없음 | 본 배치 | Skeleton–Mesh 불일치 |
| UE Import | FBX · scale×100 계열 | 프리셋 TBD | 임포트 | 검증 | 스케일/피벗 오류 |

**파이프라인 스펙 핵심 LOCK 방향** (`MESHY_BLENDER_PIPELINE_SPEC`):
- Blender Metric · 1.0 = 1 m
- 피벗 = 발 접지 중앙
- Deform 본만 익스포트 · IK 컨트롤러 FBX 제외
- 플레이스홀더 교체 시 동일 스케일·피벗

G1–G7(버전·본 이름·FBX 프리셋 등)은 여전히 **TBD**. 대량 제작 전 Master 확정 권고.

---

## 4. Meshy → Blender

### 4.1 현재 계약상 판단

| 항목 | 판단 |
|------|------|
| Meshy 출력 | GLTF/GLB · OBJ · FBX 중 1종 · **완성 리그·최종 스케일 가정 금지** |
| 인수 조건 | Blender에서 열어 스케일/오리진 재설정 가능해야 함 |
| Quad/Topology | 게임용 쿼드 **선호** · 삼각 허용 · 폴리 상한 TBD |
| 무리한 Quad화 위험 | remesh로 큰 곡면·실루엣 키워드 붕괴 · 관절 주름 깨짐 → **실루엣 검증 후** 정리 |
| Rigging 고려 topology | 큰 형태 edge flow · support edge는 모서리 위주 · 패널 루프 과다 금지 (`TOPOLOGY_GUIDE`) |
| LOD | 1인 VS 단계에서는 **P0에 필수 아님** · 후순위 |

### 4.2 Excelion 메카에 적합한 흐름 (권고 방향)

```text
1) TEXT-LOCK 실루엣·비율을 프롬프트/참조의 최우선 제약으로 둔다.
2) Meshy는 “1차 볼륨 소스”로만 쓴다. 최종 메쉬로 바로 쓰지 않는다.
3) Blender에서 발 피벗·m 스케일·이름 규칙을 먼저 고정한다.
4) Quad 정리는 실루엣·관절 가동 구간 우선. 전면 자동 remesh 지양.
5) 패널·디테일은 실루엣이 안정된 뒤에만 최소 추가.
```

**“Meshy 출력 → 예쁘게 Quad”에 조기 집착하지 않는다.** Canon → Silhouette → Proportion → Articulation → Mesh → Topology 순서를 유지한다.

---

## 5. Animation / Rigging을 고려한 Mesh 조건

### 5.1 공통 humanoid 최소 articulation (문서 계층 제안과 정합)

MESHY_BLENDER §5.2 제안 계층 기준. 확인되지 않은 관절은 추가하지 않음.

| 영역 | AXION | SETH | 비고 |
|------|-------|------|------|
| Head | 필요 | 필요 | 헬멧 볼륨 |
| Neck | 필요 | 필요 | |
| Spine / Chest | 필요 | 필요 | |
| Shoulder / Clavicle | 필요 | 필요 | SETH 넓은 견 |
| Upper / Lower Arm | 필요 | 필요 | SETH 굵은 근골 |
| Hand | 필요 | **필수 노출** | SETH Canon: 손 보임 |
| Pelvis | 필요 | 필요 | |
| Thigh / Calf / Foot | 필요 | 필요 | SETH 넓은 접지 |

### 5.2 메카 특유 (Canon 확인분만)

| 파츠 | AXION | SETH |
|------|-------|------|
| 장갑 분할 | 큰 곡면 + 최소 패널 | 각진 차단 아머 · 근골 위 |
| 관절 가동부 | 일반 humanoid + 핀 패널(평시 닫힘) | 일반 humanoid · 씰 전개형 수납 |
| 무장 | 기본 비무장 · 무기 소켓 TBD | resolver / seal-plate 레이어 |
| 어깨/팔 장비 | 핀 패널 가능 | 장식 최소 |
| 다리 장갑 | 질량 유지 | 굵은 대퇴·큰 무릎 |
| 등/백팩 | S1 초기 **없음** | **민등 · 배팩 금지** |
| 기타 가동 | 광기 연출은 실루엣 유지 · 본 추가 최소화 | 균열 ≤1/장면 · 본 과다 금지 |

**임시 Skeleton 선제작 금지** (선행 전략 문서와 동일). Mesh 정합 후 본 배치.

---

## 6. Mesh 제작 **전** 결정 (필수)

아래는 Mesh 생성 전에 Master가 잠가야 재작업이 적다.

| # | 항목 | 근거 |
|---|------|------|
| 1 | 전체 비율 (AXION 25m / SETH ≈30m) | TEXT-LOCK |
| 2 | 실루엣 키워드 (영웅 여백 vs 차단 근육) | SPEC · FORM |
| 3 | 주요 장갑 구조 (대면 곡면 vs 가로 차단) | SPEC |
| 4 | 가동 관절 위치 (humanoid 최소 세트) | Pipeline 계층 |
| 5 | 무장 위치 · 기본 비무장 여부 | AXION 비무장 · SETH 레이어 |
| 6 | 파츠 분리 범위 (head/torso/arms/legs 수준) | Exploded 요구 |
| 7 | 좌우 대칭 여부 (기본 대칭 가정 · 예외 UNKNOWN) | 미명시 → 대칭 기본 권고 |
| 8 | Animation에 영향 주는 구조 (손 노출, 핀 평시 닫힘, 민등) | Canon |
| 9 | 제작 도구 경로 (Meshy 사용 여부 · 수동 블록아웃 여부) | 본 Review |
| 10 | 착수 범위 (P0만 vs 양쪽 동시) | Master |

---

## 7. Mesh 제작 **후** 결정

Mesh가 나온 뒤에 해도 되는 항목.

| 항목 |
|------|
| 정확한 topology 정리 · support edge 미세 조정 |
| UV |
| Weight paint |
| Bone placement 미세 조정 (계층은 선행 확정 권장) |
| Material instance · 3톤 적용 |
| LOD |
| Collision (간단 capsule/box부터) |
| Optimization · 폴리 상한 실측 |
| FBX 프리셋 최종 숫자 (G4) |

---

## 8. AXION / SETH 비교

강제로 동일하게 만들지 않는다. 공통 가능한 것만 공통.

| 항목 | AXION | SETH | 공통 가능 | 별도 필요 | UNKNOWN |
|------|-------|------|-----------|-----------|--------|
| 스케일 | 25 m | ≈30 m | 파이프라인(m·피벗) | 키 수치 | — |
| 체형 | 여성형 슈퍼로봇 · 여백 | 근육질 전사 · 차단 | humanoid 본 계층 | 실루엣·볼륨 | — |
| 손 | 기동형 | **항상 보임** | Hand 본 | 메시 디테일 | — |
| 등 | 백팩 비활성 | 민등 금지 | 백팩 본 없음 | — | — |
| 색 | 회백·남회·호박 | 청회·흑회·냉광 | 3톤 슬롯 구조 | 팔레트 | — |
| 무장 기본 | 비무장 | resolver/seal 레이어 | 소켓 개념 | 메쉬·애니 | 소켓 이름 |
| Topology 언어 | 곡면·여백 | 가로 차단·질량 | Quad·큰 형태 우선 | edge flow 방향 | 폴리 상한 |
| Skeleton 계열 | humanoid | humanoid | **공통 계층 가능** | 스케일·웨이트 | 본 이름 최종 |
| VS 우선도 | 플레이어 | 보스 | P0 클립 구조 | 텔레그래프 포즈 | — |

---

## 9. Production Minimum (Seth Boss Arena VS)

숫자·기간 추정 없음. 조건만 분류.

### P0 — Gameplay 검증에 반드시 필요

- 식별 가능한 humanoid 실루엣 (AXION ≠ SETH)
- 스토리 스케일 반영 (25m / ≈30m) · 발 피벗 접지
- 기본 전신 메쉬 (비무장 또는 최소 실루엣 유지 무장)
- 관절 가동에 치명적이지 않은 토폴로지 (극단적 non-manifold 금지)
- SETH 손 노출 · AXION 여성 비례+질량이 원거리에서 읽힘
- Import 후 스폰·충돌·간단한 포즈 가능 수준

### P1 — Vertical Slice 시각적 완성

- 3톤 블록 가독
- 주요 장갑 분할이 Canon 키워드와 일치
- 최소 UV · 기본 Material
- SETH 차단 흉·넓은 견 / AXION 여백·코어 아이콘성

### P2 — Presentation 개선

- 핀 패널·무기 수납 디테일
- Support edge·엣지 피니시 (로봇혼/센티넬 방향)
- 간단한 LOD

### P3 — 최종 Polish

- 고밀도 마모·손상 스테이트 메쉬
- 완전 분리 Exploded · 무기 시트 완성
- 최적화·최종 폴리 예산

---

## 10. 권고

**최종 결정은 Master.**

### AXION 제작 선행조건

1. TEXT-LOCK(FRAME_SPEC · BRAVE_FINAL_SPEC) 비율·금지 항목 재확인
2. 실루엣·25m·비무장 기본 고정
3. Mesh 도구 경로 선택 (Meshy 1차 vs 수동)
4. (권장) T1 VERIFIED — 공간 스케일 피드백

### SETH 제작 선행조건

1. FORM · SETH_FINAL_SPEC 손 보임·≈30m·민등 고정
2. 차단 실루엣 vs AXION 대비 검증 체크리스트
3. 동일 도구 경로라도 **볼륨·edge flow는 별도**
4. (권장) T1 VERIFIED

### Meshy 사용 시 권장 흐름

```text
TEXT-LOCK 제약 프롬프트
  → Meshy 1차 볼륨
  → Blender: m 스케일 · 발 피벗 · 이름
  → 실루엣 검증 (실패 시 재생성 또는 수동 수정)
  → 관절 구간 topology
  → 최소 디테일 → (이후) UV / 리그
```

### Blender의 역할

- 스케일·오리진·명명 계약의 **유일한 확정 지점**
- Topology 정리 · Rig deform 준비 · FBX 베이크
- Meshy 출력을 최종으로 승격하지 않음

### Rigging / Skeleton / Animation 시작 시점

| 시점 | 조건 |
|------|------|
| Rigging 시작 | 최소 Mesh(P0 실루엣) 존재 후 |
| Skeleton 생성 | Mesh 정합 · 공통 humanoid 계층 확정 후 · **임시 선제작 금지** |
| Animation 시작 | Skeleton + 최소 Mesh · P0 조립식 클립만 |

### 현재 즉시 제작 가능한 것

- 본 Review 및 선행 전략 문서 기반 **범위·순서 결정**
- (로컬) T1 VERIFIED 체크리스트 수행
- Canon 실루엣 체크리스트를 프롬프트/블록아웃 가이드로 문서화 (Design 본문 수정 없이)

### 현재 제작하면 안 되는 것

- 최종 메쉬로 오인될 대량 Meshy 산출 커밋
- 임시 Skeleton 선제작 후 애니 양산
- Mannequin/Mixamo를 본 경로로 고정
- ORD-GRUNT · Canon/Novel 수정
- T1 UNVERIFIED 상태에서 T2+ 에셋 양산

---

## 위험 요약

| 위험 | 설명 |
|------|------|
| 실루엣 미고정 채 Mesh | 전량 재작업 |
| 무리한 자동 Quad | 관절·곡면 붕괴 |
| Skeleton 선행 | Mesh–본 불일치 |
| 양쪽 동시 고품질 목표 | 1인 범위 폭발 |
| Concept PNG를 Canon화 | TEXT-LOCK 위반 |

---

## NEXT

1. **Master:** Mesh 제작 착수 범위 · AXION/SETH 순서 · 도구 결정
2. UE 사용 가능 시 **T1 검증**
3. T1 VERIFIED 후 T2 착수 검토
4. Mesh 1차 확보 후 Skeleton 계층 확정 → P0 Animation

**본 문서는 Readiness 조사·권고만 수행한다. Mesh/Skeleton/Animation 구현 지시가 아니다.**

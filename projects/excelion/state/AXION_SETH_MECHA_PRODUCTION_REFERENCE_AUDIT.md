# AXION_SETH_MECHA_PRODUCTION_REFERENCE_AUDIT — Excelion

> 2026-08-16 · READ-ONLY 조사 + 문서화 전용  
> Canon / Novel / Unreal / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT / Design 파일 **변경 없음**  
> 실제 삼면도 제작 · Concept Image 생성 · Mesh 생성 · Blender 수정 **금지**  
> 목적: AXION / SETH Mesh 제작 전 Production Reference 확보 상태를 조사하고 Mesh 제작 가능성만 판정

**상태: Reference Audit 완료 · Mesh 제작 착수 전 Master 결정 대기**

---

## STATUS

### 완료
- AXION (BRAVE) reference audit
- SETH reference audit
- 기존 이미지/문서 조사
- threeview PNG / NOTES 조사
- Production Reference 항목 분류
- Mesh 제작 가능성 판정
- 추가 필요 자료 최소 목록
- 문서 저장
- Commit

### 현재 기준 (고정)
| 항목 | 상태 |
|------|------|
| AXION Canon 외형 | TEXT-LOCK EXISTING |
| SETH Canon 외형 | TEXT-LOCK EXISTING |
| 삼면도 PNG (orthographic) | **MISSING** |
| 실제 Mesh | **MISSING** |
| Skeleton / Animation | **MISSING** |
| VS Candidate A | APPROVED |
| T1 | IMPLEMENTED / UNVERIFIED |
| T2~T9 | BLOCKED |
| ORD-GRUNT | HOLD |

### 미확인
- 과거 세션에서 생성된 PNG가 로컬에만 존재하는지 여부 (Git에는 미반영)
- Concept PNG가 삼면도 제작 시 참고 가능한 정도 (REFERENCE only · Canon 아님)

### MISSING
- AXION Front / Side / Rear orthographic PNG
- SETH Front / Side / Rear orthographic PNG
- Scale reference 이미지
- 실제 Skeletal Mesh / Skeleton

### CONFLICT
- 없음 (TEXT-LOCK 문서 간 충돌 미발견)

### Master 결정 필요
- Production Reference(삼면도 등) 제작 범위 승인 여부
- Mesh 제작 착수 전 삼면도 필수 여부
- Concept PNG를 REFERENCE로만 쓸지 / 추가 정리 필요 여부

### 변경하지 않은 것
- Canon · Novel · Unreal · Blueprint · Asset · Animation · VFX · Audio · Input · ORD-GRUNT · Design 파일 · 폴더 구조

---

## 명명

런타임/게임 AXION = 디자인 TEXT-LOCK상 **BRAVE** (플레이어 주인공기).  
본 문서에서 AXION과 BRAVE는 동일 기체를 가리킨다.

---

## 1. AXION (BRAVE) Reference Audit

### 1.1 문서 (Canon / Design)

| 자료 | 경로 | 분류 | 비고 |
|------|------|------|------|
| BRAVE_FINAL_SPEC | design/mecha/brave/BRAVE_FINAL_SPEC.md | **EXISTING** | TEXT-LOCK FINAL · 25m · 여성형 슈퍼로봇 · 여백 · 비무장 |
| FRAME_SPEC | design/brave/FRAME_SPEC.md | **EXISTING** | TEXT-LOCK · 슬롯 · 핀 패널 |
| BRAVE_INFLUENCE | design/brave/BRAVE_INFLUENCE.md | **EXISTING** | 영향 언어 |
| DESCRIPTION | design/mecha/brave/DESCRIPTION.md | **EXISTING** | 외형 요약 |
| SUPER_ROBOT_DESIGN_LANGUAGE | design/mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md | **EXISTING** | 상위 언어 |
| MECHA_3TONE | design/MECHA_3TONE_LOW_DETAIL.md | **EXISTING** | 3톤 |
| THREEVIEW_CURRENT | design/THREEVIEW_CURRENT.md | **EXISTING** | PNG HOLD · brave PHASE4 |
| threeview NOTES | design/mecha/brave/threeview/NOTES.md | **EXISTING** | 생성 지시 이력 · PNG 미커밋 |
| MECHA_STATUS | design/MECHA_STATUS.md | **EXISTING** | Three-view: NOTES only · PNG HOLD |

### 1.2 이미지

| 자료 | 위치 | 분류 | 비고 |
|------|------|------|------|
| Concept / 생성 이미지 (ChatGPT·Gemini 다수, 디자인 시트 등) | design/brave/*.png · *.jpg | **REFERENCE** | Canon 변경 근거 **아님** · 참고 풀 |
| Orthographic threeview PNG | design/mecha/brave/threeview/ | **MISSING** | .gitkeep + NOTES only |
| Scale / 비율 기준 이미지 | — | **MISSING** | |

### 1.3 Novel / 기타

Novel 내 외형 상세는 본 감사에서 전수 검색하지 않음.  
MECHA_STATUS · SPEC이 스토리 역할·외형을 TEXT-LOCK으로 통합한 상태이므로, 외형 제작 기준은 SPEC 우선.

---

## 2. SETH Reference Audit

### 2.1 문서 (Canon / Design)

| 자료 | 경로 | 분류 | 비고 |
|------|------|------|------|
| SETH_FINAL_SPEC | design/mecha/seth/SETH_FINAL_SPEC.md | **EXISTING** | FINAL · ≈30m · 손 보임 · 민등 · 차단 |
| FORM.md | design/character/seth/FORM.md | **EXISTING** | TEXT-LOCK 형상 |
| DESCRIPTION | design/mecha/seth/DESCRIPTION.md · character/seth | **EXISTING** | |
| OFFICIAL_SETTING | design/character/seth/OFFICIAL_SETTING.md | **EXISTING** | |
| SETH_MECHA_SPEC (원천) | design/enemy/ (참조) | **EXISTING** | SPEC 원천 |
| THREEVIEW_CURRENT | design/THREEVIEW_CURRENT.md | **EXISTING** | seth PHASE3 대기 권장 · PNG HOLD |
| MECHA_STATUS | design/MECHA_STATUS.md | **EXISTING** | Three-view 없음 · HOLD |

### 2.2 이미지

| 자료 | 위치 | 분류 | 비고 |
|------|------|------|------|
| Orthographic threeview PNG | design/mecha/seth/threeview/ | **MISSING** | .gitkeep only |
| Concept / 생성 이미지 (seth 전용) | design/mecha/seth/ · character/seth/ | **MISSING** 또는 미확인 | 본 경로에 PNG 없음 |
| Scale reference | — | **MISSING** | |

### 2.3 Novel / 기타

EP6 계단 보스 역할은 SPEC에 고정. 외형 제작 기준은 FORM + SETH_FINAL_SPEC 우선.

---

## 3. Production Reference 항목 분류

Canon에 없는 항목은 채우지 않음. 상태만 표시.

### 3.1 AXION

| 항목 | 상태 | 근거 |
|------|------|------|
| Front silhouette | **PARTIAL** | 텍스트 실루엣 키워드 EXISTING · orthographic PNG MISSING |
| Side silhouette | **PARTIAL** | 동일 |
| Rear silhouette | **PARTIAL** | 민등/백팩 비활성 텍스트 EXISTING · PNG MISSING |
| Overall proportion | **EXISTING** | 25m · 여성 비례 + 슈퍼로봇 질량 |
| Height | **EXISTING** | 25.0 m |
| Head | **EXISTING** | 헬멧 · 가로 슬릿 · 뿔·안테나 없음 |
| Torso | **EXISTING** | Imperial 여백 + 아이콘 코어 |
| Shoulder | **EXISTING** | 어깨 덩어리 분명 |
| Arm | **EXISTING** | 곡면+판 · 질량 |
| Hand | **EXISTING** | 손가락형 가능 |
| Pelvis | **PARTIAL** | 허리 한 단 언급 · 상세 적음 |
| Leg | **EXISTING** | 길되 질량 · 접지 안정 |
| Foot | **PARTIAL** | 접지 언급 · 상세 적음 |
| Back structure | **EXISTING** | 백팩·스러스터 초기 비활성 |
| Weapon | **EXISTING** | 기본 비무장 · blade/cannon/drone 수납 |
| Major articulation | **PARTIAL** | humanoid 가정 · 관절 각도 한계 UNKNOWN |
| Surface design | **EXISTING** | 저~중밀도 패널 · 여백 |
| Material boundary | **EXISTING** | 3톤 `#C0C8D0` / `#2A3A4A` / `#E8A020` |

### 3.2 SETH

| 항목 | 상태 | 근거 |
|------|------|------|
| Front silhouette | **PARTIAL** | 단정·차단·손 보임 텍스트 · PNG MISSING |
| Side silhouette | **PARTIAL** | 동일 |
| Rear silhouette | **PARTIAL** | 민등 · 망토·배팩 금지 텍스트 · PNG MISSING |
| Overall proportion | **EXISTING** | ≈30m · 근육질 전사 · BRAVE+20% |
| Height | **EXISTING** | 약 30 m |
| Head | **EXISTING** | 단정 헬멧 · 슬릿 · 뿔·왕관 금지 |
| Torso | **EXISTING** | 가로 차단 흉갑 |
| Shoulder | **EXISTING** | 넓은 견 |
| Arm | **EXISTING** | 굵은 사지 |
| Hand | **EXISTING** | **손 보임** 필수 |
| Pelvis | **PARTIAL** | 중저 중심 · 상세 적음 |
| Leg | **EXISTING** | 굵은 대퇴 · 넓은 접지 |
| Foot | **PARTIAL** | 넓은 접지 · 상세 적음 |
| Back structure | **EXISTING** | 민등 · 배팩 금지 |
| Weapon | **EXISTING** | line-resolver · seal-plate · 근접 제압 |
| Major articulation | **PARTIAL** | humanoid · 각도 한계 UNKNOWN |
| Surface design | **EXISTING** | 장식 최소 · 각+근골 |
| Material boundary | **EXISTING** | 저채도 청회·흑회 · 냉광 슬릿 |

---

## 4. Mesh 제작 가능성 판정

| 기체 | 판정 | 이유 |
|------|------|------|
| **AXION** | **PARTIALLY READY** | TEXT-LOCK 비율·실루엣·색·금지가 문서에 존재. 그러나 orthographic 삼면도 PNG MISSING → Meshy/블록아웃 시 해석 분산·재작업 위험. Concept PNG는 REFERENCE only. |
| **SETH** | **PARTIALLY READY** | TEXT-LOCK 비율·손 보임·민등·차단이 문서에 존재. 삼면도 PNG 및 전용 Concept 이미지 MISSING → 동일 위험. |

**READY 아님.** 현재 자료만으로 “최종 Mesh” 착수는 권하지 않음.  
**NOT READY 아님.** 최소 실루엣 블록아웃/프롬프트 제약은 문서로 가능.

---

## 5. 추가로 필요한 자료 (최소 · Canon 미확정 항목 강제 아님)

Mesh 제작을 **안정적으로** 시작하려면 다음이 유리하다. 임의 요구사항으로 확정하지 않음.

| 우선 | 자료 | AXION | SETH | 비고 |
|------|------|-------|------|------|
| P0 | Front orthographic | MISSING | MISSING | 실루엣·비율 고정 |
| P0 | Side orthographic | MISSING | MISSING | 깊이·질량 |
| P0 | Rear orthographic | MISSING | MISSING | 등 구조 검증 |
| P1 | Scale reference (높이 막대 등) | MISSING | MISSING | 25m / 30m |
| P1 | Major articulation 표기 | PARTIAL | PARTIAL | 관절 위치만 |
| P2 | Weapon 수납/전개 참고 | 텍스트 EXISTING | 텍스트 EXISTING | PNG 선택 |

Concept PNG(AXION 쪽 다수)는 **REFERENCE**로만 사용. TEXT-LOCK과 충돌 시 TEXT-LOCK 우선 · 충돌 시 보고.

---

## 6. Production Package 최소 구조 (검토만 · 생성 안 함)

향후 유용할 수 있는 구조 (이번 작업에서 폴더 생성/이동 **하지 않음**):

```text
projects/excelion/design/mecha/
  brave/          (또는 axion/)
    threeview/    ← orthographic PNG 목표 위치 (현재 .gitkeep)
  seth/
    threeview/    ← 동일
```

현재 threeview 경로는 이미 존재하며 PNG만 비어 있음. 구조 자체는 추가 생성 불필요.

---

## 7. 선행 문서와의 관계

| 문서 | 관계 |
|------|------|
| AXION_SETH_MECHA_MESH_PRODUCTION_READINESS_REVIEW | Mesh 파이프라인·P0~P3 · 본 Audit은 Reference 입력값 확보에 초점 |
| AXION_SETH_ANIMATION_SKELETON_STRATEGY_REVIEW | Skeleton 전략 · Mesh 이후 |
| THREEVIEW_CURRENT · NOTES | PNG HOLD · 생성 이력 |
| MESHY_BLENDER_PIPELINE_SPEC | 도구 계약 |

본 Audit은 위 문서와 **중복 생성하지 않음**. Reference 상태만 분리 기록.

---

## 8. 위험

| 위험 | 설명 |
|------|------|
| 삼면도 없이 Meshy 직행 | 비율·여백·차단 키워드 이탈 → Mesh·Rig·Anim 연쇄 재작업 |
| Concept PNG를 Canon화 | TEXT-LOCK 위반 |
| 양쪽 고품질 삼면도 동시 | 1인 범위 과다 |
| T1 UNVERIFIED 상태에서 에셋 양산 | 공간 스케일 피드백 없음 |

---

## NEXT

1. **Master:** Reference Audit 검토  
2. 필요 시 Production Reference(삼면도 등) **제작 범위 승인**  
3. 승인 후 Reference 확보 → Mesh 제작 여부 결정  
4. T1 실기 검증 가능 시 T1 VERIFIED 유지/승격  
5. Mesh 확보 전 Skeleton / Animation 착수 금지 (기존 전략 유지)

**본 문서는 조사·판정만 수행한다. 삼면도·Mesh·Canon 구현 지시가 아니다.**

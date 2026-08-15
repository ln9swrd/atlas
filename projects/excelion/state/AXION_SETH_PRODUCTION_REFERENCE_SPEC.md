# AXION_SETH_PRODUCTION_REFERENCE_SPEC — Excelion

> 2026-08-16 · READ-ONLY 분석 + 문서화 전용  
> Canon / Novel / Unreal / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT / Design 파일 **변경 없음**  
> 실제 삼면도 PNG · Concept Image · Mesh · Blender 수정 **금지**  
> 목적: 현재 TEXT-LOCK만으로 Mesh 제작용 Production Reference를 구성할 수 있는지 정리하고, 삼면도 제작 전 확정 항목을 분리한다

**상태: Production Reference Spec 작성 완료 · Master 결정 대기**

---

## STATUS

### 완료
- AXION Production Reference 분석
- SETH Production Reference 분석
- Locked / Inferred / Unknown 분류
- Three-view 요구사항 정리
- Mesh 제작 전/후 조건 분리
- Concept 활용 기준
- 문서 저장
- Commit

### 현재 판정 (변경 없음)
| 기체 | Mesh 준비도 |
|------|-------------|
| AXION (BRAVE) | **PARTIALLY READY** |
| SETH | **PARTIALLY READY** |

### MISSING
- Orthographic Front / Side / Rear PNG (AXION · SETH)
- Scale reference 이미지
- 관절 각도 한계 수치
- 최종 UV / Material instance 경로

### Master 결정 필요
- 삼면도 제작 전 최소 항목 승인 목록 (본 문서 §8)
- 삼면도 없이도 P0 Mesh 블록아웃 허용 여부
- Concept PNG 활용 수준 (REFERENCE only 유지 권고)

### 변경하지 않은 것
- Canon · Novel · Unreal · Blueprint · Asset · Animation · VFX · Audio · Input · ORD-GRUNT · Design 파일

---

## 명명

런타임 AXION = 디자인 TEXT-LOCK **BRAVE**. 본 문서에서 AXION = BRAVE.

---

## 상태 정의

| 상태 | 의미 |
|------|------|
| **LOCKED** | Canon/TEXT-LOCK에 직접 명시 · 제작 기준으로 사용 가능 |
| **INFERRED** | 명시 문장에서 합리적으로 읽히나 수치·도면으로 고정되지 않음 · Canon 승격 금지 |
| **UNKNOWN** | Canon에 없음 · 추정 금지 |
| **MISSING** | 제작에 필요하나 현재 산출물 없음 (이미지 등) |

INFERRED를 LOCKED로 바꾸지 않는다.

---

## 1. AXION (BRAVE) — 부위별 Production Reference

출처 우선: `BRAVE_FINAL_SPEC` · `FRAME_SPEC` · `DESCRIPTION` · `MECHA_STATUS`

| 항목 | 내용 | 출처 | 상태 |
|------|------|------|------|
| 전체 높이 | **25.0 m** | FRAME · FINAL | **LOCKED** |
| 전체 비율 | humanoid · **여성형 슈퍼로봇** · 머리 작게 · 어깨 과하지 않음 · 허리 한 단 · 다리 길되 **질량** | FRAME · FINAL · DESC | **LOCKED** |
| 머리 | 헬멧형 · 가로 슬릿/바이저 또는 단일 렌즈 · 뿔·안테나 없음 · 캐릭터성 | FRAME · FINAL | **LOCKED** |
| 목 | 명시 적음 · 두부–흉 연결로 읽힘 | — | **UNKNOWN** (세부) |
| 흉부 | Imperial 여백 · 중앙 코어 · 큰 곡면 장갑 · 아이콘성 | FRAME · FINAL | **LOCKED** |
| 복부 | 평면 위주 · 여백 · 허리 한 단 연결 | FRAME | **LOCKED** (요약) |
| 골반 | 허리–골반 연결 분명 · 곡선 · 스커트 비활성 | FRAME · DESC | **PARTIAL / INFERRED** |
| 어깨 | 과하지 않되 **분명한 덩어리** | FRAME · DESC | **LOCKED** |
| 팔 | 상완·전완 단순 원통+판 · 슈퍼로봇 질량 · 기본 거포·방패 없음 | FRAME | **LOCKED** |
| 손 | 손가락형 가능 · 실루엣 비파괴 | FRAME | **LOCKED** |
| 허벅지 | 판 최소 · 덩어리 · 질량 유지 | FRAME · DESC | **LOCKED** (요약) |
| 무릎 | 관절 읽힘 | FRAME | **LOCKED** (키워드) |
| 종아리 | 덩어리 · 정강이 판 최소 | FRAME · DESC | **LOCKED** (요약) |
| 발 | 안정 접지형 · 과한 스파이크 없음 | FRAME | **LOCKED** |
| 등 | 백팩·스러스터 **초기 비활성** · 등판 단순 | FRAME · FINAL | **LOCKED** |
| 장갑 | 저~중밀도 패널 · 큰 면 우선 · 여백 유지 | FRAME · 3TONE | **LOCKED** |
| 주요 실루엣 | 영웅형 · 여백 · 곡선 외곽 · 정지 시에도 돌진·타격 연상 | FINAL · DESC | **LOCKED** |
| 무장 | **기본 비무장** · blade/cannon/drone 수납·연출 레이어 | FINAL | **LOCKED** |
| 특징 파츠 | 핀 패널(평시 닫힘) · 코어 accent | FRAME | **LOCKED** |
| 색 | primary `#C0C8D0` · secondary `#2A3A4A` · accent `#E8A020` | FRAME · FINAL | **LOCKED** |
| 관절 각도 한계 | — | — | **UNKNOWN** |
| 폴리곤 상한 | — | — | **UNKNOWN** |

---

## 2. SETH — 부위별 Production Reference

출처 우선: `SETH_FINAL_SPEC` · `FORM.md` · `DESCRIPTION` · `MECHA_STATUS`

| 항목 | 내용 | 출처 | 상태 |
|------|------|------|------|
| 전체 높이 | **약 30 m** (BRAVE +20%) | FORM · FINAL | **LOCKED** |
| 전체 비율 | humanoid · **근육질 전사** · 역삼각형 · 중저 중심 · 질량감 | FORM · FINAL | **LOCKED** |
| 머리 | 단정 헬멧 · 평면~쐐기 · 가로 슬릿 1~2 · 뿔·왕관·안테나 0 | FORM · FINAL | **LOCKED** |
| 목 | 명시 적음 | — | **UNKNOWN** (세부) |
| 흉부 | 가로 차단 흉갑 · 두께 · “벽” | FORM · FINAL | **LOCKED** |
| 복부 | 전사형 최소 잘록 | FORM | **LOCKED** (요약) |
| 골반 | 안정용 골반 폭 | FORM | **LOCKED** (키워드) |
| 어깨 | 넓은 견 · 각 + 삼각근 볼륨 · 스파이크·날개 0 | FORM · FINAL | **LOCKED** |
| 팔 | 상완·전완 **굵음** · 근골 실루엣 | FORM | **LOCKED** |
| 손 | **항상 보임** · 3~5지 · 제압·처리 | FORM · FINAL | **LOCKED** |
| 허벅지 | 굵은 대퇴 · 버팀 | FORM · FINAL | **LOCKED** |
| 무릎 | 무릎 블록 큼 | FORM | **LOCKED** |
| 종아리 | 각진 정강 · 전면 판 | FORM | **LOCKED** |
| 발 | 넓은 족부 · 넓은 접지 | FORM · FINAL | **LOCKED** |
| 등 | **민등** · 배팩·망토·익 금지 | FORM · FINAL | **LOCKED** |
| 장갑 | 각진 차단 아머 · 근골 위 · 장식 최소 | FORM · FINAL | **LOCKED** |
| 주요 실루엣 | 단정 · 차단 · 근육질 · 손 보임 · 막아서 처리 | FORM · FINAL | **LOCKED** |
| 무장 | line-resolver · seal-plate · 근접 제압 · 평시 맨몸 전사 실루엣 | FINAL | **LOCKED** |
| 특징 파츠 | 차단벽 흉 · 노출 수부 | FORM | **LOCKED** |
| 색 | 저채도 청회·흑회 · 냉광 슬릿 · 금·호박·적열 금지 | FORM · FINAL | **LOCKED** |
| 관절 각도 한계 | — | — | **UNKNOWN** |
| 폴리곤 상한 | — | — | **UNKNOWN** |

**참고:** `mecha/seth/DESCRIPTION.md`의 “리부트 대기 · 실루엣 3안 전 최종 삼면도 STOP”은 **시각 리부트 정책**이다. SETH_FINAL_SPEC · FORM의 TEXT-LOCK 외형 키워드는 유지. 리부트 후보를 Canon으로 승격하지 않는다.

---

## 3. Production Reference Table (요약)

| 항목 | AXION | SETH | 출처 | 상태 |
|------|-------|------|------|------|
| Height | 25 m | ≈30 m (+20%) | FRAME/FINAL · FORM/FINAL | LOCKED |
| Proportion | 여성형 슈퍼로봇 · 여백 · 질량 | 근육질 전사 · 역삼각 · 중저 | FRAME · FORM | LOCKED |
| Head | 영웅 헬멧 · 슬릿 · 뿔 0 | 단정 헬멧 · 슬릿 · 뿔·왕관 0 | FINAL · FORM | LOCKED |
| Torso | 여백 + 코어 아이콘 | 가로 차단 흉갑 | FINAL · FORM | LOCKED |
| Shoulder | 분명한 덩어리 | 넓은 견 · 근골 | FINAL · FORM | LOCKED |
| Arm | 원통+판 · 질량 | 굵은 근골 | FRAME · FORM | LOCKED |
| Hand | 손가락형 가능 | **항상 보임** | FRAME · FORM | LOCKED |
| Leg / Foot | 질량 · 안정 접지 | 굵은 대퇴 · 넓은 접지 | FRAME · FORM | LOCKED |
| Back | 백팩 비활성 | 민등 · 배팩 금지 | FRAME · FORM | LOCKED |
| Weapon default | 비무장 | 맨몸 전사 실루엣 + 레이어 무장 | FINAL | LOCKED |
| Palette | 3톤 회백·남회·호박 | 청회·흑회·냉광 | FRAME · FORM | LOCKED |
| Front/Side/Rear PNG | MISSING | MISSING | threeview/ | **MISSING** |
| Joint limits | UNKNOWN | UNKNOWN | — | UNKNOWN |

---

## 4. Three-view 제작에 필요한 최소 정보

실제 PNG는 만들지 않는다. 정보 확보 상태만 구분.

### 4.1 FRONT

| 요소 | AXION | SETH |
|------|-------|------|
| 실루엣 | LOCKED (텍스트) | LOCKED (텍스트) |
| 비율 | LOCKED | LOCKED |
| 주요 파츠 (머리·흉·견·손·다리) | LOCKED | LOCKED |
| 장갑 경계 / 패널 밀도 | LOCKED (저~중 · 여백 vs 차단) | LOCKED (장식 최소) |
| Orthographic PNG | **MISSING** | **MISSING** |

### 4.2 SIDE

| 요소 | AXION | SETH |
|------|-------|------|
| 깊이 / 두께 | LOCKED 요약 (과하지 않음 · 날씬한 기계) | LOCKED 요약 (측면 두께 있음 · 슬림 아님) |
| 흉부·복부 돌출 | INFERRED (여백·평면 위주) | LOCKED (흉 두께 · 차단) |
| 머리 위치 | LOCKED (헬멧) | LOCKED (단정 투구) |
| 등 구조 | LOCKED (백팩 없음) | LOCKED (민등) |
| 다리 깊이 | PARTIAL | PARTIAL |
| Orthographic PNG | **MISSING** | **MISSING** |

### 4.3 REAR

| 요소 | AXION | SETH |
|------|-------|------|
| 등 구조 | LOCKED (단순 · thruster 없음) | LOCKED (민등) |
| 백팩 | LOCKED 비활성 | LOCKED 금지 |
| 후면 장갑 | PARTIAL | PARTIAL |
| 다리 후면 | UNKNOWN 세부 | UNKNOWN 세부 |
| Orthographic PNG | **MISSING** | **MISSING** |

---

## 5. Mesh 제작 최소 기준 — 분리

### A. 현재 확정 가능 (문서만)

- 전고 25 m / ≈30 m
- humanoid · AXION 여성형 슈퍼로봇 vs SETH 근육질 전사
- 손: AXION 가능 / SETH **필수 노출**
- 등: AXION 백팩 비활성 / SETH 민등
- 기본 무장 실루엣: AXION 비무장 / SETH 맨몸 전사
- 3톤(AXION) · 청회·흑회·냉광(SETH)
- 금지 목록 (건담화 · 남성 bulk · 왕관·망토 · 네메시스 카피 등)

### B. Reference 필요 (삼면도 또는 동등한 orthographic)

- Front/Side/Rear에서 읽히는 **정확한 깊이·볼륨 곡선**
- 장갑 분할 라인의 시각적 위치 (텍스트만으로는 해석 분산)
- 관절 주름·가동 여유 공간의 형상
- 발 접지 면적·피벗 정합을 도면으로 고정

### C. Master 결정 필요

- 삼면도 없이 P0 Mesh(Meshy/블록아웃) 착수 허용 여부
- AXION / SETH 제작 순서
- SETH “시각 리부트”와 TEXT-LOCK의 병행 규칙 (DESCRIPTION STOP vs FORM LOCK)
- Concept PNG를 삼면도 대용으로 쓸지 여부 (권고: **쓰지 않음**)

---

## 6. Concept PNG 활용 기준

| 수준 | 정의 | 허용 |
|------|------|------|
| **Canon** | TEXT-LOCK 문서 | Concept로 Canon 변경 **금지** |
| **Production Reference** | orthographic · 비율·실루엣 고정용 | Concept PNG는 **이 수준으로 승격하지 않음** |
| **Visual Reference** | 분위기·밀도·핀 패널 참고 | design/brave 다수 PNG = **이 수준만** |

충돌 시: **TEXT-LOCK 우선** · 이미지는 보고만 하고 수정하지 않음 · Master 결정 대상.

THREEVIEW_CURRENT · brave/threeview/NOTES: 이미지 생성 = **HOLD**. 본 Spec이 HOLD를 해제하지 않는다.

---

## 7. Mesh 준비도 (재확인 · 변경 없음)

| 기체 | 판정 | 한 줄 |
|------|------|--------|
| AXION | **PARTIALLY READY** | LOCKED 텍스트로 프롬프트·체크리스트 가능 · orthographic MISSING으로 최종 형상 고정 불가 |
| SETH | **PARTIALLY READY** | 동일 · 추가로 DESCRIPTION 리부트 STOP과 FORM LOCK 병존 → Master 정렬 필요 |

READY / NOT READY로 승격·강등하지 않음.

---

## 8. 삼면도 제작 전 Master가 결정해야 하는 최소 항목

1. **AXION 25m / SETH ≈30m 비율을 삼면도에 그대로 고정할지** (LOCKED 유지 권고)
2. **AXION 기본 비무장 · SETH 맨몸 전사 실루엣**을 삼면도 기본 포즈로 할지
3. **SETH 손 노출 · 민등**을 필수 검증 항목으로 삼면도 검수에 넣을지
4. **삼면도 없이 P0 Mesh 허용** vs **삼면도 후 Mesh만 허용**
5. **SETH 시각 리부트(DESCRIPTION STOP)** 를 삼면도 전에 닫을지 · TEXT-LOCK만으로 진행할지
6. **Concept PNG** 를 Visual Reference로만 둘지 (권고: REFERENCE only)

위 6항이 정해지기 전에는 삼면도 제작 지시·Mesh 양산을 권하지 않는다.

---

## 9. 선행 문서

| 문서 | 역할 |
|------|------|
| AXION_SETH_MECHA_PRODUCTION_REFERENCE_AUDIT | Reference 존재/결여 감사 |
| AXION_SETH_MECHA_MESH_PRODUCTION_READINESS_REVIEW | 파이프라인 · P0~P3 |
| AXION_SETH_ANIMATION_SKELETON_STRATEGY_REVIEW | Skeleton은 Mesh 이후 |
| THREEVIEW_CURRENT · threeview/NOTES | PNG HOLD |

본 문서는 **TEXT-LOCK → Production Reference 명세**에 한정. 중복 감사 아님.

---

## NEXT

1. Master: 본 Spec 검토 · §8 최소 항목 결정  
2. 승인 시: 필요한 Reference(삼면도 등) 제작 범위만 별도 지시  
3. Mesh 착수는 위 결정 + (권장) T1 VERIFIED 이후  
4. Skeleton / Animation은 Mesh 정합 후 (기존 전략 유지)

**본 문서는 분석·명세만 수행한다. 삼면도·Mesh·Canon 구현 지시가 아니다.**

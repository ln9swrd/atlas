# AXION_SETH_PRODUCTION_REFERENCE_SCOPE — Excelion

> 2026-08-16 · 계획/명세 전용  
> Canon / Novel / Design / 삼면도 PNG / Concept / Mesh / Skeleton / Animation / Unreal **변경·생성 없음**  
> 목적: §8 MASTER APPROVED 기준으로 Three-view Production Reference의 **최소 범위·순서·품질·승인 단위**만 정의한다

**상태: Scope 정의 완료 · Production Reference 제작 착수 = Master 승인 대기**

---

## STATUS

### 완료
- 제작 대상 정의
- 제작 순서 권고
- 메카별 최소 Reference 구성
- P0 품질 기준
- Canon 보호 규칙
- 승인 단위·상태 전이
- 문서 저장
- Commit

### 기준 (고정 · §8)
| 항목 | 값 |
|------|-----|
| AXION 높이 | 25 m TEXT-LOCK |
| SETH 높이 | ≈30 m TEXT-LOCK |
| Pose | Neutral A/T · Production Reference용 · Canon Pose 아님 |
| SETH 손/민등 | TEXT-LOCK 유지 · Reference 전 검수 |
| 삼면도 없이 P0 Mesh | **금지** |
| SETH 리부트 | **하지 않음** · TEXT-LOCK 유지 |
| Concept PNG | REFERENCE only |

### 현재 제작 상태
| 항목 | 상태 |
|------|------|
| T1 Level Blockout | IMPLEMENTED / UNVERIFIED |
| Production Reference §8 | MASTER APPROVED |
| AXION Three-view | **NOT STARTED** |
| SETH Three-view | **NOT STARTED** |
| Mesh | **BLOCKED** |
| Skeleton / Animation | **BLOCKED** |

### Master 결정 필요
- 본 Scope 승인 여부
- AXION Three-view 제작 **착수** 승인 여부

### 변경하지 않은 것
- Canon · Novel · Design · 이미지 · Mesh · Unreal · Blueprint · Asset

---

## 1. 제작 대상

| 기체 | 포함 | 이유 |
|------|------|------|
| **AXION (BRAVE)** | 예 | VS 플레이어 메카 · Reference 규칙·품질 기준 검증용 1호 |
| **SETH** | 예 | VS 보스 · AXION 승인 후 |

기타 메카(ORD-GRUNT, NEMESIS 등)는 본 Scope **밖**.

---

## 2. 제작 순서 (권고)

```text
AXION Three-view DRAFT
        ↓
Master 검수
        ↓
AXION APPROVED
        ↓
SETH Three-view DRAFT
        ↓
Master 검수
        ↓
SETH APPROVED
        ↓
(이후) Mesh 제작 승인 검토
```

- 양쪽 동시 제작하지 않음.
- AXION이 품질·프로세스 기준선이 됨.
- SETH는 AXION APPROVED 이후 착수 권고.

---

## 3. 메카별 최소 Production Reference

각 메카 **필수**:

| View / 요소 | 필요 | 비고 |
|-------------|------|------|
| Front orthographic | 필수 | 실루엣·비율·주요 파츠 |
| Side orthographic | 필수 | 깊이·등/흉 구조 |
| Rear orthographic | 필수 | 등·백팩 유무 검증 |
| Neutral A/T Pose | 필수 | §8 · Canon Pose 아님 |
| Height / Scale | 필수 | AXION 25m · SETH ≈30m 표기 또는 기준 막대 |

**선택 (P0 밖):** 무기 전개 뷰 · Exploded · 8방향 turnaround · 최종 렌더.

저장 위치 (기존 구조 유지 · 이번 작업에서 폴더 생성 안 함):

```text
design/mecha/brave/threeview/   ← AXION PNG 목표
design/mecha/seth/threeview/    ← SETH PNG 목표
```

현재 둘 다 PNG **MISSING** (.gitkeep / NOTES만).

---

## 4. 품질 기준 — P0 Production Reference

### 목적 한 줄

> 이 이미지를 보고 **동일한 형태의 3D Mesh**를 만들 수 있는가?

### P0 충족 조건

| 조건 | 설명 |
|------|------|
| 실루엣 명확 | 원거리에서 AXION ≠ SETH 식별 |
| 전체 비율 | 머리·흉·견·허리·다리 비례가 TEXT-LOCK과 일치 |
| 주요 장갑 경계 | 큰 면·차단/여백이 읽힘 |
| 관절 위치 | 어깨·팔꿈치·고관절·무릎 위치 추정 가능 |
| F/S/R 정합 | 세 뷰가 동일 기체·동일 스케일 |
| Scale | 25m / ≈30m 대응 가능 |
| SETH 특수 | 손 노출 · 민등이 Rear/Front에서 확인 |
| AXION 특수 | 비무장 기본 · 백팩 없음 · 여백·여성형 질량 |

### P0에서 **불필요**

- 최종 렌더 · 고급 재질 · 최종 Texture
- VFX · 포즈 연출 · 배경
- Presentation Polish · 고밀도 패널 완성
- 신규 무장·장식·색 체계

배경: 순백 권고 (기존 threeview NOTES와 정합).

---

## 5. Canon 보호

| 규칙 | 내용 |
|------|------|
| 추가 금지 | Canon에 없는 무장·장갑·백팩·장식·색 체계를 삼면도에 넣지 않음 |
| 정보 부족 | **UNKNOWN** 으로 남김 · 임의 채움 금지 |
| 디자인 판단 | **MASTER DECISION** · 에이전트가 결정하지 않음 |
| Concept PNG | REFERENCE only · 삼면도·Canon 근거 아님 |
| TEXT-LOCK 우선 | 이미지와 문서 충돌 시 문서 우선 · 보고만 |

삼면도는 Canon **변경이 아니라** TEXT-LOCK의 시각적 풀어냄(Production Reference)이다.  
새 디자인 요소가 생기면 별도 Master 승인 전까지 Mesh에 반영하지 않는다.

---

## 6. 제작 승인 단위

메카마다 **독립** 상태 전이.

```text
NOT STARTED
    ↓  (Master 착수 승인)
DRAFT
    ↓  (Master 검수)
MASTER REVIEW
    ↓  승인 / 수정 지시
APPROVED  또는  수정 후 DRAFT
```

| 기체 | 현재 |
|------|------|
| AXION | **NOT STARTED** |
| SETH | **NOT STARTED** |

- AXION APPROVED 전에 SETH DRAFT 착수 비권고.
- Mesh는 **해당 메카 Three-view APPROVED** 후에만 검토 (§8: 삼면도 없이 P0 Mesh 금지).

---

## 7. 검수 체크리스트 (Master Review용)

### AXION

- [ ] 25 m / 여성형 슈퍼로봇 질량·여백
- [ ] 기본 비무장 · 백팩 없음
- [ ] 헬멧·코어·어깨 덩어리 읽힘
- [ ] Front/Side/Rear 정합 · A/T Pose
- [ ] Canon 외 요소 없음

### SETH

- [ ] ≈30 m / 근육질 전사 · 차단 흉
- [ ] **손 보임** · **민등**
- [ ] 뿔·왕관·망토·배팩 없음
- [ ] Front/Side/Rear 정합 · A/T Pose
- [ ] Canon 외 요소 없음

---

## 8. 선행 문서

| 문서 | 역할 |
|------|------|
| AXION_SETH_PRODUCTION_REFERENCE_SPEC (§8 APPROVED) | 결정 록 |
| AXION_SETH_MECHA_PRODUCTION_REFERENCE_AUDIT | MISSING 감사 |
| AXION_SETH_MECHA_MESH_PRODUCTION_READINESS_REVIEW | Mesh는 Reference 이후 |
| THREEVIEW_CURRENT · threeview/NOTES | PNG HOLD 이력 |

본 문서는 **범위·순서·품질·승인**만. 이미지 생성 지시 아님.

---

## NEXT

1. **Master:** 본 Scope 승인 여부  
2. 승인 시: **AXION Three-view 제작 착수**만 별도 지시  
3. AXION DRAFT → Master Review → APPROVED  
4. 이후 SETH 동일  
5. 양쪽(또는 VS에 필요한 쪽) APPROVED 후 Mesh 승인 검토  
6. T1은 별도 HOLD · UE 가능 시 검증

**실제 삼면도·Mesh·Canon 작업은 Master의 다음 착수 지시 전까지 수행하지 않는다.**

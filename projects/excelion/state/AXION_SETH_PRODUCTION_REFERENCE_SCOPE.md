# AXION_SETH_PRODUCTION_REFERENCE_SCOPE — Excelion

> 2026-08-16 · 계획/명세  
> Canon / Novel 본문 변경 없음  
> 목적: §8 MASTER APPROVED 기준 Three-view Production Reference **최소 범위·순서·품질·승인 단위**

**상태: Scope MASTER APPROVED · AXION Three-view = DRAFT (Master Review 대기)**

---

## STATUS

### 완료
- Scope 정의
- Scope MASTER APPROVED (2026-08-16)
- AXION P0 DRAFT 착수 (prompt · DRAFT_STATUS · NOTES)

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
| Production Reference Scope | **MASTER APPROVED** |
| AXION Three-view | **DRAFT** (Master Review 대기) |
| SETH Three-view | **NOT STARTED** (AXION APPROVED 후) |
| Mesh | **BLOCKED** |
| Skeleton / Animation | **BLOCKED** |

### Master 결정 필요
- AXION DRAFT 검수 → APPROVED / 수정

### 변경하지 않은 것
- Canon · Novel · Mesh · Skeleton · Animation · Unreal · SETH 제작

---

## 1. 제작 대상

| 기체 | 포함 | 이유 |
|------|------|------|
| **AXION (BRAVE)** | 예 | VS 플레이어 · 1호 Reference |
| **SETH** | 예 | VS 보스 · AXION APPROVED 후 |

---

## 2. 제작 순서

```text
AXION Three-view DRAFT     ← 현재
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
Mesh 제작 승인 검토
```

---

## 3. 메카별 최소 Production Reference

| View / 요소 | 필요 |
|-------------|------|
| Front orthographic | 필수 |
| Side orthographic | 필수 |
| Rear orthographic | 필수 |
| Neutral A/T Pose | 필수 |
| Height / Scale | 필수 (25m / ≈30m) |

경로:

```text
design/mecha/brave/threeview/   ← AXION (DRAFT 문서 존재)
design/mecha/seth/threeview/    ← SETH (미착수)
```

---

## 4. 품질 기준 — P0

목적: 이 이미지를 보고 동일한 형태의 3D Mesh를 만들 수 있는가?

필수: 실루엣 · 비율 · 주요 장갑 · 관절 위치 · F/S/R 정합 · Scale  
불필요: 최종 렌더 · 고급 재질 · VFX · 배경 · 신규 디자인

---

## 5. Canon 보호

- Canon 없는 무장·백팩·장식·색 체계 추가 금지
- 정보 부족 → UNKNOWN
- 디자인 판단 → MASTER DECISION
- Concept PNG → REFERENCE only

---

## 6. 승인 단위

| 기체 | 현재 |
|------|------|
| AXION | **DRAFT** |
| SETH | **NOT STARTED** |

Mesh는 해당 메카 Three-view **APPROVED** 후에만.

---

## 7. 검수 체크리스트 (AXION)

- [ ] 25 m / 여성형 슈퍼로봇 질량·여백
- [ ] 기본 비무장 · 백팩 없음
- [ ] 헬멧·코어·어깨 덩어리 읽힘
- [ ] Front/Side/Rear 정합 · A-pose
- [ ] Canon 외 요소 없음

---

## NEXT

1. **Master Review** of AXION P0 sheet  
2. Pass → AXION APPROVED  
3. Fail → 수정 지시  
4. AXION APPROVED 후 SETH 착수 검토  
5. Mesh는 Three-view APPROVED 전 BLOCKED

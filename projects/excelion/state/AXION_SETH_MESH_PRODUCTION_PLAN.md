# AXION_SETH_MESH_PRODUCTION_PLAN — Excelion

> 2026-08-16 · 계획/명세  
> Canon / Novel 변경 금지

**상태: Mesh Production Plan = MASTER APPROVED · AXION P0 Mesh = NOT STARTED (EDITOR_REQUIRED)**

상세 실행 상태: `state/AXION_P0_MESH_PRODUCTION_STATUS.md`

---

## STATUS

### 선행 완료
| 항목 | 상태 |
|------|------|
| Production Reference §8 | MASTER APPROVED |
| AXION Three-view | **APPROVED** |
| SETH Three-view | **APPROVED** |
| Mesh Production Plan | **MASTER APPROVED** |
| AXION P0 Mesh | **NOT STARTED** · Blender/Meshy 로컬 필요 |
| SETH P0 Mesh | AXION 검수 후 |
| T1 Level Blockout | IMPLEMENTED / UNVERIFIED |
| Skeleton / Animation | BLOCKED |

### 에이전트 세션
- Blender / Meshy **없음** → Mesh 파일 미생성
- IMPLEMENTED로 기록하지 않음

### Master 결정 필요
- 로컬 AXION P0 Mesh 실행 결과 회신

---

## 1. 제작 순서

```text
Three-view APPROVED (AXION · SETH)
        ↓
Mesh Production Plan MASTER APPROVED
        ↓
AXION P0 Mesh (로컬 Meshy + Blender)
        ↓
Master 검수
        ↓
SETH P0 Mesh
        ↓
Skeleton (Mesh 후)
```

---

## 2–11. (계약 유지)

Meshy = 1차 볼륨만 · Blender m·발 피벗 · P0 ≠ 최종 · Skeleton 선제작 금지 · LOD P0 불필요 · UE P0는 Static 검증 가능.

상세는 본 문서 원문 절과 `MESHY_BLENDER_PIPELINE_SPEC` 참조. Plan 본문 기술 조건 **변경 없음**.

### Meshy
1차 볼륨 only · 최종 커밋 금지

### Blender P0
Metric 1m · 25m/≈30m · 발 피벗 · 실루엣 검증 · 최소 topology

### P0 vs 최종
P0 = 파이프라인 검증 · 최종 승격 금지

### Skeleton 전
높이·피벗·F/S/R·손/민등 확인 후

---

## NEXT

1. 로컬: AXION P0 Mesh 제작  
2. `AXION_P0_MESH_PRODUCTION_STATUS.md` → IMPLEMENTED / UNVERIFIED + 파일 경로  
3. Master Review  
4. SETH P0 Mesh  
5. Skeleton after Mesh APPROVED

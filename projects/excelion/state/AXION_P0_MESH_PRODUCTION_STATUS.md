# AXION_P0_MESH_PRODUCTION_STATUS — Excelion

> 2026-08-16  
> Mesh Production Plan = MASTER APPROVED  
> **실제 Mesh 파일 생성 없음** (에이전트 환경에 Blender / Meshy 없음)

**상태: NOT STARTED · EDITOR_REQUIRED · 문서만 갱신**

---

## STATUS

### Master 승인
| 항목 | 상태 |
|------|------|
| Mesh Production Plan | **MASTER APPROVED** |
| AXION P0 Mesh 착수 범위 | **승인됨** (범위만) |
| 실제 Mesh 산출물 | **없음** |

### 제작 상태

```text
NOT STARTED
    → (로컬 Meshy + Blender 필요)
IMPLEMENTED / UNVERIFIED
    → MASTER REVIEW
    → APPROVED
```

**현재 = NOT STARTED**  
문서만으로 IMPLEMENTED로 올리지 않음.

### 환경 조사 (에이전트 세션)

| 도구 | 결과 |
|------|------|
| Blender (`blender` / bpy) | **없음** |
| Meshy CLI / API 세션 | **없음** |
| 로컬 .blend / .fbx / .glb 산출 | **없음** |

따라서 P0 Mesh 파일을 Git에 추가하지 않음.

---

## 승인된 제작 범위 (재확인 · 변경 없음)

대상: **AXION only**

```text
Three-view APPROVED
  → Meshy 1차 볼륨 (선택)
  → Blender: m 스케일 · 발 피벗 · 실루엣 · 최소 topology
  → 검수
  → Master Review
```

금지 유지: SETH Mesh · Skeleton · Animation · UE · Canon/Novel/Three-view 수정 · Meshy=최종 취급

---

## 로컬 실행 체크리스트 (Master / 작업자)

1. APPROVED AXION Three-view 시트 확보 (세션 산출 + `design/mecha/brave/threeview/`)
2. (선택) Meshy: 볼륨만 생성 · 최종으로 저장하지 않음
3. Blender Metric · 높이 **25.0 m** · Origin = 발 접지 중앙
4. 이름 방향: `player_brave_mesh` (또는 `*_p0`)
5. F/S/R 실루엣 대조 · 차이 시 **기록만** · 임의 Canon 변경 금지
6. 산출물 경로 예: `projects/excelion/assets/models/brave/` 또는 draft 경로 (기존 ASSET_GUIDELINE 정합)
7. 상태 문서에 파일 경로·스케일·피벗 실측 기입 후 **IMPLEMENTED / UNVERIFIED** → Master Review

### 검증 항목 (실행 시)

- [ ] 전체 실루엣
- [ ] 비율 · 25m
- [ ] F/S/R 정합
- [ ] 관절 위치 대략
- [ ] 발 방향·피벗
- [ ] Mesh 오류(non-manifold 등)
- [ ] Rig 가능 여부 (대략)

---

## 미확인 / BLOCKED

| 항목 | 상태 |
|------|------|
| 실제 Meshy 출력 | BLOCKED (환경) |
| 실제 Blender .blend | BLOCKED (환경) |
| FBX/GLB P0 파일 | BLOCKED |
| Silhouette 실측 비교 | 로컬 실행 후 |
| SETH P0 Mesh | AXION 검수 후 |
| Skeleton / Animation | Mesh 후 |

---

## Master 결정 필요

- 로컬에서 AXION P0 Mesh 실행 후 산출물 경로·검수 결과 회신
- (선택) PNG Three-view를 레포에 커밋할지 여부

---

## NEXT

1. 로컬 Meshy + Blender로 AXION P0 Mesh 제작  
2. 본 문서를 IMPLEMENTED / UNVERIFIED로 갱신 + 파일 커밋  
3. Master Review → APPROVED  
4. 이후 SETH P0 Mesh  
5. Skeleton은 Mesh APPROVED 이후

**에이전트는 Mesh를 생성하지 않았다. Plan 승인 상태와 환경 제약만 기록한다.**

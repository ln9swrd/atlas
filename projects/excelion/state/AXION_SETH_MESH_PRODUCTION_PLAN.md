# AXION_SETH_MESH_PRODUCTION_PLAN — Excelion

> 2026-08-16 · 계획/명세 전용  
> 실제 Mesh · Meshy 실행 · Blender 수정 · Skeleton · Animation · Unreal **금지**  
> Canon / Novel 변경 금지  
> 목적: Three-view APPROVED 이후 **P0 Mesh 제작 순서·도구·품질 구분**을 Master가 승인할 수 있게 고정

**상태: Mesh Production Plan 작성 완료 · 실제 Mesh 착수 = Master 승인 대기**

---

## STATUS

### 선행 완료
| 항목 | 상태 |
|------|------|
| Production Reference §8 | MASTER APPROVED |
| Production Reference Scope | MASTER APPROVED |
| AXION Three-view | **APPROVED** |
| SETH Three-view | **APPROVED** |
| T1 Level Blockout | IMPLEMENTED / UNVERIFIED |
| Skeleton / Animation | BLOCKED |

### 본 문서
- 제작 순서
- Meshy / Blender 역할
- P0 vs 최종 Mesh 구분
- 공통 규칙 · UE 최소 조건
- Skeleton 전 확인 항목

### Master 결정 필요
- 본 Plan 승인
- AXION P0 Mesh **착수** 승인 (도구·범위)

### 변경하지 않은 것
- Canon · Novel · Mesh 파일 · Unreal · Blueprint

---

## 1. 제작 순서

```text
AXION Three-view APPROVED
SETH Three-view APPROVED
        ↓
Mesh Production Plan 승인   ← 현재
        ↓
AXION P0 Mesh
        ↓
Master 검수
        ↓
SETH P0 Mesh
        ↓
Master 검수
        ↓
(이후) Skeleton 계층 확정 → P0 Animation
```

- **AXION 먼저** (플레이어 · 파이프라인 검증)
- SETH는 AXION P0 Mesh 검수 후
- 동시 양산 금지

---

## 2. Meshy 사용 범위

| 허용 | 금지 |
|------|------|
| 1차 **볼륨 소스** | Meshy 출력을 최종 Mesh로 커밋/취급 |
| Three-view APPROVED 시트를 참조 제약으로 사용 | Canon/Three-view 무시 프롬프트 |
| 실루엣 재생성 반복 | 리그·애니 포함 가정 |
| GLTF/GLB/OBJ/FBX 중 1종 인수 | 최종 스케일·피벗 신뢰 |

**원칙:** Meshy = draft volume only. 최종 승격은 Blender 정리 + Master 검수 후.

---

## 3. Blender 정리 범위 (P0)

필수:

1. Metric · **1.0 = 1 m**
2. 높이: AXION **25.0 m** / SETH **≈30.0 m** (Three-view 정합)
3. Origin = **발 접지 중앙**
4. 메쉬 이름: `player_brave_mesh` / `enemy_seth_mesh` (방향)
5. 실루엣 검증 (Three-view F/S/R 대조)
6. Non-manifold · 극단적 구멍 제거
7. 관절 구간이 접히지 않을 최소 edge 확보

P0에서 **필수가 아님:**
- 완벽한 Quad 전면 변환
- 최종 UV
- 고밀도 패널
- LOD
- 무기 전개 메쉬

---

## 4. Quad / Retopology 전략

| 단계 | 전략 |
|------|------|
| P0 | 실루엣·가동 우선 · **전면 자동 remesh 지양** · 삼각 허용 |
| P1 | 주요 장갑 곡면 edge flow · support edge 최소 |
| P2+ | 필요 시 선택적 retopo · 폴리 상한 실측 후 |

TOPOLOGY_GUIDE: 슈퍼로봇 큰 형태 우선 · 패널 루프 과다 금지.

---

## 5. LOD 전략

| VS / P0 | LOD **불필요** |
|---------|----------------|
| 이후 | 필요 시 1단계 단순화만 · 본 Plan 밖 |

---

## 6. P0 Mesh vs 최종 게임 Mesh

| | **P0 Mesh** | **최종 게임 Mesh** |
|--|-------------|---------------------|
| 목적 | 스폰·스케일·실루엣·파이프라인 검증 | 출시/데모 비주얼 |
| 실루엣 | Three-view APPROVED 정합 | 동일 + polish |
| Topology | 가동 가능 최소 | 정리·optimized |
| Material | 슬롯만 또는 flat 3톤 | 인스턴스·마모 |
| UV | 최소/없음 가능 | 완료 |
| 무기 | 기본 비무장 실루엣 | 레이어 무장 |
| Skeleton | 아직 없음 · Mesh 후 | 정합 본 |
| Git 취급 | `*_p0` 또는 draft 경로 권고 | `assets/models/` 승격 |

**P0를 최종으로 승격하지 않는다.**

---

## 7. 공통 제작 규칙 (AXION · SETH)

| 규칙 | 내용 |
|------|------|
| Reference | APPROVED Three-view만 Production 기준 |
| Canon | TEXT-LOCK 우선 · Concept = REFERENCE only |
| Scale | Blender m · 스토리 키 일치 |
| Pivot | 발 중앙 |
| Back | AXION 무배팩 · SETH **민등** |
| Hands | SETH **노출** 필수 |
| Default armament | 기본 비무장 실루엣 |
| Skeleton | Mesh 정합 **후** · 임시 선제작 금지 |
| Mannequin/Mixamo | 본 경로 채택 안 함 |

별도 필요: 실루엣 언어(여백 vs 차단) · 팔레트 · 볼륨 edge flow.

---

## 8. Skeleton 이전 필수 확인

Mesh P0 검수 통과 후, Skeleton 전에:

- [ ] 높이 m 실측 (25 / ≈30)
- [ ] 발 피벗 접지
- [ ] F/S/R 실루엣 Three-view 정합
- [ ] 관절 접힘 시 메쉬 붕괴 없음 (대략)
- [ ] SETH 손 볼륨 존재 · 민등 유지
- [ ] 파츠 분리 범위 결정 (head/torso/arms/legs 수준)
- [ ] 공통 humanoid 본 계층 초안 확정 (MESHY_BLENDER §5.2 방향 · 이름 TBD)

---

## 9. UE Import 최소 조건 (P0)

| 조건 | 내용 |
|------|------|
| 포맷 | FBX (주 경로) · 프리셋 숫자 G4는 TBD |
| 포함 | 정적 또는 스키닝 전 메쉬 · (리그 전) Static으로도 검증 가능 |
| Scale | Blender m → UE cm 계열 변환 검증 |
| Pivot | 발 = 월드 접지 |
| 검증 | 스폰 · 높이 감 · 충돌 primitive 가능 |
| 머티리얼 | 임포트 후 교체 가능 슬롯 |

P0 단계에서는 **Skeletal Mesh 필수 아님**. Static Mesh로 스케일/스폰 검증 후 Rig.

---

## 10. 도구 경로 (권고 · Master 확정)

```text
APPROVED Three-view
  → Meshy (1차 볼륨, 선택)
  → Blender (스케일·피벗·실루엣·최소 topology)
  → P0 검수
  → (통과 시) 상대 메카 동일
  → Skeleton (Mesh 후)
  → FBX → UE
```

수동 블록아웃만으로 P0 가능. Meshy는 가속용 옵션.

---

## 11. 위험

| 위험 | 완화 |
|------|------|
| Meshy = 최종 오인 | P0/최종 구분 · 검수 게이트 |
| 실루엣 이탈 | Three-view 대조 필수 |
| Skeleton 선행 | 금지 유지 |
| 양쪽 동시 고품질 | AXION→SETH 순차 |
| G1–G7 미확정 | P0는 로컬 검증 중심 · 양산 전 확정 |

---

## 12. 선행 문서

| 문서 | 역할 |
|------|------|
| AXION_SETH_PRODUCTION_REFERENCE_SCOPE | Three-view APPROVED |
| AXION_SETH_MECHA_MESH_PRODUCTION_READINESS_REVIEW | 조건·P0~P3 |
| MESHY_BLENDER_PIPELINE_SPEC | 단위·피벗·FBX 계약 |
| AXION_SETH_ANIMATION_SKELETON_STRATEGY_REVIEW | Skeleton은 Mesh 후 |

---

## NEXT

1. **Master:** 본 Plan 승인 여부  
2. 승인 시: **AXION P0 Mesh 착수**만 별도 지시 (도구·산출물 경로 명시)  
3. AXION P0 검수 → SETH P0  
4. Skeleton / Animation은 Mesh 정합 후  
5. T1 VERIFIED는 병행 가능 (별도)

**본 문서는 Plan만 수행한다. Mesh 파일을 생성하지 않는다.**

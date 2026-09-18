# MESHY_BLENDER_PIPELINE_SPEC — 최소 기술 계약

> 2026-08-09 · Excelion only · **문서 계약** · 구현 없음  
> 전제: `excelion-forge` = DEPRECATION CANDIDATE (`FORGE_DEPRECATION_SURVEY_2026-08-09`)  
> 금지: Meshy 연동 코드 · Blender Add-on 구현 · UE 구현 · Forge 삭제 · 설정/스토리 변경

**목적:** Forge가 담당하던 *모델→리그→포즈/모션→엔진 전달* 구간을 대체할 때, 구현 전에 고정해야 할 최소 인터페이스를 적는다. 미확정은 **TBD**.

---

## 0. 적용 범위

| 포함 | 제외 |
|------|------|
| 인간형 메카 (BRAVE, ORD, ELITE, 보스) 정적 메쉬 + 기본 리그 + 액션 클립 | 얼굴 블렌드셰이프 정책 상세 |
| Meshy 산출 → Blender 정리 → FBX → UE 전제 | 실시간 Meshy API 연동 |
| 스케일·본·루트·익스포트·임포트 계약 | 전투 밸런스·스토리 TEXT-LOCK |

SoR 연동: `docs/07_PIPELINE.md` (의도) · `docs/ASSET_GUIDELINE.md` (더미 스케일/피벗) · `ENVIRONMENT_PLAN.md`

---

## 1. Forge 역할 → 대체 매핑

| 구 Forge 역할 (문서상) | 대체 담당 | 계약 절 |
|------------------------|-----------|--------|
| 메쉬 생성/자동화 | **Meshy** (생성) + **Blender** (정리) | §2 |
| 리깅 | **Blender** | §3–§5 |
| 포즈 / 모션 | **Blender** | §6 |
| UE 전달 | **FBX export** → UE import | §7–§8 |
| 파라메트릭 스키마 (ParaModel) | **HOLD** · 본 계약 밖 | — |

---

## 2. Meshy — 입력 / 출력

### 2.1 입력 (권장 계약)

| 항목 | 계약 | 상태 |
|------|------|------|
| 소스 | 컨셉 이미지 및/또는 짧은 텍스트 프롬프트 | TBD (워크플로 선택) |
| 참조 우선 | Excelion TEXT-LOCK 실루엣·3톤 규칙 (`ASSET_GUIDELINE`) | LOCK 의도 |
| 토폴로지 요구 | 게임용 쿼드 선호 목표 · 삼각 허용 | TBD 폴리 상한 |
| 대상 스케일 힌트 | 스토리 키 (예: BRAVE ~25m)는 **문서 참고만** · Meshy 내부 단위 신뢰 금지 | LOCK |

### 2.2 출력

| 항목 | 계약 | 상태 |
|------|------|------|
| 포맷 | **글TF/GLB 또는 OBJ 또는 FBX** 중 1종 이상 | TBD 우선 포맷 |
| 필수 포함 | 단일 또는 파츠 분리 메쉬 · 기본 머티리얼 슬롯 가능 | TBD |
| 금지 가정 | 완성 리그 · UE 즉시 사용 가능 · 최종 스케일 | LOCK (불가 가정) |
| 인수 조건 | Blender에서 열어 스케일/오리진 재설정 가능 | LOCK |

### 2.3 Meshy → Blender 핸드오프

```
Meshy export → (optional local cache) → Blender import → cleanup gate
```

Cleanup gate (최소):

1. 단위·스케일 재설정 (§4)  
2. 오리진을 합의 피벗으로 이동 (§4)  
3. 불필요 노드/더블 버텍스 정리  
4. 메쉬 이름 `{role}_{id}_mesh` (예: `player_brave_mesh`) — `ASSET_GUIDELINE` 명명과 정합

---

## 3. Blender 리깅 기준

| 항목 | 계약 | 상태 |
|------|------|------|
| 도구 | Blender (버전 **TBD**) | TBD |
| 리그 소유 | 사람 + (향후) Add-on 보조 · **Add-on 미구현** | LOCK |
| 리그 유형 | 단일 Armature · 메카 인간형 기본 | LOCK 의도 |
| 스키닝 | 메쉬 → Armature 부모 · Weight 페인트/자동 후 손보정 | LOCK 의도 |
| 컨트롤 리그 vs 변형 리그 | 변형(Deform) 본만 익스포트 대상 | LOCK 의도 |
| IK/FK 컨트롤러 | Blender 내부 전용 · **FBX에 컨트롤 본 포함 금지** | LOCK 의도 |

---

## 4. Scale / Unit / Pivot

| 항목 | 계약 | 상태 |
|------|------|------|
| Blender unit | **Metric · 1.0 = 1 meter** | **제안 LOCK** (UE cm 변환 전제) |
| UE unit | **1 uu = 1 cm** (언리얼 기본) | **제안 LOCK** |
| 변환 | Blender m → FBX → UE 시 **×100** 스케일 또는 익스포트 스케일 100 | **TBD** (익스포트 프리셋으로 고정 필요) |
| 캐릭터 키 기준 | 스토리 m 값 = Blender Z 높이 목표 (BRAVE ≈ 25.0 m) | 문서 연동 · 실측 TBD |
| 피벗 | 발 접지 중앙 · Armature 오브젝트 오리진 = 월드 발 위치 | **제안 LOCK** |
| 플레이스홀더 교체 | 동일 스케일·피벗 유지 (`ASSET_GUIDELINE`) | LOCK |

**미확정:** FBX export scale 숫자 한 줄 프리셋 이름 · UE import uniform scale 값.

---

## 5. Bone naming / hierarchy / root

### 5.1 원칙

- **ASCII only** · 공백 없음 · `PascalCase` 또는 `snake` 중 **하나**로 통일 필요 → **TBD**
- 좌/우: `L_` / `R_` 접두 **또는** `_l` / `_r` 접미 → **TBD** (UE 미러 관례와 맞출 것)
- Deform 본만 최종 계층에 포함

### 5.2 최소 계층 (인간형 메카 — 제안, 미확정)

```
Root          (이동·Yaw 전용 · 지면 기준)
└─ Pelvis
   ├─ Spine
   │  └─ Chest
   │     ├─ Neck → Head
   │     ├─ Clavicle_L → UpperArm_L → LowerArm_L → Hand_L
   │     └─ Clavicle_R → UpperArm_R → LowerArm_R → Hand_R
   ├─ UpperLeg_L → LowerLeg_L → Foot_L → (Toe_L optional)
   └─ UpperLeg_R → LowerLeg_R → Foot_R → (Toe_R optional)
```

| 항목 | 계약 | 상태 |
|------|------|------|
| 본 이름 최종 목록 | 위 제안 또는 UE Mannequin 호환 세트 | **TBD** |
| 무기/드론 소켓 본 | `Socket_*` 또는 별도 소켓 액터 | **TBD** |
| 엑셀리온 변형 본 | 추가 본 허용 · 이름 규약 별도 | **TBD** |

### 5.3 Root bone / root motion

| 항목 | 계약 | 상태 |
|------|------|------|
| Root 본 | 계층 최상단 · 기본 위치 발 피벗 | **제안 LOCK** |
| Root motion | **TBD**: (A) in-place only + 코드 이동 · (B) Root 곡선 사용 | **TBD** |
| 권장 1차 | (A) in-place 클립 · 이동은 UE CharacterMovement | **제안** (미확정) |
| Root 회전 | Yaw만 클립에 넣을지 여부 | **TBD** |

---

## 6. Pose / Animation 제작 규칙

| 항목 | 계약 | 상태 |
|------|------|------|
| 제작 장소 | Blender Action / NLA | LOCK 의도 |
| 클립 단위 | 1 Action = 1 논리 애니 (idle, walk, attack_…) | LOCK 의도 |
| 명명 | `{role}_{id}_{action}` 예: `player_brave_idle` | **제안 LOCK** |
| 프레임 레이트 | **30 fps** 또는 **60 fps** 중 하나 | **TBD** |
| 루프 | idle/walk 등 루프 클립은 1·마지막 프레임 정합 | LOCK 의도 |
| 공격/스킬 | 논루프 · 회수 프레임 명시 | LOCK 의도 |
| 베이크 | IK 결과 → Deform 본 키만 베이크 후 익스포트 | LOCK 의도 |
| 메타 | 클립 길이·루프 여부를 별도 표 또는 JSON으로 관리 | **TBD** 경로 |

전투 타이밍(대시 12f 등)은 **밸런스 SoR(B1)** 가 우선 · 애니 프레임은 나중에 맞춤.

---

## 7. FBX export 규칙

| 항목 | 계약 | 상태 |
|------|------|------|
| 포맷 | **FBX** (UE 주 경로) | **제안 LOCK** |
| 보조 | glTF 리뷰용 허용 · UE 주 경로 아님 | LOCK 의도 |
| 포함 | Deform 메쉬 + Armature + 베이크된 액션 | LOCK 의도 |
| 제외 | IK 컨트롤러 · 비변형 헬퍼 · Blender 전용 제약 | LOCK 의도 |
| Apply Transform | 익스포트 전 스케일/회전 적용 여부 | **TBD** |
| Forward / Up | **-Z Forward · Y Up** (Blender 관례) vs UE 변환 | **TBD** 프리셋 |
| 애니메이션 | Bake Animation ON · NLA 스트립 또는 선택 액션 | **TBD** |
| 파일 1개 정책 | (A) 스킨+애니 단일 FBX · (B) 스킨/애니 분리 | **TBD** |
| 출력 경로 (의도) | `assets/models/` · `assets/animations/` (`ASSET_GUIDELINE`) | LOCK 의도 |

---

## 8. UE import 전제

| 항목 | 계약 | 상태 |
|------|------|------|
| 엔진 | Unreal (버전 **TBD**) | TBD |
| 임포트 | FBX → Skeletal Mesh + Skeleton + AnimSequence | LOCK 의도 |
| Skeleton 공유 | 동일 본 계층 기체 간 Skeleton 재사용 목표 | **제안** |
| Physics Asset | 1차 자동 생성 후 손보정 | TBD |
| Anim BP | 별도 · 본 계약 밖 | — |
| 머티리얼 | 임포트 후 3톤 인스턴스로 교체 가능해야 함 | LOCK 의도 |
| 플레이스홀더 | `{role}_{id}_ph` 와 동일 스케일/피벗으로 교체 | LOCK |
| 검증 체크 | 키 높이 · 발 접지 · 1클립 재생 · 미러 본 | 최소 게이트 |

---

## 9. 최소 수락 게이트 (구현 착수 전 채울 것)

다음이 채워지기 전에는 Meshy/Blender/UE **실작업 대량 투입 금지** 권고.

| ID | 항목 | 현재 |
|----|------|------|
| G1 | Blender 버전 | TBD |
| G2 | UE 버전 | TBD |
| G3 | 본 이름 최종 표 (또는 Mannequin 매핑표) | TBD |
| G4 | FBX export 프리셋 1종 (scale/axis/bake) | TBD |
| G5 | Root motion A/B 선택 | TBD |
| G6 | 클립 fps | TBD |
| G7 | 스키+애니 FBX 단일/분리 | TBD |

**지금 LOCK 가능한 것:** 담당 분리(Meshy/Blender/UE) · metric m · 발 피벗 · deform-only export · 플레이스홀더 교체 규칙 · 명명 방향.

---

## 10. Forge 산출물 — 보존 / 폐기

Excelion 트리 기준 (`FORGE_DEPRECATION_SURVEY` 정합).

### 보존

| 대상 | 이유 |
|------|------|
| 본 계약 · `07_PIPELINE` 의도 · ENV 분리 | 후속 파이프라인 |
| TEXT-LOCK 메카/전투/스토리 | Forge 무관 |
| `excelion-forge` 원격의 문서·네이밍·익스포트 메모 (감사 후) | 지식 회수 |
| 검증된 FBX/블렌드가 **나중에** 발견되면 `assets/`로 이관 후보 | 자산 가치 |

### 폐기 (승인·감사 후)

| 대상 | 이유 |
|------|------|
| Forge를 **주 경로**로 지시하는 문서 문장 | 대체 계약으로 치환 |
| backlog `assignee_role: Forge` | 역할 재명명 |
| 미사용·미검증 Forge 전용 스크립트/캐시 (외부 레포) | 부채 |
| ParaModel 연동 가정 (HOLD 유지·별도 결정) | 본 계약 비범위 |

### 즉시 삭제 금지

`ln9swrd/excelion-forge` 파일·레포 삭제 · Excelion 외 저장소 변경 — **Master 승인 + 보존 목록 확정 전 금지**.

---

## 11. 자체 정합성 검토

| 검사 | 결과 |
|------|------|
| Forge 역할 전 구간 대체 문장 존재 | OK (§1) |
| 미확정 임의 숫자 없음 | OK (TBD) |
| ASSET_GUIDELINE 명명/피벗과 충돌 | 없음 (동일 방향) |
| 스토리/메카 TEXT-LOCK 변경 | 없음 |
| 구현 코드 포함 | 없음 |
| BRAVE 25m 등 스토리 스케일과 unit 제안 모순 | 없음 (m 기준 제안) |

---

## 12. 다음 게이트

1. 본 Spec → docs/state PR → CI → **Master 승인** → merge  
2. G1–G7 중 구현 직전 필수분 Master 확정  
3. 그 다음 Forge 제거 PR의 **삭제 범위** 확정  
4. 그 이후에만 Meshy/Blender 실험

**상태:** 최소 계약 초안 · 구현 없음 · DEPRECATION 조사와 정합.

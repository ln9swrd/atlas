# AXION_SETH_ANIMATION_SKELETON_STRATEGY_REVIEW — Excelion

> 2026-08-16 · READ-ONLY 조사 + 문서화 전용
> Canon / Novel / Unreal / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT **변경 없음**
> 목적: Seth Boss Arena Animation 제작 전, AXION·SETH Skeleton/Animation 전략을 Master가 결정할 수 있도록 사실·비교·권고안 정리
> **실제 Skeleton / Mesh / Animation 생성하지 않음**

**상태: Strategy Review 완료 · Master 전략 결정 대기**

---

## STATUS

### 완료
- 현재 Skeleton/Mesh 상태 조사
- AXION 전략 비교 (A~E)
- SETH 전략 비교
- Animation 제작 방식 비교
- 최소 Animation 목록 (P0~P3)
- 1인 개발 기준 권고안
- 문서 저장: 본 파일
- Commit

### 현재 기준 (고정)
| 항목 | 상태 |
|------|------|
| VS Candidate A | APPROVED |
| T1 | IMPLEMENTED / UNVERIFIED |
| T2~T9 | BLOCKED |
| Animation | NEW |
| Skeleton / Mecha Mesh | NOT STARTED |
| ORD-GRUNT | HOLD |

### 미확인
- UE Editor 내 숨은 에셋 여부 (Content 트리 기준 없음)
- 로컬 Blender 버전·숙련도
- Meshy 실사용 가능 여부
- 최종 메쉬 토폴로지와 본 수 일치 시점

### BLOCKED
- T1 VERIFIED 전 VS 구현
- 실제 Skeleton/Animation 제작 착수 (본 문서 승인·전략 결정 후)

### Master 결정 필요
- Skeleton 전략 (A~E 중 또는 변형)
- Animation 제작 방식 (조립식 vs 수작업 비중)
- 실제 제작 착수 범위 (P0만 등)

---

## 근거 문서 (읽기 전용)

- state/SETH_BOSS_ARENA_ASSET_PRODUCTION_PIPELINE_REVIEW.md
- state/MESHY_BLENDER_PIPELINE_SPEC.md
- state/SETH_BOSS_ARENA_MINIMUM_PRODUCTION_SPEC.md
- design/brave/FRAME_SPEC.md (AXION/BRAVE · 25m humanoid female)
- design/character/seth/FORM.md · design/mecha/seth/SETH_FINAL_SPEC.md (≈30m humanoid muscular)
- design/mecha/threeview/TOPOLOGY_GUIDE.md (참고)

---

## 1. 현재 프로젝트 확인 (Git)

| 항목 | 존재 | 분류 |
|------|------|------|
| AXION Skeleton | 없음 | NOT STARTED |
| AXION Skeletal Mesh | 없음 | NOT STARTED |
| SETH Skeleton | 없음 | NOT STARTED |
| SETH Skeletal Mesh | 없음 | NOT STARTED |
| Animation Blueprint | 없음 | NOT STARTED |
| 기존 Animation (AnimSequence 등) | 없음 | NOT STARTED |
| Retarget 대상 (완성 메쉬) | 없음 | NOT STARTED |
| BP_ExcelionCharacter / BP_SethBoss | 있음 | EXISTING (로직·배치용) |
| Content/Maps · Input · HUD | 있음 | EXISTING |

**Content 트리 기준:** Blueprints / Data / Input / Maps / UI / Scripts / __ExternalActors__ 만 확인. Animation·Mesh·Skeleton 폴더 실에셋 없음.

설계상 형태 (추정 금지, 문서 확인):
- **AXION (BRAVE):** 25m · **humanoid** · female super robot · TEXT-LOCK
- **SETH:** ≈30m · **humanoid** · 근육질 전사 · 손 노출 · TEXT-LOCK

둘 다 humanoid이므로 동일 계열 Skeleton 전략을 공유할 여지가 있다. non-humanoid 전제는 현재 자료에서 성립하지 않는다.

---

## 2. AXION 전략 비교

### A. 기존 UE Mannequin 계열 Skeleton + Retarget

| 항목 | 내용 |
|------|------|
| 장점 | 즉시 사용 가능 · 샘플 애니·Control Rig 풍부 · 빠른 PIE 피드백 |
| 단점 | 메카 비율(25m·여성형 슈퍼로봇)과 인간형 본 비율 불일치 · 최종 메쉬 리타겟 시 재작업 큼 · 메카 관절(핀 패널 등) 미반영 |
| 필요 조건 | UE Mannequin / UE5 Manny·Quinn 패키지 |
| 작업량 | 단기 LOW · 장기 HIGH (교체 비용) |
| 장기 유지보수 | 나쁨 (임시 → 최종 교체 이중 비용) |
| 메카 적합도 | 낮음 (인간형 전제) |
| 현재 적용 가능성 | 높음 (엔진 내장) |

### B. 임시 humanoid Skeleton (자체 최소 본)

| 항목 | 내용 |
|------|------|
| 장점 | Mannequin보다 메카 비율에 맞춤 가능 · 본 수 최소화 가능 |
| 단점 | 처음부터 설계 필요 · 최종 메쉬와 불일치 시 재작업 · 애니 소스 부족 |
| 필요 조건 | Blender 또는 UE에서 본 계층 정의 |
| 작업량 | 중기 MEDIUM |
| 장기 유지보수 | 중간 (최종과 동일 계층이면 유리) |
| 메카 적합도 | 중간 |
| 현재 적용 가능성 | 가능 (MESHY_BLENDER_PIPELINE_SPEC 계층 제안과 정렬 가능) |

### C. AXION 전용 Skeleton 신규 제작 (최종 의도)

| 항목 | 내용 |
|------|------|
| 장점 | TEXT-LOCK 비율·슬롯(head/torso/arm/leg)과 정합 · 핀 패널 등 확장 여지 · 한 번 맞추면 유지보수 유리 |
| 단점 | 메쉬 없이 본만 먼저 만들면 토폴로지 불일치 위험 · 제작 시간 · VS 전 과도한 투자 가능 |
| 필요 조건 | FRAME_SPEC · MESHY_BLENDER 계약 · (이상적) 최소 메쉬 또는 블록아웃 메쉬 |
| 작업량 | HIGH |
| 장기 유지보수 | 좋음 |
| 메카 적합도 | 높음 |
| 현재 적용 가능성 | 메쉬 NOT STARTED이므로 **단독 선행은 위험** |

### D. Control Rig 중심 제작

| 항목 | 내용 |
|------|------|
| 장점 | UE 내부에서 포즈·절차적 모션 · 외부 파이프라인 의존 감소 |
| 단점 | Skeleton/Mesh가 선행되어야 함 · Control Rig 숙련 필요 · 복잡한 전투 클립은 한계 |
| 필요 조건 | 유효 Skeletal Mesh + Skeleton |
| 작업량 | Skeleton 이후 MEDIUM |
| 장기 유지보수 | 중간 |
| 메카 적합도 | Skeleton에 종속 |
| 현재 적용 가능성 | Skeleton 없으므로 **후순위** |

### E. 외부 Animation → Retarget → UE

| 항목 | 내용 |
|------|------|
| 장점 | Mixamo 등 빠른 인간형 클립 · 시간 절약 |
| 단점 | 메카 실루엣·스케일 부적합 · 라이선스·품질 · 최종 메카 리타겟 이중 작업 |
| 필요 조건 | 호환 Skeleton · 리타겟 파이프 |
| 작업량 | 단기 LOW · 장기 HIGH |
| 메카 적합도 | 낮음 |
| 현재 적용 가능성 | 기술적으로 가능하나 **메카 VS에 비권장** |

---

## 3. SETH 전략

### 형태 (문서 확인분)

| 항목 | 값 |
|------|-----|
| 전고 | ≈30 m (BRAVE +20%) |
| 구조 | **humanoid** · 근육질 전사 |
| 특징 | 손 노출 · 각진 차단 아머 · 민등 |
| non-humanoid 여부 | 문서상 **아님** |

SETH도 humanoid이므로 AXION과 **동일 Skeleton 계열**을 공유하는 전략이 가능하다. 별도 non-humanoid 리그는 현재 자료 근거로 필요하지 않다.

| 전략 | SETH 적용 |
|------|----------|
| A Mannequin | AXION과 동일 단점 · 30m 스케일만 조정해도 비율 이질 |
| B 임시 humanoid | AXION과 공유 계층 가능 · 스케일만 다름 |
| C 전용 최종 | AXION과 본 이름·계층 통일 시 유지보수 유리 |
| D Control Rig | Skeleton 선행 후 |
| E 외부 애니 | 메카 부적합 동일 |

**SETH 특수:** Attack은 Pattern 텔레그래프(씰·리졸버) 중심 → 전신 복잡한 콤보보다 **포즈 + VFX 타이밍**이 P0에 더 중요할 수 있음.

---

## 4. Animation 제작 방식 비교

| 방식 | 설명 | 1인 적합성 | 비고 |
|------|------|-----------|------|
| Blender 수동 포즈 | 키프레임 전부 수작업 | 낮음 (대량 시) | 소량 P0만 가능 |
| Blender 조립식 | 기본 포즈 라이브러리·NLA 조합 | **높음** | MESHY_BLENDER §6 방향과 정합 |
| UE Control Rig | 엔진 내 포즈·리깅 보조 | 중간 | Mesh 필요 |
| UE Sequencer | 연출·컷 중심 | 낮음 (루프 전투) | VS 전투 루프에는 부차 |
| 기존 Anim Retarget | 소스 클립 → 대상 Skeleton | 소스 있을 때 높음 | 현재 소스 없음 |
| Mixamo 등 외부 | 인간형 클립 | 메카에 낮음 | 비권장 |

**핵심 대비**

```text
모든 Animation을 처음부터 수작업
  → 1인·VS 단계에서 범위 폭발 · 비권장

기본 동작 재사용·조립
  → Idle/Locomotion 루프 + Attack/Hit 짧은 클립만 제작
  → Placeholder 포즈로 PIE 검증 후 교체
  → 권장
```

---

## 5. 최소 Animation 요구사항 (Seth Arena)

### AXION

| 클립 | 우선순위 | 비고 |
|------|----------|------|
| Idle | **P0** | 루프 |
| Locomotion | **P0** | Walk/Run 최소 |
| Attack (1~2타) | **P0** | 논루프 |
| Hit | **P0** | 짧은 반응 |
| Dash | P1 | 포즈 또는 짧은 클립 |
| Death/Defeat | P1 | |
| Special | P2 | |

### SETH

| 클립 | 우선순위 | 비고 |
|------|----------|------|
| Idle / Phase1 자세 | **P0** | |
| Phase2 자세 | **P0** | |
| Attack 텔레그래프 (Blast/Beam) | **P0** | 포즈+타이밍 중심 가능 |
| Hit | **P0** | |
| Death/Defeat | **P0** | 「…보고, 끝.」 연출 최소 |
| Special | P2 | |

P3: Polish · 부가 제스처 · 고밀도 콤보 — VS 범위 밖 가능.

---

## 6. 권고안 (1인 개발 · 현재 상태 기준)

**최종 결정은 Master.** 아래는 조사 기반 권고다.

### 권고 전략 요약

```text
1) 지금 당장 Skeleton을 “임시로 하나 만들어 나중에 갈아끼우기”는 하지 않는다.
2) AXION·SETH 모두 humanoid이므로 최종 목표는
   MESHY_BLENDER_PIPELINE_SPEC에 정렬된 **공통 humanoid 메카 Skeleton 계층**.
3) VS Animation은 “풀수작업”이 아니라
   **최소 포즈/짧은 클립 조립 + VFX·타이밍**으로 P0만 채운다.
4) Skeleton·Mesh 실제작은
   T1 VERIFIED 및 (가능하면) 블록아웃 메쉬 또는 Meshy 1차 메쉬 확보 후에 착수한다.
5) Mannequin/Mixamo를 본 경로로 쓰지 않는다.
   (빠른 실험용 Placeholder는 Master 명시 승인 시에만, 최종 경로 아님을 문서화)
```

### 단계 제안

| 단계 | 내용 | 조건 |
|------|------|------|
| S0 | 본 전략 Master 승인 | 지금 |
| S1 | T1 VERIFIED | 로컬 UE |
| S2 | (선택) 블록아웃/Meshy 1차 메쉬 | 메쉬 파이프 |
| S3 | 공통 메카 Skeleton 계층 확정 (MESHY 계약 G3 등) | Spec 게이트 |
| S4 | P0 Animation (조립식·짧은 클립) | Skeleton+최소 Mesh |
| S5 | PIE · T4 검증 | T1~T3 이후 |

### 임시 Mannequin을 쓸 경우의 조건 (비권장 기본)

- Master가 “파이프라인 실험 전용 · 폐기 전제”로 명시 승인
- 산출물을 최종 Asset으로 커밋하지 않음
- 메카 TEXT-LOCK 외형 대체로 사용하지 않음

---

## 7. 위험 요약

| 위험 | 설명 |
|------|------|
| 조기 임시 Skeleton | Mesh→Rig→Anim→Retarget 전체 재작업 |
| 수작업 애니 과다 | 1인 범위 폭발 · VS 지연 |
| Mannequin 본경로화 | 메카 비율·Canon 실루엣과 충돌 |
| Skeleton만 선행 | 토폴로지·웨이트 불일치 |
| T1 미검증 상태에서 Anim 착수 | 공간·배치 문제로 재작업 |

---

## 변경하지 않은 것

- Canon
- Novel
- Unreal C++ / Blueprint
- Asset / Animation / VFX / Audio
- Input
- ORD-GRUNT
- Level

---

## NEXT

다음 작업:
- Master의 Skeleton 전략 · Animation 제작 방식 · 착수 범위 결정
- UE 사용 가능 시 T1 검증
- T1 VERIFIED 후 T2 착수 검토

선행 조건:
- 본 문서에 대한 Master 결정
- T1 VERIFIED (구현 재개 시)

**본 문서는 전략 조사·권고만 수행한다. Skeleton/Animation 구현 지시가 아니다.**

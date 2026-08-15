# T1 — Seth Boss Arena Level Blockout STATUS

> 2026-08-16 · T1 착수 시도 기록
> Canon / Novel / C++ / Blueprint 로직 / Animation / VFX / Audio / Input / ORD-GRUNT **변경 없음**
> 목적: T1 범위(최소 Arena Geometry · Spawn · Collision · 플레이 공간) 상태 기록

**상태: IMPLEMENTED / UNVERIFIED (로컬 UE Editor 대기)**

---

## STATUS

### 완료
- 기존 Maps 구조 조사
- T1 범위 대비 현재 자산 확인
- 본 상태 문서 작성·커밋

### 미수행 (환경 제약)
- 실제 Arena Geometry 편집
- Player/Seth Spawn 위치 배치
- Collision Volume 추가
- 최소 Lighting 조정
- PIE 실행 및 플레이 가능 여부 검증

### 원인
- 본 에이전트 환경에 Unreal Editor / Windows 빌드 / PIE 실행 환경 없음
- `.umap` / `__ExternalActors__` 바이너리는 텍스트 편집으로 안전하게 수정 불가
- 따라서 **맵 실체 변경을 하지 않음** (잘못된 바이너리 커밋 방지)

---

## 현재 Maps 자산 (Git 기준)

| 경로 | 비고 |
|------|------|
| `Content/Maps/NewMap.umap` | 존재 (기존 프로토타입 맵) |
| `Content/Maps/Untitled.umap` | 존재 |
| `Content/__ExternalActors__/Maps/NewMap/...` | 다수 External Actor 존재 |
| `Content/__ExternalActors__/Maps/Untitled/...` | 다수 External Actor 존재 |

기존 P5-4 검증은 이 맵들(또는 당시 활성 맵)에서 수행된 것으로 기록되어 있음.

**T1에서 요구하는 “Seth Arena 전용 최소 블록아웃”이 이미 별도 맵으로 존재하는지 여부는 바이너리 내부 확인 불가 → UNKNOWN.**

---

## T1 요구사항 vs 현재

| 요구 | 분류 | 비고 |
|------|------|------|
| Arena 최소 플레이 공간 | UNKNOWN / NEW 필요 가능 | 기존 NewMap/Untitled가 충분한지 로컬에서 확인 필요 |
| Player Spawn Point | REUSE 가능 | 기존 GameMode/Character 스폰 로직 존재 |
| Seth Spawn Point | REUSE 가능 | BP_SethBoss 존재 · 배치 위치는 맵 편집 필요 |
| Collision (낙하 방지) | UNKNOWN | 맵 내부 확인 필요 |
| 최소 Lighting | UNKNOWN | 맵 내부 확인 필요 |
| PIE 검증 | UNVERIFIED | 로컬 UE 5.4 필요 |

---

## 로컬에서 수행할 T1 체크리스트

```text
1. UE 5.4로 projects/excelion/game/Excelion 오픈
2. NewMap 또는 신규 최소 맵을 Arena용으로 사용
3. 평면/박스 기반 전투 공간 확보 (낙하 방지 Collision)
4. Player Start (또는 동등 Spawn) 배치
5. BP_SethBoss 배치 위치 확보
6. 기본 Directional Light로 시야 확보
7. PIE 실행
   - Player Spawn 확인
   - 이동 가능 확인
   - Seth 스폰/존재 확인
   - 낙하/이탈 없음 확인
8. PASS 시 본 문서 상태를 VERIFIED로 갱신
9. FAIL 시 원인만 기록 (범위 밖 수정 금지)
```

---

## 변경하지 않은 것

- Canon / Novel
- C++ Source
- Blueprint 로직
- Animation / VFX / Audio
- Input
- ORD-GRUNT
- 맵 바이너리 파일 (의도적 미수정)

---

## NEXT

다음 작업:
- **로컬 UE Editor에서 T1 체크리스트 수행**
- 결과(PASS/FAIL)를 본 문서 또는 후속 상태 문서에 기록

선행 조건:
- Windows + UE 5.4 개발 환경

검증 필요:
- PIE에서 Spawn · 이동 · Collision · 기본 시야

**T2 이후는 T1 VERIFIED 이후에만 승인.**

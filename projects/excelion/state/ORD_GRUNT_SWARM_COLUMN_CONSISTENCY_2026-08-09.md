# ORD-GRUNT — SWARM COLUMN 정합성 검증

> 2026-08-09
> 대상:
> - `ORD_GRUNT_SWARM_COLUMN_DETAIL_2026-08-09.md` (Silhouette Detail)
> - `ORD_GRUNT_SWARM_COLUMN_COMBAT_RULES_2026-08-09.md` (Combat Rules)
> 연동 대조: `BALANCE_ENEMY_MULT` · `ORD_REMNANT_TACTICS` · `ORD_SPEC` · `EP8_RESULT_UI_SPEC`

**상태: 검증 기록 · 신규 규칙 없음 · 기존 문서 수정 없음**

---

## 0. 범위

- 두 문서의 **내부 정합성**만 검증
- 불일치 → `CONFLICT` 또는 `TBD`로 기록
- 임의 결정·신규 규칙 확정 **금지**
- 기존 문서 본문 수정 **금지**

금지: 코드 · 이미지 · 삼면도 · Meshy · UE · M5 · 캐논 변경 · 신규 게임플레이 규칙 확정

---

## 1. 실루엣 ↔ 전투 역할

| 축 | Detail | Combat Rules | 판정 |
|----|--------|--------------|------|
| 역할 | 떼로 덮치는 하층 투기 기계 · 집단 압박 우선 | 집단 압박용 하층 투기 기계 · 개별 강적 아님 | **PASS** |
| 체형 | 낮고 압축 · 하체·전면 질량 | 전면 질량 + 하체로 직선 접근 | **PASS** |
| 단독 개성 | 의도적으로 약함 · 집단 식별 우선 | 단독 화력 약함 · 수로 압박 | **PASS** |
| 위계 | 네메시스/세스 키 금지 | 세스급·네메시스급 행동 금지 | **PASS** |
| 양산 | 각 · 작음 · 양산 | 무리 단위 스폰 · 소모 | **PASS** |

**CONFLICT: 없음**

---

## 2. 루프 일치 (Spawn → Formation → Approach → Pressure → Break)

| 단계 | Detail §6 실루엣 전달 | Combat Rules | 판정 |
|------|----------------------|--------------|------|
| Spawn | 낮은 기둥들이 한꺼번에 나타남 | 무리 단위 · 낮은 기둥 실루엣 동시 출현 · 동시 4–8 | **PASS** |
| Formation | (식별) 좁은 간격 · 압박 덩어리 | 좁은 간격 기둥 무리 · 산개 금지 · 재배치 | **PASS** |
| Approach | 간격이 좁아지며 한 덩어리로 합쳐짐 | 직선·짧은 대시 · 전면+하체 | **PASS** |
| Pressure | 전면 질량 + 하체 추진이 화면을 채움 | 수 압박 · 시야 오염 · 동시 출현 수 | **PASS** |
| Break | 개별은 쉽게 무너짐 · 집단 압력은 수로 유지 | HP 15 · 한 줄로 끊김 · 개별 약함/수 유지 | **PASS** |

Combat Rules는 Detail의 4단계에 **Formation·Recovery**를 명시적으로 보강. 의미 충돌 없음.

**CONFLICT: 없음**

---

## 3. Telegraph ↔ 플레이어 인식

| 거리 | Detail 식별 | Combat Telegraph | 판정 |
|------|-------------|------------------|------|
| 원거리/스폰 | 스폰 직후 “많이 온다” · 낮은 기둥 무리 | 낮은 기둥이 좁은 간격으로 출현 | **PASS** |
| 중거리 | 간격 좁아지며 압박 덩어리 | 한 덩어리로 합쳐짐 | **PASS** |
| 근거리 | 전면 질량 + 하체 추진 | 동일 | **PASS** |
| 수단 | 실루엣·형태 우선 | 형태·배치 1순위 · 색/이펙트만 의존 금지 | **PASS** |
| 보스식 왜곡 | (해당 없음 · 양산) | Phase 왜곡 텔레그래프 비적용 | **PASS** |

**CONFLICT: 없음**

---

## 4. Gameplay Result 경계

| 항목 | Combat Rules | 대조 | 판정 |
|------|--------------|------|------|
| Gameplay | 거점·목표 수치 적 | 기존 작전 Clear/Fail | **PASS** |
| Story | 격파 수가 상실/생존을 덮어쓰지 않음 | `EP8_RESULT_UI_SPEC` Clear ≠ 전원 생존 | **PASS** |
| 신규 승패 | 추가하지 않음 | Detail/캐논 비변경 | **PASS** |

Detail에는 Result 절 없음. Combat Rules가 경계를 **명시만** 하고 신규 조건을 만들지 않음.

**CONFLICT: 없음**

---

## 5. BALANCE_ENEMY_MULT / ORD_REMNANT_TACTICS

| 항목 | Combat Rules 인용 | 원문 | 판정 |
|------|-------------------|------|------|
| HP | 15 | GRUNT HP 15 | **PASS** |
| 1히트 DMG | 4–6 | 4–6 | **PASS** |
| 기동 | 1.0× | 1.0× | **PASS** |
| ARM | 1.0 | 1.0 | **PASS** |
| 동시 수 | 4–8 | 4–8 | **PASS** |
| 역할 | 수 압박 | 수 압박 | **PASS** |
| 전술 | 직선·짧은 대시 · 한 줄 끊기 · 재배치 | ORD_REMNANT_TACTICS GRUNT 패턴 | **PASS** |
| 혼합 | HEAVY/GUN 소량 가능 | 잔당 = GRUNT 주력 + HEAVY/GUN 소량 | **PASS** |

Detail은 수치를 직접 기입하지 않음. Combat Rules는 **인용·참고**로만 사용.

**CONFLICT: 없음**

---

## 6. 신규 수치 · 신규 캐논 잠입 여부

| 검사 | 결과 |
|------|------|
| Combat Rules 수치 표 | 전부 `BALANCE_ENEMY_MULT` 출처 표기 | **PASS** |
| 신규 HP/DMG/동시 수 | 없음 | **PASS** |
| 신규 승패·스토리 조건 | 없음 · EP8 스펙 참조만 | **PASS** |
| Detail 실루엣 수치화 | 비율은 방향어만 · m/% 신규 고정 없음 | **PASS** |
| 캐논 본문 변경 | 두 문서 모두 금지 명시 · 본 검증도 수정 없음 | **PASS** |

**CONFLICT: 없음**

---

## 7. TBD 오인 방지

Combat Rules에 명시된 TBD (구현 전, **확정 아님**):

| 영역 | TBD 예 |
|------|--------|
| Spawn | 좌표 · 웨이브 간격 · 스테이지별 상한 |
| Formation | 간격(m) · 열·행 템플릿 · 혼합 비율 |
| Approach | 대시 거리·쿨 · 히트박스 |
| Pressure | 동시 교전 상한 · 어그로 |
| Break | 경직 프레임 · 연속 격파 보너스 |
| Recovery | 리스폰 타이머 · 유입 조건 |
| Telegraph | 예고 시간 · 오디오 |
| Result | 격파 수 UI · 목표 키 연동 |
| B3 | TTK 구간 |

규칙:
- TBD = **구현 게이트 전 미결정**
- 설계 캐논·실루엣 고정값으로 읽지 **말 것**
- 본 검증에서 TBD를 채우거나 확정하지 **않음**

**CONFLICT: 없음 · TBD 오인 방지 명시 유지**

---

## 8. 종합

| # | 검증 항목 | 판정 |
|---|-----------|------|
| 1 | 실루엣 ↔ 전투 역할 | **PASS** |
| 2 | Spawn→…→Break 루프 | **PASS** |
| 3 | Telegraph ↔ 인식 | **PASS** |
| 4 | Gameplay Result 경계 | **PASS** |
| 5 | BALANCE / 잔당 전술 | **PASS** |
| 6 | 신규 수치·캐논 잠입 | **PASS** |
| 7 | TBD 오인 방지 | **PASS** |

```
CONFLICT: 0
TBD (미결정 구현): Combat Rules에 기입된 항목만 · 본 문서에서 확정하지 않음
PACKAGE: Silhouette Detail + Combat Rules = 상호 정합
```

---

## 9. 다음 게이트

1. 본 문서 PR → CI → 리뷰 → **Master 승인** → merge
2. 임의 merge 금지
3. 기존 Detail / Combat Rules 본문 **수정하지 않음**
4. 이미지·삼면도·Meshy·UE·M5·코드는 별도 게이트

```
CURRENT: SWARM COLUMN 설계 패키지 정합성 검증 PASS
NEXT: Master 승인 → merge → (이후) 다음 ORD 단계 검토
```

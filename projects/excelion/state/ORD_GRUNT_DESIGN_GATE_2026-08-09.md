# ORD-GRUNT — 텍스트 설계 Gate

> 2026-08-09
> 목적: 현재까지 완료된 ORD-GRUNT **텍스트 설계 트랙**의 종료 조건과 후속 진입 조건을 고정한다.

**상태: DESIGN GATE · 텍스트 트랙 종료 후보 · 시각화/모델링 미진입**

---

## 0. 범위

이 문서는 **게이트 기록**만 한다.

- 기존 4문서 본문 수정 금지
- 신규 설계·수치·캐논 추가 금지
- 구현·시각화 착수 금지

---

## 1. 대상 산출물

| # | 문서 | 역할 |
|---|------|------|
| 1 | `ORD_GRUNT_SILHOUETTE_CONCEPTS_2026-08-09.md` | 실루엣 3안 제시 |
| 2 | `ORD_GRUNT_SWARM_COLUMN_DETAIL_2026-08-09.md` | SWARM COLUMN 상세 텍스트 |
| 3 | `ORD_GRUNT_SWARM_COLUMN_COMBAT_RULES_2026-08-09.md` | 전투 운용 규칙 텍스트 |
| 4 | `ORD_GRUNT_SWARM_COLUMN_CONSISTENCY_2026-08-09.md` | Detail ↔ Rules 정합 검증 |

관련 PR (참고): #57 concepts · #58 detail · #59 combat rules · #60 consistency

---

## 2. 현재 확정 사항

| 항목 | 내용 |
|------|------|
| Shortlist | **SWARM COLUMN** = 1순위 유지 |
| Shape 문장 | 떼로 덮치는 하층 투기 기계 |
| 핵심 인상 | 낮고 압축된 집단 돌격형 · 압박 덩어리 |
| 전투 루프 | 스폰 → 접근 → 압박 → 쉽게 파괴 |
| 실루엣 ↔ 운용 | 정합 (**CONFLICT: 0**) |
| 신규 캐논 | **없음** |
| 신규 확정 수치 | **없음** (BALANCE 인용만) |
| 3안 중 비선택 | RAM FRAME · SCRAP HOUND = shortlist 밖 (폐기 선언 아님) |

텍스트 설계 패키지로서 **내부 정합은 완료**로 본다.

---

## 3. 아직 미확정인 사항

| 항목 | 상태 |
|------|------|
| SWARM COLUMN **최종 LOCK** (다른 2안 대비 공식 단독 채택) | Master 별도 승인 전 미확정 |
| 실루엣 **시각 고정** (흑실루엣·이미지) | 미착수 |
| 삼면도 · 토폴로지 | 미착수 |
| Meshy / Blender / FBX / UE | HOLD |
| M5 Visualization | HOLD / Queued |
| 스테이지별 스폰 상한·웨이브 | 미확정 |
| 실기 밸런스 재측정 (B3 TTK 등) | 미확정 |

Shortlist 1순위 ≠ 최종 단독 LOCK. 최종 LOCK은 Master 게이트.

---

## 4. TBD (구현·튜닝 · 설계 캐논 아님)

Combat Rules에 기입된 TBD만 유지. 여기서 채우지 않는다.

- 스폰 좌표 · 웨이브 간격 · 스테이지별 상한
- Formation 간격(m) · 열·행 · 혼합 비율
- 대시 거리·쿨 · 히트박스
- 동시 교전 상한 · 어그로
- 경직 프레임 · 연속 격파 보너스
- 리스폰 타이머 · 유입 조건
- 텔레그래프 예고 시간 · 오디오
- 결과 시트 격파 수 UI · 목표 키
- B3 TTK 구간

**TBD = 구현 게이트 전 미결정.** 확정 수치·캐논으로 오인 금지.

---

## 5. 다음 단계 진입 조건

다음 중 **어느 것도** Master의 **별도 승인** 없이 시작하지 않는다.

| 후속 유형 | 진입 조건 |
|-----------|-----------|
| 이미지 · 흑실루엣 시각화 | Master 승인 |
| 삼면도 | Master 승인 |
| Meshy / 모델링 | Master 승인 |
| UE 배치 · 실기 | Master 승인 |
| M5 Visualization | Master 승인 |
| 코드 구현 (스폰/AI 등) | Master 승인 |
| SWARM COLUMN 최종 LOCK 선언 | Master 승인 |
| 신규 수치 확정 · 캐논 본문 변경 | Master 승인 |

```
텍스트 설계 트랙 ──(본 Gate)──▶ 대기
                                    │
                         Master 별도 승인
                                    │
                                    ▼
                         시각화 / 모델링 / 구현
```

---

## 6. 다음 단계에서 금지되는 작업 (승인 전)

- 이미지 제작
- 삼면도 제작
- Meshy 호출 · 메시 생성
- UE 임포트 · 배치
- M5 Visualization / PNG
- 코드 구현 (프로토타입 포함, 별도 승인 없는 한)
- 캐논·스토리 본문 변경
- 신규 게임플레이 수치 확정
- 기존 4문서 본문 임의 수정
- 임의 merge로 시각화 PR 진행

---

## 7. 텍스트 트랙 종료 조건 (본 Gate)

| 조건 | 충족 |
|------|------|
| 3안 제시 완료 | ○ |
| Shortlist 1순위 상세 완료 | ○ |
| 전투 운용 규칙 텍스트 완료 | ○ |
| Detail ↔ Rules 정합 · CONFLICT 0 | ○ |
| 신규 캐논·확정 수치 잠입 없음 | ○ |
| 후속 진입·금지 조건 문서화 | ○ (본 문서) |

위가 충족되면 **ORD-GRUNT 텍스트 설계 트랙은 종료**로 기록한다.  
후속은 Master 승인 게이트를 통과한 작업만 연다.

---

## 8. 한 줄 요약

```
ORD-GRUNT 텍스트 설계 = DONE (패키지 정합)
SWARM COLUMN = shortlist 1순위 (최종 LOCK은 Master)
시각화·모델링·구현 = STOP until Master 승인
TBD = 구현 전 미결정 유지
```

---

## 9. Git / 승인 게이트

1. 본 문서 PR → CI → 리뷰 → **Master 승인** → merge
2. 임의 merge 금지
3. merge 후에도 §5·§6 금지 유지

```
CURRENT: ORD-GRUNT 텍스트 설계 Gate 문서화
NEXT: Master 승인 → merge → 텍스트 트랙 종료 기록 확정
AFTER: 다음 작업은 Master가 명시한 유형만
```

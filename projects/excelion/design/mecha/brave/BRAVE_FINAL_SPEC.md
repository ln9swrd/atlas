# BRAVE_FINAL_SPEC — mecha/brave

> 2026-08-10 · SUPER_ROBOT_DESIGN_LANGUAGE 정렬  
> 원본: `brave/FRAME_SPEC.md` · `BRAVE_INFLUENCE.md` · `06_MECHA`  
> 스토리: EP01–24 · EPISODE_MATRIX

**상태: FINAL (플레이어 기체 · 전투·구현 레이어 포함)**

상위: `../SUPER_ROBOT_DESIGN_LANGUAGE.md`

---

## 01 Identity

| 항목 | 값 |
|------|-----|
| id | brave-001 |
| 이름 | BRAVE / Brave |
| codename | EX-BRAVE-001 |
| 파일럿 | 리아 |
| 분류 | 플레이어 · **여성적 비례 SUPER ROBOT** · 차원 대응형 |
| 키 | **25 m** |

## 02 Story Role

| 구간 | 역할 |
|------|------|
| EP01–12 | **동일 형태** · 공명·광기·성장=연출 |
| EP11 | 엑셀리온 **일시 전조** |
| EP13 | 엑셀리온 **1단계 고정** |
| EP14–24 | 전선·팀·최종 · 형태는 엑셀리온 규칙 |

성장 = 형태 추가가 아니라 **S-Core·광기·엑셀리온 전개**.

## 03 Design Philosophy

- **SUPER ROBOT FIRST** — 건담/리얼로봇 금지
- **여성적 비례의 슈퍼로봇** (날씬 휴머노이드 축소 금지)
- 여백 · 단순 · **영웅 실루엣** · 곡선 외곽
- 3톤 · 저밀도 패널 유지 (`MECHA_3TONE`)
- 중밀도 이하 패널 · 로봇혼/센티넬 **피니시** (조형 언어는 슈퍼로봇)
- 진겟타 기세 · 마징가 아이콘 · **형태 카피 금지**
- 핀 패널 평시 닫힘 · 드론 출격 시만

## 04 Silhouette

| 축 | 묘사 |
|----|------|
| 전체 | 영웅형 · 머리 캐릭터성 · 어깨 덩어리 분명 · 허리 한 단 · 다리 길되 **질량** |
| 머리 | 헬멧 · 가로 슬릿/렌즈 · 영웅적 형상 · 뿔·안테나 없음 |
| 흉 | Imperial 여백 + **아이콘 코어** · 큰 곡면 장갑 |
| 팔 | 곡면+판 · 슈퍼로봇 팔 질량 · 기본 거포·방패 없음 |
| 다리 | 판 최소 · 접지 안정 · 허벅지·종아리 덩어리 |
| 배면 | 백팩·스러스터 없음 (초기형) |
| 동작 | 정지 시에도 돌진·타격·필살 연상 |

## 05 Dimensions

| 항목 | 값 |
|------|-----|
| 전고 | 25.0 m |
| mass (concept) | 48.5 |
| mobility / output | 0.7 / 0.65 (concept) |

## 06 Mechanical Structure

- humanoid base_body · **슈퍼로봇 조형**
- 슬롯 활성: head, torso_u/l, arm_l/r, leg_l/r
- 비활성(S1 초기): backpack, skirt, weapon, thruster
- 핀 패널: 메쉬 디테일 · 평시 닫힘

## 07 Armor / Material

| 용도 | 값 |
|------|-----|
| primary | `#C0C8D0` |
| secondary | `#2A3A4A` |
| accent | `#E8A020` |

매트+세미글로스 · 큰 면 우선 · 과밀도 그리블 금지 · 패널은 보조.

## 08 Head / Sensor

- 바이저 슬릿 · 시선 accent · **캐릭터성**
- 「사람 탄 기계」가 아니라 **탑승 슈퍼로봇의 얼굴**

## 09 Torso / Core

- 중앙 코어 · 필살·브레스트 계열 **빛·발사** (문양 카피 금지)
- 여백 + 아이콘성 동시

## 10 Arms / Hands

- 단순 · 손가락형 가능 · 질량 유지
- 분리 타격 = 드론/연출 (로켓펀치 직카피 금지)

## 11 Legs / Feet

- 기동·접지 · 과한 스파이크 없음 · 종아리 덩어리

## 12 Propulsion

- 초기: 내장 수준 · 배면 스러스터 비활성
- EP13+: thruster/backpack 택1–2 가능 (`EXCELION_SPEC`)

## 13 Power / Energy

- S-Core · 공명
- 광기 0–5: 표면 빛·균열·accent 점등 (`MADNESS_VISUAL`)
- 과부하: EP8형 연출 가능

## 14 Weapons

| 무장 | 비고 |
|------|------|
| brave-blade | DESCRIPTION 있음 · 실루엣 비파괴 수납 |
| brave-cannon | 코어·흉부 발사 연출 가능 |
| brave-drone | 소수 · 출격 시만 · 본체 가림 금지 |

기본 삼면도 = 비무장.

## 15 Defensive Systems

- 기동 회피 · 단가드
- 슈퍼로봇형 “한 방 버티기” 연출 가능하나 리얼 가드 게이지 보스화 금지

## 16 Special Systems

| 시스템 | 규칙 |
|--------|------|
| 공명 | 리아 전용 서사 |
| 광기 | 실루엣 유지 · 연출만 |
| 핀 패널 | 전개 시에만 기세 |
| 엑셀리온 | EP13 1단계 · 동일 골격 |

## 17 Combat Role

**플레이어 주인공기.**  
근접 고속 · 대시·콤보·카운터·필살. 목표가 항상 “돌파·선택”으로 읽힘.

## 18 Combat Loop (플레이어)

```
이동·대시 → 약·강 콤보 → 가드/회피
→ 필살/코어 게이지
→ (광기) 리스크·출력 상승 연출
→ (엑셀리온) 봉쇄 무시·배수·플레어
```

## 19 AI Behavior

N/A (플레이어).

## 20 Weakness / Counter

| 리스크 | 내용 |
|--------|------|
| 광기 과다 | 시야·제어 패널티 (`MADNESS`) |
| 과부하 | 일시 정지·대가 연출 |
| 여백 기체 | 중장갑 정면 강타에 약할 수 있음 (밸런스) |

## 21 Damage States

| 단계 | 시각 |
|------|------|
| 경미 | 스크래치 · accent 점멸 |
| 중 | 패널 균열 · 광기 동반 가능 |
| 한도 | 기동 저하 · 스토리 강제 이벤트와 연동 |

S1 중반 **형태 변경으로 손상 표현 금지**.

## 22 VFX / SFX

- accent 호박 점등 · 코어 섬광
- 광기: 가장자리 균열광
- 필살: 클린한 한 방 · 과한 그을음 남발 금지

## 23 Animation

- 기동감 있는 슈퍼로봇 보행·대시 (여성 비례 유지)
- 핀 패널 개폐 단시간
- 엑셀리온: 윤곽 확장 1단계

## 24 Three-view Requirements

- Front/Side/Back orthographic · 순백 · A/T-pose
- 25m · 여성 비례 + 슈퍼로봇 질량 · 비무장 · 백팩 없음
- Positive/Negative: DESCRIPTION 프롬프트

## 25 Turnaround Requirements

- 8방향에서 여백·여성 비례·슈퍼로봇 덩어리 유지
- ORD/콜로서스/네메시스와 실루엣 충돌 없을 것

## 26 Exploded Parts

head · torso · arms · legs · core · pin panel 단품

## 27 Weapon Sheet

blade · cannon · drone 각 수납/전개

## 28 Game Implementation

| 단계 | 정의 |
|------|------|
| 설정 | 01–16 · FRAME |
| 행동 규칙 | 플레이어 입력 맵 · 콤보 · 필살 |
| 신호 | 코어 게이지 · 광기 레벨 UI · 과부하 경고 |
| 경직 | 가벼움 우선 (슈퍼로봇 쾌감) |
| 종료 | 미션 목표 · 스토리 이벤트 |

## 29 Source / Canon References

- `../SUPER_ROBOT_DESIGN_LANGUAGE.md`
- `brave/FRAME_SPEC.md` · `BRAVE_INFLUENCE.md` · `EXCELION_SPEC.md`
- `mecha/brave/DESCRIPTION.md`
- docs/06_MECHA · MADNESS_VISUAL · weapon/brave-*

## 30 Open Issues

| # | 이슈 |
|---|------|
| 1 | 조작·콤보 수치 테이블 |
| 2 | 삼면도 PNG HOLD |
| 3 | 엑셀리온과 시트 분리 vs 동일 문서 앵커 |
| 4 | 드론 AI 한도 |

---

## 금지 요약

- S1 중반 형태 변경 · 남성 bulk · 성인 히로인 과무장
- 진겟타·마징가 형태 직카피 · 팔레트 임의 변경
- 핀/드론 상시 전개로 여백 파괴 · 70s 평면 저밀도
- **건담/리얼로봇 · 패널 과밀 · 날씬 휴머노이드 축소**

---

## 상태 블록

```
CURRENT: SUPER ROBOT FIRST 정렬 · 여성 비례 슈퍼로봇 명시
DONE: 플레이어 기체 FINAL · 조작 루프 골격 · 엑셀리온 연결
NEXT: 삼면도 PNG · 액션 수치
BLOCKED: PNG HOLD · 액션 수치
PRESERVE: 25m · 3톤 · 여백 · 저밀도 패널 · EP1–12 동일 형태
```

**STEP 7 = Done · 2026-08-10 언어 정렬.**

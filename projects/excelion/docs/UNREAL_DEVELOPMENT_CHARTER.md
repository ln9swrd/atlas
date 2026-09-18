# UNREAL_DEVELOPMENT_CHARTER — Excelion

> 2026-08-10 · Unreal 실기 준비용 기준 문서  
> 원천: PROJECT_CHARTER · 00_VISION · 08_PLAY_BRAVE · SUPER_ROBOT_DESIGN_LANGUAGE · VERTICAL_SLICE_EP1_6_8  
> VS 보스: **세스** (P0 LOCK)

**상태: P0 정합**

---

## 1. Unreal Engine 개발 목적

Excelion을 **Mission-Based 3D Action**으로 실제 플레이 가능한 형태로 구현한다.

목표:
- 슈퍼로봇 메카 전투의 손맛과 소년만화적 희열을 검증한다.
- 기존 스토리·전투·기체 설계를 Unreal에서 바로 구현할 수 있는 기술 기준을 고정한다.
- Vertical Slice를 통해 “재미있는가”를 최소 범위로 확인한다.

**금지:** 설정·스토리 TEXT-LOCK 임의 변경 · 건담식 리얼로봇 방향 전환.

---

## 2. 목표 플랫폼

| 항목 | 값 | 상태 |
|------|-----|------|
| 주 플랫폼 | PC (Windows) · Win64 | **LOCK** (P0) |
| 부 플랫폼 | TBD (콘솔 검토 가능) | TBD |
| 입력 | 게임패드 우선 · 키보드/마우스 병행 | LOCK 의도 |
| 해상도 / FPS | 60 FPS 목표 · `TECHNICAL_REQUIREMENTS` | FPS **LOCK** |

---

## 3. 게임 장르

- **Mission-Based 3D Action**
- 모던 슈퍼로봇 / SF + 생체기계
- 서사 톤: 소년만화 · 열혈 + 광기 · 리아 중심

참고 작품 방향: Gunbuster, Getter Robo, Gurren Lagann, Five Star Stories  
(조형·감정 기준. 시스템 카피 금지)

---

## 4. 핵심 게임플레이

공통 루프:

```
탐색 → 적 조우 → 전투(접근→콤보→밀기→필살) → 보상/진행 → 다음 구역
```

핵심 시스템:
- **S-Core**: 필살·초필 게이지 · 의지 주도 · 광기 대가
- 근접 (썬더 블레이드) / 중거리 (브레스트 캐논) / 보조 (드론)
- 대시 회피 · Heat 관리
- 보스: Phase 기반 패턴 (시간·행동 트리거, HP% 전환 금지)

플레이 우선순위: **스토리 > 플레이 > 디자인·설정(가변)**

상세: `docs/08_PLAY_BRAVE.md` · `docs/02_COMBAT.md` · `design/combat/COMBAT_LOOP.md`

---

## 5. 카메라 방향

| 항목 | 방향 | 상태 |
|------|------|------|
| 기본 | 3인칭 추적 (메카 후방 약간 상단) | 제안 |
| 전투 | 락온 시 대상 중심 보정 · 필살 시 연출 카메라 | TBD |
| 보스 | 패턴 경고·판정 가독성 우선 | LOCK 의도 |
| 금지 | 1인칭 고정 · 과도한 시네마틱 차단 | — |

수치·스프링암·충돌은 `TECHNICAL_REQUIREMENTS.md`에서 TBD로 관리.

---

## 6. 전투 중심 설계

- 모든 시스템·에셋·AI는 **전투 피드백**을 최우선으로 한다.
- 피드백 최소 세트: 히트스톱 · 플래시 · SFX · 숫자 · 위험 경고.
- 보스 패턴은 정직한 텔레그래프 → 학습 → 왜곡 → 붕괴 구조.
- 플레이어 쾌감: 가벼운 경직 · 명확한 한 방 · S-Core “끌어냈다” 체감.

구현 진입점 순서:
1. Phase 상태 머신
2. 예고·판정 공통
3. 플레이어 이동/공격/피격
4. 적 패턴 1개
5. 보스 1종 (**세스**)
6. 피드백 버스

---

## 7. 개발 범위 (이번 준비 단계 이후)

**포함**
- Unreal 프로젝트 골격 (C++ + Blueprint)
- BRAVE 플레이어 기체 기본 이동·전투
- ORD-GRUNT 등 양산 적 1종
- 보스 1종 (**세스** · Vertical Slice / P0)
- 기본 UI (HP · S-Core · Heat)
- 기본 VFX/Audio 훅
- Data Asset / Data Table 기반 수치

**제외 (현재)**
- 전체 S1 24화 구현
- 모든 보스·모든 맵
- 네트워크·멀티플레이
- 완전 시네마틱 파이프라인
- ParaModel 실시간 연동
- Meshy/Blender 자동화 코드 (문서 계약만 존재)

---

## 8. Vertical Slice 목표

기존 잠금: `state/VERTICAL_SLICE_EP1_6_8.md`  
VS 보스: `docs/UNREAL_PRE_IMPLEMENTATION_DECISIONS.md` **세스 LOCK**

Unreal 1차 목표:
- 5~10분 플레이 가능한 전투 데모
- 플레이어 메카 1 (BRAVE)
- 적 메카 1종 (ORD-GRUNT 권장)
- 보스 1 (**세스**)
- 전투 지역 1
- 무기 2~3 · 필살기 1
- 기본 UI · 기본 VFX

기존 EP1/6/8 설계와 충돌 시 **기존 설정 · P0 LOCK 우선**.

---

## 9. 기술적 우선순위

1. 플레이어 이동·대시·기본 공격
2. 히트 판정 · 데미지 · 피드백
3. S-Core 게이지 · 필살
4. 적 AI (단순 추적·공격) → 보스 Phase (세스)
5. 카메라·락온
6. UI·세이브 (최소)
7. 데이터 드리븐 수치

C++: 핵심 로직·컴포넌트 · Blueprint: 콘텐츠 조정·연출·에디터 작업.

---

## 10. 현재 단계

| 항목 | 상태 |
|------|------|
| 스토리·전투·기체 설계 | 텍스트 진행 · 다수 LOCK/FINAL |
| P0 기술 결정 | **LOCK** |
| 시각화 · ParaModel | HOLD |
| 파이프라인 (Meshy→Blender→FBX→UE) | 문서 계약만 · 구현 TBD |
| Unreal 프로젝트 | **미생성** (UE 환경 대기) |

---

## 11. 다음 단계

1. UE 5.4.x 설치 환경에서 프로젝트 생성
2. 최소 골격 구현 (이동 · 히트 · Damage · S-Core)
3. 세스 1 Phase 검증

---

## 12. 원칙 요약

- **SUPER ROBOT FIRST** — 건담/리얼로봇 금지
- 기존 Excelion 설정 우선 · 임의 변경 금지
- 과도한 시스템 설계 금지 · 구현 가능한 수준만
- 모든 변경 Git 기록 · 중단 대비 상태 문서 유지

# MENOS Gameplay Screen UI 개선 작업 계획

상태: PROPOSAL
목적: 기존 MENOS 전투 화면 기능을 유지하면서 게임 플레이 화면의 품질을 단계적으로 개선한다.
범위: Combat Screen의 기존 UI/화면 표현 개선. 전투 규칙, 적 AI, 웨이브 규칙, 공격 수치 등은 각 단계에서 직접 필요하지 않으면 변경하지 않는다.

## 1. 작업 원칙

1. 기존 기능을 먼저 확인하고 재사용한다.
2. 한 번의 작업에서는 하나의 개선 항목만 변경한다.
3. 기존 기능의 동작을 유지한 상태에서 UI 표현만 개선하는 것을 우선한다.
4. 각 단계마다 최소 검증 후 결과를 기록한다.
5. 검증되지 않은 시각적 문제를 사실처럼 단정하지 않는다.
6. 기존 Asset으로 해결 가능한 경우 신규 Asset을 만들지 않는다.
7. 목적 달성 후 자동으로 다음 단계로 진행하지 않는다.
8. 각 단계가 성공하면 STOP하고 Master의 다음 지시를 기다린다.
9. 기존 변경사항을 임의로 되돌리거나 덮어쓰지 않는다.
10. Commit / Push는 Master 승인 없이는 수행하지 않는다.

## 2. 현재 기준선

### CONFIRMED
- MENOS의 핵심 화면은 Combat Screen이다.
- 현재 전투 화면은 main.gd의 UI 렌더링과 기존 전투 시스템이 결합되어 있다.
- 기존 전투 기능에는 Robot, Enemy, Spawn, Wave, Tower, Combat 관련 기능이 포함되어 있다.
- 현재 UI에는 전투 상태, ATLAS 상태, Tower 관련 조작, Wave 관련 정보 등이 존재한다.
- 기존 화면 구조를 바탕으로 UI 개선을 진행할 수 있다.

### UNVERIFIED
- 실제 PIE에서 최종적인 화면 품질과 체감 가독성.
- 실제 해상도별 UI 스케일과 겹침 문제.
- 최종 아트 Asset 적용 후의 시각적 완성도.

### 주의
현재 UI 코드에 이미 변경사항이 있을 수 있으므로 작업 시작 시 HEAD / Branch / Working Tree / Diff를 다시 확인한다.
## 3. 단계별 개선 순서

### STEP 1 — 화면 기준 해상도와 카메라 구성 정리
목적:
게임 화면이 개발용 맵 뷰처럼 보이지 않도록 화면의 기준 크기와 전장 표시 영역을 먼저 안정화한다.

수정 대상:
- 기존 viewport / camera 관련 설정
- 전장 표시 영역
- HUD가 전장을 침범하는 영역

성공 조건:
- 전장과 HUD의 경계가 명확하다.
- 화면 크기가 달라져도 핵심 전투 영역이 지나치게 흔들리지 않는다.
- 기존 이동/공격/웨이브 기능이 영향을 받지 않는다.

검증:
CODE → 실제 화면 가능 시 PIE에서 화면 비율 확인.

---

### STEP 2 — 전투 영역의 시각적 우선순위 정리
목적:
화면에서 ATLAS와 적의 전투가 가장 먼저 보이도록 전장 표현의 우선순위를 정한다.

수정 대상:
- 배경 대비
- 전장 여백
- 유닛 표시 크기
- 전투 중심 영역의 시각적 밀도

성공 조건:
- HUD보다 전투가 먼저 인식된다.
- ATLAS / Enemy / 주요 공격 효과가 서로 묻히지 않는다.
- 맵 정보는 전투를 방해하지 않는다.

범위 제한:
새로운 전투 시스템이나 AI는 추가하지 않는다.

---

### STEP 3 — ATLAS 표시 품질 개선
목적:
MENOS의 핵심 캐릭터인 ATLAS가 화면에서 명확한 주인공으로 읽히게 한다.

수정 대상:
- ATLAS 화면 크기
- 선택/상태 표시
- HP 표시
- 공격 상태 표시
- 특수공격 상태 표시

성공 조건:
- 현재 위치를 즉시 파악할 수 있다.
- HP와 전투 상태를 짧은 시간에 이해할 수 있다.
- 기존 이동/공격/Special 동작은 변경하지 않는다.

검증:
기존 Robot 기능의 입력과 상태 변화가 유지되는지 확인.
### STEP 4 — Enemy 가독성 개선
목적:
적의 종류와 위협 정도를 전투 중 빠르게 구분할 수 있도록 한다.

수정 대상:
- Enemy 크기와 대비
- HP bar
- Heavy / Giant 등 주요 위협 표시
- 피격 상태 표시

성공 조건:
- 적 무리가 겹쳐도 개별 적의 존재가 읽힌다.
- 중요한 적의 위치와 상태를 파악할 수 있다.
- 적 이동/공격/피해 계산에는 영향을 주지 않는다.

---

### STEP 5 — 공격과 피격 효과의 가독성 개선
목적:
슈퍼로봇 전투의 핵심인 '공격 → 이동 → 명중 → 피해'의 인과관계를 화면에서 명확하게 만든다.

수정 대상:
- 기본 공격
- Special 공격
- 투사체
- 명중 효과
- 피격 표시
- 필요 최소한의 화면 효과

성공 조건:
- 어떤 공격이 누구에게 맞았는지 이해할 수 있다.
- 피해 발생 시점이 시각적으로 납득된다.
- 기존 공격 피해량과 판정 규칙은 변경하지 않는다.

범위 제한:
새로운 공격 시스템이나 밸런스 조정은 하지 않는다.

---

### STEP 6 — HUD 정보 계층 정리
목적:
정보를 많이 보여주는 것이 아니라 '지금 필요한 정보'가 먼저 보이도록 정리한다.

우선순위:
1. ATLAS 상태
2. Base 상태
3. 현재 Wave / 전투 진행
4. Special / 주요 명령
5. Tower 조작
6. 보조 정보

수정 대상:
- 패널 위치
- 크기
- 간격
- 텍스트 계층
- 아이콘/버튼 표현

성공 조건:
- 전투 중 시선 이동이 과도하지 않다.
- 주요 정보와 보조 정보가 시각적으로 구분된다.
- 기존 조작 기능은 그대로 사용할 수 있다.
### STEP 7 — HUD의 MENOS 전용 시각 언어 적용
목적:
단순한 MOBA/개발 도구 UI가 아니라 MENOS의 슈퍼로봇 전투 화면으로 보이게 한다.

기준:
- 산업 SF
- 군사 전술 화면
- 슈퍼로봇의 강한 실루엣
- 제한된 장식
- 전투 가독성 우선

수정 대상:
- 패널 프레임
- 버튼 형태
- 상태 표시
- 강조선
- 색상 체계

주의:
LoL의 UI를 그대로 복제하지 않는다.
LoL에서 참고할 것은 정보 배치와 전투 가독성이지, 그래픽 자산이나 고유 UI 디자인이 아니다.

성공 조건:
- MENOS의 전투 화면이라는 인상이 생긴다.
- 장식 때문에 전투 가독성이 떨어지지 않는다.

---

### STEP 8 — Minimap / 전장 보조 정보 개선
목적:
전체 전투 상황을 파악할 수 있는 보조 정보를 전투 화면과 충돌하지 않게 배치한다.

수정 대상:
- Minimap 위치
- 크기
- 플레이어/적/기지 표시
- 전장 범위 표시

성공 조건:
- 현재 전장 위치를 빠르게 파악할 수 있다.
- Minimap이 본 전투를 가리지 않는다.

---

### STEP 9 — 승리 / 패배 / 웨이브 전환 연출 정리
목적:
전투의 시작과 종료, 중요한 상태 변화가 명확하게 전달되도록 한다.

수정 대상:
- Wave 시작 상태
- Wave 종료 상태
- Victory
- Defeat
- 필요한 최소 사운드/화면 효과

성공 조건:
- 플레이어가 현재 전투 상태를 오해하지 않는다.
- Victory / Defeat가 즉시 인식된다.
- 기존 승패 판정 자체는 변경하지 않는다.

---

### STEP 10 — 전체 화면 통합 검증
목적:
개별 개선이 서로 충돌하지 않는지 확인한다.

검증:
- UI 겹침
- 전투 영역 침범
- ATLAS 가독성
- Enemy 가독성
- 공격 효과
- Wave 정보
- Minimap
- Victory / Defeat
- 기존 입력

판정:
ACCEPT·STOP / CHANGE METHOD / HOLD 중 하나로 판정한다.
## 4. 각 단계의 공통 작업 절차

각 STEP은 다음 순서로만 진행한다.

1. 기준선 확인
   - HEAD
   - Branch
   - Working Tree
   - 관련 파일
   - 기존 Diff

2. 증상 확인
   - 실제 코드에서 현재 구현을 확인한다.
   - 가능한 경우 실제 화면에서 확인한다.

3. 최소 변경 정의
   - 해당 STEP에 필요한 기존 함수/값만 선정한다.
   - 관련 없는 코드에는 손대지 않는다.

4. 변경
   - 한 STEP의 목적만 구현한다.

5. Diff 확인
   - 의도한 변경만 있는지 확인한다.
   - 예상하지 않은 변경이 있으면 즉시 중단한다.

6. 최소 검증
   - CODE VERIFIED
   - 필요 시 BUILD VERIFIED
   - 가능하면 EDITOR VERIFIED / PIE VERIFIED

7. 판정
   - 목적 달성: ACCEPT·STOP
   - 방법 수정 필요: CHANGE METHOD
   - 정보 부족/환경 문제: HOLD
   - 실패: FAIL

8. 기록
   - CURRENT_STATE.md 또는 작업 문서에 결과를 기록한다.

## 5. 변경 금지 범위

UI 품질 개선 작업이라는 이유만으로 다음을 자동 변경하지 않는다.

- 전투 밸런스
- 적 AI
- Wave 규칙
- Spawn 규칙
- Tower 공격 규칙
- ATLAS 공격 피해량
- Special 피해량 / 쿨다운
- Map Data
- Stage Data
- 기존 Asset의 삭제/대체
- 새로운 외부 Asset 도입
- main.gd 대규모 리팩터링

이 항목들은 별도 목적과 승인 없이 변경하지 않는다.

## 6. 작업 중단 조건

다음 중 하나가 발생하면 해당 STEP에서 HOLD한다.

- 실제 구현 위치가 확인되지 않음
- 기존 기능과 충돌 가능성이 있음
- 새로운 설계 판단이 필요함
- 신규 Asset이 필수임
- 예상하지 않은 Diff 발생
- 기존 기능이 변경됨
- 실제 화면 결과가 예상과 다름
- 범위가 UI 개선을 넘어섬

## 7. 우선 실행 대상

첫 작업은 STEP 1만 수행한다.
STEP 1이 검증되어 ACCEPT·STOP 된 이후 Master의 다음 지시가 있을 때 STEP 2로 진행한다.

전체 10단계를 한 번에 구현하지 않는다.

## 8. 보고 형식

각 STEP 종료 시:

**STATUS** — PASS / HOLD / FAIL / UNVERIFIED

**목적** — 해당 STEP에서 해결하려던 문제

**기준선** — HEAD / Branch / Working Tree / 관련 파일

**조사 결과** — CONFIRMED 중심

**세라의 기술 판단** — 변경 근거

**마리의 판정** — 목적 충족 여부

**변경 사항** — 실제 변경만

**검증 상태** — CODE / BUILD / EDITOR / PIE

**미확인 사항** — 직접 확인하지 못한 내용

**OUT OF SCOPE** — 수행하지 않은 후속 작업

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**다음 단계** — Master가 요청한 경우에만 기록

## 9. 최종 원칙

MENOS의 핵심 가치는 슈퍼로봇의 전투 구현이다.
따라서 UI는 전투를 장식하는 것이 아니라 전투를 더 명확하고 강하게 보여주는 방향으로 개선한다.

**한 번에 하나.**
**기존 기능 유지.**
**최소 변경.**
**검증 후 다음 단계.**
**성공하면 STOP.**

## Handoff — STEP 1 Gameplay-Safe Camera (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — Bottom HUD가 전투 영역을 덮는 구조에서 카메라 기준을 HUD 제외 영역에 맞추고, 전장 중심을 안정적으로 유지한다.

**기준선** — Branch `main`; 기존 변경사항 보존; Commit / Push 없음.

**조사 결과**
- **CONFIRMED** — 프로젝트 viewport는 1400×860이다.
- **CONFIRMED** — 현재 Combat 화면은 `main.gd`에서 Camera2D와 화면 HUD를 함께 사용한다.
- **CONFIRMED** — Bottom HUD는 기존 변경사항에 의해 188px 높이로 설정되어 있다.
- **CONFIRMED** — 기존 카메라는 MAP 전체 크기를 기준으로 중앙에 배치되어 HUD가 사용하는 화면 영역을 별도로 고려하지 않았다.
- **CONFIRMED** — `_camera_target_clamped()` 역시 전체 viewport 높이를 기준으로 카메라 이동 범위를 계산했다.

**변경 사항**
- **CHANGED** — `_setup_camera()`의 초기 카메라 중심을 Bottom HUD 높이의 절반만큼 아래로 보정하여, HUD 위쪽의 게임플레이 영역 중심에 전장을 맞췄다.
- **CHANGED** — `_camera_target_clamped()`가 카메라 이동 범위를 계산할 때 전체 viewport 대신 `viewport height - BOTTOM_HUD_HEIGHT`를 게임플레이 안전 영역으로 사용하도록 수정했다.
- **UNCHANGED** — 맵 크기, TileMap, 전투 규칙, 이동/공격, Wave, Spawn, Tower, Robot 로직은 변경하지 않았다.
- **UNCHANGED** — 기존 UI 레이아웃 변경사항은 이번 STEP의 기존 변경으로 유지했으며 되돌리지 않았다.

**검증**
- **CODE VERIFIED** — 수정 diff 확인.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. 현재 환경에서 Godot 실행 파일을 확인하지 못했다.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 현재 단계에서 화면 기준을 바꾸는 최소 변경은 HUD 안전 영역을 카메라 계산에 반영하는 것이다.
- 맵/전투 데이터를 수정하지 않고 카메라 계층만 보정했으므로 범위 내 변경이다.

**마리의 판정**
- STEP 1의 코드 목적은 충족했다.
- 실제 PIE에서 카메라 위치와 화면 체감은 확인하지 못했으므로 시각적 최종 PASS로 확대하지 않는다.
- 추가 UI 변경은 수행하지 않는다.

**미확인 사항**
- 실제 1400×860 PIE에서 전장 상하 여백과 HUD 경계가 의도대로 보이는지.
- 다른 해상도에서 동일한 카메라 안전 영역이 적절한지.

**OUT OF SCOPE**
- STEP 2 전투 영역 시각 개선
- ATLAS 표시 개선
- Enemy 표시 개선
- 공격/피격 VFX 개선
- HUD 재디자인 추가
- Asset 제작/교체

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.

## Handoff — STEP 2 Combat Visual Priority (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — 전투 시스템을 변경하지 않고 ATLAS-01과 적 유닛이 전장의 주요 시각적 초점이 되도록 표시 크기와 전투 가독성을 조정한다.

**기준선** — Branch main; STEP 1 및 기존 main.gd 변경사항 보존; Commit / Push 없음.

**조사 결과**
- **CONFIRMED** — 전투 유닛은 main.gd의 _draw()에서 직접 스프라이트, 발밑 링, HP Bar, 피격 효과를 렌더링한다.
- **CONFIRMED** — ATLAS-01 기본 전투 표시 크기는 64×114였고, 적 표시 크기는 ENEMY_SPRITE_SIZES 값을 그대로 사용했다.
- **CONFIRMED** — 타워 표시 크기는 60×90이었다.
- **CONFIRMED** — 유닛의 이동/공격/타겟팅/충돌 데이터와 렌더링 크기는 코드상 별개로 처리된다.
- **CONFIRMED** — Godot 실행 파일은 현재 연결된 환경의 PATH에서 확인되지 않아 PIE 실행은 수행하지 못했다.

**변경 사항**
- **CHANGED** — ATLAS-01 렌더링 크기를 64×114 → 78×132로 조정하고 발밑/HP Bar 위치와 폭을 함께 보정했다.
- **CHANGED** — Enemy 렌더링 크기를 기존 ENEMY_SPRITE_SIZES의 1.08배로 표시하도록 조정했다.
- **CHANGED** — Tower 렌더링 크기를 60×90 → 64×96으로 소폭 조정했다.
- **UNCHANGED** — Enemy/Robot/Tower의 HP, 공격력, 사거리, 이동속도, AI, 타겟팅, 충돌, Wave, Spawn 규칙은 변경하지 않았다.
- **UNCHANGED** — Asset 파일 자체와 map/stage 데이터는 변경하지 않았다.

**검증**
- **CODE VERIFIED** — 수정 위치와 렌더링 경로 확인.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. Godot 실행 파일 미확인.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 표시 크기만 조정하여 전투 유닛의 시각적 존재감을 높이는 것은 현재 STEP 2의 목적에 직접 대응한다.
- 전투 데이터와 렌더링 데이터가 분리되어 있어 시스템 동작 변경 없이 적용 가능하다.

**마리의 판정**
- STEP 2의 코드 목적은 충족했다.
- 실제 화면에서 크기 증가가 과도하지 않은지, 타일/오브젝트와의 충돌감이 없는지는 PIE 미검증 상태이므로 최종 시각 PASS로 확대하지 않는다.
- 추가 배경/Asset 변경은 수행하지 않는다.

**미확인 사항**
- 실제 PIE에서 ATLAS/Enemy/Tower의 시각적 비율과 전장 가독성.
- 다른 해상도에서 확대된 유닛과 HUD의 균형.

**OUT OF SCOPE**
- STEP 3 ATLAS 표시 품질의 추가 개선
- Enemy 가독성의 추가 개선
- 공격/피격 VFX 개선
- HUD 추가 변경
- Asset 제작/교체

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.

## Handoff — STEP 3 ATLAS Presentation Quality (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — ATLAS-01을 전투 화면의 주인공으로 더 명확하게 인식시키되, 게임플레이 시스템은 변경하지 않는다.

**기준선** — Branch main; STEP 1~2 및 기존 main.gd 변경사항 보존; Commit / Push 없음.

**조사 결과**
- **CONFIRMED** — ATLAS는 idle/move/attack/skill 애니메이션을 상태에 따라 선택하고 있다.
- **CONFIRMED** — 기존 선택 표시는 원형 링과 가로/세로 십자선이었다.
- **CONFIRMED** — 기존 피격 표시는 단순 원형 플래시였으며, 공격/특수공격 상태에는 이미 별도 애니메이션이 존재한다.
- **CONFIRMED** — ATLAS 렌더링 크기는 STEP 2에서 78×132로 확대된 상태였다.

**변경 사항**
- **CHANGED** — ATLAS 선택 표시를 디버그성 십자선에서 펄스형 이중 아크 링으로 변경했다.
- **CHANGED** — ATLAS 특수공격 중 금색 회전 아크, 일반 공격 중 청록색 회전 아크를 발밑에 추가했다.
- **CHANGED** — 피격 플래시 반경을 기존 34에서 42로 확대해 확대된 ATLAS 실루엣과 맞췄다.
- **UNCHANGED** — 공격력, HP, 사거리, 이동, AI, 타겟팅, 특수공격 동작, Wave 규칙, Spawn 규칙은 변경하지 않았다.
- **UNCHANGED** — ATLAS Asset 파일 자체는 변경하지 않았다.

**검증**
- **CODE VERIFIED** — ATLAS 렌더링 경로와 상태 조건을 확인하고 수정 diff를 확인했다.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. Godot 실행 파일 미확인.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 선택/공격/특수공격 표시를 전투 데이터와 분리된 렌더링 계층에서 처리하므로 게임플레이 규칙에 영향을 주지 않는다.
- 기존 애니메이션 Asset을 유지하면서 상태별 시각 피드백을 강화하는 최소 변경이다.

**마리의 판정**
- STEP 3의 코드 목적은 충족했다.
- 실제 PIE에서 링의 크기와 색상, 애니메이션 가독성은 확인하지 못했으므로 시각적 최종 PASS로 확대하지 않는다.
- 추가 Asset 제작/교체는 수행하지 않는다.

**미확인 사항**
- 실제 PIE에서 선택 링과 공격 아크가 ATLAS 실루엣을 방해하지 않는지.
- 고해상도/저해상도에서 ATLAS 표시와 HUD의 균형.
- 실제 전투 중 특수공격 아크가 VFX와 충분히 구별되는지.

**OUT OF SCOPE**
- STEP 4 Enemy 가독성 추가 개선
- STEP 5 공격/피격 VFX 전체 개선
- HUD 추가 변경
- Asset 제작/교체
- 전투 밸런스 변경

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.


## Handoff — STEP 4 Enemy Readability (2026-09-29)

**STATUS** — PASS / 실제 화면 UNVERIFIED

**목적** — 적의 타입과 현재 HP 상태를 전투 중 더 빠르게 식별할 수 있도록 표시 계층을 개선한다. Enemy AI, 스탯, 이동, 타겟팅, Spawn 규칙은 변경하지 않는다.

**기준선** — Branch main; STEP 1~3 및 기존 main.gd 변경사항 보존; Commit / Push 없음.

**조사 결과**
- **CONFIRMED** — Enemy 렌더링은 main.gd의 _draw()에서 타입별 sprite, 발밑 링, 피격 플래시, 이름, HP Bar를 직접 표시한다.
- **CONFIRMED** — 현재 모든 Enemy의 발밑 링과 HP Bar가 동일한 붉은 계열 표현을 사용하고 있었다.
- **CONFIRMED** — Enemy 타입은 normal/rusher/heavy/giant로 구분되며 렌더링 크기도 타입별로 이미 다르다.
- **CONFIRMED** — 피격 시 enemy.flash가 설정되며 기존 플래시는 data.radius 기반이었다.

**변경 사항**
- **CHANGED** — Enemy 타입별 발밑 액센트 색을 구분했다: normal red, rusher orange, heavy violet, giant gold.
- **CHANGED** — giant에만 저강도 외곽 펄스 링을 추가해 대형 적의 존재감을 구분했다.
- **CHANGED** — Enemy HP Bar를 최소 34px 폭, 5px 높이로 통일해 작은 적에서도 읽기 쉽게 했다.
- **CHANGED** — HP Bar 색을 Enemy 타입 액센트와 동일하게 맞췄다.
- **CHANGED** — Enemy 이름 표시를 9px → 10px로 조정하고 HP Bar와 정렬했다.
- **CHANGED** — 피격 플래시 반경을 실제 표시 크기 기준으로 계산하도록 변경했다.
- **UNCHANGED** — Enemy HP, 공격력, 방어력, 사거리, 이동속도, AI, 타겟팅, 충돌, Wave, Spawn 규칙.
- **UNCHANGED** — Enemy Asset 파일, map/stage 데이터.

**검증**
- **CODE VERIFIED** — Enemy 렌더링 경로와 변경 diff 확인.
- **git diff --check** — PASS.
- **BUILD VERIFIED** — UNVERIFIED. Godot 실행 파일 미확인.
- **EDITOR VERIFIED** — UNVERIFIED.
- **PIE VERIFIED** — UNVERIFIED.

**세라의 기술 판단**
- 타입별 액센트와 HP 표시를 렌더링 계층에서만 변경했으므로 전투 로직에는 영향을 주지 않는다.
- giant 외곽 펄스도 giant 타입의 기존 렌더링 분기 안에서만 동작한다.

**마리의 판정**
- STEP 4의 코드 목적은 충족했다.
- 실제 PIE에서 색상 구분과 HP Bar 크기가 과하거나 부족하지 않은지는 확인하지 못했으므로 시각적 최종 PASS로 확대하지 않는다.
- 추가 Asset 제작/교체는 수행하지 않는다.

**미확인 사항**
- 실제 PIE에서 타입별 색상 인지가 충분한지.
- 다수 적이 겹칠 때 HP Bar와 이름이 과밀해지지 않는지.
- 저해상도에서 최소 34px HP Bar가 충분히 읽히는지.

**OUT OF SCOPE**
- STEP 5 공격/피격 VFX 전체 개선
- Enemy AI/밸런스/Spawn 변경
- Asset 제작/교체
- HUD 추가 변경

**현실성 판단** — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE

**판정** — ACCEPT·STOP. 다음 STEP은 Master의 별도 지시 후 진행한다.

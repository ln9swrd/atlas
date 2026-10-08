# MARIE → COPILOT / SERRA

## TASK — Gameplay P1 실제 구현 진행

Master가 세라의 구현안·검증안을 검토한 결과에 따라 진행을 승인했습니다. 목적은 P1 보완이며 추가 Gameplay 기능으로 확장하지 않습니다.

## 범위
### 즉시 구현
- P1-2 Player Profile 저장 경계: `user://` 전용 persistence로 분리. 기존 Content SQLite는 사용자 저장용으로 쓰지 않는다. 기존 Profile row가 있을 가능성을 고려해 비파괴 one-time import 경로를 최소 구현한다. migration이 데이터 손실 위험을 만들면 HOLD.
- P1-3 `defeat_giant`: Giant 미처치 상태에서 일반 Wave clear만으로 Victory/Reward/Stage transition이 발생하지 않도록 한다. Giant 처치 시 기존 완료 경로와 중복 보상/전환이 발생하지 않게 한다. 다른 Mission Type은 유지한다.
- P1-4 참조 검증: Gameplay-critical Stage/Wave/Map/Enemy/Lane 참조는 Stage 진입 전에 fail-fast. Unknown Enemy/Lane/Map을 조용히 다른 값이나 기본 Map으로 fallback하지 않는다. Editor Validator와 Runtime Loader의 최소 필수 검증 계약을 맞춘다.

### P1-1 Reward Gold
- 경제 Canon은 아직 확정하지 않는다.
- 현재 코드의 `player_profile.gold`를 임의로 다음 Stage build budget으로 재해석하지 않는다.
- Reward Gold가 다음 Stage 경제에 연결되어야 한다는 별도 Master 결정이 없는 상태에서는 경제 동작을 변경하지 않는다.
- 단, 현재 Reward Gold가 어디에 저장되고 어떤 경로에서 소비되는지 명확히 문서화/검증에 필요한 최소 코드 정리는 가능하나 경제 의미를 새로 만들지 않는다.

## 안전 규칙
- 시작 전 HEAD / Branch / Working Tree 기록.
- 기존 변경사항 절대 삭제·되돌림·덮어쓰기 금지.
- 특히 `godot/content/menos.sqlite`, Map Editor, Settings 관련 기존 변경 보존.
- 원본 Content SQLite 데이터 수정 금지.
- migration 검증은 원본 DB가 아닌 격리 복사본에서 수행.
- 필요한 테스트 fixture는 격리 환경에서만 생성.
- 수정 후 전체 `git diff`와 `git diff --check` 확인.
- Commit / Push 금지.
- 예상 밖 변경 또는 데이터 손실 위험 발생 시 즉시 HOLD.

## 최소 검증
1. CODE VERIFIED: 실제 수정 경로와 호출 관계 확인.
2. P1-2: 격리 환경에서 profile 생성 → 저장 → 재실행 → Level/XP/Gold/Progression 복원 확인. corrupt/missing 처리도 확인.
3. P1-3: defeat_giant + Giant 미처치에서 Victory 차단, Giant 처치에서 정확히 1회 완료. clear_encounters/defend_base 회귀 확인.
4. P1-4: Unknown Enemy, Unknown Lane, Unknown Map을 각각 한 변수씩 넣어 Stage 진입 실패 확인. 정상 데이터는 계속 진입. fallback first-battle Map이 사용되지 않는지 확인.
5. Build 실행.
6. `git diff --check` PASS.
7. 실제 Master 관찰 전까지 PIE VERIFIED로 표시하지 않는다.

## Campaign 1
- 기존 Campaign 1 Production Acceptance를 취소하거나 재심사하지 않는다.
- 다만 P1-3/P1-4 변경으로 기존 Campaign 1 정상 데이터가 깨지지 않는지 최소 회귀 검증한다.

## 보고
`D:\Atlas\projects\menos\state\COPILOT_TO_MARIE.md`에 기존 보고서를 보존하고 이번 구현 결과를 새 섹션으로 추가한다.

반드시 포함:
- STATUS PASS / HOLD / FAIL
- 시작/종료 HEAD, Branch, Working Tree
- 실제 변경 파일
- P1-2/P1-3/P1-4 변경 및 검증 결과
- P1-1은 경제 정책 미확정으로 변경하지 않았음을 명시
- CODE / BUILD / EDITOR / PIE 상태
- git diff --check
- 기존 변경사항 보존 여부
- Campaign 1 회귀 영향
- UNVERIFIED
- OUT OF SCOPE
- 세라의 기술 판단

## 종료
구현과 최소 검증이 성공하면 STOP한다. 추가 P2 조사/구현, Commit/Push는 하지 않는다.

---
# TASK — Map Editor CRUD GUI/Runtime Verification

## 목적
Map Editor CRUD 구현이 실제 Editor 사용 흐름에서 동작하는지 최소 검증한다.

## 범위
- Map Editor의 New Map
- Save
- Duplicate Map
- Delete Map
- 기존 canonical map 삭제 차단
- Stage 참조 Map 삭제 차단
- unsaved 변경 보호

## 성공 조건
1. 원본 `godot/content/menos.sqlite`를 변경하지 않는다.
2. 격리 DB 또는 복사 프로젝트를 사용한다.
3. 실제 Godot Editor GUI에서 가능한 경우 위 흐름을 백그라운드로 실행한다.
4. GUI 조작이 불가능하면 동일 UI가 호출하는 MapLoader 경로를 격리 DB에서 직접 검증한다.
5. 결과를 `COPILOT_TO_MARIE.md`에 기록한다.

## 금지사항
- Commit / Push 금지.
- Canonical map 수정/삭제 금지.
- 기존 Working Tree 변경사항 정리/되돌리기 금지.
- 본 범위 외 코드 수정 금지.

## 변경 권한
검증에 필요한 임시 테스트 파일은 격리 영역에서만 생성한다. 제품 코드 변경은 발견된 결함이 있을 때 별도 PROPOSAL로 보고하고 중지한다.

## 보고 형식
STATUS / 기준선 / 검증 방법 / 확인 결과 / CODE / BUILD / EDITOR / PIE 상태 / 미확인 / 결함 / 기술 판단 / 다음 결정 필요사항.


---
# TASK — BGM Content Editor 최소 구현

## 목적
Master가 BGM Pilot 4-context와 PIE Runtime 전환을 승인했습니다. Content Editor의 disabled BGM 메뉴를 실제 authoring 기능으로 전환합니다.

## 범위
- 기존 Content Editor의 BGM 메뉴 활성화.
- 기존 BGM Definition / Loader / Repository / Validator / Runtime 구조를 재사용.
- 기존 `bgm_definitions` SQLite 구조와 호환되는 최소 Editor authoring UI 구현.
- 최소 기능: 목록 조회, 선택, 신규/편집, 저장, 삭제(참조/사용 중이면 보호), Validator 오류 표시, Pilot 4-context 확인.
- 가능하면 기존 SFX/Voice 등 Content Editor의 authoring 패턴을 재사용.
- Runtime BGM Controller 자체는 재설계하지 않는다.
- 15-track / 3 Faction × 5 Context 확장은 하지 않는다.

## 성공 조건
1. BGM 버튼이 disabled 상태가 아니며 Content Editor에서 진입 가능.
2. 기존 4개 Pilot Definition을 읽어 목록/상세 편집 대상으로 표시.
3. 최소 CRUD 저장 경로가 실제 BGM repository/DB와 일치.
4. 필수 필드/Validator 오류를 저장 전에 차단하거나 명확히 표시.
5. 삭제 시 참조/사용 중 보호가 동작.
6. 기존 BGM Runtime/Validator smoke가 회귀 없이 통과.
7. 원본 Working Tree의 기존 변경사항을 보존.

## 안전 규칙
- 시작 시 HEAD / Branch / Working Tree 기록.
- 현재 dirty 변경을 절대 되돌리거나 덮어쓰지 않는다. 특히 Settings, Map Editor, SQLite, MK 변경 보존.
- 원본 `godot/content/menos.sqlite`를 임의 데이터 변경용으로 사용하지 않는다. Editor 구현에 필요한 스키마/fixture 검증은 격리 복사본을 우선 사용한다.
- 삭제/대규모 Asset 변경 금지.
- Commit / Push 금지.
- 예상 밖 변경 발견 시 HOLD.
- 수정 후 scoped diff 및 `git diff --check` 확인.

## 검증
- CODE VERIFIED: 실제 Content Editor → BGM Editor → Repository/Validator 호출 경로 확인.
- BUILD VERIFIED: Godot headless/editor build 또는 기존 프로젝트 build 경로 확인.
- EDITOR VERIFIED: 가능한 경우 실제 Godot Editor에서 BGM 메뉴 진입 및 Pilot 목록 확인.
- PIE VERIFIED: Master가 직접 관찰해야 하므로 세라는 자동화/GUI smoke 결과를 PIE VERIFIED로 표시하지 않는다.
- 기존 BGM 4-context runtime/validator smoke 회귀 확인.

## 보고
`D:\\Atlas\\projects\\menos\\state\\COPILOT_TO_MARIE.md`에 새 섹션으로 추가.
반드시 STATUS, 시작/종료 HEAD, Branch, Working Tree, 변경 파일, 구현 범위, 검증 결과(CODE/BUILD/EDITOR/PIE), diff-check, 기존 변경 보존 여부, UNVERIFIED, OUT OF SCOPE, 세라 기술 판단, 다음 결정 필요사항을 기록.

## 종료
최소 구현과 검증이 성공하면 STOP. 추가 BGM 확장, Commit/Push, 다른 Content Editor 메뉴 구현은 하지 않는다.

# COPILOT → MARIE

## 작업 결과 전달 규칙

Copilot은 조사 결과만 기록합니다.
구현, 수정, 삭제, Commit, Push는 수행하지 않습니다.

### 상태 분류
- CONFIRMED
- HIGH CONFIDENCE
- INFERENCE
- UNVERIFIED

### 결과

현재 TASK-001 결과를 여기에 기록합니다.

각 발견사항은 다음 형식을 사용합니다.

#### [P0/P1/P2/P3] 제목
- 분류:
- 영역:
- 근거 문서:
- 관련 코드/데이터:
- 현재 동작:
- 기대 동작:
- 영향:
- 검증 상태:
- 최소 검증 방법:
- 추가 조사 필요:

## 문서/구현 불일치

없음 / 내용을 기록

## Runtime 검증 필요사항

없음 / 내용을 기록

## 정상 확인 영역

내용을 기록

## 작업 상태

PENDING / COMPLETE / HOLD

---

# TASK — Gameplay P1 독립 검증

## STATUS
UNVERIFIED — 정적 코드 경로 대조는 완료했으나, 원본 SQLite를 읽거나 격리 Runtime/Export 검증을 실행하지 않았습니다. 아래에서는 직접 확인한 구조적 동작과 현재 데이터에 의존하는 부분을 분리합니다.

## 기준선
- HEAD: `335f3800b111f45c1b246148d8b4b2a50ee092bb`
- Branch: `main`
- Working Tree: dirty. 시작 및 종료 시 기존 상태를 확인했으며 본 조사에서는 프로젝트 코드·Scene·Asset·JSON·SQLite와 기존 변경을 수정·삭제·되돌리지 않았습니다.
- 조사 시점: 2026-10-08 15:35 KST
- 사용한 격리 데이터/환경: 없음. 원본 `godot/content/menos.sqlite`를 열지 않았고 Godot Runtime, 테스트, Export를 실행하지 않았습니다. 기존 `state/CURRENT_STATE.md`의 승인 기록과 smoke 결과만 문서 근거로 참조했습니다.
- 변경 사항: 이 보고서만 작성했습니다. 해당 경로는 작성 전 이미 untracked 상태였습니다.

## P1-1 Reward Gold
- 판정: CONFIRMED — Stage Reward Gold가 Player Profile 값으로 저장되지만, 다음 Stage의 Tower 구매용 runtime Gold로 연결되지 않습니다.
- 검증 방법: `GameController`의 보상 지급, Stage 초기화, 다음 Stage 전환, Tower 구매 자금 경로를 정적으로 대조했습니다.
- CONFIRMED 사실:
  - `_grant_stage_reward()`는 `reward.gold`를 `player_profile.gold`에 더하고 `_save_robot_progression()`을 호출합니다.
  - `PlayerProfileRepository.save_profile()`은 해당 Profile을 SQLite의 `player_profile` 테이블에 저장합니다.
  - 다음 Stage 전환은 `reset_game()`을 호출하며 runtime `gold`를 해당 Stage의 `initial_gold`로 설정합니다.
  - Tower 구매는 `player_profile.gold`가 아닌 runtime `gold`를 검사하고 차감합니다.
  - 코드 전체에서 `player_profile.gold`를 읽어 runtime Tower economy로 반영하는 경로를 찾지 못했습니다.
- 재현 결과: Runtime 재현은 실행하지 않았습니다. 코드 경로상 Reward Gold가 `player_profile.gold`에만 증가하고, 다음 Stage의 runtime `gold`는 `initial_gold`로 초기화됩니다.
- 원인: Profile reward balance와 Stage runtime build balance 사이의 transfer/consumer 경로가 없습니다. 별도 영구 재화로 쓰는 소비 경로도 확인하지 못했습니다.
- Runtime 상태: 정적 코드 동작 CONFIRMED; 실제 화면·저장값 확인 UNVERIFIED.
- 변경 사항: 없음.

## P1-2 Player Profile 저장
- 판정: CONFIRMED — 저장 경로는 사용자 저장 영역이 아니라 Content SQLite입니다. Export 환경에서 저장·재실행 성공/실패 여부는 UNVERIFIED입니다.
- 검증 방법: `PlayerProfileRepository`의 DB 경로, open mode, table bootstrap, read/write 코드를 대조했습니다. Export 실행은 하지 않았습니다.
- CONFIRMED 사실:
  - `SQLITE_PATH`는 `res://content/menos.sqlite`이며 `load_profile()`과 `save_profile()` 모두 `read_only = false`로 DB를 엽니다.
  - `load_profile()`도 `_ensure_table()`을 호출하고 이 함수는 `CREATE TABLE IF NOT EXISTS`를 실행합니다.
  - 저장 데이터는 `player_profile` 테이블의 `raw_json`으로 기록됩니다.
  - `state/CURRENT_STATE.md`는 사용자 데이터와 Content DB 분리를 원칙으로 기록하고 있어 구현 구조와 문서상 경계가 일치하지 않습니다.
  - Profile이 Export PCK의 `res://` 경로에서 실제로 변경·재로드 가능한지는 검증하지 않았습니다. 저장이 실패한다고 단정하지 않습니다.
- 저장/재실행 결과: 실행하지 않아 UNVERIFIED.
- 원인 또는 구조: 사용자 진행 데이터를 Content DB 경로에 두고 쓰기 가능 모드로 연결한 구조입니다. Export writable 경로가 보장되는지 근거가 없습니다.
- Runtime 상태: 경로와 write-capable 설정은 코드상 CONFIRMED; Export persistence는 UNVERIFIED.
- 변경 사항: 없음. 원본 DB에 접속하지 않았습니다.

## P1-3 defeat_giant
- 판정: CONFIRMED — Runtime의 일반 Wave 종료 승리 분기에는 `defeat_giant` 목표 충족 여부 검사가 없습니다. 현재 Campaign 1 데이터가 이 경로를 악용하거나 잘못 구성했는지는 DATA DEPENDENT입니다.
- 검증 방법: Giant 사망 처리와 일반 `check_wave_clear()` Stage/Campaign 완료 분기를 대조했습니다. Runtime/fixture는 실행하지 않았습니다.
- CONFIRMED 사실:
  - Giant 처치는 Mission이 `defeat_giant`일 때 별도 `_complete_defeat_giant_mission()` 경로를 호출합니다.
  - 그러나 마지막 Encounter/Wave의 spawn queue가 비고 살아있는 Enemy가 없으면 `check_wave_clear()`가 Mission Type/목표 달성 상태를 확인하지 않은 채 Single 승리 또는 Campaign 보상·다음 Stage/최종 승리 경로로 진입합니다.
  - 따라서 유효한 `defeat_giant` Stage에서 Giant가 요구되는 전투 전에 모든 Wave를 소진할 수 있다면, Mission 목표와 무관하게 Stage가 완료될 수 있습니다.
  - Content Validator는 Mission Type 자체는 확인하지만 Mission Type과 Encounter 내 Giant 요구 구성을 대응해 검증하는 규칙은 확인되지 않았습니다.
- 재현 결과: 정적 분기 분석으로 조건부 완료 경로 확인. 실행 재현은 하지 않았습니다.
- 현재 Campaign 1 데이터와 시스템 규칙의 구분:
  - `state/CURRENT_STATE.md`는 Campaign 1 smoke에서 `stages=3`, `giant=true`, 최종 Victory를 기록합니다. smoke 테스트는 관찰된 각 Enemy에 직접 대량 피해를 적용합니다.
  - 이 기록은 해당 검증 시 Giant가 등장하고 처치되었음을 뒷받침하지만, 현재 수정 상태 DB의 실제 Mission Type/배치 또는 Giant 없이 조기 Stage 완료가 가능한지 확인하지는 않습니다.
  - Campaign 1 Production Acceptance 기록은 재심사하지 않았으며 승인 상태를 변경하지 않습니다.
- Runtime 상태: 시스템 분기 CONFIRMED; 현재 Campaign 데이터별 영향 UNVERIFIED.
- 변경 사항: 없음.

## P1-4 참조 검증
- 판정: CONFIRMED — Runtime fail-fast 검증에는 누락이 있으며, 잘못된 데이터가 fallback으로 진행되거나 적 생성 시점까지 지연될 수 있습니다. 현재 SQLite 데이터가 실제로 잘못됐는지는 DATA DEPENDENT입니다.
- 검증 방법: `StageLoader`, `MapLoader`, `ContentValidator`, `GameController` 로드·스폰 경로를 정적으로 대조했습니다. DB 접근과 fixture 실행은 하지 않았습니다.
- CONFIRMED 사실:
  - Runtime `StageLoader`는 Stage 구조, Mission/Reward resolve, Wave Group의 자료형/count/interval/lanes 배열 형태를 검사합니다.
  - Runtime `StageLoader`는 Wave의 Enemy ID가 Enemy Catalog에 존재하는지, `lanes` 항목이 Map의 유효 lane인지 검사하지 않습니다.
  - Editor `ContentValidator`는 Stage Wave의 Enemy ID 존재 여부를 검사하나, Group lane이 Map의 spawn/lane ID인지 대응 검증하는 코드는 확인되지 않았습니다.
  - `spawn_enemies()`는 유효하지 않은 요청 lane이면 다른 spawn point를 선택하는 fallback이 있습니다. 요청 값의 불일치가 fail-fast 되지 않습니다.
  - 잘못된 Enemy ID는 `enemy_definitions[entry.type]` 조회 시점까지 차단되지 않습니다.
  - `MapLoader`는 JSON 데이터 형식 일부는 검사하지만 Map 전용 전체 gameplay contract를 Runtime Stage load 전에 검증하지 않습니다. `load_stage_map()`이 실패하면 `_ready()`의 caller는 `build_first_battle_map()` fallback을 호출합니다. 따라서 Map load 실패가 항상 시작 전 명시적 차단을 뜻하지 않습니다.
  - 반면 Editor Validator는 Stage↔Map 로드 및 일부 Map 필드·Allied spawn 참조를 검사합니다. Editor validation coverage는 Runtime Loader coverage와 동일하지 않습니다.
- 잘못된 참조별 결과:
  - Enemy ID: Editor Validator는 미등록 ID를 오류로 기록; Runtime StageLoader는 미검증. 실제 spawn에서 정의를 직접 조회하므로 그 시점의 실행 오류 위험이 있습니다. 재현하지 않았습니다.
  - Lane ID: StageLoader와 Editor Validator 모두 Map 기준 lane 존재 여부 검증을 확인하지 못함; Runtime은 spawn point fallback 선택. 요청 lane과 다른 위치로 spawn할 수 있습니다.
  - Stage Map ID/경로: StageLoader는 비어 있지 않은 문자열인지 확인; 실제 Map resolve는 후속 `MapLoader`에서 수행. 로드 실패 시 caller의 기본 Map fallback이 있습니다. 현재 데이터 결과는 미검증.
  - Map spawn/lane 데이터 누락: Runtime Map parse는 일부 필드를 기본값으로 생략/초기화할 수 있습니다. `spawn_enemies()`는 `LANES`가 비면 반환하고 Wave는 실행 상태일 수 있어 진행 정체 위험이 있습니다. 실제 Map 레코드에서 그런 상태인지는 미확인입니다.
- Runtime 상태: 검증 격차/fallback 코드 CONFIRMED; 현재 Campaign 참조 오류 및 실행 영향 UNVERIFIED.
- 변경 사항: 없음.

## 추가 발견
- 없음. 범위 외 발견을 확장 조사하지 않았습니다.

## OUT OF SCOPE
- 문제 수정, Canon/경제 설계 결정, 실제 Campaign 1 데이터 재심사.
- 원본 SQLite 열기·복사·쓰기, Godot Runtime/Smoke/Export 실행, 테스트 데이터 생성.
- 본 작업지시의 네 항목 외 Gameplay 후보 조사.

## 세라의 기술 판단
- P1-1은 Profile reward value와 Stage purchase balance가 서로 다른 상태이며 연결 소비 경로가 없어 구조적 단절이 확인됩니다. Reward Gold가 의도적으로 비소비 영구 재화인지에 대한 문서 근거는 확인되지 않아 경제 설계 의도는 미확정입니다.
- P1-2는 실제 Profile Repository가 `res://content/menos.sqlite` 쓰기 가능 경로를 사용한다는 점까지 확인했습니다. 이는 사용자 저장/Content 정의 분리 원칙과 불일치하지만, Export 저장 성공 여부는 실험하지 않아 결론 내리지 않습니다.
- P1-3은 일반 Wave 종료 승리 경로가 Mission 목표 검사를 생략한다는 시스템 규칙 문제입니다. 기존 Campaign 1 smoke 및 Production Acceptance는 그대로 유효한 범위에서 존중하며, 해당 승인 기록만으로 모든 `defeat_giant` 데이터 조합의 동작을 일반화하지 않습니다.
- P1-4는 Editor Validator가 일부 참조를 검사해도 Runtime Loader에서 같은 검증을 보장하지 않으며, lane/map에 fallback이 있음을 확인했습니다. 현재 데이터의 건전성은 별도 읽기 전용 데이터 확인이 필요합니다.
- 위 결함 판정은 수정 승인이나 작업 단계 자동 진행을 의미하지 않습니다.

## HOLD 필요 여부
HOLD 불필요. 예상하지 못한 변경이나 원본 접근 위험은 발생하지 않았습니다. 요청된 코드/문서 경로를 정적으로 확인하고 기존 변경사항을 보존했습니다. 실제 DB/Export/Runtime 검증을 수행하지 않은 부분은 각 항목에 UNVERIFIED로 남겼습니다.

## Marie 검토 요청
- Reward Gold가 Stage build budget과 별도인 영구 재화인지, 별도라면 의도된 소비처가 있는지 확인해 주세요.
- Profile의 최종 저장 권한이 `user://`인지 Content DB인지 결정해 주세요. Export 검증을 승인하는 경우 원본과 분리된 격리 프로젝트/DB에서만 실행이 필요합니다.
- `defeat_giant` Mission의 목표 완료 조건을 모든 Stage에서 강제해야 하는지 확인해 주세요.
- 잘못된 Stage/Wave/Map 참조에 대해 Runtime 진입 실패를 요구할지, 명시적 fallback을 허용할지 확인해 주세요.
- 이 보고 이후에는 검토와 별도 지시를 기다립니다. 자동으로 수정 단계에 진입하지 않습니다.

## 작업 상태
COMPLETE — 독립 정적 검증과 결과 기록 완료. Runtime/격리 데이터 검증은 미실행이며 Marie 검토 대기.

---

# TASK — Gameplay P1 Implementation Result

## STATUS
HOLD — 승인된 P1-2/P1-3/P1-4 구현과 격리 검증은 완료했습니다. 다만 작업 종료 전 Working Tree 재확인에서 시작 기준 기록에 없던 `projects/menos/docs/SETTINGS_MENU_IMPLEMENTATION_SPEC.md` 수정과 `projects/menos/runtime_capture.png` 미추적 파일이 발견되어, 소유/유입 경위를 확인할 때까지 추가 정리와 후속 작업을 중단합니다. 해당 파일들은 Copilot이 수정·생성·삭제하지 않았습니다.

## 기준선
- 시작 및 종료 HEAD: `335f3800b111f45c1b246148d8b4b2a50ee092bb` (변경 없음)
- Branch: `main`
- Working Tree: dirty. 기존 SQLite, Map Editor, Settings, `CURRENT_STATE.md`, MK 변경을 보존했습니다. 종료 전 예상 밖으로 확인된 Settings spec 수정과 runtime capture 파일도 그대로 두었습니다.
- 조사/구현 시점: 2026-10-08
- 격리 프로젝트: `D:\Temp\menos-p1-validation-20261008`. 원본 프로젝트와 분리된 복사본에서 회귀 테스트와 Export를 실행했습니다. SQLite fixture 변경은 복사본에만 수행했습니다.
- 원본 `godot/content/menos.sqlite`: 이번 작업에서 쓰기 대상으로 열지 않았고 수정하지 않았습니다.
- Commit / Push: 수행하지 않음.

## 변경 파일
- `godot/scripts/player_profile_repository.gd`
- `godot/scripts/stage_loader.gd`
- `godot/scripts/stage_manager.gd`
- `godot/editor/content_validator.gd`
- `godot/game_controller.gd`
- `godot/tests/gameplay_p1_regression_smoke_test.gd` (격리 실행용 회귀 테스트)
- 이 보고서

## 구현 및 검증

### P1-2 — Profile 저장 경계
- Profile 신규 저장 위치를 `user://menos_campaign_robot_profile.json`으로 변경했습니다.
- 기존 `player_profile` 행은 사용자 파일이 없을 때만 read-only로 읽어 가져오며, 성공 시 사용자 저장소에 기록합니다. Content SQLite 쓰기는 제거했습니다.
- 격리 테스트에서 legacy import, Level/XP/Gold/progression/inventory 복원, 사용자 파일 저장·재로드, legacy 값 변경 후 재-import 방지, 손상 파일 보존, Profile 누락 처리를 확인했습니다.
- 별도 Godot 프로세스가 동일한 `user://` 저장 파일을 읽어 Level/XP/Gold/progression/inventory를 복원하는 항목도 테스트 코드에 포함했습니다.
- 결과: `P1_2_PROFILE_PERSISTENCE_PASS`, `P1_2_SEPARATE_PROCESS_PROFILE_PASS` 조건 포함 `GAMEPLAY_P1_REGRESSION_PASS` — exit code 0.

### P1-3 — `defeat_giant` 완료 게이트
- 최종 Wave가 끝났어도 Giant 목표가 완료되지 않았다면 Defeat/목표 실패로 정지시키며 Reward와 Stage 전환을 수행하지 않도록 했습니다.
- Giant 사망 완료 경로와 다른 Mission 완료 경로에 Stage 단위 중복 완료 방어를 추가했습니다.
- 격리 테스트에서 목표 미달 차단, Giant 처치 완료, 중복 처치 가드, `clear_encounters` 및 `defend_base` 회귀를 확인했습니다.
- 결과: `P1_3_GIANT_REQUIRED_PASS`, `P1_3_MISSION_REGRESSION_PASS`; 전체 회귀 스크립트 exit code 0.

### P1-4 — Gameplay 참조 fail-fast
- Runtime Stage Loader에서 Map resolve/필수 gameplay geometry, Enemy ID, Map lane, `defeat_giant` Stage의 Giant wave 구성을 검증하도록 했습니다.
- Campaign Stage 참조 정규화/중복/미해결/카탈로그 존재 여부를 확인하고 Campaign 진입 전에 해당 Stage들을 사전 로드 검증합니다.
- GameController의 잘못된 Stage/Map 데이터를 기본 전투 Map으로 대체하던 fallback을 제거하고 오류 화면 경로를 추가했습니다.
- Editor Content Validator는 Runtime과 공유하는 Stage 참조 검증 함수를 사용합니다.
- 격리 테스트에서 정상 `stage_01` 및 Campaign 사전 검증, Unknown Enemy/Lane/Map 거부를 확인했습니다.
- 결과: `P1_4_STAGE_REFERENCE_VALIDATION_PASS`; 전체 회귀 스크립트 exit code 0.

## 검증 상태
- CODE VERIFIED: PASS — Godot headless editor 초기화/스크립트 클래스 등록 성공. P1 regression 및 기존 Campaign 1, Combat Timing, Fixed Tower, Giant Runtime, Pilot HUD smoke가 모두 exit code 0으로 완료.
- BUILD VERIFIED: PASS — 격리 복사본에서 Windows Desktop `--export-debug` 성공, `p1-validation.exe` 생성 확인. 출력에는 Editor 내장 ICU 데이터 사용 경고가 있었으며 Export 실패는 없었습니다.
- EDITOR VERIFIED: UNVERIFIED — headless editor project scan/import만 성공. GUI 편집기에서 수동 확인하지 않았습니다.
- PIE VERIFIED: NOT VERIFIED — 실행하지 않았습니다.
- `git diff --check`: PASS — scoped 변경에 대해 exit code 0. 단, 새 보고서 및 회귀 테스트는 untracked 파일이므로 기본 `git diff --check`의 tracked-file 검사에 포함되지 않습니다.
- 일부 의도된 음성 fixture(손상 JSON, Unknown Enemy/Lane/Map, Giant 미달)는 `push_error` 로그를 출력하지만 테스트는 해당 입력 거부를 확인하고 정상 종료했습니다. 종료 시 일부 smoke에서 Godot ObjectDB/resource leak 경고가 관찰됐으며 테스트 exit code는 0입니다.

## Campaign 1 회귀
- 격리 복사본에서 `campaign_runtime_smoke_test.gd` 실행 결과: `CAMPAIGN_RUNTIME_SMOKE_PASS stages=3 giant=true impact_vfx=true`, exit code 0.
- 기존 Campaign 1 Production Acceptance는 재심사하지 않았습니다. 위 결과는 격리 smoke 회귀 증거이며 화면 관찰/PIE 증거가 아닙니다.

## 미변경 및 미검증
- P1-1 Reward Gold 경제 의미는 승인대로 변경하지 않았습니다. 다음 Stage 자금 연결이나 경제 규칙은 추가하지 않았습니다.
- 원본 DB를 대상으로 migration 실행, 배포된 제품의 실제 user-directory 쓰기, GUI Editor, PIE는 검증하지 않았습니다.
- `CURRENT_STATE.md` 및 발견된 외부 Working Tree 변경은 이 결과 저장 요청 범위에서 수정하지 않았습니다.
- Scope 밖: P2 작업, 추가 기능, 데이터/경제 정책 변경, 기존 변경사항 정리, Commit/Push.

## 세라의 기술 판단
- P1-2/P1-3/P1-4 최소 구현과 격리 회귀/Export 기준은 통과했습니다. 이는 GUI Editor/PIE 승인이나 Campaign 1 Production Acceptance 재승인을 뜻하지 않습니다.
- 예상 밖의 Settings spec 변경과 runtime capture 파일은 구현 결과와 인과관계가 확인되지 않아 결함으로 판정하지 않았고, 변경하지 않았습니다.
- 다음 단계는 해당 Working Tree 변경의 소유/유입 경위를 확인하고, 이 diff와 보고서를 검토한 뒤 별도 승인으로 결정해야 합니다. P2로 자동 진행하지 않습니다.

## 작업 상태
구현 및 격리 최소 검증 완료. HOLD 조건에 따라 보고 기록 후 정지; 추가 코드/데이터 변경 없음.

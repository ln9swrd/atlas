# SFX Production Pipeline — Source to MENOS Runtime

## 목적
원천 SFX를 생성 서비스 또는 사용 조건이 확인된 기존 Source에서 확보하고, Source 검사부터 Production Asset, SFX Definition, Runtime Binding, 검증까지 일관된 파이프라인으로 처리한다. 특정 Source 제공자나 생성 서비스는 Canon으로 고정하지 않는다.

## 범위
- SFX만 대상이다.
- BGM과 Voice는 별도 도메인으로 관리한다.
- Firefly는 사용할 수 있는 원천 음원 생성 선택지 중 하나이며, MENOS의 Runtime/Authoring 시스템은 Source 제공자와 독립적으로 유지한다.
- 현재 `ROBOT_LASER_FIRE` P0 pilot의 기록된 출처는 Firefly가 아니라 Freesound의 Daleonfire / `Laser2` (CC0)이다. 실제 Asset 출처와 변환 정보는 `godot/sound/ATTRIBUTION.md`를 기준으로 한다.

## 역할 분담
### Master
1. Marie가 제공한 SFX 제작 사양과, 생성 방식을 선택한 경우 해당 도구용 Prompt를 사용한다.
2. 승인된 생성 서비스에서 원천 WAV를 만들거나, 사용 조건이 확인된 Source 음원을 확보한다.
3. 지정된 Source 폴더에 원본을 보존한다.
4. 실제 청취를 통해 후보의 미학적 품질을 판단한다.
5. 최종 Production 승인 여부를 결정한다.

### Marie
- SFX 요구사항 및 제작 사양 정의
- Firefly Prompt 설계
- SFX 구조/정책 설계
- 기술 결과 분석 및 판정
- Master 청취 결과를 기준으로 후속 작업 판단

### Sera
- Source 파일 검사
- Audio Processing 실행
- Production Asset 생성
- Prompt/Provenance 기록
- Audio Asset 등록
- SFX Definition 등록
- Runtime Binding 구현
- Validator/Smoke Test 실행
- 변경 Diff 및 검증 결과 보고

Sera의 기술 판단은 PROPOSAL이며 Canon이 아니다. Commit/Push는 수행하지 않는다.

## 전체 파이프라인
Source 생성/확보 → Source 검사 → Audio Processing → Production WAV → Source/Prompt/Provenance Record → Audio Asset → SFX Definition → Runtime Binding → 게임 검증 → Master 청취 승인 → Production Lock

## Source Audio 원칙
원천 WAV는 불변 자료로 취급한다. Production 처리로 원본을 덮어쓰지 않는다.

권장 구조:
`godot/audio_source/sfx/<category>/`

Production Asset:
`godot/audio/sfx/<category>/`

Source와 Production을 명확히 분리한다.

## Authoring / Provenance
각 원천 SFX는 Prompt 및 생성 정보를 추적할 수 있어야 한다.
권장 Sidecar: `<audio>.prompt.md`
최소 기록:
- Asset ID
- Source Path
- Generation Tool
- Generation Model
- Generation Prompt
- Negative Prompt
- Generation Conditions
- Revision
- Source/License 상태
- Processing Revision
- Status

SFX는 이미지와 달리 Prompt만으로 최종 결과를 완전히 재현할 수 없으므로 Processing 과정도 기록한다.

## Audio Processing
Source를 직접 수정하지 않고 Production 복사본을 대상으로 필요한 처리만 수행한다.
- Trim
- Silence 제거
- Fade In/Out
- Normalize
- EQ
- Compression
- Pitch
- Sample Rate/Format 변환
모든 처리를 무조건 적용하지 않는다. SFX 종류에 따라 필요한 처리만 적용한다.
Processing Record에는 최소한 적용된 처리와 Revision을 기록한다.

## 품질 검증
### 기술 검증
Sera가 파일 형식, 샘플레이트, 채널, 길이, 무음 구간, Peak/RMS, Clipping, 주파수 특성, 비정상적인 tail, Production 적합성을 검사한다.
### 청취 검증
직접 청취를 통한 미학적 품질 판단은 Master가 수행한다. AI/자동 분석은 Master의 실제 청취 승인을 대체하지 않는다.

## Audio Asset과 SFX Definition 분리
Audio Asset은 실제 Production 음원을 의미한다.
SFX Definition은 게임 이벤트에서 해당 음원을 어떻게 사용할지 정의한다.
예: `AUDIO_SFX_ROBOT_LASER_FIRE_01` → 실제 음원 Asset, `ROBOT_LASER_FIRE` → SFX Definition
Definition에는 Category, Variants, Volume, Pitch Randomization, Concurrency, Priority, Bus, Spatial Mode, Loop Policy, Cooldown/Steal Policy 등을 포함할 수 있다.

## Variant와 Revision 구분
Variant는 동일한 SFX 이벤트에서 랜덤/상황별로 사용할 서로 다른 음원이다.
Revision은 동일 Asset 또는 Definition의 개선 버전이다.
둘을 혼용하지 않는다.

## SFX 재생 정책
확장 가능한 형태로 One Shot, Loop, Loop + Start, Loop + End를 지원한다.
Spatial Mode: UI/Screen, World, Attached.
전투 SFX의 동시 재생 폭주를 방지하기 위해 Concurrency, Priority, Steal Policy를 지원한다.

## Runtime 연결 원칙
Gameplay 코드는 실제 WAV 파일 경로를 직접 참조하지 않는다.
`Gameplay Event → SFX Binding → SFX Definition → Audio Asset → Audio Playback` 구조를 사용한다.
예: `Robot Attack → ROBOT_LASER_FIRE → Variant 선택 → SFX Bus 재생`
SFX가 없어도 Gameplay 자체가 중단되어서는 안 된다. Missing SFX는 Warning/Validation 대상으로 처리하고 Fail-safe로 Runtime을 계속한다.

## 기존 MENOS SFX 이관
현재 `game_controller.gd`의 `SFX_STREAMS`와 `play_sfx()` 기반 구조는 Legacy Source로 취급하고 단계적으로 SFX Definition/Binding 구조로 이관한다.
기존 Gameplay Timing과 판정은 변경하지 않는다.
현재 확인된 기존 SFX ID: ui_click, ui_confirm, ui_cancel, ui_error, tower_select, tower_build, enemy_spawn, wave_start.
이관은 기존 동작을 유지하면서 Definition/Runtime Adapter를 먼저 연결하고, 검증 후 Legacy 직접 참조를 제거하는 방식으로 수행한다.

## Coverage Validation
SFX Required Event와 실제 Definition을 비교할 수 있어야 한다.
검증 결과: Required SFX 수, Defined 수, Missing 수, Unused 수, Invalid Binding 수.
모든 Gameplay Event가 반드시 SFX를 가져야 하는 것은 아니다. Event별 Required / Optional / None 정책을 둘 수 있다.

## License / Provenance
외부 Source 또는 생성 서비스 사용 시 원천 출처와 사용 조건을 기록한다.
Production 전에는 License 상태를 확인한다.
`LICENSE_VERIFIED`와 `UNVERIFIED`를 구분한다.
생성 서비스의 정책이 변경될 수 있으므로 특정 서비스 사용을 MENOS Canon으로 고정하지 않는다.

## Production State
권장 상태: SOURCE, PROCESSING, TECH_VERIFIED, MASTER_REVIEW, APPROVED, PRODUCTION, DEPRECATED, UNVERIFIED.
TECH_VERIFIED는 기술 검증을 의미하며 Master 승인과 동일하지 않다.
Master 승인 이후에는 Production Lock을 적용하고, 변경이 필요하면 새 Revision으로 만든다.

## P0 Pilot
전체 SFX를 한 번에 제작하지 않는다.
첫 End-to-End Pilot은 `ROBOT_LASER_FIRE` 하나로 한다.
성공 조건:
1. Source WAV 확보 및 실제 출처/사용 조건 기록 (`ROBOT_LASER_FIRE` 현재 기록: Freesound / Daleonfire / CC0)
2. Source 검사 PASS
3. Production WAV 생성
4. Prompt/Provenance 기록
5. Audio Asset 등록
6. SFX Definition 등록
7. MENOS Runtime Binding
8. 기술 Smoke Test PASS
9. Master 실제 청취 승인
Pilot이 성공하면 동일 Pipeline을 나머지 SFX에 확장한다.

## 변경 안전성
- Source WAV는 덮어쓰지 않는다.
- 기존 Gameplay 판정/Timing은 변경하지 않는다.
- 기존 SFX는 단계적으로 이관한다.
- 변경 후 Diff를 확인한다.
- 관련 없는 문제는 수정하지 않는다.
- Commit/Push는 Master 승인 후 수행한다.

## 현재 구현 정합성

현재 코드 기준으로 SFX P0 기술/Authoring 기반은 구현되어 있다.
- SFX Definition / Repository / Loader / Validator / Runtime Adapter / Editor가 존재한다.
- ROBOT_LASER_FIRE P0 pilot과 기존 SFX Definition binding이 등록되어 있다.
- Content Editor SFX entry가 활성화되어 있다.
- Technical validation / Save / Reload / Delete / Runtime resolution smoke가 PASS 상태다.
- Master 청취 확인(소리 재생 여부): 2026-10-09 CONFIRMED — Master가 SFX, BGM, Voice 모두 소리가 난다고 확인했다.
- 음향 품질에 대한 Production Acceptance와 PIE에서의 audio 상태 전환 관찰은 별도 항목이며 UNVERIFIED다.
- Legacy direct-file SFX playback은 호환 경계로 유지되며 단계적 이관 대상이다
## 상태
STATUS — PROPOSAL
이 문서는 SFX 제작/Authoring/Runtime 연결 설계안이다. Canon 승인은 Master의 결정에 따른다.
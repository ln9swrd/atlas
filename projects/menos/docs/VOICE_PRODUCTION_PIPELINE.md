# MENOS Voice Production Pipeline

## 0. 현재 구현 상태

STATUS: PARTIAL IMPLEMENTATION / P0 PILOT APPROVED

이 문서의 초기 상태 선언(Voice Editor 및 Runtime 미구현)은 과거 계획 단계의 기록이며, 현재 상태로 사용하지 않는다. 2026-10-08 기록과 `state/CURRENT_STATE.md`에 따르면 Voice Definition/Repository/Loader/Validator/Runtime Adapter/Editor가 구현되어 있고 Content Editor의 VOICE 항목이 활성화되어 있다. SQLite에는 `voice_definitions` catalog가 있으며, `VOICE_PILOT_FACTION_01_ATTACK_01_KO`가 P0 파일럿으로 Master 승인되었다.

현재 승인 범위는 단일 P0 Voice 파일럿과 최소 Wave-start Runtime trigger에 한정된다. CODE/BUILD/EDITOR 검증 및 Master의 파일럿 승인 기록이 있으나, 이 문서의 최신 기록 기준 PIE 관찰은 별도로 VERIFIED 처리되지 않았다. 전체 Dialogue/Subtitle 아키텍처, 완전한 Dialogue → Voice → Subtitle/Presentation E2E 경로, Production Lock 및 전체 진영/캐릭터 확장은 완료된 것으로 간주하지 않는다.

본 문서에는 설계 제안과 후속 구현 기록이 함께 포함되어 있다. 초기 제안 및 역사적 상태는 현재 구현 상태보다 우선하지 않으며, 설계 제안은 Master 승인 전까지 Canon이 아니다. 기존 SFX/BGM Runtime 구현과 Voice의 승인 범위를 혼동하지 않는다.

## 0.1 P0 구현 원칙

Voice P0는 전체 캐릭터/진영 Voice를 한 번에 제작하지 않는다. 하나의 Dialogue를 대상으로 다음 End-to-End 경로를 먼저 검증한다.

`Dialogue ID → Voice Profile → Voice Asset → Voice Definition → Runtime Binding → Voice Playback → Subtitle/Dialogue Link`

Voice가 없어도 Gameplay가 중단되지 않는 Silent Fallback을 기본 정책으로 한다. Dialogue/Subtitle 자체와 Voice Asset을 분리하여 관리한다.

P0 최소 Definition 필드는 다음으로 제한한다.

- ID
- Dialogue ID
- Voice Profile ID
- Voice Asset
- Language
- Volume
- Bus
- Priority
- State

Intro/Outro, 고급 Spatial Audio, 복잡한 Queue/Concurrency, 다국어 전체 세트, Production Lock 등은 P1 이후로 둔다.


## 1. 목적

MENOS Voice의 생성, 관리, 등록, Runtime 적용을 위한 Production 파이프라인을 정의한다.

Voice는 SFX의 Gameplay Event나 BGM의 Game State/Faction Context와 달리 Script/Dialogue와 Voice Identity를 핵심 Authoring 기준으로 사용한다.

기본 흐름:
Script / Dialogue ID → Voice Profile → Generation Prompt / Conditions → Source Voice → Source Check → Processing → Voice Asset → Voice Definition → Runtime Binding → Subtitle / Localization Link → Master Listening Approval → Production Lock

본 문서는 설계 제안이며 Master 승인 전까지 Canon으로 승격하지 않는다.

## 2. 핵심 구조

Voice는 세 정보를 분리한다.

1. Script: 무엇을 말하는가.
2. Voice Profile: 누가 어떻게 말하는가.
3. Voice Asset: 실제 생성된 음원.

기본 관계:
Character/Faction → Voice Profile → Dialogue → Voice Asset → Voice Definition → Runtime Binding

Script와 Generation Prompt도 분리한다. Script는 발화 내용, Generation Prompt는 연기와 생성 조건을 정의한다.

## 3. 역할

### Master
- 제공된 Voice Prompt로 원본 음성을 생성한다.
- 원본 음성을 직접 청취한다.
- 캐릭터 목소리, 발음, 감정, 전달력, 일관성을 최종 판단한다.
- Production Approval과 Lock을 결정한다.

### Marie
- Voice 구조와 Authoring 기준을 설계한다.
- Character/Faction Voice Profile 기준을 설계한다.
- Script / Dialogue ID 정책을 정의한다.
- 생성 Prompt와 연기 기준을 작성한다.
- 기술 검증 기준을 정의하고 결과를 판정한다.

### Sera
- Source 검사
- Processing
- Prompt/Provenance 기록
- Voice Asset/Definition 등록
- Runtime Binding
- Subtitle/Dialogue 연결
- Validator/Smoke Test
- Diff 및 검증 결과 보고

Sera의 기술 판단은 PROPOSAL이며 Canon이 아니다. Commit/Push는 수행하지 않는다.

## 4. Source

Adobe Firefly Speech 등 Master가 승인한 생성 도구를 사용할 수 있다. 생성 도구는 MENOS Runtime과 독립적으로 유지한다.

특정 서비스나 모델을 영구적인 Canon으로 고정하지 않는다. 무료 이용 조건, 상업적 이용 조건, 모델별 제한은 실제 Production 시점에 다시 확인한다.

원본 Voice는 immutable Source로 취급한다.

권장:
godot/audio_source/voice/<faction_or_character>/

Production:
godot/audio/voice/<faction_or_character>/

Source와 Production을 분리하며 Source를 직접 수정하지 않는다.

## 5. Script / Dialogue ID

모든 발화는 고유 Dialogue ID를 가진다.

예:
DIALOGUE_FACTION_01_CHARACTER_01_ATTACK_01

권장 관계:
Dialogue ID → Script Text → Language → Voice Profile → Voice Asset

Script가 변경되면 기존 Voice Asset의 유효성을 재검토한다. 의미가 달라지는 변경은 단순 Asset Revision으로 숨기지 않는다.

## 6. Script 상태와 Freeze

권장 상태:
SCRIPT_DRAFT
SCRIPT_REVIEW
SCRIPT_APPROVED
SCRIPT_FROZEN

SCRIPT_FROZEN 이전의 Voice는 Production-ready로 취급하지 않는다.

Script 변경 시 기존 Voice Asset과 Subtitle/Localization의 영향 범위를 다시 검증한다.

## 7. Voice Profile

Voice Profile은 Voice Production의 1급 Authoring 정보다.

최소 정보:
- Voice Profile ID
- Character ID
- Faction ID
- Language / Locale
- Voice Type의 서술적 범위
- Tone
- Pitch Character
- Speaking Speed
- Energy
- Emotional Range
- Delivery Style
- Pronunciation Rules
- Special Speech Rules
- Generation Tool / Model
- Generation Conditions
- Revision
- Status

Voice Profile은 동일 Character의 여러 대사에서 일관성을 유지하기 위한 기준이다.

실존 인물의 Voice Clone을 사용할 경우 별도의 권리와 동의 검토가 필요하다.

## 8. 3 Faction Voice Domain

MENOS에 진영이 3개라면 Voice도 최소 3개의 Faction Voice Domain으로 관리할 수 있다.

Faction 01 → Character Voice Profiles → Dialogue
Faction 02 → Character Voice Profiles → Dialogue
Faction 03 → Character Voice Profiles → Dialogue

BGM의 3 Faction BGM Set과 달리 Voice는 단순히 3개 음원 묶음이 아니다.

실제 음성이 필요한 캐릭터 수만큼 Voice Profile이 존재할 수 있으므로 현재 단계에서 캐릭터 수를 임의로 확정하지 않는다.

## 9. Voice Category

필요에 따라 다음 Category를 지원한다.
- Character Dialogue
- Combat Bark
- Attack / Skill Call
- Hit / Damage Reaction
- Warning
- Tactical / Command
- Entrance / Exit
- Victory
- Defeat
- System / Narration

모든 Category를 반드시 제작하지 않는다. Event별 Required / Optional / None 정책을 둔다.

## 10. Prompt / Provenance

모든 생성 Voice는 Prompt와 생성 정보를 추적할 수 있어야 한다.

권장 Sidecar:
<audio>.prompt.md

Authoring Record:
- Asset ID
- Dialogue ID
- Character ID
- Faction ID
- Source Path
- Script Text
- Language
- Voice Profile ID
- Generation Tool
- Generation Model
- Generation Prompt
- Negative Prompt 또는 제한 조건
- Generation Conditions
- Revision
- Source / License Status
- Processing Revision
- Status

Prompt는 단순 설명문이 아니라 Authoring 정보다.

## 11. Voice Profile과 Generation Prompt

Voice Profile은 반복 사용되는 기본 음성 기준이고 Generation Prompt는 개별 대사의 상황과 연기를 보완한다.

예:
Voice Profile = 낮고 단단한 톤, 빠르지 않은 전달, 전투 지휘형
Dialogue Prompt = 공격 직전, 짧고 강한 명령형, 높은 전투 집중도, 과도한 비명 금지

이 구조로 같은 Character의 여러 대사를 일관되게 생성할 수 있다.

## 12. Pronunciation / Language

최소 다음을 관리한다.
- Language
- Locale
- Pronunciation Rule
- Proper Noun Pronunciation
- Acronym Pronunciation
- Number / Code Pronunciation
- Character / Robot Name Pronunciation

동일 Dialogue의 한국어/영어 등 언어별 Voice Asset을 별도로 관리할 수 있다.

언어별 Voice는 별도의 생성 및 검증 대상이다.

## 13. Voice Asset과 Voice Definition

Voice Asset은 실제 Production 음원이다.

예:
VOICE_ASSET_FACTION_01_CHARACTER_01_ATTACK_01_KO_01

Voice Definition은 게임에서 사용하는 방법을 정의한다.

예:
CHARACTER_01_ATTACK_BARK

Definition에는 필요에 따라 다음을 포함한다.
- ID
- Dialogue ID
- Character
- Faction
- Category
- Language
- Voice Asset
- Variant
- Volume
- Pitch
- Priority
- Bus
- Spatial Mode
- Concurrency
- Cooldown
- Interrupt Policy
- Subtitle Link
- Context
- Revision
- Approval Status
- Production Lock

Gameplay Code는 WAV 경로를 직접 참조하지 않는다.

## 14. Variant / Revision / Candidate

Variant는 동일 Dialogue/Event에서 선택할 서로 다른 음원이다.

Revision은 동일 Asset/Definition의 개선 버전이다.

Candidate는 생성 결과 중 아직 Production용으로 선택되지 않은 후보다.

권장 흐름:
CANDIDATE → Technical Check → Master Listening → SELECTED → Production

모든 생성 결과를 Variant로 등록하지 않는다.

## 15. Audio Processing

Source를 직접 수정하지 않고 Production 복사본에 필요한 처리만 적용한다.

가능한 처리:
- Trim
- Silence Removal
- Fade In / Fade Out
- Normalize / Loudness Adjustment
- EQ
- Compression
- De-noise
- De-click
- Sample Rate Conversion
- Format Conversion

모든 처리를 무조건 적용하지 않는다. Voice의 발음과 연기 특성을 손상시키는 과도한 Processing을 피한다.

Processing Record에는 실제 적용한 처리와 Revision을 기록한다.

## 16. Voice Timing

Gameplay Timing은 Voice 길이에 종속되지 않는다.

기본 구조:
Gameplay Event 발생 → Voice 재생 → Subtitle 표시 → Voice 종료

Voice가 길거나 짧아도 공격 판정, Damage, Wave, Victory/Defeat 상태가 Voice 때문에 지연되어서는 안 된다.

## 17. Subtitle / Dialogue Link

Voice가 존재하는 Dialogue는 필요에 따라 Subtitle과 연결한다.

권장:
Dialogue ID → Localization / Script → Voice Definition

Subtitle은 Voice 파일명을 직접 참조하지 않는다.

Voice Missing이 Subtitle 또는 Gameplay를 중단시켜서는 안 된다.

## 18. Runtime

권장 Runtime:
Gameplay / Dialogue Event → Voice Binding → Voice Definition → Voice Asset → Audio Playback

필요한 경우 Dialogue ID → Localization / Script → Subtitle을 별도로 연결한다.

Voice Asset이 없어도 Gameplay는 계속되어야 한다. Missing Voice는 Validation 및 Production 상태 문제로 처리한다.

## 19. Spatial Mode

필요에 따라:
- UI / Screen
- World
- Attached
- Narration

캐릭터 전투 대사는 Attached 또는 World, 전역 경고는 Screen 또는 World, 메뉴 Voice는 UI / Screen을 사용할 수 있다.

모든 Voice를 3D Spatial Audio로 만들 필요는 없다.

## 20. Concurrency / Interrupt

전투에서 Voice가 과도하게 겹치는 것을 방지하기 위해 필요에 따라:
- Priority
- Max Concurrent
- Cooldown
- Interruptible
- Interrupt Priority
- Steal Policy

를 지원한다.

중요한 Boss Warning이 일반 Combat Bark보다 높은 Priority를 가질 수 있다.

이 정책은 Gameplay 판정을 변경하지 않는다.

## 21. Audio Bus

Voice는 공통 Audio Core를 사용할 수 있지만 Authoring Definition은 분리한다.

필요한 경우 Voice Bus와 Voice Volume을 별도로 관리한다.

Mute/Pause 정책은 Audio Core와 일관되게 유지한다.

## 22. 기술 검증

Sera가 다음을 검사한다.
- 파일 존재
- Format
- Sample Rate
- Channels
- Duration
- Peak / Clipping
- Silence
- 비정상 Noise
- Asset Registration
- Definition Registration
- Dialogue ID Link
- Voice Profile Link
- Language Link
- Runtime Binding
- Subtitle Link
- Validator

## 23. Master 청취 검증

Master가 최종 판단한다.
- 캐릭터 적합성
- 발음
- 전달력
- 감정 표현
- 전투 상황 적합성
- 진영 정체성
- Character Voice 일관성
- 반복 청취 피로도
- 다른 Voice와의 충돌
- 실제 게임 적합성

기술 검증 PASS는 Master 청취 승인과 동일하지 않다.

## 24. Character Consistency Review

동일 Character의 Voice는 개별 파일 단위로만 평가하지 않는다.

검토:
- 음색 일관성
- Pitch 일관성
- Speaking Speed
- Accent / Pronunciation
- Emotion Range
- Energy Range

대표 Dialogue 묶음을 청취하여 Character Voice Identity를 확인한다.

## 25. Faction Consistency Review

진영 단위에서도 확인한다.
- 진영 내 Character 구분
- 공통적인 음성적 분위기
- 다른 진영과의 식별성
- Command / Warning 톤의 일관성

구체적인 진영 Voice Canon은 Master 승인 없이 확정하지 않는다.

## 26. Coverage Validator

Voice Validator는 최소 다음을 검사한다.
- Required Dialogue
- Defined Dialogue
- Missing Dialogue
- Unused Definition
- Missing Voice Asset
- Invalid Binding
- Missing Voice Profile
- Character / Faction mismatch
- Language mismatch
- Script mismatch
- Subtitle Link mismatch
- Duplicate Dialogue Binding
- Invalid Production State

Event별 Required / Optional / None을 지원한다.

Required Voice가 Missing이면 Production-ready로 취급하지 않는다. Optional Missing은 Warning과 Fail-safe로 처리할 수 있다.

## 27. License / Provenance

생성 도구, 모델, 생성 조건, 원본 위치, 사용 권한 상태를 기록한다.

상태 예:
LICENSE_VERIFIED
UNVERIFIED

특정 서비스의 무료/상업적 이용 조건은 영구적인 Canon으로 기록하지 않는다.

Partner/Third-party Voice Model은 해당 모델의 별도 이용 조건을 확인한다.

## 28. Production State

권장 상태:
SCRIPT_DRAFT
SCRIPT_REVIEW
SCRIPT_APPROVED
SCRIPT_FROZEN
SOURCE
PROCESSING
TECH_VERIFIED
MASTER_REVIEW
APPROVED
PRODUCTION
DEPRECATED
UNVERIFIED

기술 검증과 Master 승인은 별도 상태다.

Master 승인 후 Production Lock을 적용한다. Lock 이후 변경은 새로운 Revision으로 처리한다.

## 29. Production-ready 조건

다음이 모두 충족되어야 한다.
- Dialogue ID
- SCRIPT_FROZEN
- Character ID
- 필요한 경우 Faction ID
- Voice Profile
- Source
- Prompt / Provenance
- Language
- Voice Asset
- Voice Definition
- Runtime Binding
- License 상태
- Technical Verification PASS
- Master Listening Approval
- Production Lock

핵심 항목이 누락되면 Production-ready로 취급하지 않는다.

## 30. Fail-safe

다음 상황에서도 Gameplay는 계속되어야 한다.
- Voice Asset Missing
- Voice Definition Missing
- Audio Load Failure
- Voice Playback Failure
- Subtitle Missing
- Optional Localization Missing

정책에 따라 Voice Missing → Subtitle 유지 → Gameplay 계속 또는 Silent Fallback → Gameplay 계속을 사용한다.

Required Voice의 누락은 Runtime 중단이 아니라 Validation/Production 상태의 문제다.

## 31. Legacy Migration

기존 Gameplay Code에 Voice 직접 재생이 존재하면 Legacy Source로 식별한다.

이관:
1. 기존 Gameplay Timing 유지
2. 기존 판정 유지
3. Dialogue ID / Voice Definition 도입
4. Runtime Adapter 연결
5. Smoke Test
6. Legacy 직접 참조 제거

Legacy 제거 전 기존과 신규의 동작 차이를 확인한다.

## 32. P0 Pilot

전체 Voice를 한 번에 제작하지 않는다.

P0는 하나의 Character와 하나의 Dialogue로 End-to-End 검증한다.

예:
FACTION_01 / CHARACTER_01 / DIALOGUE_01

검증:
Script → Voice Profile → Generation Prompt → Source Voice → Source Check → Processing → Prompt/Provenance → Voice Asset → Voice Definition → Runtime Binding → Subtitle / Dialogue Link → Technical Smoke Test → Master Listening → Production Lock

P0 성공은 전체 Voice Production 승인이나 모든 Character Voice 승인을 의미하지 않는다.

## 33. SFX / BGM과의 차이

SFX:
Gameplay Event → SFX Binding → SFX Definition → Audio Asset

BGM:
Game State / Faction / Context → BGM Binding → BGM Definition → Track

Voice:
Dialogue / Gameplay Event → Voice Binding → Voice Definition → Voice Asset

Voice에는 추가로 Script → Voice Profile → Generation이라는 Authoring 계층이 존재한다.

공통 Audio Core를 사용할 수 있지만 Definition, Validator, Authoring 정책은 분리한다.

## 34. Master 승인 단위

Voice는 파일 하나만 승인하는 것보다:
1. Voice Profile 확인
2. 대표 Dialogue 청취
3. Character 단위 일관성 확인
4. 필요한 경우 Faction 단위 비교
5. Production 승인

순으로 검토하는 것이 적절하다.

개별 파일의 Technical PASS만으로 Character Voice를 Canon으로 확정하지 않는다.

## 35. 변경 안전성

- Source Voice를 덮어쓰지 않는다.
- Script 변경을 숨기기 위해 기존 Voice Asset을 무단 재사용하지 않는다.
- Voice Profile 변경 시 영향 범위를 확인한다.
- Production Asset 변경 후 Diff와 등록 상태를 확인한다.
- Gameplay Timing과 판정을 변경하지 않는다.
- 관련 없는 문제는 수정하지 않는다.
- 삭제/덮어쓰기/대규모 Asset 변환은 Master 승인 없이 수행하지 않는다.
- Commit/Push는 Master 승인 후 수행한다.

## 36. 범위 제한

본 문서는 Voice Production Pipeline 설계에 한정한다.

현재 확정하지 않는 항목:
- 실제 3개 Faction의 Voice Character 목록
- Character별 Voice Personality Canon
- 실제 Script 문구
- 실제 Voice Profile 값
- 특정 생성 서비스의 영구 사용
- Voice Actor 또는 실존 인물 Voice Clone 사용
- 전체 Voice 제작 수량

이 항목은 실제 게임 기획과 Master 승인을 통해 확정한다.

## 37. 현실성 판단

TECHNICALLY POSSIBLE:
- Prompt 기반 Voice 생성
- WAV Source 확보
- Voice Profile 기반 관리
- Dialogue ID 연결
- Runtime Binding
- Subtitle 연동
- Validator
- Production Lock

PRACTICALLY FEASIBLE:
- SFX/BGM과 동일한 Source/Production/Definition 분리
- 3 Faction Voice Domain
- Character별 Voice Profile
- P0 Pilot 후 단계적 확장

RECOMMENDED:
- Script Freeze 후 Voice Production
- Voice Profile을 1급 Authoring 정보로 관리
- Candidate와 Variant 분리
- Character 단위 청취 검증
- Dialogue ID 중심 Runtime Binding
- Voice Missing Fail-safe

BUSINESS VIABLE:
- 생성 서비스의 실제 이용권/상업 이용 조건을 Production 시점에 확인한다.
- 특정 무료 정책을 프로젝트 Canon으로 고정하지 않는다.

## 38. 설계안의 권한 및 현재 상태 참조

이 절과 앞선 설계 절은 Production / Authoring / Runtime 연결의 설계 기준과 제안을 기록한다. 이 절의 `STATUS: PROPOSAL`은 설계 제안의 권한 상태를 뜻하며, Voice 기능 전체가 미구현이라는 의미가 아니다.

현재 구현 및 승인 상태는 본 문서의 `## 0. 현재 구현 상태`와 그 뒤에 추가된 날짜별 진행 기록을 기준으로 판단한다. 날짜별 기록이 설계 제안과 충돌하면 실제 확인된 구현 상태 및 Master 승인 범위를 우선하며, 미승인 제안은 Canon이 아니다.

PROPOSAL ≠ CANON


## 22. 2026-10-08 P0 Technical Foundation Progress

The previously proposed Voice P0 path has now been implemented through the technical authoring/runtime foundation.

CONFIRMED:
- Voice Definition, Loader, Repository, Validator, Runtime Adapter, and Voice Editor are implemented.
- Content Editor VOICE entry is enabled.
- SQLite voice_definitions catalog exists with one Draft pilot.
- Missing Voice Asset is non-blocking and resolves through Silent Fallback.
- Background smoke tests for validation, repository persistence, runtime fallback, editor entry, and Content Editor entry PASS.

UNVERIFIED:
- Actual Voice Asset generation/source approval.
- Actual playback/listening.
- PIE verification.
- Production Acceptance / Production Lock.

DECISION GATE:
Master must provide or approve the first Voice Asset and approve its performance before further Voice content expansion.

PROPOSAL:
Do not expand Voice to all three Factions, multiple characters, or multiple languages until the single pilot is accepted. Keep generation-tool choice non-Canon and re-check current commercial/usage terms at the time of actual production.


## 23. 2026-10-08 P0 Asset Progress

CONFIRMED:
- Master approved continuation at the P0 Voice asset decision gate.
- Pilot asset `godot/sound/VOICE_PILOT_FACTION_01_ATTACK_01_KO.wav` exists and is linked by the pilot Voice Definition.
- Technical inspection: 22.05 kHz, mono, 16-bit PCM, 1.242 s, peak 0.3929, RMS 0.0429, no clipping samples detected.
- Background validation, repository, runtime fallback, editor entry, and Content Editor entry smoke tests PASS.
- The local source/tool evidence is `D:\Atlas\_ppaso_voice`; its README describes a Korean single-speaker TTS model and its repository LICENSE is Apache 2.0.

UNVERIFIED:
- Exact generation command.
- Exact script text used for the pilot.
- Exact generation prompt/conditions.
- Master listening, pronunciation, acting, character suitability, PIE playback, Production Acceptance, and Production Lock.

DECISION GATE:
Master listening of the actual pilot asset.

PROPOSAL:
- Do not expand Voice coverage before the pilot is accepted.
- Before generating the next asset, record Script Text, Voice Profile, Generation Tool/Model, Generation Prompt, Conditions, and source revision in a sidecar/provenance record.
- After pilot acceptance, verify one actual Dialogue → Voice → Subtitle/Dialogue runtime path before scaling content.


## 24. 2026-10-08 Runtime Asset Verification Progress

CONFIRMED:
- Godot 4.7.2 reimported `VOICE_PILOT_FACTION_01_ATTACK_01_KO.wav` successfully and produced the corresponding import metadata.

## 25. 2026-10-08 Minimum Runtime Integration Progress

- Confirmed actual SQLite `voice_definitions` catalog contains `VOICE_PILOT_FACTION_01_ATTACK_01_KO` and resolves `res://sound/VOICE_PILOT_FACTION_01_ATTACK_01_KO.wav`.
- Added the minimum gameplay Runtime path: `GameController.start_wave()` invokes the Voice pilot once through `VoiceDefinitionRepository` → `VoiceRuntimeAdapter` → `AudioStreamPlayer`.
- Added `godot/tests/voice_runtime_integration_smoke_test.gd`; headless integration verification PASS against the actual `start_wave()` path.
- This is a pilot runtime trigger, not a finalized Dialogue/Subtitle architecture.
- PIE / human listening / Production Acceptance remain UNVERIFIED.
- The actual project resource now loads as an `AudioStream` with duration 1.24226757369615 seconds.
- A temporary background runtime check created an `AudioStreamPlayer`, entered it into the scene tree, invoked `play()`, and completed without a runtime load/play API failure.
- Existing Voice validation, repository, editor-entry, and Content Editor smoke tests remain PASS.

LIMITATION:
- Headless runtime playback verifies resource loading and playback invocation, not human auditory quality or physical speaker output.
- PIE VERIFIED remains UNVERIFIED until the actual game is run and the Master observes the result.

DECISION GATE:
Actual Master listening / PIE observation remains the minimum remaining Voice acceptance check.

PROPOSAL:
- Keep the pilot as the sole Voice production candidate until acceptance.
- After acceptance, add exactly one Dialogue -> Voice -> subtitle/runtime presentation E2E case before expanding Voice coverage.


## 26. 2026-10-08 Voice P0 Master Approval

CONFIRMED:
- Master approved the actual Voice P0 pilot asset `VOICE_PILOT_FACTION_01_ATTACK_01_KO`.
- The pilot is now an APPROVED Production Candidate for the current Voice P0 scope.
- The approval does not expand Voice coverage, establish a full Dialogue/Subtitle architecture, or define the complete 3-Faction Voice set.
- Existing technical/runtime integration remains the approved minimum implementation path.

VERIFICATION STATUS:
- CODE VERIFIED — Voice Definition/Repository/Runtime Adapter and the minimum Wave-start trigger are implemented and smoke-tested.
- BUILD VERIFIED — project/export validation completed successfully.
- EDITOR VERIFIED — Voice Editor and Content Editor Voice entry validated in background.
- PIE VERIFIED — not independently promoted from automated/background verification.
- Master Voice Approval — APPROVED for the P0 pilot candidate.

PRODUCTION BOUNDARY:
- Keep the current pilot as the sole approved Voice candidate until a new Master decision expands scope.
- Do not generate additional Voice assets automatically.
- Do not introduce full Dialogue/Subtitle architecture automatically.
- Production Lock and broader Voice coverage remain separate future decisions.

PROPOSAL:
- When Voice work resumes, first establish one authoritative Dialogue record and its exact script/provenance, then verify one Dialogue → Voice → Subtitle/Presentation E2E path.
- Record exact Script Text, Voice Profile, Generation Tool/Model, Generation Prompt, Conditions, and source revision before producing additional assets.

STATUS: PASS — Voice P0 pilot approved; scope remains locked.

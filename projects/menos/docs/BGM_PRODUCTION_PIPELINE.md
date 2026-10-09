# MENOS BGM Production Pipeline

## 1. 목적

MENOS의 BGM을 생성·관리·등록·런타임 적용하기 위한 Production 파이프라인을 정의한다.

BGM은 SFX와 달리 개별 Gameplay Event보다 Game State / Faction / Context를 중심으로 운용한다.

기본 흐름:

Firefly Source → Source Check → Processing → Prompt/Provenance → BGM Asset → BGM Definition → Runtime Binding → Master Listening Approval → Validator

본 문서는 현재 설계 제안이며 Master 승인 전까지 Canon으로 승격하지 않는다.

## 2. 역할

### Master

- 제공된 BGM 생성 Prompt를 사용하여 원본 음악을 생성한다.
- 생성된 원본 파일을 저장한다.
- 원본 음악을 직접 청취하여 사용 적합성을 판단한다.
- 최종 Approval 및 Production 전환을 결정한다.

### Marie

- BGM 구조와 Authoring 기준을 설계한다.
- 생성 Prompt를 작성한다.
- 기술 검증 기준을 정의하고 결과를 판정한다.
- 진영별 BGM Set 및 Context 구조를 관리한다.

### Sera

- 원본 파일의 기술 상태를 검사한다.
- Processing, Asset 등록, Definition 등록, Runtime Binding, Validator를 수행한다.
- 기술 판단은 PROPOSAL이며 Canon이 아니다.

## 3. Source

사용자가 Adobe Firefly 등 승인된 생성 도구에서 Prompt를 사용하여 원본 음악을 생성한다.

원본 파일은 다음 원칙을 따른다.

- Source는 immutable로 취급한다.
- Production용 변환 파일과 분리한다.
- 원본을 직접 수정하지 않는다.
- 재생성은 기존 Revision을 덮어쓰지 않고 새로운 Revision으로 관리한다.

권장 구조:

godot/audio_source/bgm/<faction_or_category>/

Production 파일:

godot/audio/bgm/<faction_or_category>/

## 4. Prompt / Provenance

모든 생성 BGM은 생성 Prompt를 관리해야 한다.

권장 Sidecar:

<track>.prompt.md

Authoring Record:

- Asset ID
- Source Path
- Generation Tool
- Generation Model
- Generation Prompt
- Negative Prompt
- Generation Conditions
- Revision
- Source / License Status
- Processing Revision
- Status

Prompt는 재현성을 위한 Authoring 정보이며 단순 설명문이 아니다.

Prompt 변경은 Revision 증가로 처리한다.

## 5. BGM Asset과 BGM Definition 분리

### BGM Asset

실제 음원 파일이다.

예:

BGM_FACTION_01_COMBAT_01

### BGM Definition

음원을 어떤 게임 상태에서 어떻게 사용할지 정의한다.

예:

FACTION_01_COMBAT

Definition에는 최소 다음 정보를 가질 수 있다.

- ID
- Faction
- Context
- Audio Asset
- Intro / Loop / Outro
- Loop Point
- Duration
- BPM / Tempo metadata
- Transition / Crossfade
- Volume
- Bus
- Priority
- Variant
- State
- Revision
- Approval Status
- Production Lock

음원 파일 경로를 Gameplay Code에 직접 하드코딩하지 않는다.

## 6. Faction BGM Set

MENOS의 진영이 3개라면 BGM은 기본적으로 **3개의 Faction BGM Set**을 갖는다.

구조:

Faction 01 BGM Set
- Normal / Stage
- Combat / Tension
- Boss
- Victory
- Defeat

Faction 02 BGM Set
- Normal / Stage
- Combat / Tension
- Boss
- Victory
- Defeat

Faction 03 BGM Set
- Normal / Stage
- Combat / Tension
- Boss
- Victory
- Defeat

따라서 기본 설계상 최소:

3 Factions × 5 Contexts = 15개의 BGM Context

이다.

단, Context 수는 실제 게임 요구사항에 따라 증가할 수 있다.

## 7. Faction 음악 정체성

3개 진영은 단순히 서로 다른 곡을 사용하는 것이 아니라 각 Faction BGM Set에 일관된 음악적 정체성을 부여한다.

각 Faction Set의 Prompt에는 필요에 따라 다음 요소를 고정한다.

- Genre / Style
- Instrumentation
- Rhythm
- Tempo
- Harmonic Character
- Mood
- Energy Level
- Texture
- Production Character

이 기준은 개별 곡의 복제가 아니라 같은 진영에 속한 BGM 사이의 일관성을 확보하기 위한 것이다.

## 8. Runtime 구조

권장 Runtime 흐름:

Game State / Faction
→ BGM Binding
→ BGM Definition
→ Track / Segment
→ Audio Playback

예:

FACTION_01 + COMBAT
→ FACTION_01_COMBAT
→ BGM_FACTION_01_COMBAT_01
→ Audio Playback

Gameplay Logic은 특정 WAV/OGG 파일을 직접 호출하지 않는다.

## 9. Context Transition

대표적인 전환:

Normal → Combat
Combat → Boss
Boss → Victory
Boss → Defeat

필요한 경우 Intro / Loop / Outro 또는 Crossfade를 사용한다.

BGM 전환 실패가 Gameplay 자체를 중단해서는 안 된다.

Missing BGM은 Fail-safe 정책에 따라 무음 또는 기본 대체 BGM으로 처리한다.

## 10. Processing

필요한 경우 Production 음원에만 다음 처리를 적용한다.

- Trim
- Silence Removal
- Fade In / Fade Out
- Normalize / Loudness Adjustment
- EQ
- Compression
- Sample Rate / Format Conversion
- Loop Point Preparation
- Intro / Loop / Outro 분리

Processing은 원본 Source를 변경하지 않는다.

과도한 Processing은 금지하며 목적에 필요한 최소 처리만 수행한다.

## 11. 기술 검증과 청취 검증

Sera가 수행하는 기술 검증:

- 파일 존재
- 포맷
- Sample Rate
- Channels
- Duration
- Peak / Clipping
- Silence
- Loop Point
- Asset Registration
- Definition Registration
- Runtime Binding
- Validator

Master가 수행하는 최종 청취 검증:

- 실제 음악성
- 게임 분위기 적합성
- 진영 정체성
- 반복 청취 피로도
- 전환 자연스러움
- 최종 사용 승인

기술 검증 PASS는 Master 청취 승인과 동일하지 않다.

## 12. Variant와 Revision

Variant와 Revision을 구분한다.

Variant:
- 동일 Context를 위한 서로 다른 음원
- 예: FACTION_01_COMBAT_01 / _02 / _03

Revision:
- 동일 음원의 개선 또는 수정 버전
- 예: FACTION_01_COMBAT_01 Rev.2

Revision 변경은 기존 Production 파일을 무단 교체하지 않는다.

## 13. License / Provenance

생성 도구, 생성 조건, 원본 위치, 사용 권한 상태를 기록한다.

상태 예:

- LICENSE_VERIFIED
- UNVERIFIED

서비스의 무료/상업적 이용 조건은 영구적인 Canon으로 기록하지 않는다. 실제 Production 시점의 서비스 정책을 확인한다.

## 14. Production State

권장 상태:

SOURCE
PROCESSING
TECH_VERIFIED
MASTER_REVIEW
APPROVED
PRODUCTION
DEPRECATED
UNVERIFIED

Master 승인 후 Production Lock을 적용한다.

Production Lock 이후 변경은 새로운 Revision으로 처리한다.

## 15. Coverage Validator

BGM Validator는 최소 다음을 검사한다.

- Required Context
- Defined Context
- Missing Context
- Unused Definition
- Invalid Binding
- Missing Asset
- Invalid Asset
- Faction Set completeness

예:

Required:
FACTION_01 / COMBAT

Defined:
FACTION_01 / COMBAT

Result:
PASS

진영의 필수 BGM Context가 누락되면 Production-ready 상태로 취급하지 않는다.

## 16. SFX와의 차이

SFX:
Gameplay Event 중심
→ Event → SFX Binding → SFX Definition → Audio Asset

BGM:
Game State / Faction / Context 중심
→ State/Faction → BGM Binding → BGM Definition → Track

두 시스템은 공통 Audio Core를 사용할 수 있지만 Authoring Definition과 Runtime 정책은 분리한다.

## 17. P0 Pilot

첫 구현은 전체 15개를 한 번에 제작하지 않는다.

P0는 한 개 Faction의 대표 Context 하나로 End-to-End 검증한다.

예:

FACTION_01 / COMBAT

검증:

Firefly Source
→ Source Check
→ Processing
→ Prompt/Provenance
→ BGM Asset
→ BGM Definition
→ Runtime Binding
→ Master Listening
→ Validator

P0 성공은 전체 BGM Production 승인이나 15개 전체 제작 승인을 의미하지 않는다.

## 18. 범위 제한

본 문서는 BGM에 한정한다.

SFX 및 VOICE의 구현을 자동으로 시작하지 않는다.

새로운 Faction, Context, 음악적 Canon은 Master 승인 없이 확정하지 않는다.

## 19. 현재 구현 정합성

현재 코드 기준으로 BGM 기술 기반은 구현되어 있다.
- BGM Definition / Repository / Loader / Validator / Runtime Controller / Editor가 존재한다.
- Faction 01의 Normal / Combat / Victory / Defeat pilot binding이 등록되어 있다.
- GameController의 Run State → BGM Context binding이 구현되어 있다.
- BGM Runtime Controller 및 Definition/Adapter validation은 PASS 상태다.
- Master 실제 청취(소리 재생 여부): 2026-10-09 CONFIRMED. 음악적 적합성에 대한 Production Acceptance 및 PIE에서의 상태 전환 관찰은 별도 항목이며 UNVERIFIED다.
- Definition의 crossfade 필드는 존재하지만 실제 crossfade playback은 현재 구현되지 않았다
## 20. 상태

STATUS: PROPOSAL

현재 문서는 BGM Production Pipeline과 3-Faction BGM Set 구조를 기록한다.

PROPOSAL ≠ CANON

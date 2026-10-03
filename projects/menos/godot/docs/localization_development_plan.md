# MENOS 다국어 메시지 외부화 개발계획

## 1. 목적

현재 MENOS 프로젝트의 사용자 표시 메시지는 다수의 GDScript에 문자열 리터럴로 직접 작성되어 있다. 다국어 지원을 위해 메시지 자체를 코드에서 분리하고, 언어별 저장소에서 로드하는 구조로 전환한다.

현재 지원 언어는 다음 2개로 한정한다.

- `ko` — 한국어
- `en` — 영어

본 계획의 목적은 한국어/영어를 안정적으로 지원하면서 향후 다른 언어를 추가할 때 GDScript 수정이 필요하지 않은 구조를 만드는 것이다.

## 2. 범위

### 포함

- 게임 런타임의 사용자 표시 메시지
- Editor의 사용자 표시 메시지
- 버튼/Label/Dialog/Tooltip/상태 메시지
- 로그 중 사용자에게 표시되는 텍스트
- 오류/경고/검증 결과 메시지
- 문자열 포맷 파라미터가 포함된 메시지
- 현재 언어 선택 및 변경
- 언어별 메시지 저장소
- 메시지 키 누락/중복/포맷 오류 검증
- 기본 언어 fallback 정책

### 제외

- Sprite/Asset 파일명
- 내부 ID, enum, 코드 식별자
- JSON의 schema key
- 이벤트 타입/상태값
- 경로와 리소스 식별자
- 개발자 전용 디버그 출력의 자동 번역
- 번역 품질 자체의 검수
- 현재 범위에 없는 제3언어 추가

## 3. 현재 상태 조사

**CONFIRMED**

현재 프로젝트에는 독립적인 localization repository 또는 `ko`/`en` 메시지 저장소가 존재하지 않는다.

사용자 표시 문자열이 여러 GDScript에 직접 존재하며, `image_editor.gd`에는 Catalog Editor UI, 상태 메시지, 오류 메시지 등이 직접 작성되어 있다. `game_controller.gd`에도 런타임 로그와 사용자 표시 문자열이 직접 존재한다. 다른 Editor 스크립트에도 동일한 패턴이 확인된다.

따라서 파일별로 문자열을 각각 외부화하는 방식보다 공통 localization access layer를 만드는 것이 필요하다.

## 4. 목표 구조

```text
content/
  localization/
    ko.json
    en.json

scripts/
  localization_repository.gd
```

실제 파일명과 경로는 구현 단계에서 기존 프로젝트의 content/settings 구조와 충돌하지 않는지 확인 후 확정한다.

언어별 JSON은 메시지의 물리적 권위(authority)가 된다.

예시:

```json
{
  "common.ok": "확인",
  "common.cancel": "취소",
  "image_editor.catalog_editor": "카탈로그 에디터",
  "image_editor.source_image": "소스 이미지",
  "image_editor.select_source_first": "먼저 소스 이미지 또는 Asset을 선택하세요.",
  "runtime.not_enough_energy": "ENERGY가 부족합니다."
}
```

영어 파일은 동일한 key set을 유지한다.

```json
{
  "common.ok": "OK",
  "common.cancel": "Cancel",
  "image_editor.catalog_editor": "Catalog Editor",
  "image_editor.source_image": "Source Image",
  "image_editor.select_source_first": "Select a source image or asset first.",
  "runtime.not_enough_energy": "Not enough ENERGY."
}
```

## 5. LocalizationRepository 설계

새로운 공통 접근 계층을 만든다.

권장 API:

```gdscript
LocalizationRepository.get("common.ok")
LocalizationRepository.get("image_editor.source_image")
LocalizationRepository.get("runtime.not_enough_energy", {"skill": skill_name})
LocalizationRepository.set_locale("ko")
LocalizationRepository.get_locale()
LocalizationRepository.reload()
```

역할:

1. 현재 locale 결정
2. locale JSON 로드
3. 메시지 key 조회
4. 포맷 파라미터 적용
5. 누락 key 처리
6. fallback 처리
7. 캐시 관리
8. locale 변경 시 갱신 신호 제공

코드는 직접 JSON을 읽지 않고 반드시 `LocalizationRepository`를 통해 메시지를 요청한다.

## 6. Locale 결정 정책

우선순위는 다음과 같이 한다.

1. 사용자가 저장한 언어 설정
2. 프로젝트 기본 언어
3. `en` fallback

초기 구현에서는 `ko`와 `en`만 허용한다.

권장 기본값은 기존 프로젝트의 실제 UI 정책을 조사한 뒤 확정하며, 임의로 Canon으로 고정하지 않는다.

사용자 설정 저장소는 기존 `SettingsManager`와 통합한다. 별도의 언어 설정 저장소를 추가하여 동일한 설정을 이중 관리하지 않는다.

## 7. Fallback 정책

메시지 key가 현재 언어에 없으면 다음 순서로 처리한다.

```text
current locale
    ↓ missing
fallback locale (en)
    ↓ missing
key 자체 또는 명시적인 missing-message 표시
```

누락된 번역을 빈 문자열로 처리하지 않는다.

개발 환경에서는 누락 key를 검출할 수 있어야 하며, Production에서는 사용자에게 이해 가능한 fallback을 제공한다.

## 8. Message Key 규칙

메시지 key는 UI 위치/기능을 기준으로 안정적인 namespace를 사용한다.

예:

```text
common.ok
common.cancel
common.apply
common.delete
common.save

image_editor.title
image_editor.source_image
image_editor.select_source_first
image_editor.asset_not_found
image_editor.catalog_updated

stage_editor.title
stage_editor.no_search_results

runtime.target_locked
runtime.target_switched
runtime.not_enough_energy
```

메시지의 한국어/영어 텍스트 자체를 key로 사용하지 않는다.

코드 식별자와 메시지 key를 동일시할 필요도 없다. key는 사용자 메시지의 안정적인 논리 ID다.

## 9. 문자열 포맷 정책

동적 값은 메시지 문자열 안에 직접 조합하지 않고 포맷 파라미터로 전달한다.

예:

```gdscript
LocalizationRepository.get("runtime.target_locked", {
    "target": enemy_name
})
```

locale 파일:

```json
"runtime.target_locked": "Target locked: {target}."
```

한국어:

```json
"runtime.target_locked": "{target}을(를) 대상으로 지정했습니다."
```

구현 시 placeholder 이름은 locale 간 동일해야 한다.

## 10. Content 이름과 UI 메시지의 분리

콘텐츠 데이터의 `display_name`, Unit/Robot/Skill 이름 등은 일반 UI 메시지와 동일한 방식으로 취급할지 별도 판단한다.

권장 구조는 다음과 같다.

```text
Content ID
  ↓
localized display name
  ↓
UI message
```

즉, `valkyrie`, `heavy`, `area_attack` 같은 내부 ID를 번역 문자열로 바꾸지 않는다.

향후 콘텐츠 자체의 다국어 이름이 필요하면 domain JSON의 `name` 필드를 언어별 이름 저장소로 분리하거나 별도 localized content layer를 도입한다. 이것은 본 계획의 1차 구현 범위에서는 제외한다.

## 11. 구현 단계

### Phase 1 — Localization 기반 계층

- `LocalizationRepository` 설계 및 구현
- `ko.json`, `en.json` 생성
- locale 선택/조회 API 구현
- fallback 구현
- 캐시 및 reload 구현
- key/placeholder 검증 기능 구현

성공 조건:

- 코드에서 `LocalizationRepository.get()`으로 두 언어의 메시지를 조회할 수 있음
- 누락 key가 fallback으로 처리됨
- locale 변경이 정상적으로 반영됨

### Phase 2 — Settings 연동

- 기존 `SettingsManager`와 locale 설정 연결
- 사용자 언어 설정 저장
- 시작 시 locale 복원
- 지원 언어 목록 제공

성공 조건:

- 앱 재시작 후 선택한 언어가 유지됨
- 별도 중복 설정 파일이 생성되지 않음

### Phase 3 — Editor 메시지 외부화

우선 현재 문제가 확인된 Editor부터 진행한다.

1. `image_editor.gd`
2. `asset_catalog_editor.gd`
3. `map_editor.gd`
4. `stage_editor.gd`
5. `robot_editor.gd`
6. `tower_editor.gd`
7. `unit_editor.gd`
8. 기타 Editor GDScript

UI 생성 코드의 문자열을 key 조회로 변경한다.

예:

```gdscript
button.text = LocalizationRepository.get("common.apply")
status_label.text = LocalizationRepository.get("image_editor.catalog_updated")
```

### Phase 4 — Runtime 메시지 외부화

`game_controller.gd`를 시작점으로 사용자 표시 런타임 메시지를 분리한다.

예:

- Target locked
- Target switched
- Not enough ENERGY
- skill requirement messages
- equipment messages
- HUD 표시 문자열

내부 디버그 로그와 개발자 전용 진단 문자열은 사용자 메시지와 구분한다.

### Phase 5 — 전체 GDScript 감사

모든 `.gd`를 대상으로 사용자 표시 문자열을 검색한다.

분류:

```text
USER MESSAGE       → localization으로 이동
CONTENT NAME       → domain localization 검토
INTERNAL ID        → 코드 유지
DEBUG MESSAGE      → 별도 판단
ENGINE/API TEXT    → 코드 유지
```

단순히 모든 문자열을 localization으로 옮기지 않는다.

## 12. 검증 계획

### 정적 검증

- 모든 locale JSON이 정상 JSON인지 검사
- `ko`와 `en`의 key set 비교
- 중복 key 검사
- placeholder set 비교
- 빈 translation 검사
- 코드의 직접 사용자 메시지 검색

### Runtime 검증

각 언어에서 최소 다음을 확인한다.

- Title/UI 표시
- Editor 주요 화면
- Dialog
- Status message
- 오류 메시지
- 동적 placeholder 메시지
- locale 변경
- 재시작 후 locale 유지

### 검증 상태 정의

- **CODE VERIFIED** — localization 호출 경로와 JSON 구조 확인
- **BUILD VERIFIED** — 실제 Build 성공
- **EDITOR VERIFIED** — Editor UI에서 해당 언어 확인
- **PIE VERIFIED** — 실제 Runtime에서 해당 언어 확인
- **NOT VERIFIED** — 아직 검증하지 않음

자동화된 문자열 검사 PASS는 `EDITOR VERIFIED` 또는 `PIE VERIFIED`를 의미하지 않는다.

## 13. 변경 안전성

기존 메시지를 일괄 치환하지 않는다.

각 단계에서:

1. 기존 문자열 목록 수집
2. 메시지 key 결정
3. `ko`/`en` 번역 등록
4. 코드 호출부 변경
5. diff 확인
6. Godot parse/load 확인
7. 해당 Editor/Runtime 화면 확인

깨진 문자열이나 인코딩 문제가 발견된 파일은 localization 작업과 함께 무관한 코드 변경까지 자동 수정하지 않는다.

## 14. 실패 및 HOLD 조건

다음 상황에서는 구현을 중단하고 판단을 요청한다.

- 기존 `SettingsManager`와 locale 설정 authority가 충돌함
- 기존 UI 시스템이 예상과 다른 translation mechanism을 사용함
- 콘텐츠 이름과 UI 메시지의 경계가 불명확함
- locale 변경을 런타임 중 즉시 반영해야 하는 요구가 발생함
- 외부 번역 시스템 또는 새로운 Asset이 필요함
- 기존 저장 데이터와 호환성 문제가 발생함

## 15. 현실성 판단

**TECHNICALLY POSSIBLE** — 현재 프로젝트 구조에서 JSON 기반 locale 저장소와 repository layer로 구현 가능.

**PRACTICALLY FEASIBLE** — 현재 문자열이 여러 GDScript에 분산되어 있으므로 단계적인 외부화가 필요하지만, 기존 ConfigRepository/SettingsManager 구조와 충돌 없이 구현할 수 있다.

**RECOMMENDED** — 사용자 표시 메시지와 설정/콘텐츠 데이터를 분리하여 관리하는 것이 향후 언어 추가와 유지보수에 적합하다.

**BUSINESS VIABLE** — 한국어/영어 2개 언어를 우선 지원하는 규모에서는 별도의 번역 서버나 외부 localization 서비스 없이 프로젝트 내부 JSON 저장소로 충분하다.

## 16. 완료 기준

다음 조건을 모두 만족하면 1차 다국어 기반 구축 완료로 판정한다.

- 한국어/영어 locale 저장소 존재
- `LocalizationRepository`를 통한 메시지 조회
- `SettingsManager`와 언어 설정 통합
- Editor 주요 사용자 메시지 외부화
- Runtime 주요 사용자 메시지 외부화
- locale key/placeholder 검증 통과
- 직접 하드코딩된 사용자 메시지의 잔여 목록이 감사 결과로 분류됨
- 한국어/영어에서 주요 Editor/Runtime 화면 확인

## 17. 현재 판정

**STATUS — PLAN READY**

현재 단계에서는 설계와 개발계획만 확정한다. 실제 localization 파일 생성 및 GDScript 외부화는 별도 구현 작업으로 취급한다.

**PROPOSAL** — 위 구조를 기준으로 구현한다.

**CANON** — Master 승인 전에는 아님.

**OUT OF SCOPE** — 제3언어, 외부 번역 서비스, 자동 번역, 콘텐츠 이름의 완전한 다국어화.

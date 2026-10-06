
# MENOS 콘텐츠 독창성 및 참조 관리 정책 제안

STATUS — PROPOSAL / NOT CANON

목적: 일본 만화·애니메이션 및 기타 기존 창작물의 장르적 영향을 유지하면서도, Robot에 한정하지 않고 MENOS의 캐릭터·적·무기·건축물·UI·명칭·스킬 연출·스토리 설정 등 전체 콘텐츠에서 특정 기존 작품의 구체적 표현을 복제하거나 강하게 연상시키는 위험을 줄인다.

## 1. 기본 원칙

- 장르의 일반적인 문법과 아이디어는 참고할 수 있으나 특정 작품의 구체적 표현을 직접 복제하지 않는다.
- 특정 작품의 캐릭터, 로봇, 무기, 복장, 건축물, UI, 로고, 명칭, 필살기명, 설정 등을 그대로 재현하거나 단순 변형하는 방식은 사용하지 않는다.
- 특정 한 작품을 기준으로 디자인을 변형하는 대신, 여러 일반적 요소와 자체 설계 요구사항을 조합하여 독립적인 결과물을 만든다.
- 팬심이나 장르적 취향 자체를 제한하는 것이 아니라, 최종 표현의 독립성을 관리한다.
- 이 문서는 법률적 안전을 보증하지 않는다. 상업 출시 전 주요 Asset과 명칭은 필요 시 전문적인 법률/상표 검토 대상이 된다.

## 2. 적용 범위

다음 모든 콘텐츠를 동일한 정책 대상으로 취급한다.

- Robot
- Character / Pilot
- Enemy / Unit
- Tower
- Weapon / Item
- Skill / Ability
- Faction / Organization
- Map / Building / Environment
- UI / Icon / Logo
- Animation / VFX / Sound reference
- Name / Title / Terminology
- Story / Setting / Mission presentation

즉, "Robot만 독창적이면 충분하다"는 기준을 사용하지 않는다.

## 3. 직접 참조 정책

제작 과정에서 특정 작품을 직접적인 디자인 기준으로 지정하지 않는다.

피해야 할 제작 지시 예:
- 특정 작품의 특정 로봇과 유사하게 제작
- 특정 캐릭터의 얼굴/복장/헤어/무기를 조합하여 제작
- 특정 작가의 고유한 표현을 그대로 모사하도록 지시

대신 다음과 같이 자체 설계 언어를 사용한다.

예:
- SD 비율
- 역삼각형 체형
- 산업용 기계 구조
- 중장갑
- 곤충 형태의 구조적 모티프
- 제한된 색상 수
- 자체적인 가슴/머리/관절 구조

## 4. 디자인 독창성 기록

주요 Asset은 제작 시 다음 정보를 기록하는 방향을 권장한다.

- Genre Influence
- General Motifs
- Direct Reference: None 또는 실제 사용한 참조
- Design Origin
- Original Elements
- Similarity Review Result

예:

    Asset: Robot_001
    Genre Influence: Super Robot / Military Mecha / SD
    Direct Reference: None
    Design Origin: Industrial machine / armored vehicle / insect morphology
    Original Elements: 자체 머리 구조 / 자체 흉부 구조 / 자체 장갑 배치

이 기록은 법적 판단 자체가 아니라 제작 의도와 독립적인 디자인 과정을 추적하기 위한 내부 자료다.

## 5. 유사성 자체검수

주요 콘텐츠는 다음 순서로 검토한다.

    Idea
      ↓
    Design
      ↓
    Similarity Review
      ↓
    Revise if necessary
      ↓
    Asset Approval

검수 시 특히 다음을 함께 본다.

- 전체 실루엣
- 비율
- 얼굴/머리 구조
- 대표적인 장식
- 색상 배치
- 무기 형태
- 복장 구조
- 대표 포즈
- 이름/명칭
- 핵심 설정 및 연출

단일 세부 요소만 보지 않고 최종 결과의 전체적인 인상을 검토한다.

## 6. 이름과 설정

디자인과 별도로 명칭도 독립적으로 설계한다.

검수 대상:
- Robot 이름
- Character 이름
- Faction 이름
- Skill 이름
- Weapon 이름
- Mission 이름
- 장소명
- 조직명
- 기술/필살기명

기존 작품의 고유 명칭을 일부 변형하는 방식으로 독창성을 확보했다고 판단하지 않는다.

## 7. AI 생성 Asset

AI를 사용하여 Asset을 제작하는 경우에도 특정 작품이나 작가의 고유한 표현을 직접 모사하도록 지시하지 않는다.

프롬프트는 MENOS 자체의 디자인 언어, 구조, 기능, 비율, 색상, 재질, 실루엣 요구사항으로 작성한다.

생성 결과 역시 유사성 자체검수의 대상이다. AI 생성물이라는 사실만으로 독창성이 확보되었다고 간주하지 않는다.

## 8. Workshop과의 관계

Workshop 사용자 제작 콘텐츠에도 동일한 원칙을 적용하는 방향을 권장한다.

다만 Workshop 콘텐츠는 신뢰할 수 없는 사용자 입력이므로 내부 Authoring Editor보다 별도의 Validate 단계가 필요하다.

    Workshop Content
      ↓
    Schema Validation
      ↓
    Reference Validation
      ↓
    Content / Asset Policy Review
      ↓
    Runtime Eligibility

자동 검출만으로 모든 저작권 문제를 판정할 수 있다고 가정하지 않는다.

## 9. 책임 경계

- Content Editor: 콘텐츠의 독립적인 정의와 참조를 관리
- Localization: 명칭/설명의 언어별 표현을 관리
- Gameplay / Settings: 전역 규칙을 관리
- Asset Review: 주요 Asset의 독창성 검수 기록을 관리
- Workshop Validate: 사용자 제작 콘텐츠의 형식/참조/실행 안전성을 검증

## 10. 상태 및 검증

STATUS — PROPOSAL / NOT CANON

이 문서는 정책 제안이며 Master의 명시적 승인 전에는 Canon이 아니다.

CODE VERIFIED — 해당 정책 자체는 문서 수준 제안이며 코드 검증 대상이 아니다.
BUILD VERIFIED — NOT APPLICABLE.
EDITOR VERIFIED — NOT APPLICABLE.
PIE VERIFIED — NOT APPLICABLE.

법률적 판단, 특정 Asset의 침해 여부, 특정 국가의 저작권/상표 적용은 본 문서만으로 확정하지 않는다.

## 11. 종료 기준

목적은 "모든 콘텐츠를 특정 작품과 완전히 다르게 만드는 것"이 아니라, 제작 과정에서 특정 작품의 구체적인 표현을 직접 복제하는 위험을 체계적으로 줄이는 것이다.

Master가 정책을 승인하면 이후 개별 Editor/Asset 제작 규칙에 필요한 최소 항목만 단계적으로 반영한다. 승인 전에는 Canon 변경이나 대규모 Asset 수정으로 자동 확장하지 않는다.

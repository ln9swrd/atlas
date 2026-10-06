# MENOS — SQLite / ODB PK Migration Plan

STATUS — PROPOSAL / NOT CANON

## 1. 목적

MENOS의 데이터 식별 체계를 하나로 통일한다.

최종 목표:

```text
ODB PK Number
      ↓
SQLite
JSON Migration Source / Legacy Data
Content Editor
Runtime
Workshop Content
Content References
```

모든 Schema의 식별자는 ODB PK 번호를 사용한다.

Name / Title / Display Name은 변경 가능한 속성이며 식별자로 사용하지 않는다.

JSON을 즉시 삭제하지 않는다. 기존 JSON은 Migration Source / Legacy Data로 보존하고, 해당 데이터가 SQLite + ODB PK 체계로 안전하게 이전되고 모든 참조가 검증된 후 폐기 여부를 결정한다.

## 2. 핵심 원칙

1. 한 번에 전체 데이터를 변경하지 않는다.
2. 데이터 유형별로 하나씩 조사하고 전환한다.
3. 조사 단계는 READ-ONLY를 기본으로 한다.
4. 변경 전 HEAD / Branch / Working Tree / 기존 변경사항을 확인한다.
5. 기존 데이터와 참조를 임의로 삭제하거나 덮어쓰지 않는다.
6. 각 데이터 유형의 기존 PK와 참조 경로를 먼저 확인한다.
7. ODB PK를 임의로 생성하지 않는다.
8. 이름/제목을 PK로 사용하지 않는다.
9. Migration 후 Editor와 Runtime 양쪽 참조를 검증한다.
10. 하나의 유형이 성공하면 중지하고 다음 유형은 별도로 진행한다.
11. 예상과 다른 참조나 충돌이 발견되면 HOLD한다.

## 3. 작업 단위

각 데이터 유형은 다음 순서로 처리한다.

```text
대상 선정
↓
현재 Schema 조사
↓
현재 PK 조사
↓
JSON 구조 조사
↓
Editor 참조 조사
↓
Runtime 참조 조사
↓
FK / Cross Reference 조사
↓
ODB PK Mapping 설계
↓
Master 승인
↓
최소 변경
↓
Diff / DB 검증
↓
Editor 검증
↓
Runtime 검증
↓
Accept / Hold
```

## 4. 1차 조사 대상

우선 실제 프로젝트에서 사용 빈도와 참조 범위가 큰 Content부터 조사한다.

권장 조사 후보:

1. Robot
2. Unit / Enemy
3. Tower
4. Skill
5. Faction
6. Map
7. Stage
8. Mission
9. Campaign
10. Wave / Encounter
11. Reward / Economy
12. Building
13. BGM
14. SFX
15. VFX
16. 기타 Catalog 데이터

단, 실제 시작 순서는 현재 SQLite와 JSON의 참조 구조를 확인한 뒤 결정한다.

## 5. 데이터 유형별 조사 항목

각 유형에 대해 최소 다음을 기록한다.

### SQLite
- Table 이름
- PK 컬럼
- PK 타입
- PK 생성 방식
- 현재 PK 값 범위
- UNIQUE 제약
- FK
- 관련 Table
- 기존 데이터 수

### JSON
- 파일 위치
- ID 필드
- ID 타입
- Name / Title 필드
- 다른 Content 참조 필드
- 파일 간 참조
- SQLite와 동일 데이터 여부
- JSON만 존재하는 데이터

### Content Editor
- Editor 위치
- Repository / Loader
- Create
- Load
- Save
- Delete
- ID 생성 방식
- 참조 선택 방식

### Runtime
- Loader
- Repository
- Lookup 방식
- ID 참조
- Name 참조
- 파일명 참조
- Runtime Cache

## 6. ODB PK Mapping

기존 데이터의 식별자를 바로 삭제하지 않는다.

예:

```text
Legacy JSON ID
      ↓
Legacy SQLite ID
      ↓
ODB PK
```

필요한 경우 Mapping Table 또는 Migration Mapping 자료를 별도로 유지한다.

동일한 Content가 JSON과 SQLite 양쪽에 존재하는 경우 먼저 동일 데이터인지 확인하고 하나의 ODB PK로 통합한다.

이름이 같다는 이유만으로 동일 데이터라고 판단하지 않는다.

## 7. PK 충돌 처리

다음 경우는 자동 병합하지 않는다.

- 서로 다른 데이터가 동일 PK를 사용
- JSON ID와 SQLite ID가 서로 다른 객체를 가리킴
- 동일 이름이지만 다른 Content
- 하나의 Content가 여러 ID로 존재
- 참조 대상이 존재하지 않음
- 삭제된 데이터의 오래된 참조가 존재

이 경우 HOLD 후 원인을 확인한다.

## 8. JSON 처리 정책

JSON은 다음 세 단계로 취급한다.

### LEGACY
기존 데이터 원본. 삭제 금지.

### MIGRATION SOURCE
SQLite/ODB PK 전환에 필요한 데이터를 추출하는 원본.

### RETIRED
모든 참조가 SQLite/ODB PK 체계로 전환되고 데이터 무결성이 확인된 후에만 폐기 후보가 된다.

JSON을 먼저 삭제하지 않는다.

## 9. SQLite 전환 원칙

최종 SQLite Schema는 각 Content의 PK를 ODB PK 번호로 사용한다.

예:

```text
robots
 └─ odb_pk INTEGER PRIMARY KEY

units
 └─ odb_pk INTEGER PRIMARY KEY

towers
 └─ odb_pk INTEGER PRIMARY KEY
```

실제 컬럼명은 기존 프로젝트의 Schema와 Runtime 영향을 조사한 후 결정한다.

`document_id TEXT` 같은 기존 식별자가 발견되더라도 즉시 삭제하지 않는다.

## 10. 참조 전환

기존:

```text
robot.json
 → "enemy_name": "Asura"
```

또는

```text
robot
 → document_id = "robot.asura"
```

같은 참조가 존재할 경우 최종적으로:

```text
robot
 → target_odb_pk = N
```

형태의 PK 참조로 전환한다.

필요한 실제 필드명은 Schema 조사 후 결정한다.

## 11. Editor 전환

각 Editor는 다음을 ODB PK 기준으로 통일한다.

- Create
- Load
- Save
- Delete
- List
- Select Reference
- Cross Reference

사용자가 화면에서 보는 Name / Title은 자유롭게 변경할 수 있어야 한다.

Name 변경으로 Reference가 깨지면 실패로 판정한다.

## 12. Runtime 전환

Runtime은 다음 순서로 검증한다.

```text
ODB PK
↓
Repository / Loader
↓
Content Object
↓
Cross Reference
↓
Gameplay Runtime
```

Runtime에서 Name / Title / 파일명을 통해 Content를 찾는 경로가 발견되면 조사 대상으로 기록한다.

## 13. 검증 기준

각 데이터 유형마다 최소 다음을 검증한다.

### DATA VERIFIED
SQLite 데이터가 ODB PK 기준으로 정확히 존재한다.

### REFERENCE VERIFIED
다른 Content의 참조가 올바른 ODB PK를 가리킨다.

### EDITOR VERIFIED
Editor에서 조회 / 저장 / 선택이 정상이다.

### RUNTIME VERIFIED
Runtime에서 실제 Content가 정상적으로 로드되고 사용된다.

### RENAME VERIFIED
Name / Title을 변경해도 참조가 유지된다.

## 14. 변경 안전성

각 유형 전환 전에:

- HEAD
- Branch
- Working Tree
- 기존 변경사항
- 대상 SQLite 파일
- 대상 JSON 파일

을 확인한다.

변경 후:

- Git Diff
- SQLite Schema
- Row Count
- PK 중복
- Orphan Reference
- Editor Load
- Runtime Load

을 확인한다.

## 15. 성공 조건

한 데이터 유형의 전환은 다음 조건을 모두 만족해야 성공이다.

```text
기존 데이터 보존
AND
ODB PK 적용
AND
참조 정상
AND
Editor 정상
AND
Runtime 정상
AND
Name / Title 변경에도 참조 유지
```

조건을 만족하면 해당 유형은 ACCEPT·STOP한다.

다음 유형으로 자동 진행하지 않는다.

## 16. 금지사항

- 전체 SQLite를 한 번에 재작성
- JSON 일괄 삭제
- PK 임의 생성
- 이름 기반 자동 병합
- 확인되지 않은 FK 수정
- 기존 변경사항 덮어쓰기
- Runtime 확인 없이 Legacy 데이터 폐기
- Migration 중 새로운 Gameplay 기능 추가
- Migration 범위를 TD 콘텐츠 개발로 확대

## 17. 최종 상태 목표

```text
                    ODB PK
                       │
       ┌───────────────┼───────────────┐
       ↓               ↓               ↓
    SQLite          Editor          Runtime
       │               │               │
       └───────────────┼───────────────┘
                       ↓
                Cross References
                       ↓
                Gameplay Content

JSON Legacy
     ↓
Migration
     ↓
검증 완료
     ↓
Retired 후보
```

최종적으로 Content의 존재와 참조는 SQLite + ODB PK를 기준으로 관리하고, JSON은 검증된 Migration 이후 Legacy 저장 구조에서 제외하는 것을 목표로 한다.

## 18. 판정 상태

- CONTINUE — 현재 유형의 조사/전환을 계속할 수 있음
- CHANGE METHOD — 현재 방법보다 판별력이 높은 방법 필요
- ACCEPT·STOP — 해당 유형 전환 성공
- HOLD — 핵심 정보 부족, 충돌 또는 새로운 설계 판단 필요

PROPOSAL ≠ CANON.
실제 ODB PK 할당 규칙과 최종 Migration Schema는 조사 결과와 Master 승인 후 확정한다.


## 19. 현재 실행 결과 (2026-10-07)

본 계획의 승인된 데이터 유형별 ODB PK Migration 검토를 완료했다.

### ACCEPT·STOP / PASS

| Content | 결과 | ODB PK 범위 | 검증 |
|---|---|---:|---|
| Robot | PASS | asura=1, valkyrie=2 | CODE / DB / Headless |
| Unit | PASS | basic=3 ~ unit_01=8 | CODE / DB / Headless |
| Tower | PASS | rail=9 | CODE / DB / Headless |
| Skill | PASS | area_attack=10 ~ heavy_pierce=13 | CODE / DB / Headless |
| Stage | PASS | stage_01=14 ~ stage_03=16 | DB / StageLoader / Headless |
| Mission | PASS | mission_stage_01=17 ~ mission_stage_03=19 | CODE / Reference / Headless |
| Campaign | PASS | main_campaign=20 | CODE / Reference / Headless |
| Reward | PASS | reward_stage_01=21 ~ reward_stage_03=23 | CODE / Reference / Headless |
| Building | PASS | 생성 검증 PK=24 | CODE / Headless CRUD |

### HOLD / 변경 없음

| Content | 판정 | 사유 |
|---|---|---|
| Faction | HOLD | 현재 실질 Faction 데이터가 없어 PK 할당 근거 부족 |
| Map | HOLD | Stage의 map_file 문자열 경로와 전용 MapLoader 구조가 있어 별도 참조 계층 설계 필요 |
| Wave / Encounter | HOLD | Stage 내부 중첩 구조이며 독립 Table/Repository가 없어 정규화 시 범위 확대 |
| BGM | HOLD | 독립 BGM Content Schema/Repository 및 데이터 없음 |
| SFX | HOLD | 직접 Asset 참조이며 독립 SFX Content Schema/Repository 없음 |
| VFX | HOLD | 직접 Asset/코드 효과이며 독립 VFX Content Schema/Repository 없음 |

### 현재 ODB PK 할당 기준

현재 검증된 다음 ODB PK는 24이며, 이후 번호를 임의로 선할당하지 않는다. 새로운 Content의 PK는 실제 생성/마이그레이션 시 ODB Registry 규칙에 따라 할당한다.

### 종료 판정

승인된 1차 Migration Plan의 조사·전환 대상은 현재 범위에서 모두 처리했다. PASS 항목은 ACCEPT·STOP했고, HOLD 항목은 새로운 Schema 설계나 데이터 정규화가 필요한 사유가 확인되어 변경하지 않았다.

본 결과는 Migration Plan의 실행 상태 기록이며, Master 승인 없이 Canon 또는 HOLD 항목의 설계를 확정하지 않는다.

PROPOSAL ≠ CANON.

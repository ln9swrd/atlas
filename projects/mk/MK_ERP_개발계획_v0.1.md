# MK ERP 개발계획 v0.1

## 1. 목적
현재 설계를 실제 Windows Stand Alone ERP로 구현한다.
수주, 발주, 생산실적, 입출고, 재고, 기준정보, Lot 추적, 보고서, Excel, 인쇄, 백업을 대상으로 한다.

## 2. 핵심 원칙
- 내부 DB PK와 업무용 식별자를 분리한다.
- MK Lot No는 사용자가 직접 입력한다.
- 거래처 Lot No도 사용자가 직접 입력한다.
- 두 Lot 번호는 DB PK가 아니다.
- 저장 시 필수값, 중복, 관계 및 형식을 검증한다.
- 재고는 Transaction에서 산출한다.
- LOSS는 별도 유형으로 유지한다.
- Excel은 원장 DB가 아닌 분석/전달 수단으로 사용한다.

## 3. 기술 기반
- Windows Desktop
- C# / WPF / .NET 8 계열
- SQLite
- EF Core + SQLite
- MVVM
- Presentation → Application → Domain → Infrastructure → SQLite

## 4. 개발 단계
Phase 0: 기준선, 개발환경, 솔루션 구성
Phase 1: SQLite, EF Core, Migration, 공통 Repository, 데이터 사전
Phase 2: 품목, 등급, 거래처, 거래처별 품목, 단가
Phase 3: MK Lot / 거래처 Lot 입력 및 추적 구조
Phase 4: 수주 및 단가 연계
Phase 5: 발주
Phase 6: 생산실적
Phase 7: 입고 / 출고 / LOSS
Phase 8: 재고현황 / Lot별 재고 / 재고조정
Phase 9: 조회 / 보고서 / 인쇄 / PDF / Excel
Phase 10: 백업 / 복원
Phase 11: 통합 검증 및 Windows 배포

## 5. Phase별 기본 성공조건
각 Phase는 기능 구현 후 최소 검증을 수행한다.
성공조건을 만족하면 해당 Phase를 종료한다.
- DB 생성 및 Migration 성공
- 기준정보 CRUD 및 관계 무결성 성공
- Lot 직접입력 및 중복/관계 검증 성공
- 수주 단가 자동조회 및 적용단가 보존 성공
- 입출고/Loss Transaction 저장 성공
- 재고 계산 정확성 확인
- 주요 화면 Excel 출력 성공
- 보고서 인쇄/PDF 성공
- 백업/복원 성공
- 핵심 시나리오 Build/Runtime 검증 성공

## 6. 공통 UI
조회, 초기화, 신규, 저장, 삭제/취소, Excel, 인쇄 기능을 공통화한다.
그리드는 Excel 사용 습관을 고려해 정렬, 필터, 열 너비, 복사, 키보드 이동을 지원한다.

## 7. Lot 구현 원칙
DB 내부에는 별도의 LOT_ID를 둔다.
사용자는 MK Lot No와 거래처 Lot No를 직접 입력한다.
입력된 업무용 Lot 번호를 원장과 추적 화면에서 그대로 표시한다.
Lot 간 관계가 1:N, N:1 또는 N:M인지 확정되지 않은 경우 구현을 고정하지 않고 HOLD한다.

## 8. 재고 원칙
기본적으로 기말재고 = 기초 + 입고 - 출고 - LOSS로 산출한다.
실제 구현에서는 입출고 유형별 증감 방향을 데이터 사전으로 관리한다.
Carrier Excel의 생산일자는 거래일자와 별도 필드로 보존한다.

## 9. 검증 상태
CODE VERIFIED: 실제 코드 경로 확인
BUILD VERIFIED: 실제 Build 성공
EDITOR VERIFIED: Asset/설정 확인
PIE VERIFIED: 실제 Runtime 확인
NOT VERIFIED: 아직 확인하지 않음

## 10. 1차 완료 기준
기준정보, 수주, 발주, 생산실적, 입출고/Loss, 재고, Lot 추적,
Excel, 보고서/인쇄/PDF, 백업/복원, Windows 설치 및 핵심 Runtime 검증이 완료되어야 한다.

## 11. 보류 항목
- MK Lot 중복 허용 범위
- 거래처 Lot와 MK Lot 관계 cardinality
- 한 입고에 여러 Lot 입력 방식
- 수주 단가 수동 수정 여부
- 문서번호 규칙
- 재고조정 승인 규칙
- Carrier 가격표의 인상 의미
- SUS의 각인확인 의미
- 생산일자 적용 범위

## 12. 범위 밖
웹 서버, 클라우드, 모바일, REST API, BOM/MRP, 고급 생산계획,
생산원가 시스템, 불필요한 외부 서비스 연동은 1차 범위에서 제외한다.

## 13. 종료 원칙
목적 달성 후 자동으로 다음 기능을 시작하지 않는다.
각 단계의 성공조건을 만족하면 STOP한다.

문서 상태: PROPOSAL
Master 승인 전까지 Canon이 아니다.

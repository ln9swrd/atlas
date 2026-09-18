# ART_DIRECTION — Excelion

> 2026-08-10 · Unreal 에셋 제작 연결용  
> 원천: SUPER_ROBOT_DESIGN_LANGUAGE · MECHA_3TONE_LOW_DETAIL · 00_VISION · BRAVE_FINAL_SPEC

**상태: 초안 · 기존 방향 유지**

---

## 1. 한 줄

Excelion의 모든 메카는 **슈퍼로봇**이다. 곡선과 큰 형태로 영웅적 조형을 만든다. 건담식 리얼로봇이 아니다.

---

## 2. 우선순위

```
실루엣 > 장갑 덩어리 > 곡면 > 색상 블록 > 기계 디테일 > 패널라인
```

- 멀리서도 캐릭터·역할이 읽혀야 한다.
- 흉부·어깨·머리에 아이콘성.
- 사지에 질량감 (날씬 인간형 축소 금지).

---

## 3. 메카 디자인 규칙

| 규칙 | 내용 |
|------|------|
| SUPER ROBOT FIRST | 1차 분류는 항상 슈퍼로봇 |
| 곡선 | 주요 외곽에 곡선·완만 곡면 적극 사용 |
| 3톤 | primary / secondary / accent 약 3톤 |
| 저밀도 패널 | 패널은 보조 · 실루엣을 가리지 않음 |
| 캐릭터성 | 머리·얼굴에 캐릭터성 (단순 센서 덩어리 금지) |

**금지:** military realism · excessive panel · Gundam mobile suit 인상 · 하드서피스 일색.

---

## 4. 색·재질

- BRAVE 예: primary `#C0C8D0` · secondary `#2A3A4A` · accent `#E8A020`
- 매트 + 세미글로스 · 큰 면 우선
- Unreal: Material Instance로 톤 교체 가능하게

---

## 5. 환경·UI (최소)

- 전투 가독성 우선 (위험 존·텔레그래프 명확)
- UI: 미니멀 HUD · 소년만화적 과한 장식 지양
- 맵 무드: 기존 `design/env` · MAP_MOOD 참조

---

## 6. Unreal 연결

- 메쉬: 게임용 토폴로지 · 발 피벗 · 스케일 m→cm
- 머티리얼: 3톤 인스턴스
- VFX: Niagara · accent 계열 · 클린한 한 방
- 애니: 슈퍼로봇 보행·대시 질량감

상세: `MECHA_MODELING_GUIDELINE` · `MATERIAL_GUIDELINE` · `VFX_GUIDELINE` · 파이프라인 스펙

---

## 7. 참고 감성

Gunbuster · Getter · Gurren Lagann · FSS — **감정·기세**. 형태 직카피 금지.

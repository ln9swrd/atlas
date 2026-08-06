# FSS_STYLE_REF — Five Star Stories / Mortar Headd 스타일 참조

> 2026-08-06  
> 출처: 핀테레스트 보드 `ln9swrd/fss` · 나가노 마모루 《파이브 스타 스토리즈》 Mortar Headd 디자인 언어  
> 용도: Excelion 디자인 **참고 방향** (TEXT-LOCK을 덮어쓰지 않음)

**상태: 참조 문서**

---

## 1. 한 줄

FSS 스타일 = **기사·귀족의 예술품으로서의 메카**.  
양산 병기가 아니라, 전투하면서도 **아름답고·위엄 있으며·살아 있는 기계**로 읽히는 디자인.

---

## 2. 핵심 특징 (구체)

### 2.1 실루엣 · 비율

| 축 | 내용 |
|----|------|
| 전체 | humanoid · **우아하고 긴** 인상 · 투박함보다 정제된 라인 |
| 머리 | 개성이 강한 헤드 디자인 (마스크·뿔·장식 헬멧). 얼굴면이 “가면”처럼 읽힘 |
| 목·상체 | 상대적으로 가늘거나 세련된 상체 · 어깨는 존재감 있으나 과한 bulk 지양 |
| 허리 | 한 단 들어간 라인 · 기동과 우아함을 동시에 |
| 다리 | 길고 날씬 · 접지감은 유지하되 “달리는 기사” 인상. 가끔 힐/포인트 풋 암시 |
| 손 | 정교한 매니퓰레이터 · 덩치로 실루엣을 깨지 않음 |

### 2.2 표면 · 디테일 밀도

- **고밀도 패널 라인** + 리벳·분할이 명확
- 장갑이 “판을 붙인 것”이 아니라 **조각된 금속 예술**처럼 보임
- 곡면과 각면의 혼용 (유기적 곡선 + 날카로운 엣지)
- 장식성: 문양·프레resco 느낌의 선·문장이 가능하나 **과하면 실루엣 파괴**
- 품질감: 로봇혼 / 센티넬 / 볼크스 IMS급 피니시와 자연스럽게 맞음

### 2.3 분위기 · 읽힘

| 읽힘 | 설명 |
|------|------|
| 기사 | 중세·르네상스 기사의 갑옷을 미래로 옮긴 인상 |
| 예술품 | 전장에서 위압적이면서 퍼레이드에서도 아름다움 |
| 살아 있는 기계 | 순수 무기보다 “의지와 품격이 있는 존재” |
| 귀족성 | 양산기와 확실히 구분되는 고급감·유일성 |

### 2.4 색 · 마감

- 금속감 강함 (매트 + 세미글로스 혼용)
- 저채도 고급 금속 + 포인트 컬러 (금·은·냉색 악센트 등)
- 과도한 원색·카툰 채도 지양
- 표면이 “그려진 그림”이 아니라 “주조·연마된 금속”으로 읽히게

---

## 3. Excelion에 적용할 때 (중요)

FSS는 **참고 방향**이다. 기존 TEXT-LOCK을 덮어쓰지 않는다.

| 기체 | FSS에서 가져올 수 있는 것 | 가져오면 안 되는 것 |
|------|---------------------------|---------------------|
| **BRAVE** | 우아한 비율 · 여백 속 고급 표면 밀도 · 여성형 우아함 | 과한 장식·뿔·가면·힐로 실루엣 붕괴 |
| **엑셀리온** | 광익·광윤과 어울리는 “열린 예술품” 인상 | 완전 다른 두 번째 기체로 읽히는 변화 |
| **세스** | 정제된 각·차단의 **고급감** | FSS식 장식·위계 장식 (세스는 장식 최소) |
| **아슈르** | 위계·길이·원격 존재감과 맞는 **귀족적 위압** | 손/무장이 드러나거나 광기형 일그러짐 |
| **ORD** | (거의 가져오지 않음) | FSS 고급감 부여 시 양산 정체성 붕괴 |

### 원칙

1. **실루엣 키워드 우선** (CAST / MECHA_SPEC / FRAME_SPEC)
2. FSS는 **표면 처리·품격·디테일 밀도**를 올리는 데 사용
3. “FSS 카피”가 아니라 “FSS급 완성도 + Excelion 고유 실루엣”
4. `DESIGN_QUALITY.md` (로봇혼/센티넬)와 방향이 일치함 → 채택 가능

---

## 4. 금지 (Excelion 기준)

- FSS 고유 헤드 장식(특정 뿔·가면)을 그대로 이식
- 장식 과다로 실루엣 키워드 파괴
- ORD에 FSS 고급감 부여
- “FSS 스타일이니까”라며 TEXT-LOCK 비율·색·금지 조항 무시
- 저밀도·카툰화 (FSS 본연과도 반대)

---

## 5. 제작 시 프롬프트 보조 문구 (참고)

```
Five Star Stories Mortar Headd inspired elegance and mechanical density,
knightly aristocratic presence, refined elongated humanoid proportions,
intricate industrial panel lines with sculptural armor quality,
premium metal finish (matte + semi-gloss), sharp clean edges,
Bandai Robot Spirits / Sentinel level detail density,
NOT a direct copy of any specific FSS unit, preserve Excelion silhouette keywords.
```

---

## 6. 관련 문서

- `design/DESIGN_QUALITY.md` (품질 바)
- `design/brave/FRAME_SPEC.md`
- `design/enemy/ASHUR_MECHA_SPEC.md` · `SETH_MECHA_SPEC.md` · `ORD_SPEC.md`
- 각 `mecha/*/DESCRIPTION.md` · `OFFICIAL_SETTING.md`

**FSS = 품격과 밀도 참조. 실루엣과 금지 조항은 Excelion TEXT-LOCK이 우선.**

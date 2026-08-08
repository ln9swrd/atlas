# THREEVIEW_CURRENT — 한 번에 하나만, 순서대로 순환

> 자동화는 **CURRENT 1개만** 처리한 뒤 QUEUE의 **다음**으로 CURRENT를 갱신한다.  
> 대상은 `design/README.md`의 제작 단위만 사용한다.

## CURRENT

```
mecha/brave
```

## QUEUE

```
character/lia
character/kai
character/yuna
character/rei
character/seth
mecha/brave
mecha/excelion
mecha/seth
mecha/ord-grunt
mecha/ord-heavy
mecha/ord-gun
mecha/ord-mid
env/earth-defense
env/earth-siege
env/lunar
env/gate
weapon/brave-blade
weapon/brave-cannon
weapon/brave-drone
weapon/seth-line-resolver
weapon/seth-seal-plate
```

## 완료 로그

| 날짜 | 대상 | 결과 | 다음 CURRENT |
|------|------|------|-------------|
| 2026-08-06 | character/lia | 삼면도 생성 (A-pose, orthographic, white bg, 16세 비율, 손 강조); NOTES 갱신 | character/kai |
| 2026-08-06 | character/kai | 삼면도 생성 (A-pose, orthographic, white bg, 한 치 큼·안정 어깨, 통신 장비 자연스럽게); NOTES 추가 | character/yuna |
| 2026-08-06 | character/yuna | 삼면도 생성 (A-pose, orthographic, white bg, 거리·시선·가장자리, 절제된 존재감); NOTES 추가 | character/rei |
| 2026-08-06 | mecha/brave | 순서 외 생성 (A-pose, orthographic, 여백·여성형·단순, #C0C8D0/#2A3A4A/#E8A020); NOTES 추가 | character/rei (유지) |
| 2026-08-06 | character/rei | 삼면도 생성 (A-pose, orthographic, white bg, 단정·지휘·침묵, 절제); NOTES 추가 | character/ashur |
| 2026-08-07 | character/ashur | 삼면도 생성 후 **폴더 삭제** (최종보스=네메시스). 큐에서 제거 | character/seth |
| 2026-08-07 | (cleanup) | QUEUE에서 character/ashur · mecha/ashur · weapon/ashur-* 제거 | character/seth |
| 2026-08-08 | character/seth | 삼면도 생성 (A-pose, orthographic, white bg, 단정·차단·전선 밀도, 무표정, 처리 손); NOTES·prompt·negative 추가 | mecha/brave |

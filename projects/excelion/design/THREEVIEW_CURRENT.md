# THREEVIEW_CURRENT — 한 번에 하나만, 순서대로 순환

> 자동화는 **CURRENT 1개만** 처리한 뒤 QUEUE의 **다음**으로 CURRENT를 갱신한다.  
> 대상은 `design/README.md`의 제작 단위만 사용한다.

## CURRENT

```
character/rei
```

## QUEUE

```
character/lia
character/kai
character/yuna
character/rei
character/ashur
character/seth
mecha/brave
mecha/excelion
mecha/ashur
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
weapon/ashur-order-sight
weapon/ashur-decree-field
```

## 완료 로그

| 날짜 | 대상 | 결과 | 다음 CURRENT |
|------|------|------|-------------|
| 2026-08-06 | character/lia | 삼면도 생성 (A-pose, orthographic, white bg, 16세 비율, 손 강조); NOTES 갱신 | character/kai |
| 2026-08-06 | character/kai | 삼면도 생성 (A-pose, orthographic, white bg, 한 치 큼·안정 어깨, 통신 장비 자연스럽게); NOTES 추가 | character/yuna |
| 2026-08-06 | character/yuna | 삼면도 생성 (A-pose, orthographic, white bg, 거리·시선·가장자리, 절제된 존재감); NOTES 추가 | character/rei |

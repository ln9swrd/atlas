# THREEVIEW_CURRENT — 한 번에 하나만

> CURRENT 1개 처리 후 QUEUE 다음으로 갱신.

## CURRENT

```
mecha/brave  (이미지 HOLD · 검수 대기)
```

## QUEUE

```
mecha/excelion
mecha/seth
mecha/creil
mecha/aegis
mecha/nemesis
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

## 완료 로그 (요약)

| 날짜 | 대상 | 결과 |
|------|------|------|
| 2026-08-06~08 | character/* · seth | 삼면도 세션 생성 |
| 2026-08-08 | mecha/brave | M5 · PNG HOLD · BRAVE_FINAL_SPEC Done |
| 2026-08-08 | mecha 재편 | creil·aegis·nemesis DESCRIPTION · D12/D13 LOCK |

## 규칙

- 제작 단위 = `mecha/<unit>/DESCRIPTION.md` 1차
- 스펙 충돌 시 enemy/brave 원본 우선
- 이미지 생성·커밋 = **HOLD**

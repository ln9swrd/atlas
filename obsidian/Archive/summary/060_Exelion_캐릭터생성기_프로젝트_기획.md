# Exelion 캐릭터 생성기 · Forge 기획

## 위치
- Atlas = 개발 시스템
- Exelion = 게임
- **Exelion Forge** = 콘텐츠(에셋) 생산 엔진

캐릭터 생성기는 Forge의 **첫 번째 핵심 기능**.

## 프로젝트명
**Exelion Forge** (대장간) — 캐릭터·무기·장갑·부품·리그 등을 "단조"한다.

## Forge 모듈 구조 (목표)
```
Exelion Forge
├── Character Generator   ← 현재 우선
├── Armor Generator
├── Weapon Generator
├── Material Library
├── Rig Generator
├── Animation Tools
├── Export Pipeline
└── Blender Add-on
```

## Character Generator 흐름
```
파라미터 → 기본 골격 → Body → Armor → Head/Shoulder → Weapon
→ Details → Subdivision → Rig → LOD → Export
```
Blender에서는 슬라이더(Height, Body Width, Armor Type, Wing Size 등)로 조절하면 모델이 재생성됨.

## 파라메트릭 모델링의 의미
- 브레이브 · 엠프레스 · 적 메카 · 양산기 · 보스 모두 같은 생성 시스템 공유
- 메카 디자인 언어를 코드로 정의하는 작업
- 게임 에셋뿐 아니라 **STL 피규어 판매**에도 동일 파이프라인 활용 가능

## 역할 분리
- Atlas: 개발 관리
- Forge: 에셋 생산

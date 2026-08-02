# makerfac-needs-research

메이커팩(네이버 카페) 질문&답변 게시판 기반 STL 모델링 / 3D 프린트 사업 니즈 조사 프로젝트.

## 목적
- STL 모델링 및 3D 프린트 관련 사업 아이템 발굴
- 사용자 니즈(요청, 불편, 아이디어) 파악

## 수집 원칙 (안전 우선)
- 로그인만 수동, 이후는 **기존 크롬 연결** 반자동 가능
- 세션당 **20~30개**, 글 사이 **8~20초** 대기, 일 **50개 이하**
- 이미 열람한 글 재열람 금지 (`notes/viewed-ids.md`)
- Headless 금지, 캡차·제한 시 즉시 중단
- 개인 분석 전용 (외부 공개 없음)

자세한 절차: [`tools/SAFE_COLLECT.md`](tools/SAFE_COLLECT.md)

## 구조
```
projects/makerfac-needs-research/
├── README.md
├── state/
├── templates/post-template.md
├── tools/
│   ├── SAFE_COLLECT.md      # 크롬 연결·실행 가이드
│   └── collect_safe.py      # 보수적 수집 스크립트
├── collected/
│   ├── _inbox/              # 수집 직후 미분류
│   ├── 01-모델링의뢰/
│   ├── 02-기능성부품/
│   ├── 03-출력품질이슈/
│   ├── 04-상용화판매/
│   └── 05-기타아이디어/
├── analysis/summary.md
└── notes/
    ├── session-log.md
    └── viewed-ids.md
```

## 대상
- 카페: https://cafe.naver.com/makerfac
- 게시판: https://cafe.naver.com/f-e/cafes/23815302/menus/24?viewType=L

# collected

## 주 저장 형식: `posts.jsonl`

한 줄 = 게시글 하나 (JSON Lines, UTF-8).

```json
{
  "id": "260472",
  "title": "제목",
  "url": "https://cafe.naver.com/f-e/cafes/23815302/articles/260472",
  "collected_at": "2026-08-02T13:30:00",
  "source_board": "qna",
  "category": null,
  "keywords": [],
  "need_summary": null,
  "body": "본문 텍스트…",
  "business": {
    "potential": null,
    "reason": null,
    "notes": null
  },
  "status": "inbox"
}
```

| 필드 | 설명 |
|------|------|
| `status` | `inbox` → 분류 후 `categorized` / `ignored` |
| `category` | `modeling` / `parts` / `print_quality` / `commerce` / `idea` 등 |
| `business.potential` | `high` / `medium` / `low` |

## 주제 폴더 (01~05)

예전 마크다운 분류용. 신규 수집은 **jsonl만** 사용.
기존 `_inbox/*.md` 가 있으면 필요 시 jsonl로 이관하거나 참고용으로 두면 됩니다.

## 확인 예 (PowerShell)

```powershell
Get-Content .\posts.jsonl -Tail 3 -Encoding utf8
```

```powershell
python -c "import json; print(sum(1 for _ in open('posts.jsonl',encoding='utf-8')))"
```

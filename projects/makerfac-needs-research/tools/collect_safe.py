#!/usr/bin/env python3
"""
makerfac 안전 수집 스크립트
- 크롬 CDP 연결, 글 ID 중복 스킵, 일일/세션 한도
- 게시판 여러 페이지를 돌며 신규 후보 수집
- 저장: collected/posts.jsonl
"""

from __future__ import annotations

import argparse
import json
import random
import re
import sys
import time
from datetime import date, datetime
from pathlib import Path
from urllib.parse import urlencode

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("playwright 필요: pip install playwright")
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
NOTES = ROOT / "notes"
COLLECTED = ROOT / "collected"
POSTS_JSONL = COLLECTED / "posts.jsonl"
VIEWED = NOTES / "viewed-ids.md"
SESSION_LOG = NOTES / "session-log.md"

BOARD_BASE = "https://cafe.naver.com/f-e/cafes/23815302/menus/24"
CDP_URL = "http://127.0.0.1:9222"

DEFAULT_LIMIT = 50
HARD_CAP = 60
DAILY_CAP = 100
DEFAULT_PAGES = 5
MIN_DELAY = 6.0
MAX_DELAY = 15.0

ARTICLE_ID_RE = re.compile(r"/articles/(\d+)")


def article_id(url: str) -> str | None:
    m = ARTICLE_ID_RE.search(url)
    return m.group(1) if m else None


def normalize_article_url(url: str) -> str:
    aid = article_id(url)
    if not aid:
        return url.split("?")[0]
    return f"https://cafe.naver.com/f-e/cafes/23815302/articles/{aid}"


def board_url(page_num: int) -> str:
    q = {"viewType": "L", "page": str(page_num)}
    return f"{BOARD_BASE}?{urlencode(q)}"


def is_noise_link(url: str, title: str) -> bool:
    if "commentFocus" in url:
        return True
    t = title.strip()
    if not t or len(t) < 4:
        return True
    if re.match(r"^댓글\s*수", t) or t in ("댓글수", "댓글"):
        return True
    if re.match(r"^\[\d+\]$", t):
        return True
    return False


def load_viewed_ids() -> set[str]:
    ids: set[str] = set()
    if VIEWED.exists():
        text = VIEWED.read_text(encoding="utf-8")
        ids.update(ARTICLE_ID_RE.findall(text))
        for u in re.findall(r"https://cafe\.naver\.com[^\s\)|]+", text):
            aid = article_id(u)
            if aid:
                ids.add(aid)
        for m in re.finditer(r"id:(\d+)", text):
            ids.add(m.group(1))
    if POSTS_JSONL.exists():
        with POSTS_JSONL.open(encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                    aid = str(obj.get("id") or "")
                    if aid:
                        ids.add(aid)
                except json.JSONDecodeError:
                    continue
    return ids


def count_today_in_viewed() -> int:
    if not VIEWED.exists():
        return 0
    today = date.today().isoformat()
    return sum(
        1
        for line in VIEWED.read_text(encoding="utf-8").splitlines()
        if line.startswith(f"- {today}")
    )


def append_viewed(url: str, title: str) -> None:
    NOTES.mkdir(parents=True, exist_ok=True)
    if not VIEWED.exists():
        VIEWED.write_text(
            "# 열람/저장 기록\n\n글 ID 기준 재열람 금지.\n\n## 기록\n",
            encoding="utf-8",
        )
    aid = article_id(url) or "?"
    line = (
        f"- {date.today().isoformat()} | id:{aid} | "
        f"{normalize_article_url(url)} | {title.strip()[:80]}\n"
    )
    with VIEWED.open("a", encoding="utf-8") as f:
        f.write(line)


def append_session_log(opened: int, saved: int, note: str = "") -> None:
    NOTES.mkdir(parents=True, exist_ok=True)
    if not SESSION_LOG.exists():
        SESSION_LOG.write_text("# 세션 로그\n\n## 실제 기록\n\n", encoding="utf-8")
    block = (
        f"\n### 세션 {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
        f"- **열람**: {opened}개\n"
        f"- **저장**: {saved}개\n"
        f"- **비고**: {note or 'collect_safe 자동 (jsonl)'}\n"
    )
    with SESSION_LOG.open("a", encoding="utf-8") as f:
        f.write(block)


def human_delay() -> None:
    sec = random.uniform(MIN_DELAY, MAX_DELAY)
    print(f"  … {sec:.1f}s 대기")
    time.sleep(sec)


def save_post(title: str, url: str, body: str) -> Path:
    COLLECTED.mkdir(parents=True, exist_ok=True)
    aid = article_id(url) or "unknown"
    record = {
        "id": aid,
        "title": title.strip(),
        "url": normalize_article_url(url),
        "collected_at": datetime.now().isoformat(timespec="seconds"),
        "source_board": "qna",
        "category": None,
        "keywords": [],
        "need_summary": None,
        "body": (body or "")[:8000],
        "business": {"potential": None, "reason": None, "notes": None},
        "status": "inbox",
    }
    with POSTS_JSONL.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")
    return POSTS_JSONL


def wait_list_stable(page) -> None:
    """SPA 추가 네비게이션이 끝난 뒤 링크 추출."""
    try:
        page.wait_for_load_state("domcontentloaded", timeout=15000)
    except Exception:
        pass
    try:
        page.wait_for_load_state("networkidle", timeout=20000)
    except Exception:
        pass
    # 글 링크가 나타날 때까지
    try:
        page.wait_for_selector(
            'a[href*="/articles/"]',
            timeout=20000,
        )
    except Exception:
        pass
    time.sleep(1.5)


def extract_raw_links(page) -> list[dict]:
    """한 번의 evaluate로 href/title 추출 (네비게이션에 덜 취약)."""
    return page.evaluate(
        """() => {
          const out = [];
          const seen = new Set();
          for (const a of document.querySelectorAll('a[href*="/articles/"]')) {
            let href = a.href || a.getAttribute('href') || '';
            const title = (a.innerText || '').trim();
            if (!href || !title) continue;
            if (href.includes('commentFocus')) continue;
            if (!href.includes('/cafes/23815302/articles/')) continue;
            if (seen.has(href)) continue;
            seen.add(href);
            out.push({ href, title });
          }
          return out;
        }"""
    )


def collect_links_from_page(page, viewed_ids: set[str], keyword: str) -> list[tuple[str, str]]:
    raw: list[dict] = []
    last_err: Exception | None = None
    for attempt in range(1, 4):
        try:
            wait_list_stable(page)
            raw = extract_raw_links(page) or []
            last_err = None
            break
        except Exception as e:
            last_err = e
            msg = str(e)
            print(f"  링크 추출 재시도 {attempt}/3: {msg[:80]}")
            time.sleep(2.0 * attempt)
            try:
                page.wait_for_load_state("domcontentloaded", timeout=10000)
            except Exception:
                pass
    if last_err and not raw:
        print(f"  링크 추출 실패: {last_err}")
        return []

    out: list[tuple[str, str]] = []
    seen: set[str] = set()
    for item in raw:
        href = (item.get("href") or "").strip()
        title = (item.get("title") or "").strip()
        if not href or not title:
            continue
        if href.startswith("/"):
            href = "https://cafe.naver.com" + href
        if is_noise_link(href, title):
            continue
        aid = article_id(href)
        if not aid or aid in seen or aid in viewed_ids:
            continue
        if keyword and keyword.lower() not in title.lower():
            continue
        seen.add(aid)
        out.append((title, href))
    return out


def goto_resilient(page, url: str) -> bool:
    for attempt in range(1, 4):
        try:
            page.goto(url, wait_until="domcontentloaded", timeout=60000)
            wait_list_stable(page)
            return True
        except Exception as e:
            print(f"  goto 재시도 {attempt}/3: {e}")
            time.sleep(2.0 * attempt)
    return False


def main() -> None:
    parser = argparse.ArgumentParser(description="makerfac 안전 수집")
    parser.add_argument("--keyword", default="", help="제목 키워드 필터")
    parser.add_argument("--limit", type=int, default=DEFAULT_LIMIT)
    parser.add_argument("--cdp", default=CDP_URL)
    parser.add_argument("--daily-cap", type=int, default=DAILY_CAP)
    parser.add_argument(
        "--pages", type=int, default=DEFAULT_PAGES,
        help="목록에서 탐색할 최대 페이지 수 (기본 5)",
    )
    args = parser.parse_args()
    limit = max(1, min(args.limit, HARD_CAP))
    daily_cap = max(1, args.daily_cap)
    max_pages = max(1, min(args.pages, 20))

    viewed_ids = load_viewed_ids()
    today_count = count_today_in_viewed()
    remaining_today = max(0, daily_cap - today_count)
    if remaining_today <= 0:
        print(f"오늘 한도 소진 ({today_count}/{daily_cap}). 종료.")
        sys.exit(0)
    limit = min(limit, remaining_today)

    print(f"이미 기록된 글 ID: {len(viewed_ids)}개")
    print(f"오늘 처리: {today_count}/{daily_cap} → 이번 세션 한도 {limit}")
    print(f"목록 페이지: 최대 {max_pages}페이지")
    print(f"저장: {POSTS_JSONL.relative_to(ROOT)} (JSONL)")
    print(f"대기 {MIN_DELAY}~{MAX_DELAY}s")

    with sync_playwright() as p:
        try:
            browser = p.chromium.connect_over_cdp(args.cdp)
        except Exception as e:
            print(f"크롬 연결 실패. CDP={args.cdp}\n  {e}")
            sys.exit(1)

        context = browser.contexts[0] if browser.contexts else browser.new_context()
        page = context.pages[0] if context.pages else context.new_page()

        if args.keyword:
            print(f"키워드 필터: {args.keyword}")

        candidates: list[tuple[str, str]] = []
        seen_ids: set[str] = set()

        for pg in range(1, max_pages + 1):
            url = board_url(pg)
            print(f"\n목록 페이지 {pg}/{max_pages}: {url}")
            if not goto_resilient(page, url):
                print("  목록 로드 실패 — 중단")
                break
            human_delay()
            batch = collect_links_from_page(page, viewed_ids | seen_ids, args.keyword)
            print(f"  이 페이지 신규: {len(batch)}개")
            for title, href in batch:
                aid = article_id(href)
                if aid and aid not in seen_ids:
                    seen_ids.add(aid)
                    candidates.append((title, href))
            if len(candidates) >= limit:
                print(f"  후보 {len(candidates)}개 ≥ 한도 {limit} — 목록 탐색 종료")
                break

        print(f"\n총 신규 후보: {len(candidates)}개")
        if not candidates:
            print(
                "첫 N페이지 글이 모두 이미 기록되어 있거나 링크를 못 읽었습니다.\n"
                "--pages 를 늘리거나 잠시 후 다시 실행하세요."
            )

        opened = 0
        saved = 0
        for title, href in candidates:
            if opened >= limit:
                break
            print(f"\n[{opened + 1}/{limit}] {title[:60]}")
            print(f"  {href}")
            if not goto_resilient(page, href):
                print("  열기 실패")
                append_viewed(href, title + " [open-fail]")
                human_delay()
                opened += 1
                continue

            human_delay()
            body = ""
            try:
                body = page.evaluate(
                    """() => {
                      const el = document.querySelector('article')
                        || document.querySelector('.article-board')
                        || document.querySelector('#app')
                        || document.body;
                      return el ? (el.innerText || '') : '';
                    }"""
                )
            except Exception:
                body = ""

            path = save_post(title, href, body or "")
            append_viewed(href, title)
            opened += 1
            saved += 1
            print(f"  저장 → {path.name} (id={article_id(href)})")

        append_session_log(opened, saved)
        print("\n=== 세션 종료 ===")
        print(f"열람: {opened} | 저장: {saved}")
        print(f"데이터: {POSTS_JSONL}")


if __name__ == "__main__":
    main()

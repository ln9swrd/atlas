#!/usr/bin/env python3
"""
makerfac 안전 수집 스크립트
- 이미 실행 중인 크롬(remote-debugging-port=9222)에 연결
- 세션당 소량, 긴 랜덤 대기, 글 ID 기준 재열람 방지, 일일 상한
"""

from __future__ import annotations

import argparse
import random
import re
import sys
import time
from datetime import date, datetime
from pathlib import Path
from urllib.parse import urlparse, parse_qs

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("playwright 필요: pip install playwright")
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
NOTES = ROOT / "notes"
INBOX = ROOT / "collected" / "_inbox"
VIEWED = NOTES / "viewed-ids.md"
SESSION_LOG = NOTES / "session-log.md"

BOARD_URL = (
    "https://cafe.naver.com/f-e/cafes/23815302/menus/24?viewType=L"
)
CDP_URL = "http://127.0.0.1:9222"

DEFAULT_LIMIT = 25
HARD_CAP = 30
DAILY_CAP = 50
MIN_DELAY = 8.0
MAX_DELAY = 20.0

ARTICLE_ID_RE = re.compile(r"/articles/(\d+)")


def article_id(url: str) -> str | None:
    m = ARTICLE_ID_RE.search(url)
    return m.group(1) if m else None


def normalize_article_url(url: str) -> str:
    """쿼리 제거한 본문 URL (중복 판별용)."""
    aid = article_id(url)
    if not aid:
        return url.split("?")[0]
    return f"https://cafe.naver.com/f-e/cafes/23815302/articles/{aid}"


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
    """viewed-ids.md 에서 article id 집합."""
    if not VIEWED.exists():
        return set()
    text = VIEWED.read_text(encoding="utf-8")
    ids = set(ARTICLE_ID_RE.findall(text))
    # 구형: URL만 있고 id 추출 가능한 줄
    for u in re.findall(r"https://cafe\.naver\.com[^\s\)|]+", text):
        aid = article_id(u)
        if aid:
            ids.add(aid)
    return ids


def count_today_in_viewed() -> int:
    if not VIEWED.exists():
        return 0
    today = date.today().isoformat()
    n = 0
    for line in VIEWED.read_text(encoding="utf-8").splitlines():
        if line.startswith(f"- {today}"):
            n += 1
    return n


def append_viewed(url: str, title: str) -> None:
    NOTES.mkdir(parents=True, exist_ok=True)
    if not VIEWED.exists():
        VIEWED.write_text(
            "# 열람/저장 기록\n\n"
            "글 ID 기준으로 한 번 처리한 글은 다시 열지 않습니다.\n\n"
            "## 기록\n",
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
        f"- **비고**: {note or 'collect_safe 자동'}\n"
    )
    with SESSION_LOG.open("a", encoding="utf-8") as f:
        f.write(block)


def human_delay() -> None:
    sec = random.uniform(MIN_DELAY, MAX_DELAY)
    print(f"  … {sec:.1f}s 대기")
    time.sleep(sec)


def save_inbox(title: str, url: str, body: str) -> Path:
    INBOX.mkdir(parents=True, exist_ok=True)
    safe = re.sub(r"[^\w가-힣\-]+", "_", title)[:60] or "post"
    aid = article_id(url) or "x"
    path = INBOX / f"{date.today().isoformat()}_{aid}_{safe}.md"
    if path.exists():
        path = INBOX / f"{date.today().isoformat()}_{aid}_{safe}_{int(time.time())}.md"
    content = (
        f"# 수집 기록 – 미분류\n\n"
        f"## 게시글 정보\n"
        f"- **제목**: {title}\n"
        f"- **작성일**: (확인 후 기입)\n"
        f"- **원문 링크**: {normalize_article_url(url)}\n"
        f"- **수집일**: {date.today().isoformat()}\n\n"
        f"## 핵심 니즈 요약\n- (검토 후 작성)\n\n"
        f"## 본문 주요 내용\n\n{body[:4000]}\n\n"
        f"## 관련 키워드\n- \n\n"
        f"## 사업 아이템 관점 메모\n"
        f"- 가능성: (높음 / 보통 / 낮음)\n"
        f"- 이유: \n"
    )
    path.write_text(content, encoding="utf-8")
    return path


def main() -> None:
    parser = argparse.ArgumentParser(description="makerfac 안전 수집")
    parser.add_argument("--keyword", default="", help="검색 키워드 (선택)")
    parser.add_argument(
        "--limit", type=int, default=DEFAULT_LIMIT, help="세션 최대 열람 수"
    )
    parser.add_argument("--cdp", default=CDP_URL, help="Chrome CDP URL")
    parser.add_argument(
        "--daily-cap", type=int, default=DAILY_CAP, help="하루 최대 열람 수"
    )
    args = parser.parse_args()
    limit = max(1, min(args.limit, HARD_CAP))
    daily_cap = max(1, args.daily_cap)

    viewed_ids = load_viewed_ids()
    today_count = count_today_in_viewed()
    remaining_today = max(0, daily_cap - today_count)
    if remaining_today <= 0:
        print(f"오늘 한도 소진 ({today_count}/{daily_cap}). 종료.")
        sys.exit(0)
    limit = min(limit, remaining_today)

    print(f"이미 기록된 글 ID: {len(viewed_ids)}개")
    print(f"오늘 처리: {today_count}/{daily_cap} → 이번 세션 한도 {limit}")
    print(f"대기 {MIN_DELAY}~{MAX_DELAY}s")

    with sync_playwright() as p:
        try:
            browser = p.chromium.connect_over_cdp(args.cdp)
        except Exception as e:
            print(
                "크롬 연결 실패. 디버깅 포트로 크롬을 먼저 실행하세요.\n"
                f"  CDP: {args.cdp}\n  오류: {e}"
            )
            sys.exit(1)

        context = browser.contexts[0] if browser.contexts else browser.new_context()
        page = context.pages[0] if context.pages else context.new_page()

        if args.keyword:
            print(f"키워드 필터: {args.keyword}")

        print(f"이동: {BOARD_URL}")
        page.goto(BOARD_URL, wait_until="domcontentloaded", timeout=60000)
        human_delay()

        anchors = page.locator('a[href*="/cafes/23815302/articles/"]').all()
        candidates: list[tuple[str, str]] = []
        seen_ids: set[str] = set()
        for a in anchors:
            try:
                href = a.get_attribute("href") or ""
                title = (a.inner_text() or "").strip()
            except Exception:
                continue
            if not href or not title:
                continue
            if href.startswith("/"):
                href = "https://cafe.naver.com" + href
            if is_noise_link(href, title):
                continue
            aid = article_id(href)
            if not aid or aid in seen_ids or aid in viewed_ids:
                continue
            if args.keyword and args.keyword.lower() not in title.lower():
                continue
            seen_ids.add(aid)
            candidates.append((title, href))

        print(f"신규 후보: {len(candidates)}개")
        opened = 0
        saved = 0

        for title, href in candidates:
            if opened >= limit:
                break
            print(f"\n[{opened + 1}/{limit}] {title[:60]}")
            print(f"  {href}")
            try:
                page.goto(href, wait_until="domcontentloaded", timeout=60000)
            except Exception as e:
                print(f"  열기 실패: {e}")
                append_viewed(href, title + " [open-fail]")
                human_delay()
                opened += 1
                continue

            human_delay()
            body = ""
            for sel in ["article", ".article-board", "#app", "body"]:
                loc = page.locator(sel).first
                try:
                    if loc.count():
                        body = loc.inner_text(timeout=5000)
                        if len(body) > 80:
                            break
                except Exception:
                    continue

            path = save_inbox(title, href, body or "(본문 추출 실패 — 수동 확인)")
            append_viewed(href, title)
            opened += 1
            saved += 1
            print(f"  저장: {path.relative_to(ROOT)}")

        append_session_log(opened, saved)
        print("\n=== 세션 종료 ===")
        print(f"열람: {opened} | 저장: {saved}")
        print("session-log.md 에 자동 기록됨.")
        print("의심 화면(캡차 등)이 보였다면 오늘은 추가 실행하지 마세요.")


if __name__ == "__main__":
    main()

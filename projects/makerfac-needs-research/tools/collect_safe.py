#!/usr/bin/env python3
"""
makerfac 안전 수집 스크립트
- 이미 실행 중인 크롬(remote-debugging-port=9222)에 연결
- 세션당 소량, 긴 랜덤 대기, viewed-ids 스킵
"""

from __future__ import annotations

import argparse
import random
import re
import sys
import time
from datetime import date
from pathlib import Path

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("playwright 필요: pip install playwright")
    sys.exit(1)

# --- 경로 (tools/ 기준 상위 = 프로젝트 루트) ---
ROOT = Path(__file__).resolve().parent.parent
NOTES = ROOT / "notes"
INBOX = ROOT / "collected" / "_inbox"
VIEWED = NOTES / "viewed-ids.md"

BOARD_URL = (
    "https://cafe.naver.com/f-e/cafes/23815302/menus/24?viewType=L"
)
CDP_URL = "http://127.0.0.1:9222"

# --- 안전 기본값 ---
DEFAULT_LIMIT = 25
MIN_DELAY = 8.0
MAX_DELAY = 20.0


def load_viewed_urls() -> set[str]:
    if not VIEWED.exists():
        return set()
    text = VIEWED.read_text(encoding="utf-8")
    return set(re.findall(r"https://cafe\.naver\.com[^\s\)|]+", text))


def append_viewed(url: str, title: str) -> None:
    NOTES.mkdir(parents=True, exist_ok=True)
    if not VIEWED.exists():
        VIEWED.write_text(
            "# 열람/저장 기록\n\n"
            "한 번 처리한 글은 다시 열지 않습니다.\n\n"
            "## 기록\n",
            encoding="utf-8",
        )
    line = f"- {date.today().isoformat()} | {url} | {title.strip()[:80]}\n"
    with VIEWED.open("a", encoding="utf-8") as f:
        f.write(line)


def human_delay() -> None:
    sec = random.uniform(MIN_DELAY, MAX_DELAY)
    print(f"  … {sec:.1f}s 대기")
    time.sleep(sec)


def save_inbox(title: str, url: str, body: str) -> Path:
    INBOX.mkdir(parents=True, exist_ok=True)
    safe = re.sub(r"[^\w가-힣\-]+", "_", title)[:60] or "post"
    path = INBOX / f"{date.today().isoformat()}_{safe}.md"
    content = (
        f"# 수집 기록 – 미분류\n\n"
        f"## 게시글 정보\n"
        f"- **제목**: {title}\n"
        f"- **작성일**: (확인 후 기입)\n"
        f"- **원문 링크**: {url}\n"
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
    parser.add_argument(
        "--cdp", default=CDP_URL, help="Chrome CDP URL"
    )
    args = parser.parse_args()
    limit = max(1, min(args.limit, 30))  # 하드캡 30

    viewed = load_viewed_urls()
    print(f"이미 기록된 URL: {len(viewed)}개")
    print(f"세션 한도: {limit} | 대기 {MIN_DELAY}~{MAX_DELAY}s")

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

        target = BOARD_URL
        if args.keyword:
            # 카페 내 검색은 UI가 자주 바뀜 → 우선 게시판 진입 후 사용자가 검색해도 됨
            print(f"키워드 힌트: {args.keyword} (목록에서 제목 필터에 사용)")

        print(f"이동: {target}")
        page.goto(target, wait_until="domcontentloaded", timeout=60000)
        human_delay()

        # 링크 수집 (네이버 카페 DOM은 변경될 수 있음 → 느슨한 셀렉터)
        anchors = page.locator('a[href*="/cafes/23815302/articles/"]').all()
        candidates: list[tuple[str, str]] = []
        seen_href: set[str] = set()
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
            if href in seen_href or href in viewed:
                continue
            if args.keyword and args.keyword.lower() not in title.lower():
                continue
            seen_href.add(href)
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

        print("\n=== 세션 종료 ===")
        print(f"열람: {opened} | 저장: {saved}")
        print("notes/session-log.md 에 오늘 세션을 기록하세요.")
        print("의심 화면(캡차 등)이 보였다면 오늘은 추가 실행하지 마세요.")


if __name__ == "__main__":
    main()

#!/usr/bin/env bash
# 마스터용 L-8 / L-9 / L-10(부분) 배치
# Repo root에서 실행:  bash scripts/master_l8_l10.sh <command>
# 문서: docs/06_OPERATIONS/MASTER_BATCH.md
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BRANCH_IMPL="impl/atlas-extension"
EXT_DIR="projects/atlas-extension"

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

need_git_clean_or_confirm() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "WARNING: working tree not clean:"
    git status --short
    read -r -p "Continue anyway? [y/N] " ans
    [[ "${ans:-}" =~ ^[Yy]$ ]] || die "aborted"
  fi
}

cmd_status() {
  info "repo: $ROOT"
  info "branch: $(git branch --show-current 2>/dev/null || echo '?')"
  git fetch origin 2>/dev/null || true
  echo "--- origin/main ---"
  git log -1 --oneline origin/main 2>/dev/null || echo "(no origin/main)"
  echo "--- origin/${BRANCH_IMPL} ---"
  git log -1 --oneline "origin/${BRANCH_IMPL}" 2>/dev/null || echo "(no remote branch)"
  echo "--- tracked junk? ---"
  git ls-files "${EXT_DIR}/node_modules" 2>/dev/null | head -3 || true
  git ls-files "${EXT_DIR}"/*.vsix 2>/dev/null || true
  if git ls-files "${EXT_DIR}/node_modules" 2>/dev/null | grep -q .; then
    echo "STATUS: node_modules still tracked → run: bash scripts/master_l8_l10.sh l9"
  else
    echo "STATUS: node_modules not in index (good or never tracked)"
  fi
}

# L-8: rebase impl onto main
cmd_l8() {
  info "L-8: fetch + rebase ${BRANCH_IMPL} onto origin/main"
  need_git_clean_or_confirm
  git fetch origin
  git checkout "${BRANCH_IMPL}"
  git rebase origin/main
  info "L-8 OK. If conflicts were fixed: git add … && git rebase --continue"
  info "Evidence line: L-8 rebase ok ($(git rev-parse --short HEAD))"
}

# L-9: untrack node_modules / vsix, commit, push
cmd_l9() {
  info "L-9: untrack node_modules and vsix on ${BRANCH_IMPL}"
  git fetch origin
  git checkout "${BRANCH_IMPL}"

  local changed=0
  if git ls-files "${EXT_DIR}/node_modules" 2>/dev/null | grep -q .; then
    git rm -r --cached "${EXT_DIR}/node_modules"
    changed=1
  else
    info "node_modules not tracked — skip rm"
  fi

  # shellcheck disable=SC2086
  if git ls-files "${EXT_DIR}"/*.vsix 2>/dev/null | grep -q .; then
    git rm --cached "${EXT_DIR}"/*.vsix 2>/dev/null || true
    changed=1
  else
    info "no tracked vsix — skip"
  fi

  if [[ "$changed" -eq 0 ]]; then
    info "Nothing to untrack. Still push if you need remote sync."
  else
    git commit -m "chore(extension): stop tracking node_modules and vsix"
  fi

  info "Pushing ${BRANCH_IMPL}…"
  git push origin "${BRANCH_IMPL}"
  info "L-9 OK. Evidence: L-9 untrack/push ($(git rev-parse --short HEAD))"
}

# L-8 then L-9
cmd_l8_l9() {
  cmd_l8
  cmd_l9
  info "Batch L-8+L-9 done. HEAD=$(git rev-parse --short HEAD)"
  echo "Paste into state/TASK_MAP Evidence:"
  echo "Evidence: L-8 rebase + L-9 untrack/push ($(git rev-parse --short HEAD))"
}

# L-10 partial: npm only (no F5)
cmd_l10_npm() {
  info "L-10 partial: npm install + compile (F5 is manual)"
  command -v npm >/dev/null || die "npm not found"
  cd "${ROOT}/${EXT_DIR}"
  npm install
  npm run compile
  cd "$ROOT"
  info "Compile OK. Do NOT commit node_modules."
  info "Next: VS Code → open repo → F5 → docs/04_IDE_EXTENSION/F5_CHECKLIST.md"
}

cmd_help() {
  cat <<'EOF'
Usage: bash scripts/master_l8_l10.sh <command>

Commands:
  status     Remote tips + whether node_modules still tracked
  l8         Rebase impl/atlas-extension onto origin/main
  l9         Untrack node_modules/vsix, commit, push impl branch
  l8-l9      l8 then l9 (recommended batch)
  l10-npm    npm install + compile under projects/atlas-extension
  help       This text

Not automated (마스터 manual):
  - F5 Extension Host smoke (dev PC + Ollama)
  - PR #3 merge + tag
  - G6 Decision 승인 (docs/06_OPERATIONS/G6_DECISION_DRAFTS.md)
  - state/ TASK_MAP Evidence 한 줄 기록

Run from any cwd; script cds to repo root.
EOF
}

main() {
  local c="${1:-help}"
  case "$c" in
    status)  cmd_status ;;
    l8)      cmd_l8 ;;
    l9)      cmd_l9 ;;
    l8-l9)   cmd_l8_l9 ;;
    l10-npm) cmd_l10_npm ;;
    help|-h|--help) cmd_help ;;
    *) die "unknown command: $c (try: help)" ;;
  esac
}

main "$@"

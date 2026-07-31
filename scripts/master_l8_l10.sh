#!/usr/bin/env bash
# 마스터용 L-8 / L-9 / L-10(부분) 배치
#   bash scripts/master_l8_l10.sh <command>
# 원격 이름이 origin이 아니면 자동 탐지 (github 등) 또는:
#   GIT_REMOTE=github bash scripts/master_l8_l10.sh l8-l9
# 문서: docs/06_OPERATIONS/MASTER_BATCH.md
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BRANCH_IMPL="impl/atlas-extension"
BRANCH_MAIN="main"
EXT_DIR="projects/atlas-extension"

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }
warn() { echo "WARNING: $*" >&2; }

# Prefer GIT_REMOTE env, else origin, else github, else first remote
resolve_remote() {
  if [[ -n "${GIT_REMOTE:-}" ]]; then
    echo "$GIT_REMOTE"
    return
  fi
  if git remote get-url origin >/dev/null 2>&1; then
    echo "origin"
    return
  fi
  if git remote get-url github >/dev/null 2>&1; then
    echo "github"
    return
  fi
  local first
  first="$(git remote 2>/dev/null | head -1 || true)"
  if [[ -n "$first" ]]; then
    echo "$first"
    return
  fi
  echo ""
}

REMOTE="$(resolve_remote)"

need_git_clean_or_confirm() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "WARNING: working tree not clean:"
    git status --short
    if [[ ! -t 0 ]]; then
      die "dirty tree and no TTY — commit/stash first or run interactively"
    fi
    read -r -p "Continue anyway? [y/N] " ans
    [[ "${ans:-}" =~ ^[Yy]$ ]] || die "aborted"
  fi
}

fetch_remote() {
  if [[ -z "$REMOTE" ]]; then
    warn "no git remote configured — skip fetch"
    return 1
  fi
  info "fetch $REMOTE"
  git fetch "$REMOTE" || {
    warn "fetch $REMOTE failed"
    return 1
  }
  return 0
}

cmd_status() {
  info "repo: $ROOT"
  info "branch: $(git branch --show-current 2>/dev/null || echo '?')"
  info "remotes:"
  git remote -v 2>/dev/null || echo "  (none)"
  info "resolved REMOTE=${REMOTE:-'(none)'}  (override: GIT_REMOTE=name)"
  fetch_remote || true
  if [[ -n "$REMOTE" ]]; then
    echo "--- ${REMOTE}/${BRANCH_MAIN} ---"
    git log -1 --oneline "${REMOTE}/${BRANCH_MAIN}" 2>/dev/null || echo "(no ${REMOTE}/${BRANCH_MAIN})"
    echo "--- ${REMOTE}/${BRANCH_IMPL} ---"
    git log -1 --oneline "${REMOTE}/${BRANCH_IMPL}" 2>/dev/null || echo "(no ${REMOTE}/${BRANCH_IMPL})"
  fi
  echo "--- local main ---"
  git log -1 --oneline "${BRANCH_MAIN}" 2>/dev/null || echo "(no local main)"
  echo "--- local ${BRANCH_IMPL} ---"
  git log -1 --oneline "${BRANCH_IMPL}" 2>/dev/null || echo "(no local ${BRANCH_IMPL})"
  echo "--- tracked junk (sample) ---"
  git ls-files "${EXT_DIR}/node_modules" 2>/dev/null | head -3 || true
  git ls-files "${EXT_DIR}"/*.vsix 2>/dev/null || true
  local ncount
  ncount="$(git ls-files "${EXT_DIR}/node_modules" 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "${ncount:-0}" -gt 0 ]]; then
    echo "STATUS: node_modules still tracked ($ncount paths) → run: bash scripts/master_l8_l10.sh l9"
  else
    echo "STATUS: node_modules not in index"
  fi
  command -v npm >/dev/null && echo "STATUS: npm=$(command -v npm)" || echo "STATUS: npm not found (l10-npm skip on this machine)"
}

# L-8: rebase impl onto main (remote if available, else local main)
cmd_l8() {
  need_git_clean_or_confirm
  local base="${BRANCH_MAIN}"
  if fetch_remote && git rev-parse --verify "${REMOTE}/${BRANCH_MAIN}" >/dev/null 2>&1; then
    base="${REMOTE}/${BRANCH_MAIN}"
  else
    warn "using local ${BRANCH_MAIN} as rebase base"
    git rev-parse --verify "${BRANCH_MAIN}" >/dev/null 2>&1 || die "no ${BRANCH_MAIN} branch"
  fi
  info "L-8: checkout ${BRANCH_IMPL} && rebase onto ${base}"
  git show-ref --verify --quiet "refs/heads/${BRANCH_IMPL}" \
    || die "branch ${BRANCH_IMPL} missing — create or fetch it first"
  git checkout "${BRANCH_IMPL}"
  git rebase "${base}"
  info "L-8 OK. HEAD=$(git rev-parse --short HEAD)"
  echo "Evidence: L-8 rebase ok ($(git rev-parse --short HEAD)) base=${base}"
}

# L-9: untrack; push only if remote works
cmd_l9() {
  info "L-9: untrack node_modules/vsix on ${BRANCH_IMPL}"
  git show-ref --verify --quiet "refs/heads/${BRANCH_IMPL}" \
    || die "branch ${BRANCH_IMPL} missing"
  git checkout "${BRANCH_IMPL}"

  local changed=0
  if git ls-files "${EXT_DIR}/node_modules" 2>/dev/null | grep -q .; then
    git rm -r --cached "${EXT_DIR}/node_modules"
    changed=1
  else
    info "node_modules not tracked — skip"
  fi

  local vsix_list
  vsix_list="$(git ls-files "${EXT_DIR}" | grep '\.vsix$' || true)"
  if [[ -n "$vsix_list" ]]; then
    # shellcheck disable=SC2086
    echo "$vsix_list" | xargs -r git rm --cached
    changed=1
  else
    info "no tracked vsix — skip"
  fi

  if [[ "$changed" -eq 0 ]]; then
    info "Nothing to untrack."
  else
    git commit -m "chore(extension): stop tracking node_modules and vsix"
  fi

  if [[ -z "$REMOTE" ]]; then
    warn "no remote — skip push. Add remote then: git push <remote> ${BRANCH_IMPL}"
  else
    info "push ${REMOTE} ${BRANCH_IMPL}"
    if git push "$REMOTE" "${BRANCH_IMPL}"; then
      info "push OK"
    else
      warn "push failed — untrack commit is local only. Fix remote auth and push later."
    fi
  fi
  echo "Evidence: L-9 untrack ($(git rev-parse --short HEAD)) remote=${REMOTE:-none}"
}

cmd_l8_l9() {
  cmd_l8
  cmd_l9
  info "Batch L-8+L-9 done. HEAD=$(git rev-parse --short HEAD)"
  echo "Paste TASK_MAP Evidence:"
  echo "Evidence: L-8 rebase + L-9 untrack ($(git rev-parse --short HEAD))"
}

cmd_l10_npm() {
  info "L-10 partial: npm install + compile"
  command -v npm >/dev/null || die "npm not found — install Node.js or run on machine with npm"
  cd "${ROOT}/${EXT_DIR}"
  npm install
  npm run compile
  cd "$ROOT"
  info "Compile OK. Do NOT commit node_modules."
  info "Next: VS Code F5 → docs/04_IDE_EXTENSION/F5_CHECKLIST.md (or impl branch copy)"
}

cmd_help() {
  cat <<EOF
Usage: bash scripts/master_l8_l10.sh <command>

Commands:
  status     Remotes, tracked junk, npm availability
  l8         Rebase ${BRANCH_IMPL} onto main (remote or local)
  l9         Untrack node_modules/vsix, commit, push if remote OK
  l8-l9      l8 then l9
  l10-npm    npm install + compile
  help       This text

Env:
  GIT_REMOTE=github   Force remote name (your machine often uses 'github' not 'origin')

Examples:
  git remote -v
  GIT_REMOTE=github bash scripts/master_l8_l10.sh status
  bash scripts/master_l8_l10.sh l9

Manual: F5, PR merge, G6 approve, TASK_MAP Evidence line
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
    *) die "unknown: $c (try help)" ;;
  esac
}

main "$@"

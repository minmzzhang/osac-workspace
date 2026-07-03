#!/usr/bin/env bash
set -euo pipefail

# sync-forks.sh — Sync your GitHub forks with their upstream repos.
#
# bootstrap.sh keeps local clones fast-forwarded against `origin/main`, but it
# never pushes those updates to the fork repos hosted on GitHub (it only adds
# and fetches the `fork` remote). Over time your forks on GitHub drift further
# and further behind upstream, which then requires PR branches (rebased onto
# a stale fork) to be force-pushed once you notice.
#
# This script checks the workspace root plus every immediate subdirectory,
# finds repos that have a recognizable upstream/fork remote pair, and calls
# `gh repo sync` to bring the fork's default branch up to date directly on
# GitHub. It then fetches the fork remote locally so local refs match too.
#
# Two remote naming conventions are supported, since they coexist in this
# workspace:
#   - origin=upstream, fork=your fork   (used by bootstrap.sh for component
#     repos like osac-installer, osac-aap, etc.)
#   - origin=your fork, upstream=parent (the standard `gh repo fork --clone`
#     convention; used by the osac-workspace repo itself)
#
# Usage:
#   ./sync-forks.sh              Sync all discovered forks (fast-forward only)
#   ./sync-forks.sh --force      Hard-reset forks to match upstream (use if a
#                                 fork's default branch has diverged, e.g. from
#                                 commits pushed directly to it)
#   ./sync-forks.sh <dir> [...]  Only sync the given dirs (use "." for the
#                                 workspace root repo itself)
#   ./sync-forks.sh --help       Show this help message

FORCE=false
DIRS=()

usage() {
  sed -n '2,29p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --help|-h) usage; exit 0 ;;
    *) DIRS+=("$arg") ;;
  esac
done

if ! command -v gh &>/dev/null; then
  echo "Error: gh CLI is not installed. Install it: https://cli.github.com/"
  exit 1
fi
if ! gh auth status &>/dev/null; then
  echo "Error: gh CLI is not authenticated. Run 'gh auth login'."
  exit 1
fi

repo_slug_from_url() {
  # Normalizes both SSH and HTTPS remote URLs to "owner/repo".
  local url="$1"
  echo "$url" | sed -E 's#^(git@github\.com:|https://github\.com/)##; s#\.git$##'
}

# Given a dir, print "source_remote dest_remote" (the remote to sync FROM and
# the remote whose GitHub-hosted fork should be updated), or nothing if the
# dir doesn't match either supported convention.
detect_remote_pair() {
  local dir="$1"
  local has_origin=false has_fork=false has_upstream=false
  git -C "$dir" remote get-url origin &>/dev/null && has_origin=true
  git -C "$dir" remote get-url fork &>/dev/null && has_fork=true
  git -C "$dir" remote get-url upstream &>/dev/null && has_upstream=true

  if [ "$has_origin" = true ] && [ "$has_fork" = true ]; then
    echo "origin fork"
  elif [ "$has_origin" = true ] && [ "$has_upstream" = true ]; then
    echo "upstream origin"
  fi
}

# Discover repos: the workspace root itself, plus any immediate subdirectory,
# that is a git repo matching one of the two supported remote conventions.
if [ ${#DIRS[@]} -eq 0 ]; then
  DIRS+=(".")
  for d in */; do
    d="${d%/}"
    DIRS+=("$d")
  done
fi

echo "Checking for forks to sync..."
[ "$FORCE" = true ] && echo "   (using --force: fork default branches will be hard-reset)"
echo ""

FAILED=()
SYNCED=()
CHECKED=0

for dir in "${DIRS[@]}"; do
  # Require the directory itself to own a .git entry (dir or file, for
  # submodules) so plain subdirectories don't fall back to a parent repo's
  # git context and get misdetected as separate repos.
  if [ ! -e "$dir/.git" ]; then
    continue
  fi

  read -r source_remote dest_remote <<< "$(detect_remote_pair "$dir")"
  if [ -z "${source_remote:-}" ]; then
    continue
  fi
  CHECKED=$((CHECKED + 1))

  label="$dir"
  [ "$dir" = "." ] && label="$(basename "$(pwd)") (root)"

  source_url=$(git -C "$dir" remote get-url "$source_remote")
  dest_url=$(git -C "$dir" remote get-url "$dest_remote")
  source_slug=$(repo_slug_from_url "$source_url")
  dest_slug=$(repo_slug_from_url "$dest_url")

  echo "$label  (${dest_slug} <- ${source_slug})"

  default_branch=$(gh api "repos/${source_slug}" -q .default_branch 2>/dev/null) || {
    echo "   Could not determine default branch for ${source_slug}. Skipping."
    FAILED+=("$dir")
    echo ""
    continue
  }

  sync_args=(repo sync "$dest_slug" --source "$source_slug" --branch "$default_branch")
  [ "$FORCE" = true ] && sync_args+=(--force)

  if gh "${sync_args[@]}" 2>&1 | sed 's/^/   /'; then
    git -C "$dir" fetch "$dest_remote" "$default_branch" --quiet 2>/dev/null || true
    echo "   Synced ${dest_slug}#${default_branch}"
    SYNCED+=("$dir")
  else
    echo "   Sync failed for ${dest_slug} — it may have diverged. Re-run with --force to hard-reset it."
    FAILED+=("$dir")
  fi
  echo ""
done

if [ "$CHECKED" -eq 0 ]; then
  echo "No repos with a recognizable upstream/fork remote pair found."
  exit 0
fi

echo "----------------------------------------"
echo "Synced: ${#SYNCED[@]}"
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "Failed: ${#FAILED[@]} (${FAILED[*]})"
  echo "   Diverged forks need --force to hard-reset, e.g.:"
  echo "   ./sync-forks.sh --force ${FAILED[*]}"
  exit 1
fi

#!/usr/bin/env bash
# vault-git-sync: pull/commit (optional push) an Obsidian vault git repo
# bash 3.2 compatible
set -euo pipefail

DEFAULT_VAULT_PARENT_1="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
DEFAULT_VAULT_1="$DEFAULT_VAULT_PARENT_1/Obsidian Vault"

usage() {
  echo "usage:" >&2
  echo "  $0 status [--vault DIR]" >&2
  echo "  $0 sync [--vault DIR] [--message MSG] [--no-pull] [--push]" >&2
  echo >&2
  echo "env:" >&2
  echo "  OBSIDIAN_VAULT_DIR   default vault dir" >&2
  echo "  VAULT_GIT_SYNC_ALLOW_PUSH=1   required to allow --push" >&2
}

die() { echo "vault-git-sync: $*" >&2; exit 2; }

pick_default_vault() {
  if [ -n "${OBSIDIAN_VAULT_DIR:-}" ]; then
    echo "$OBSIDIAN_VAULT_DIR"; return 0
  fi
  if [ -d "$DEFAULT_VAULT_1" ]; then
    echo "$DEFAULT_VAULT_1"; return 0
  fi
  if [ -d "$DEFAULT_VAULT_PARENT_1" ]; then
    for d in "$DEFAULT_VAULT_PARENT_1"/*; do
      if [ -d "$d" ]; then
        echo "$d"; return 0
      fi
    done
  fi
  echo ""; return 0
}

cmd=${1:-}
shift || true

vault=""
message=""
do_pull=1
want_push=0

parse_flags() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --vault) shift; vault=${1:-}; [ -n "$vault" ] || die "--vault needs a DIR" ;;
      --message) shift; message=${1:-}; [ -n "$message" ] || die "--message needs a MSG" ;;
      --no-pull) do_pull=0 ;;
      --push) want_push=1 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown arg: $1" ;;
    esac
    shift || true
  done
}

ensure_repo() {
  [ -n "$vault" ] || vault=$(pick_default_vault)
  [ -n "$vault" ] || die "cannot determine vault dir; pass --vault DIR or set OBSIDIAN_VAULT_DIR"
  [ -d "$vault" ] || die "vault dir not found: $vault"
  [ -d "$vault/.git" ] || die "not a git repo (missing .git): $vault"
}

show_status() {
  ensure_repo
  (cd "$vault" && git status -sb)
}

sync_repo() {
  ensure_repo
  ( cd "$vault"
    if [ $do_pull -eq 1 ]; then
      git pull --rebase || die "git pull --rebase failed"
    fi
    git add -A
    if git diff --cached --quiet; then
      echo "no changes"
    else
      if [ -z "$message" ]; then
        message="vault sync $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      fi
      git commit -m "$message" || die "git commit failed"
      echo "committed"
    fi
    if [ $want_push -eq 1 ]; then
      if [ "${VAULT_GIT_SYNC_ALLOW_PUSH:-}" != "1" ]; then
        die "refusing to push: set VAULT_GIT_SYNC_ALLOW_PUSH=1"
      fi
      git push || die "git push failed"
      echo "pushed"
    else
      echo "push skipped"
    fi
  )
}

case "$cmd" in
  status) parse_flags "$@"; show_status ;;
  sync) parse_flags "$@"; sync_repo ;;
  -h|--help|help|"") usage; exit 0 ;;
  *) die "unknown command: $cmd" ;;
esac

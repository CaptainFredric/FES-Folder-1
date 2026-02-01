#!/usr/bin/env bash
set -euo pipefail

# Usage: copy_dan_local.sh /path/to/DanDeBugger.md
# Walks local ~/Documents/GitHub (or provided base) for git repos and copies the
# file into each repo at .vscode/DanDeBugger.md (default). Dry-run by default.

SRC="${1:-$HOME/Documents/GitHub/docs/DanDeBugger.md}"
BASE_DIR="${2:-$HOME/Documents/GitHub}"
DEST_REL=".vscode/DanDeBugger.md"
DRY_RUN=1

if [ "$SRC" = "--apply" ]; then
  echo "Usage: $0 /path/to/DanDeBugger.md [base_dir]"
  exit 1
fi

if [ ! -f "$SRC" ]; then
  echo "Source file not found: $SRC"
  exit 1
fi

echo "Source: $SRC"
echo "Base dir: $BASE_DIR"

read -r -p "Proceed with dry-run? (y to continue) " ans
if [ "$ans" = "y" ]; then
  DRY_RUN=1
else
  read -r -p "Set DRY_RUN=0 to actually copy and commit (type 'apply' to proceed): " applyans
  if [ "$applyans" = "apply" ]; then
    DRY_RUN=0
  else
    echo "Aborting. No changes made."; exit 0
  fi
fi

find "$BASE_DIR" -type d -name ".git" -print0 |
while IFS= read -r -d '' gitdir; do
  repo_root="$(dirname "$gitdir")"
  dest="$repo_root/$DEST_REL"
  echo "Repo: $repo_root"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  DRY RUN: would copy $SRC -> $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$SRC" "$dest"
    pushd "$repo_root" >/dev/null
    git add "$DEST_REL"
    if ! git diff --cached --quiet --exit-code; then
      git commit -m "chore: add DanDeBugger instructions"
      git push
      echo "  Committed and pushed $DEST_REL"
    else
      echo "  No changes to commit for $DEST_REL"
    fi
    popd >/dev/null
  fi
done

echo "All done. DRY_RUN=$DRY_RUN"

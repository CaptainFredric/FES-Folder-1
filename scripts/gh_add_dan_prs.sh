#!/usr/bin/env bash
set -euo pipefail

# Usage: gh_add_dan_prs.sh /path/to/local/DanDeBugger.md
# Creates a branch in each repo in your account, adds the file at the chosen path,
# pushes the branch and opens a PR. Dry-run mode is default.

OWNER="CaptainFredric"                       # update if needed
LOCAL_FILE="${1:-./docs/DanDeBugger.md}"    # first arg or default to docs/DanDeBugger.md
TARGET_PATH="docs/DanDeBugger.md"            # path inside each repo
BRANCH_PREFIX="chore/add-dan-de-bugger"
COMMIT_MSG="chore: add DanDeBugger instructions"
DRY_RUN=1

if [ "$1" = "--apply" ]; then
  DRY_RUN=0
fi

if [ ! -f "$LOCAL_FILE" ]; then
  echo "Local file not found: $LOCAL_FILE"
  exit 1
fi

echo "Using local file: $LOCAL_FILE"

# Ensure gh is authenticated
if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found. Install and authenticate (gh auth login) first."
  exit 1
fi

repos=$(gh repo list "$OWNER" --limit 500 --json name -q '.[].name')

for repo in $repos; do
  echo "Processing: $repo"
  tmpdir=$(mktemp -d)
  git clone "https://github.com/$OWNER/$repo.git" "$tmpdir"
  pushd "$tmpdir" >/dev/null

  branch="${BRANCH_PREFIX}-$(date +%s)"
  git checkout -b "$branch"
  mkdir -p "$(dirname $TARGET_PATH)"
  cp "$LOCAL_FILE" "$TARGET_PATH"
  git add "$TARGET_PATH"
  if git diff --cached --quiet --exit-code; then
    echo "  No changes to commit for $repo"
  else
    git commit -m "$COMMIT_MSG"
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "  DRY RUN: would push branch $branch and open PR for $repo"
    else
      git push --set-upstream origin "$branch"
      gh pr create --title "$COMMIT_MSG" --body "Adds DanDeBugger instructions." --base main --head "$branch" || true
      echo "  PR opened for $repo"
    fi
  fi

  popd >/dev/null
  rm -rf "$tmpdir"
done

echo "Done. DRY_RUN=$DRY_RUN"

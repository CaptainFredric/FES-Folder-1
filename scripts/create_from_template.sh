#!/usr/bin/env bash
set -euo pipefail

# Usage: create_from_template.sh new-repo-name [--private|--public] [--description "desc"]
# Requires gh CLI authenticated.

TEMPLATE_OWNER="CaptainFredric"
TEMPLATE_REPO="dan-de-bugger-template"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 new-repo-name [--private|--public] [--description \"desc\"]"
  exit 1
fi

NEW_REPO="$1"
shift || true

VISIBILITY="public"
DESC=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --private) VISIBILITY="private"; shift ;;
    --public) VISIBILITY="public"; shift ;;
    --description) DESC="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

echo "Creating repo $NEW_REPO from template $TEMPLATE_OWNER/$TEMPLATE_REPO (visibility=$VISIBILITY)"

gh repo create "$NEW_REPO" --template "$TEMPLATE_OWNER/$TEMPLATE_REPO" --$VISIBILITY --confirm --description "$DESC"

echo "Repository created: https://github.com/$TEMPLATE_OWNER/$NEW_REPO"

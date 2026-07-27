#!/usr/bin/env bash
# Holt zu Sitzungsbeginn den aktuellen Online-Stand von My Island,
# damit auf der neuesten Fassung weitergearbeitet wird.
set -uo pipefail

ZIEL_BRANCH="main"

cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

origin="$(git remote get-url origin 2>/dev/null || true)"
printf '%s' "$origin" | grep -qi 'myisland' || exit 0

git fetch --quiet origin "$ZIEL_BRANCH" >/dev/null 2>&1 || exit 0

# Nur wenn nichts Unfertiges herumliegt: sauber auf den aktuellen Stand gehen.
if [ -z "$(git status --porcelain)" ]; then
  git checkout --quiet "$ZIEL_BRANCH" >/dev/null 2>&1 \
    && git merge --ff-only --quiet "origin/$ZIEL_BRANCH" >/dev/null 2>&1
fi

exit 0

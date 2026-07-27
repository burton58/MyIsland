#!/usr/bin/env bash
# Auto-Save für My Island.
#
# Sichert alle Änderungen und stellt sie online (Branch: main). Läuft als
# Stop-Hook am Ende jeder Antwort, kann aber auch von Hand aufgerufen werden:
#   bash .claude/hooks/auto-save.sh
#
# Der Hook gibt JSON auf stdout aus; Claude Code zeigt "systemMessage" an.
set -uo pipefail

ZIEL_BRANCH="main"

melde() {
  # $1 = Text für die Person am Bildschirm
  esc="$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  printf '{"systemMessage":"%s","suppressOutput":true}\n' "$esc"
  exit 0
}

cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}" 2>/dev/null || exit 0

git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# --- Regel 1: nur im MyIsland-Repo etwas tun -------------------------------
origin="$(git remote get-url origin 2>/dev/null || true)"
if ! printf '%s' "$origin" | grep -qi 'myisland'; then
  melde "Automatisches Speichern übersprungen: Dieser Ordner gehört nicht zum Projekt My Island."
fi

# --- Gibt es überhaupt etwas zu tun? ---------------------------------------
git add -A >/dev/null 2>&1

hat_aenderungen=1
git diff --cached --quiet 2>/dev/null && hat_aenderungen=0

hat_ungepushtes=0
if git rev-parse --verify "origin/$ZIEL_BRANCH" >/dev/null 2>&1; then
  [ "$(git rev-list --count "origin/$ZIEL_BRANCH..HEAD" 2>/dev/null || echo 0)" -gt 0 ] && hat_ungepushtes=1
else
  hat_ungepushtes=1
fi

if [ "$hat_aenderungen" -eq 0 ] && [ "$hat_ungepushtes" -eq 0 ]; then
  exit 0   # nichts geändert – still bleiben
fi

# --- Commit ----------------------------------------------------------------
if [ "$hat_aenderungen" -eq 1 ]; then
  dateien="$(git diff --cached --name-only | head -5 | tr '\n' ',' | sed 's/,$//; s/,/, /g')"
  anzahl="$(git diff --cached --name-only | wc -l | tr -d ' ')"
  [ "$anzahl" -gt 5 ] && dateien="$dateien u. a."
  zeit="$(date '+%d.%m.%Y, %H:%M')"

  git commit -q -m "Änderungen vom $zeit" -m "Bearbeitet: $dateien" >/dev/null 2>&1 || true
fi

# --- Online stellen, mit Wiederholung bei Netzwerkproblemen ----------------
push_fehler=""
for wartezeit in 0 2 4 8 16; do
  [ "$wartezeit" -gt 0 ] && sleep "$wartezeit"
  push_fehler="$(git push origin "HEAD:$ZIEL_BRANCH" 2>&1)" && {
    melde "Gespeichert und online aktualisiert."
  }
done

# --- Push abgelehnt: erst neuen Stand holen, dann noch einmal --------------
if printf '%s' "$push_fehler" | grep -qiE 'rejected|non-fast-forward|fetch first'; then
  if git pull --rebase --quiet origin "$ZIEL_BRANCH" >/dev/null 2>&1; then
    if git push origin "HEAD:$ZIEL_BRANCH" >/dev/null 2>&1; then
      melde "Gespeichert und online aktualisiert (zwischenzeitliche Änderungen wurden zusammengeführt)."
    fi
  else
    git rebase --abort >/dev/null 2>&1 || true
    melde "Deine Änderungen sind lokal gesichert, aber online noch nicht angekommen: Es gibt eine Überschneidung mit einer anderen Änderung. Bitte einmal Bescheid geben, damit das aufgelöst werden kann."
  fi
fi

melde "Deine Änderungen sind gesichert, konnten aber gerade nicht online gestellt werden (Verbindungsproblem). Beim nächsten Mal wird es automatisch nachgeholt."

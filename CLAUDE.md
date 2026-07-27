# Agent-Anweisungen für das Repo „My Island"

## Wer hier arbeitet

An diesem Repo arbeitet **Christine**. Sie ist keine Entwicklerin und kennt
GitHub nicht. Begriffe wie *Repository*, *Commit*, *Push*, *Branch*, *Merge*,
*Pull Request*, *Diff* oder *Konflikt* sagen ihr nichts — sie muss sie auch nie
lernen. Für sie gibt es nur: „Ich beschreibe, was ich möchte, und danach ist es
gespeichert."

## Regel 1 — Nur dieses Repo

Es wird **ausschließlich im Repo `burton58/MyIsland`** gearbeitet.

- Keine Dateien in anderen Repos lesen, ändern, anlegen oder löschen.
- Keine weiteren Repos in die Sitzung holen (`add_repo`, `git clone`, o. Ä.).
- Keine neuen Repos anlegen.
- Keine Arbeit außerhalb des Projektordner-Baums von MyIsland.

Wenn eine Anfrage ein anderes Repo betreffen würde: **nicht ausführen.** Kurz und
ohne Fachbegriffe sagen, dass hier nur an My Island gearbeitet wird, und
anbieten, das Thema stattdessen innerhalb von My Island zu lösen.

## Regel 2 — Alles wird automatisch gespeichert

Jede Änderung wird **automatisch** gesichert und online gestellt — Christine muss
darum nie bitten und nie zustimmen.

- Ziel ist immer der Branch **`main`**. Es gibt aktuell keinen Deploy-Branch und
  keine Feature-Branches. Nichts anderes anlegen.
- **Keine Pull Requests.** Nicht anlegen, nicht vorschlagen.
- Erledigt wird das automatisch vom Auto-Save-Hook
  (`.claude/hooks/auto-save.sh`, ausgelöst am Ende jeder Antwort). Zusätzlich
  gilt: Wenn eine Sitzung endet, ohne dass der Hook lief, den Stand am Ende der
  eigenen Antwort selbst sichern — mit demselben Skript:
  `bash .claude/hooks/auto-save.sh`
- Nie nachfragen im Sinne von „Soll ich das committen?" oder „Soll ich das
  pushen?". Die Antwort ist immer ja.

## Regel 3 — Sprache und Ton

- **Immer Deutsch**, auch in Commit-Nachrichten.
- Keine Git- oder GitHub-Begriffe gegenüber Christine. Stattdessen:
  | statt | sagen |
  |---|---|
  | committen / pushen | „gespeichert" / „gesichert" |
  | Repository | „das Projekt" / „My Island" |
  | Branch `main` | einfach gar nicht erwähnen |
  | Merge-Konflikt | „zwei Änderungen haben sich überschnitten — ich habe es zusammengeführt" |
  | Pull Request | (kommt nicht vor) |
- Am Ende einer Antwort in einem Satz sagen, **was** geändert wurde und dass es
  gespeichert ist. Keine Datei-Statistiken, keine Commit-Hashes, keine Links auf
  GitHub, außer sie fragt ausdrücklich danach.
- Änderungen ruhig erklären, aber knapp. Rückfragen nur, wenn eine Antwort
  wirklich nötig ist, um weiterzumachen.

## Regel 4 — Nichts kaputt machen

Christine kann einen Fehler nicht selbst rückgängig machen, deshalb:

- Vor dem Überschreiben oder Löschen einer Datei den Inhalt ansehen.
- Löschen oder große Umbauten vorher kurz in einem Satz ankündigen und
  bestätigen lassen — das ist die **einzige** Ausnahme von „nie nachfragen".
- Die Historie nie umschreiben: kein `git reset --hard`, kein
  `git push --force`, kein `git rebase` auf bereits Gespeichertem.
- Wenn etwas schiefgeht: nicht zu retten versuchen, indem der Stand verworfen
  wird. Lieber stehen lassen und Christine sagen, dass ihr Mann (Repo-Inhaber)
  drüberschauen sollte.

## Das Projekt

`index.html` ist die komplette App — ein einzelnes HTML-File mit
CSS und JavaScript darin, keine Installation, kein Build. Zum Anschauen einfach
im Browser öffnen. `SPEC.md` beschreibt, wie die App aufgebaut ist und was sie
kann; wer größere Änderungen macht, sollte dort vorher reinschauen und die Datei
danach nachziehen, wenn sich etwas Grundlegendes geändert hat.

**Kein API-Key** gehört in `index.html` — er wäre für alle sichtbar,
die die Seite öffnen. Der KI-Begleiter läuft ohne Key mit Ersatztexten weiter.

## Die App ist live

Alles, was gespeichert wird, ist rund eine Minute später öffentlich unter
<https://burton58.github.io/MyIsland/> zu sehen — dort schaut Christine auf
ihrem iPhone drauf. Zwei Dinge folgen daraus:

- Das Repo ist **öffentlich**. Keine privaten Daten, keine Passwörter, keine
  Schlüssel in Dateien schreiben, auch nicht „nur zum Testen".
- Wenn sie fragt „ist das schon auf meinem Handy?": ja, sie muss die Seite nur
  neu laden. Falls sie nichts sieht, ist meist die alte Fassung im Speicher —
  Seite schließen und neu öffnen hilft.

Die Datei muss `index.html` heißen und im obersten Ordner liegen, sonst ist die
Adresse nicht mehr erreichbar. Nicht umbenennen, nicht verschieben.

## Für den Repo-Inhaber

Die Automatik steckt in `.claude/settings.json`:
- `SessionStart` → `.claude/hooks/session-start.sh` holt den aktuellen Stand.
- `Stop` → `.claude/hooks/auto-save.sh` sichert und pusht nach `main`.

Beides lässt sich mit `/hooks` ansehen oder abschalten. Regel 1 ist eine
Anweisung an den Agenten, keine technische Sperre — wer die Datei ändert, hebt
sie auf. Für echte Absicherung bräuchte es eingeschränkte Zugriffsrechte auf
GitHub-Seite.

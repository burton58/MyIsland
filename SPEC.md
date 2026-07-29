# My Meditation Island — App-Spezifikation

Meditations-App rund um die eigene "Insel": Nutzer:innen richten sich über einen Kompass aus, wählen passende geführte Meditationen aus einer kategorisierten Bibliothek und bekommen am Ende einen Rückblick, was sich verändert hat.

**Wichtig fürs Verständnis der Marke:** Die Insel ist eine **Metapher**, kein Themenzwang. Sie steht für den Kraftort in einem selbst — den Ort, an den man sich zurückzieht, um anzukommen, durchzuatmen und bei sich zu sein. Das heisst: Die *Insel* ist der Rahmen (Startseite, Kompass, Abschluss, Bildsprache), die *Meditationen darin* müssen inhaltlich nicht bei "Strand und Palmen" bleiben — genau wie ein Rückzugsort auch nicht bedeutet, dass jedes Gespräch darin vom Rückzugsort handeln muss. Siehe §5a für die daraus folgende Themenvielfalt.

Titel/Überschriften wurden entsprechend angepasst: Browser-Tab und Home-Bildschirm-Symbol heissen jetzt **"My Meditation Island"** (vorher "My Island"), die Kopfzeile auf Kompass-/Meditations-/Abschluss-Seite heisst **"Gestalte deine Inselreise"** (vorher "Gestalte deine Trauminsel") — man *reist*, man baut keine Insel mehr zusammen (der alte Insel-Konfigurator ist ohnehin nicht im Hauptfluss, siehe §4). Der Text unten auf der Startseite benennt die Metapher jetzt direkt: "Deine Insel ist dein Kraftort in dir – der Ort, an den du dich zurückziehst, um bei dir anzukommen."

Aktueller Stand ist ein **einzelnes, selbstständiges HTML-File** (`index.html`) — kein Build-Step, keine externen Abhängigkeiten außer einem Fetch-Call an die Anthropic API für den Chat-Begleiter. Dieses Dokument beschreibt den Ist-Zustand, damit er 1:1 in ein neues Repo übersetzt werden kann (z. B. als React/Next-App mit echten Routen statt CSS-Step-Umschaltung).

---

## 1. Tech-Stack (aktuell)

- Reines HTML + CSS + Vanilla JS (ein `<script>`-Block, IIFE)
- Kein Framework, kein Bundler
- Alle Fotos sind **base64-inline** als JPEG eingebettet (kein separater Asset-Ordner)
- KI-Begleiter ruft `https://api.anthropic.com/v1/messages` direkt per `fetch()` auf (Modell `claude-sonnet-4-6`), mit Fallback-Textbausteinen bei Fehlern/Offline
- Persistenz: **keine** — der State lebt nur in JS-Variablen im Speicher, kein LocalStorage, kein Backend

**Empfehlung fürs neue Repo:** Struktur in echte Komponenten/Routen auflösen (z. B. `/`, `/kompass`, `/meditation`, `/session`, `/abschluss`), State in einen zentralen Store (Context/Zustand/Redux) heben, Fotos als echte Asset-Dateien statt base64.

---

## 2. Design-System

### Farben
| Token | Wert | Verwendung |
|---|---|---|
| `--forest` | `#2f5233` | dunkles Grün, Überschriften/Logo |
| `--sage` / `--sage-deep` | `#82b998` / `#5a9370` | Primär-Buttons (Verlauf), CTA-Pillen |
| `--sun` / `--sun-deep` | `#ffd447` / `#ff9a3d` | Akzent (Empfehlungs-Badge) |
| `--ink` | `#0b2b33` | Fließtext |
| `--card` / `--cream` | `#ffffff` / `#fbf6ec` | Karten-Hintergründe |

### Typografie
- Fließtext: System-Sans (`-apple-system, Segoe UI, Roboto, …`)
- Überschriften/Logo: `--serif` = Georgia / Iowan Old Style / Palatino / serif-Fallback

### Wiederkehrende Muster
- **Matte Foto-Hintergründe**: Auf Kompass-, Meditations- und Abschlussseite liegt das Titel-Foto (Insel + Boot, Sonnenuntergang) als `body`-Hintergrund, abgedunkelt mit `linear-gradient(rgba(8,28,25,.82…86))` — bewusst "matt", nicht das helle Originalfoto.
- **Frosted Cards**: `.compass-card` = `rgba(251,250,246,.94)` + `backdrop-filter: blur(14px)`
- **Persistente Tab-Bar** unten (`.tabbar`, 70px hoch, dunkel/transparent, während der Session ausgeblendet): 5 Tabs, alle aktiv/klickbar — Home, Insel-Kompass, Meditation 1, Meditation 2, Profil. Meditation 1/2 führen zu den beiden parallelen Auswahl-Varianten (siehe §3.3/§3.3a).

---

## 3. Seiten-/Flow-Übersicht

Umsetzung aktuell über ein `data-step`-Attribut auf `<body>` + CSS-Sichtbarkeitsregeln pro Step (kein Router). Reihenfolge:

```
Home  →  Kompass  →  Meditationsauswahl  →  Session (Vollbild)  →  Abschluss
 ↺ (Neu beginnen)                                                    ↳ "Noch eine Meditation" → zurück zu Meditationsauswahl
```

Der frühere Insel-Konfigurator-Schritt (`island`) existiert im Code noch (SVG-Insel-Generator mit Größe/Wetter/Meer/Charakter/Boot), ist aber **aus dem Hauptfluss entfernt** — "Los geht's" auf der Startseite führt direkt zum Kompass. Er war bis vor Kurzem noch indirekt über den Button "Zurück auf die Insel" im Abschluss erreichbar (zeigte die SVG-Szene als Vollbild); dieser Button wurde entfernt (siehe §3.5), damit ist der Insel-Step jetzt **vollständig unerreichbar** über die Oberfläche.

### 3.1 Home (`data-step="home"`)
- Vollflächiges Foto (Boot + Insel, Sonnenuntergang), edge-to-edge, keine Karte/Rand
- Oben auf dem Foto: Titel "My Meditation Island" (Serif, weiß, einzeilig) + Untertitel "Geführte Meditationen auf Schweizerdeutsch" + Hinweis "🇨🇭 Von 3 Minuten bis zur halben Stunde"
- Unten auf dem Foto: Text "Kurz durchatmen: Meditation, die sich anfühlt wie Ferien auf deiner Insel." + CTA-Pille "Los geht's" (→ Kompass) + Textlink "Anmelden" (→ ebenfalls Kompass, kein echtes Auth — siehe §7 für die Frage, ob der Knopf überhaupt gebraucht wird)
- Dunkler Verlauf oben *und* unten fürs Lesen, sonst ist die Mitte des Fotos frei sichtbar
- Kleiner, interaktiver Kompass mittig im Foto (`#compassWrapHome`, teilt sich `compassBefore` mit dem echten Kompass auf Schritt 1): Antippen lässt ihn auf volle Grösse aufwachsen, blendet den Marketing-Text/CTA gegen einen "Weiter"-Knopf direkt am Kompass ein. Tippt man daneben (statt drauf), während er gross ist, schrumpft er wieder auf die Ausgangsgrösse — ein zweites Antippen macht das Aufwachsen rückgängig, ohne die Seite zu verlassen. Beim Verlassen der Startseite (egal über welchen Weg) wird er beim nächsten Aufruf immer wieder klein zurückgesetzt.

### 3.2 Kompass ("Der Kompass")
- Fotobasierter Nautik-Kompass (echtes Kompass-Foto, kreisförmig zugeschnitten) mit transparentem SVG-Overlay: Vier Wörter statt Himmelsrichtungen: **oben Denken, unten Fühlen, links Anspannung, rechts Entspannung**
- Eigene Karten-Überschrift **"🧭 Der Kompass"** — der allgemeine Seitenkopf (Topbar/Stepper) ist auf diesem Schritt bewusst ausgeblendet, sonst gäbe es zwei Titel übereinander (gleiches Prinzip wie schon beim Profil-Tab)
- Karten-Überschrift **"🧭 Der Kompass"** als kleine, volldeckende Plakette (`#eef6f2`-Hintergrund, Pill-Form, fett) statt loser Text mit text-shadow-Schein — Text-Shadow allein ging auf dem hellen Foto optisch unter, egal wie groß/fett; erst der feste Hintergrund (gleicher Ton wie die Erklär-Karten und `.trial-box`) macht den Titel zuverlässig lesbar.
- Kurzer Einleitungssatz ("Setze die Nadel dahin, wo du gerade stehst: zwischen Denken und Fühlen, und zwischen angespannt und entspannt.") und ein Abschlusssatz ("Daraus finden wir deine passende Meditation."), beide als normaler `.lead`-Text — die frühere 2×2-Erklär-Karten-Box (`.compass-explain-grid`, je eine Karte für Denken/Fühlen/Angespannt/Entspannt) wurde entfernt, die beiden Sätze reichen als Einordnung. "Zurück"/"Weiter" sind bewusst **nicht** anders gestylt als auf jeder anderen Seite (unterschiedliche Knopfgrössen je Seite wirkten inkonsistent) — die nötige Höhe wird stattdessen beim Kompass eingespart: 240px auf normalen Handys (iPhone 14, Pro Max) statt dem App-Standard 320px, auf kurzen Bildschirmen (`@media (max-height:700px)`, z. B. iPhone SE) ein deutlich kleinerer Kompass (145px). Ziel und aktueller Stand: **alles inklusive der Buttons ganz unten bleibt ohne Scrollen sichtbar**, auf allen drei getesteten Bildschirmgrössen — kein Scrollen wird hier bewusst in Kauf genommen, auch wenn der Kompass auf sehr kleinen Bildschirmen dafür deutlich kleiner ausfällt.
- **Anzahl- und Dauer-Picker für Meditation 2** (`#durationGroupCompass`, zweispaltige `.pref-row` direkt vor "Weiter zu den Meditationen"): "Wie viele Meditationen?" (1/2/3, `#countOptsV2`) und "Wie lange möchtest du meditieren?" (5/10/15/20/30 Min, `#durationOptsV2`). Setzen die globalen `desiredCountV2`/`durationV2`, die Meditation 2 (§3.3a) beim Öffnen einer Kategorie zum automatischen Auffüllen verwendet — beide Fragen kommen dadurch schon hier statt erst auf der Kategorie-Seite.
- Ein roter Punkt/Zeiger, **frei innerhalb der Scheibe verschiebbar** (nicht nur am Rand!) — wichtig: die beiden Achsen (Denken↔Fühlen, Anspannung↔Entspannung) sind **unabhängig voneinander** wählbar
- Ergebnis wird **nicht in Prozent**, sondern als kurzes Wort ausgegeben (`moodOf()`/`moodHtml()`, siehe §5) — dabei zählt **nur der Winkel**, nicht wie weit gezogen wird: welcher der beiden Pole eines Quadranten (z. B. Fühlen oder Entspannung) näher an der Nadel liegt, bestimmt das Wort
- Speichert `compassBefore = {x, y}` (jeweils −1…1)

### 3.3 Meditationsauswahl 1 ("Deine Meditationen", `data-step="meditation"`, Tab "Meditation 1")

Die Bibliothek nach Dauerstufe gegliedert (Kurze/Mittlere/Tiefe Inselreisen) — auf Christines Wunsch die ursprüngliche Gliederung, nachdem Meditation 1 zwischenzeitlich auf Kategorie-Kacheln umgestellt war und dadurch nicht mehr von Meditation 2 zu unterscheiden war. Beide Varianten sind jetzt wieder klar verschieden und über eigene Tabs erreichbar.

- Eigene Karten-Überschrift **"🧘 Deine Meditationen"** — der allgemeine Seitenkopf (Topbar/Stepper) ist auf diesem Schritt bewusst ausgeblendet, sonst gäbe es zwei Titel übereinander (gleiches Prinzip wie beim Kompass-, Abschluss- und Profil-Schritt, siehe §3.2/§3.5)
- **Keine Präferenz-Fragen mehr:** Die früheren Felder "Wie viele Meditationen?" (1/2/3) und "Maximale Dauer insgesamt?" (10/20/30 Min/egal) wurden auf Christines Wunsch entfernt — die Seite beginnt direkt mit Status, Kompass-Hinweis und Bibliothek.
- Live-Status: "2 ausgewählt · 13 Min gesamt" (ohne Ziel-/Obergrenzen-Vergleich, da es kein Budget mehr gibt)
- Bibliothek in **3 aufklappbaren Kategorien** nach Dauerstufe — Kurze (mini, 3–6 Min), Mittlere (mittel, 7–14 Min), Tiefe (tief, 15–30 Min) Meditationen/Inselreisen (siehe §5), Mehrfachauswahl mit nummerierten Checkboxen (①②③…), **ohne Obergrenze** — beliebig viele, beliebig lang
- Kompass-Hinweis (`#recNote`) nennt **nicht** die grobe Richtung ("Kompass zeigt Fühlen"), sondern das tatsächliche Stimmungswort aus `moodOf()` (feiner als die 4 Richtungen, z. B. "grüblerisch"/"unruhig"/"geborgen" statt nur "Denken"/"Fühlen") plus einen dazu passenden Satz, wohin die Übungen von genau da aus führen (`MOODS[...].next`/`MOOD_BALANCED.next`, siehe §5 "Kompass") — z. B. "😔 Dein Kompass zeigt: Aufgewühlt. Diese Übungen helfen dir zu ausgeglichenen, entspannten Gefühlen." Alle Übungen der zugehörigen groben Richtung tragen weiterhin ein **"Empfohlen"-Abzeichen** plus Zeile "Passt zu \<Richtung\>" (Meditationen sind nur nach den 4 groben Richtungen einsortiert, nicht nach den 8 Stimmungswörtern).
- Vorauswahl: **genau eine** Übung zur Kompass-Richtung (die kürzeste als sanfter Einstieg) ist beim Öffnen schon angehakt, ihre Kategorie **klappt automatisch auf**. Ohne Anzahl-/Dauer-Frage gibt es kein Budget mehr, das eine grössere Vorauswahl rechtfertigen würde — alles Weitere wählt die Person frei dazu.
- KI-Begleiter-Chat (kontextbewusst, kann per `[EMPFEHLUNG: <Name>]`-Tag eine Übung zur Auswahl hinzufügen)
- "Insel betreten & starten →" → Vollbild-Session
- **Offen:** Welche Übung tatsächlich vorgeschlagen wird, richtet sich weiterhin nur nach der groben Richtung (+ kürzeste Dauer für die Vorauswahl) — der Empfehlungs-**Text** ist jetzt fein nach Stimmungswort formuliert, die Empfehlungs-**Logik** (welche Übungen) noch nicht nach dem Intensitäts-Konzept, das Christine beschrieben hat (siehe §5 "Geplant: Intensität + Empfehlungslogik"). Umsetzung wartet noch auf die Meditations-Klassifizierung von Christine (welche Übung zu welcher Intensitätsstufe passt).

### 3.3a Meditationsauswahl 2 ("Nach Kategorie wählen", `data-step="meditation2"`, Tab "Meditation 2")

Eigener Tab in der Tab-Bar (`data-tab="meditation2"`), gleichberechtigt neben Meditation 1 — beide sind parallele Optionen, die Christine gegeneinander ausprobieren und sich dann für eine entscheiden kann. Beide Flüsse teilen sich dieselbe Session-Wiedergabe. Der Unterschied zu Meditation 1: Kategorie-Kacheln statt Akkordeon; Anzahl und Dauer werden schon auf der Kompass-Seite gewählt und automatisch aufgefüllt statt manuell aus dem Akkordeon ausgewählt.

- **Kategorie-Kacheln:** 2×2-Raster (`.catv2-grid`) mit einer Kachel je Kompass-Richtung, jede mit passendem Symbol: 🧠 Denken, ❤️ Fühlen, 🌪️ Anspannung, 🌊 Entspannung — aktuell Emoji-Platzhalter, keine echten Yoga-Icons; Christine sucht dafür passende Yoga-Symbole/-Referenzen und liefert sie nach. Antippen zeigt alle Meditationen dieser Richtung (nicht nach mini/mittel/tief unterteilt, einfach die volle Liste).
- **Anzahl und Dauer, schon auf der Kompass-Seite gewählt:** "Wie viele Meditationen?" (1/2/3, `#countOptsV2`) und "Wie lange möchtest du meditieren?" (5/10/15/20/30 Min, `#durationOptsV2`). Beide Picker sitzen auf der **Kompass-Seite** (§3.2), nicht auf der Kategorie-Seite von Meditation 2 selbst — beim Öffnen einer Kategorie sind Anzahl und Zieldauer also schon gesetzt.
- **Auto-Auswahl:** `autoFillV2()` sucht je Slot (Zieldauer geteilt durch Anzahl) die Übung, die dieser Grösse am nächsten kommt — dieselbe Logik wie früher bei Meditation 1 (§5, Auswahl-Logik), nur mit `desiredCountV2`/`durationV2` statt `desiredCount`/`maxDuration`.
- Einzelne Übungen bleiben antippbar (an-/abwählen), begrenzt auf die gewählte Anzahl (älteste fliegt raus, wenn eine neue dazukommt) — `chosenMedIdsV2` ist ein eigener, separater Auswahl-Zustand.
- Live-Status: "2 von 3 ausgewählt · 15 Min gesamt (Ziel: 20 Min)"
- "Insel betreten & starten →" kopiert `chosenMedIdsV2` nach `chosenMedIds` und startet dieselbe Session-Wiedergabe wie Meditation 1 — Session-Player, Playlist-Logik und Abschluss sind identisch, nur der Auswahl-Bildschirm unterscheidet sich.

### 3.4 Session (Vollbild, `body.entered.in-session`)
- Hintergrund: **aktuell überall dasselbe Titel-Foto** (nicht die animierte SVG-Insel), scharf statt verwischt gezeigt
- Unteres Panel: Name + Position ("Meditation 2 von 3"), Fortschritts-Punkte für die Playlist, Anleitungstext (wandert mit der Zeit durch die `steps[]`), Fortschrittsbalken, Timer, Pause/Vorspulen/Fertig
- Playlist spielt die gewählten Übungen **automatisch nacheinander** ab
- ⚠️ Geplant (siehe §5a): der Hintergrund soll künftig zum Thema der jeweiligen Meditation passen, nicht mehr immer die Insel zeigen

### 3.5 Abschluss
- Zweiter Kompass (gleiche Optik/Bedienung), Frage "Wie fühlst du dich jetzt?" → `compassAfter`
- Rückblick: **nur noch** Vorher/Jetzt (in Worten) + Liste der gemachten Meditationen mit Dauer — **keine** Insel-Details mehr (Größe/Palmen/Wetter wurden bewusst entfernt)
- Ein Satz zur Veränderung (`updateShift()`, vergleicht Vorher/Jetzt)
- "Brauchst du noch etwas?": Buttons **"Noch eine Meditation"** (zurück zur Auswahl, neue Empfehlung basiert auf dem *neuen* Kompassstand), **"Ein Mudra für mich"** und **"Ein Mantra für mich"** — beide zeigen je 1 Karte aus einer fest hinterlegten Bibliothek, ausgewählt passend zur aktuellen Kompass-Richtung (siehe §5, `MUDRAS`/`MANTRAS`/`waehlePassend()`). Die Auswahl ist **deterministisch** aus der genauen Nadel-Position berechnet, nicht zufällig — mehrfaches Antippen desselben Buttons zeigt darum immer dasselbe Ergebnis, solange sich der Kompass nicht verändert. Die beiden Buttons sind unabhängig: man kann keins, eins oder beide antippen.
- Begleiter-Chat (zweite Instanz, ohne Empfehlungs-Tag-Parsing)
- "Neu beginnen" / "Fertig →" — beide beenden die Sitzung gleich (Auswahl/Verlauf-Zwischenstand zurücksetzen, zurück zu Home). Der frühere Button "Zurück auf die Insel" (→ Vollbild-Ansicht der SVG-Insel-Szene) wurde entfernt: unnötiger Zwischenschritt mit einem Bild, das nicht zum Rest der App passte (echtes Foto überall sonst, hier eine gezeichnete Szene).
- Eigene Karten-Überschrift **"🌅 Zurück von der Insel"** — der allgemeine Seitenkopf (Topbar/Stepper, "Gestalte deine Inselreise") ist auf diesem Schritt bewusst ausgeblendet, sonst gäbe es zwei Titel übereinander (gleiches Prinzip wie beim Kompass-Schritt, siehe §3.2)

---

## 4. Insel-Konfigurator (aktuell nicht im Hauptfluss, Code vorhanden)

Falls im neuen Repo reaktiviert werden soll: eigener Screen mit Live-Vorschau oben (80% Höhe) und kompakter, scrollbarer Filterleiste unten (20% Höhe). Optionen: Wetter (sonnig/wolkig), Meer (ruhig/wellig), Charakter (Geschlecht, Haut-/Haar-/Outfitfarbe per Swatches), Ankunft (Boot/schon da). Größe und Palmenanzahl sind fix auf "Mittel". Insel + Boot + Person sind alle als handgezeichnete SVG-Illustration umgesetzt (kein Foto), inkl. animiertem Boot-Einlaufen, schwimmenden Fischen, Wolken/Sonne je nach Wetter.

---

## 5. Datenmodell & Kernlogik

### Kompass
```js
compassBefore = { x: -1..1, y: -1..1 }   // x: -1=Anspannung … 1=Entspannung
compassAfter  = { x: -1..1, y: -1..1 }   // y: -1=Denken     … 1=Fühlen

dirFromCompass(c)   // → "nord"|"sued"|"west"|"ost", dominante Achse gewinnt - bestimmt WELCHE
                        //   Uebungen als "Empfohlen" markiert werden (grobe Richtung, siehe §3.3)
moodOf(c)/moodHtml(c) // → { emoji, word, next } (siehe MOODS: 4 Richtungspaare × 2 Woerter "vert"/"horiz",
                        //   + Sonderfall MOOD_BALANCED "ausgeglichen" bei Betrag < 0.15). Nur der WINKEL
                        //   entscheidet, welcher der beiden Pole eines Quadranten naeher liegt - wie weit
                        //   man zieht (Laenge) spielt bewusst keine Rolle. "next" ist Christines Formulierung
                        //   dafuer, wohin die Uebungen von genau diesem Stimmungswort aus fuehren (siehe
                        //   #recNote in §3.3) - eigenstaendiger Text pro Wort, unabhaengig von dirFromCompass.
compassText(c)      // Prozent-Variante — nur noch intern für den KI-Kontext genutzt, NICHT mehr im UI
```

#### Geplant (Entwurf von Christine, teilweise umgesetzt): Intensität + Empfehlungslogik

Christine hat die Quadranten-Logik bestätigt/vorgegeben und eine Empfehlungsrichtung je Quadrant sowie ein neues Intensitäts-Konzept beschrieben. Inzwischen umgesetzt: **jedes der 8 Stimmungswörter hat einen eigenen `next`-Text** (`MOODS[...].next`/`MOOD_BALANCED.next`, siehe oben), der in `#recNote` auf der Meditation-1-Seite erscheint statt der groben Richtung:

| Stimmungswort | `next`-Text (umgesetzt) |
|---|---|
| grüblerisch | Diese Übungen führen dich zu ruhigeren, klareren Gedanken. |
| angespannt | Diese Übungen bringen dir mehr Entspannung. |
| unruhig | Diese Übungen bringen dich zurück zur Ruhe. |
| aufgewühlt | Diese Übungen helfen dir zu ausgeglichenen, entspannten Gefühlen. |
| entspannt | Diese Übungen bauen dieses gute Gefühl weiter aus. |
| geborgen | Diese Übungen vertiefen diese Ruhe noch mehr. |
| gelassen | Diese Übungen machen dich noch gelassener und zufriedener. |
| gedankenvoll | Diese Übungen führen zu weniger, dafür klareren und ruhigeren Gedanken. |
| ausgeglichen (Zentrum) | Diese Übungen helfen dir, dieses Gleichgewicht zu halten. |

**Noch offen — Intensität:** Aktuell zählt beim Kompass weiterhin nur der Winkel, nicht die Distanz vom Zentrum (siehe Kommentar bei `moodOf()` oben). Christine möchte das um eine Intensitäts-Achse pro Pol erweitern:
- Gedanken-Achse (Richtung Denken): aussen = sehr viele/rasende Gedanken, Richtung Mitte = ruhige, klare Gedanken.
- Gefühle-Achse (Richtung Fühlen): aussen = sehr belastende/intensive Gefühle, Richtung Mitte = ausgeglichene Gefühle.
- Anspannungs-Achse: Anspannung ↔ Entspannung bleibt wie gehabt ein Pol-zu-Pol-Gegensatz (kein Zentrum-Konzept nötig).

**Noch offen — welche Übung tatsächlich vorgeschlagen wird:** Der `next`-Text beschreibt nur die Richtung in Worten; **welche der 40 Meditationen** dazu passt, hängt weiterhin nur von der groben Richtung (`dirFromCompass`) ab, nicht vom feineren Stimmungswort oder der Intensität. Das braucht eine Klassifizierung, welche Meditation zu welchem Stimmungswort *und* welcher Intensitätsstufe passt — diese liefert Christine noch nach. Bis dahin bleibt die eigentliche Auswahl-Logik in Meditation 1 & 2 (§3.3/§3.3a) unverändert (Richtung + kürzeste/Zieldauer).

### Meditationen
```js
DIRS = { nord:"Denken", sued:"Fühlen", west:"Anspannung", ost:"Entspannung" }  // + je ein Erklärsatz

MEDITATIONS[] = {
  id, dir ("nord"|"sued"|"west"|"ost"), cat ("mini"|"mittel"|"tief"),
  name, min (Zahl), desc, steps: [ "...", "...", ... ]  // Anleitungstexte, zeitlich verteilt über die Dauer
}
```
- **40 handgeschriebene Meditationen insgesamt** (13 mini / 13 mittel / 14 tief) — siehe §5a für die volle Titelliste. Kein Generator mehr: `generateLibrary()`/`THEMES`/`PHRASES` wurden entfernt, jeder Eintrag ist ein einzeln geschriebenes Skript.
- Das Feld `cat` ("mini"/"mittel"/"tief") gruppiert die Akkordeon-Kategorien in Meditation 1 (siehe §3.3); Meditation 2 gruppiert stattdessen nur nach Kompass-Richtung (`dir`), nicht nach Dauerstufe.

### Mudras & Mantras (Abschluss-Seite)
```js
MUDRAS[]  = { dir, name, how, why }   // 20 Eintraege, 5 je Richtung, Erklaerung auf Hochdeutsch
MANTRAS[] = { dir, text, why }        // 20 Eintraege, 5 je Richtung, auf Hochdeutsch

waehlePassend(liste, c)  // filtert auf die zu c passende Richtung, waehlt daraus DETERMINISTISCH
                          // (aus c.x/c.y berechneter Index, kein Math.random()) genau 1 Eintrag -
                          // dieselbe Nadel-Position liefert also immer dasselbe Ergebnis
zeigeMudra()/zeigeMantra()  // rendern die Karte in #mudraBox/#mantraBox, Richtung/Position kommt aus compassAfter
```

## 5a. Themenvielfalt (umgesetzt)

**Entscheidung:** Die Insel bleibt das einzige Bild/Branding der App (kein zweites, drittes Landschafts-"Skin"). Die *Meditationen selbst* sind inhaltlich breiter als vorher — nicht mehr nur Strand/Palmen/Wellen, sondern klassische Themen aus Achtsamkeit, Körperarbeit und Alltagsbewältigung. Die vier Kompass-Richtungen (Denken/Fühlen/Anspannung/Entspannung) bleiben als Zuordnungs-Logik bestehen; jedes Thema hat weiterhin eine Richtung zugeordnet, damit die Empfehlungslogik unverändert funktioniert.

**Umgesetzte Titelliste (40 Meditationen, alle handgeschrieben)** — ersetzt die früher automatisch generierten "Insel-<Thema>"-Einträge aus `THEMES[dir]`/`PHRASES[dir]` (dieser Generator inkl. `generateLibrary()` wurde entfernt, `MEDITATIONS[]` enthält jetzt alle 40 Einträge direkt). Jeder Titel ist einer Kategorie, einer festen Dauer und einer Kompass-Richtung zugeordnet, damit sowohl die Richtungs-Empfehlung (Meditation 1) als auch die Dauer-Auffüllung (Meditation 2) über die ganze Liste hinweg genug Auswahl haben — nicht nur ein, zwei Themen decken jede Dauerstufe ab. Titel in *Kursiv* sind die 8 ursprünglichen Flaggschiff-Skripte, die unverändert geblieben sind.

**Mini (3–6 Min), 13 Titel:**

| Titel | Dauer | Richtung | Themenfamilie |
|---|---|---|---|
| *Atem-Anker* | 5 | Denken | Atem/Fokus |
| *Wellen-Atem* | 4 | Anspannung | Atem/Kurzintervention |
| *Dankbarkeit am Strand* | 5 | Entspannung | Dankbarkeit (Insel) |
| Kurzer Körper-Scan | 6 | Entspannung | Körperarbeit |
| Erdungsatem | 4 | Anspannung | Erdung |
| Kurze Lichtmeditation | 5 | Entspannung | Licht |
| Dankbarkeits-Blitzlicht | 3 | Fühlen | Dankbarkeit |
| Vertrauens-Anker | 6 | Entspannung | Vertrauen |
| Kraft-Impuls | 4 | Anspannung | Stärke |
| Herz beruhigen | 3 | Fühlen | Herz |
| Freundlicher Blick auf mich | 5 | Fühlen | Selbstmitgefühl |
| Fantasiereise: Ankommen am See | 6 | Fühlen | Fantasiereise |
| Feierabend-Übergang | 4 | Denken | Alltag |

**Mittel (7–14 Min), 13 Titel:**

| Titel | Dauer | Richtung | Themenfamilie |
|---|---|---|---|
| *Gedanken wie Wolken* | 8 | Denken | Gedankenarbeit |
| *Herzraum* | 7 | Fühlen | Herz |
| *Gefühle benennen* | 6 | Fühlen | Gefühlsarbeit |
| *Stille genießen* | 6 | Entspannung | Ruhe |
| Wurzelchakra – Erdung | 9 | Anspannung | Chakra |
| Herzchakra – Weite | 11 | Fühlen | Chakra |
| Stirnchakra – Klarheit | 9 | Denken | Chakra |
| Vertrauen aufbauen | 11 | Entspannung | Vertrauen |
| Innere Stärke | 9 | Anspannung | Stärke |
| Loslassen, was nicht mehr trägt | 13 | Anspannung | Loslassen |
| Verzeihen – ein erster Schritt | 11 | Fühlen | Verzeihen |
| Alltag einer berufstätigen Mutter | 13 | Denken | Alltag |
| Fantasiereise: Waldlichtung | 9 | Entspannung | Fantasiereise |

**Tief (15–30 Min), 14 Titel:**

| Titel | Dauer | Richtung | Themenfamilie |
|---|---|---|---|
| *Körper lösen* | 10 | Anspannung | Körperarbeit |
| Grosses Loslassen | 19 | Anspannung | Loslassen |
| Chakren-Reise: alle sieben Zentren | 27 | Denken | Chakra (umfassend) |
| Lichtmeditation – Ganzkörper | 23 | Entspannung | Licht |
| Tiefes Vertrauen | 19 | Entspannung | Vertrauen |
| Innere Stärke vertiefen | 23 | Anspannung | Stärke |
| Verzeihen – dir selbst und anderen | 27 | Fühlen | Verzeihen |
| Schwangerschafts-Reise: Verbindung zum Kind | 23 | Fühlen | Lebensphase |
| Fantasiereise: Bergspitze | 30 | Denken | Fantasiereise |
| Fantasiereise: Winterlandschaft | 19 | Denken | Fantasiereise |
| Fantasiereise: Insel | 27 | Fühlen | Fantasiereise (Insel) |
| Yoga-Nidra-artige Tiefenentspannung | 30 | Entspannung | Tiefenentspannung |
| Dankbarkeits-Reise (ausführlich) | 15 | Fühlen | Dankbarkeit |
| Geduld im Umgang mit Kindern (vertieft) | 15 | Anspannung | Alltag/Kinder |

**Verteilung über die vier Kompass-Richtungen** (Summe über alle 40): Denken 8 · Fühlen 12 · Anspannung 10 · Entspannung 10. Nicht perfekt gleich, aber bewusst nah dran — Fühlen ist am stärksten besetzt, weil sich viele der gewünschten Themen (Herz, Dankbarkeit, Verzeihen, Chakra-Herz, Schwangerschaft) inhaltlich dort einordnen. Falls das zu schief wirkt, liesse sich z. B. "Fantasiereise: Insel" oder "Dankbarkeits-Reise" auf Denken/Entspannung umlegen, ohne die Titel selbst zu ändern.

**Dauer-Abdeckung je Kategorie:** Mini deckt 3–6 Min in allen vier Stufen mehrfach ab, Mittel deckt 6–13 Min, Tief deckt 10–30 Min inklusive der 30-Min-Stufe. Damit hat die Dauer-Auffüllung in Meditation 2 (§3.3a, `autoFillV2()`) in jeder Kategorie und Richtung genug Auswahl, um nah an die gewünschte Zieldauer zu kommen, statt immer auf denselben ein, zwei Titeln zu landen.

**Bildsprache pro Meditation:** Der Foto-Hintergrund von Kompass-, Meditations- und Session-Seite (aktuell überall dasselbe Insel-Foto, siehe §3.4/§2) soll künftig **zur jeweiligen Meditation passen** — eine Fantasiereise "Bergspitze" mit Insel-Hintergrund abzuspielen wäre inhaltlich unstimmig. Konkret geplant:
- Insel-Foto bleibt Standard-Hintergrund für Home, Kompass, Meditationsauswahl, Abschluss (der "Rahmen" der Reise) sowie für alle Insel-thematischen Meditationen.
- Für andere Themen (Wald, See, Winterlandschaft, Bergspitze, Chakren/Licht, …) braucht es **je ein eigenes Foto** für den Session-Hintergrund — diese Fotos liefert die Repo-Inhaberin, sie werden nicht selbst erzeugt/erfunden.
- Bis die zusätzlichen Fotos vorliegen, bleibt der Insel-Hintergrund als Platzhalter für alle Themen bestehen.

**Umsetzung (noch offen):** `MEDITATIONS[]` bräuchte ein Feld `bg` (welches Foto für die Session), damit die Bildsprache pro Meditation (siehe oben) tatsächlich variiert. Bis die zusätzlichen Fotos von der Repo-Inhaberin vorliegen, bleibt der Insel-Hintergrund als Platzhalter für alle Themen bestehen.

### Auswahl-Logik
```js
chosenMedIds = []        // Reihenfolge = Playlist-Reihenfolge (Meditation 1), keine Obergrenze
catOpenState = { mini:false, mittel:false, tief:false }  // Accordion-Zustand (Meditation 1)
completedLog = []        // [{name, min, seconds}], während der Session befüllt

chosenMedIdsV2  = []     // eigener Auswahl-Zustand für Meditation 2
currentCatV2    = null   // gewählte Kompass-Richtung/Kategorie in Meditation 2
durationV2      = 10     // Minuten, auf der Kompass-Seite gewählt
desiredCountV2  = 2      // 1..3, auf der Kompass-Seite gewählt
```
Meditation 1 hat seit dem Entfernen der Anzahl-/Dauer-Frage **keinen Auswahl-Zustand für Präferenzen mehr** (`desiredCount`/`maxDuration` sind ersatzlos raus): Vorausgewählt wird genau eine Übung — die kürzeste zur Kompass-Richtung passende — danach ist die Auswahl frei und unbegrenzt (siehe §3.3). Meditation 2 hat Anzahl+Dauer weiterhin (auf der Kompass-Seite statt auf der Auswahl-Seite selbst): `autoFillV2()` sortiert die Kategorie nach Nähe zur Zieldauer je Slot (`durationV2 / desiredCountV2`) und füllt bis `desiredCountV2` erreicht oder `durationV2` überschritten würde — dieselbe Rechenregel, die früher bei Meditation 1 galt (siehe §3.3a).

### Session/Playlist
```js
session = { timer, elapsed, total, paused, queue: MeditationObjekt[], index }
```
`advanceQueue()` schaltet automatisch zur nächsten Übung, `completedLog` wird dabei fortlaufend befüllt (auch bei vorzeitigem Abbruch via "Fertig").

### Steps
```
STEPS = { home, island (optional, nicht im Fluss), compass, meditation, meditation2, outro, profil, abo }
TAB_FOR_STEP = { home:"home", compass:"kompass", meditation:"meditation", meditation2:"meditation2", profil:"profil" }
// "outro"/"abo"/"island" haben keinen eigenen Tab
```

---

## 6. KI-Begleiter

- Zwei Chat-Instanzen: eine auf der Meditationsauswahl (`allowRecommend = true`), eine im Abschluss (`false`)
- System-Prompt: warmherziger, kurzer (max. 3 Sätze), unaufdringlicher Begleiter, keine Diagnosen, ermutigt bei ernster Not zu echtem menschlichen Kontakt
- Bekommt vollen Kontext mitgeschickt: Kompass vorher/(nachher), aktuelle Auswahl bzw. abgeschlossene Meditationen
- Kann in der Auswahl-Ansicht per angehängtem `[EMPFEHLUNG: <exakter Name>]`-Tag eine Übung **zur Mehrfachauswahl hinzufügen** (nicht ersetzen)
- Fallback-Sätze bei API-Fehlern/Offline (kein Absturz, kein sichtbarer Fehler für die Person)

---

## 7. Offene Punkte / nächste Schritte für das neue Repo

1. **Architektur**: von "ein HTML-File mit `data-step`" zu echten Routen/Komponenten migrieren.
2. **Assets**: Fotos aus base64 lösen, als echte Dateien (WebP/AVIF) mit `srcset` einbinden.
3. **Persistenz**: Verlauf und Abo-Testphase liegen inzwischen in `localStorage` (geräte-gebunden, siehe §5 in `index.html`, Schlüssel `myisland.verlauf.v1`/`myisland.abo.v1`) — kein Server, kein geräteübergreifendes Konto. Bei echtem Verkauf braucht es dafür ein richtiges Konto/Backend (siehe Zahlungsanbieter-Hinweis unten).
4. **Meditationstexte**: alle 40 Übungen sind inzwischen handgeschrieben (siehe §5a) — keine generierten Platzhaltertexte mehr.
5. **"Profil"-Tab**: existiert inzwischen (Status-Karte, Insel-Woche, Inselreise, Verlauf löschen). Der "Schlaf"-Tab wurde entfernt statt als Platzhalter stehen zu lassen.
6. **Barrierefreiheit**: Kompass-Drag aktuell nur Pointer-Events — Tastatursteuerung/ARIA fehlt noch.
7. **Mehrsprachigkeit**: Oberfläche Hochdeutsch, Meditationen Schweizerdeutsch, beides hart codiert.
8. **Themenvielfalt** (siehe §5a): Titelliste und Texte sind umgesetzt. Offen: passende Fotos je Thema beschaffen und `bg`-Feld je Meditation einführen.
9. **Bezahlung**: Testphase/Abo-Zustand ist reine Anzeige-Logik ohne echten Zahlungsanbieter — siehe Hinweis auf der Abo-Seite in der App ("noch nicht bezahlbar"). Solange das so ist, steht in `index.html` der Schalter `var ABO_LIVE = false;` — damit bleibt die ganze Bibliothek für alle offen (keine gesperrten Übungen, keine Testphasen-/Ablauf-Anzeige in Profil und Abo-Seite). Die Test-/Abo-Logik (`hatAbo()`, `imTest()`, `GRATIS_IDS`, Plan-Auswahl) bleibt vollständig im Code erhalten und lässt sich mit `ABO_LIVE = true` jederzeit wieder scharf schalten, sobald eine echte Bezahlung angeschlossen wird.
10. **Kompass-Empfehlungslogik (Meditation 1 & 2)**: Entwurf von Christine liegt vor — Quadranten-Stimmungswörter (bereits umgesetzt) und ein eigener Empfehlungs-**Text** je Stimmungswort sind umgesetzt (`MOODS[...].next`, `#recNote` in Meditation 1, siehe §5 "Geplant: Intensität + Empfehlungslogik"). Noch offen: das Intensitäts-Konzept (Distanz vom Zentrum soll künftig mitzählen) und die eigentliche Auswahl-**Logik** (welche der 40 Übungen zu welchem Stimmungswort/welcher Intensität passt) — beides wartet auf die Meditations-Klassifizierung von Christine. Gleiches offen für die Yoga-Icons der Kategorie-Kacheln in Meditation 2 (siehe §3.3a). Sobald es soweit ist, wird dieser Teil mit dem leistungsfähigeren Opus-5-Modell umgesetzt (Christines Wunsch).

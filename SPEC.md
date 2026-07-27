# My Island — App-Spezifikation

Meditations-App rund um die eigene "Insel": Nutzer:innen richten sich über einen Kompass aus, wählen passende geführte Meditationen aus einer kategorisierten Bibliothek und bekommen am Ende einen Rückblick, was sich verändert hat.

**Wichtig fürs Verständnis der Marke:** Die Insel ist eine **Metapher**, kein Themenzwang. Sie steht für den Kraftort in einem selbst — den Ort, an den man sich zurückzieht, um anzukommen, durchzuatmen und bei sich zu sein. Das heisst: Die *Insel* ist der Rahmen (Startseite, Kompass, Abschluss, Bildsprache), die *Meditationen darin* müssen inhaltlich nicht bei "Strand und Palmen" bleiben — genau wie ein Rückzugsort auch nicht bedeutet, dass jedes Gespräch darin vom Rückzugsort handeln muss. Siehe §5a für die daraus folgende Themenvielfalt.

Titel/Überschriften wurden entsprechend angepasst: Browser-Tab und Home-Bildschirm-Symbol heissen weiterhin **"My Island"**, die Kopfzeile auf Kompass-/Meditations-/Abschluss-Seite heisst **"Gestalte deine Inselreise"** (vorher "Gestalte deine Trauminsel") — man *reist*, man baut keine Insel mehr zusammen (der alte Insel-Konfigurator ist ohnehin nicht im Hauptfluss, siehe §4). Der Text unten auf der Startseite benennt die Metapher jetzt direkt: "Deine Insel ist dein Kraftort in dir – der Ort, an den du dich zurückziehst, um bei dir anzukommen."

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
- **Persistente Tab-Bar** unten (`.tabbar`, 70px hoch, dunkel/transparent): Home, Meditation (aktiv/klickbar), Schlaf, Profil (beide Letzteren zeigen nur ein "bald"-Badge — keine echte Funktion).

---

## 3. Seiten-/Flow-Übersicht

Umsetzung aktuell über ein `data-step`-Attribut auf `<body>` + CSS-Sichtbarkeitsregeln pro Step (kein Router). Reihenfolge:

```
Home  →  Kompass  →  Meditationsauswahl  →  Session (Vollbild)  →  Abschluss
 ↺ (Neu beginnen)                                                    ↳ "Noch eine Meditation" → zurück zu Meditationsauswahl
```

Der frühere Insel-Konfigurator-Schritt (`island`) existiert im Code noch (SVG-Insel-Generator mit Größe/Wetter/Meer/Charakter/Boot), ist aber **aus dem Hauptfluss entfernt** — "Los geht's" auf der Startseite führt direkt zum Kompass. Der Insel-Step wird nur noch indirekt gebraucht: sein Standard-Rendering ist der Hintergrund der Session, wenn man **nicht** im "in-session"-Fotomodus ist (siehe unten).

### 3.1 Home (`data-step="home"`)
- Vollflächiges Foto (Boot + Insel, Sonnenuntergang), edge-to-edge, keine Karte/Rand
- Oben auf dem Foto: Titel "My Island" (Serif, weiß) + Tagline "Eine Insel für dich. Zeit zum Ankommen."
- Unten auf dem Foto: Text "Deine Insel im Alltag – ein Moment zum Ankommen, Durchatmen und einfach Sein." + CTA-Pille "Los geht's" (→ Kompass) + Textlink "Anmelden" (→ ebenfalls Kompass, kein echtes Auth)
- Dunkler Verlauf oben *und* unten fürs Lesen, sonst ist die Mitte des Fotos frei sichtbar

### 3.2 Kompass ("Deine innere Ausrichtung")
- Gezeichneter Nautik-Kompass (SVG): Messing-Gehäuse, 8-strahlige Rose mit Hell/Dunkel-Schattierung je Zacke, 32 feine Randstriche
- Vier Wörter statt Himmelsrichtungen: **oben Denken, unten Fühlen, links Anspannung, rechts Entspannung**
- Ein roter Punkt/Zeiger, **frei innerhalb der Scheibe verschiebbar** (nicht nur am Rand!) — wichtig: die beiden Achsen (Denken↔Fühlen, Anspannung↔Entspannung) sind **unabhängig voneinander** wählbar
- Ergebnis wird **nicht in Prozent**, sondern in weichen Sätzen ausgegeben (`compassWords()`, siehe §5)
- Speichert `compassBefore = {x, y}` (jeweils −1…1)

### 3.3 Meditationsauswahl
- Zwei Präferenz-Fragen oben: "Wie viele Meditationen?" (1/2/3) und "Maximale Dauer insgesamt?" (10/20/30 Min/egal)
- Live-Status: "2 von 3 ausgewählt · 15 Min gesamt (Ziel: 20 Min)"
- Bibliothek in **3 aufklappbaren Kategorien** (siehe §5), Mehrfachauswahl mit nummerierten Checkboxen (①②③…)
- Empfehlungslogik wählt automatisch passende Übungen zur Kompass-Richtung; die Kategorie mit einer Empfehlung **klappt automatisch auf**
- KI-Begleiter-Chat (kontextbewusst, kann per `[EMPFEHLUNG: <Name>]`-Tag eine Übung zur Auswahl hinzufügen)
- "Insel betreten & starten →" → Vollbild-Session

### 3.4 Session (Vollbild, `body.entered.in-session`)
- Hintergrund: **aktuell überall dasselbe Titel-Foto** (nicht die animierte SVG-Insel), scharf statt verwischt gezeigt
- Unteres Panel: Name + Position ("Meditation 2 von 3"), Fortschritts-Punkte für die Playlist, Anleitungstext (wandert mit der Zeit durch die `steps[]`), Fortschrittsbalken, Timer, Pause/Vorspulen/Fertig
- Playlist spielt die gewählten Übungen **automatisch nacheinander** ab
- ⚠️ Geplant (siehe §5a): der Hintergrund soll künftig zum Thema der jeweiligen Meditation passen, nicht mehr immer die Insel zeigen

### 3.5 Abschluss
- Zweiter Kompass (gleiche Optik/Bedienung), Frage "Wie fühlst du dich jetzt?" → `compassAfter`
- Rückblick: **nur noch** Vorher/Jetzt (in Worten) + Liste der gemachten Meditationen mit Dauer — **keine** Insel-Details mehr (Größe/Palmen/Wetter wurden bewusst entfernt)
- Ein Satz zur Veränderung (`updateShift()`, vergleicht Vorher/Jetzt)
- "Brauchst du noch etwas?": Buttons **"Noch eine Meditation"** (zurück zur Auswahl, neue Empfehlung basiert auf dem *neuen* Kompassstand) und **"Ein Mantra für mich"** (schickt automatisch eine Anfrage an den Chat-Begleiter)
- Begleiter-Chat (zweite Instanz, ohne Empfehlungs-Tag-Parsing)
- "Neu beginnen" (→ Home) / "Zurück auf die Insel" (→ Vollbild-Ansicht der SVG-Insel, ohne Session)

---

## 4. Insel-Konfigurator (aktuell nicht im Hauptfluss, Code vorhanden)

Falls im neuen Repo reaktiviert werden soll: eigener Screen mit Live-Vorschau oben (80% Höhe) und kompakter, scrollbarer Filterleiste unten (20% Höhe). Optionen: Wetter (sonnig/wolkig), Meer (ruhig/wellig), Charakter (Geschlecht, Haut-/Haar-/Outfitfarbe per Swatches), Ankunft (Boot/schon da). Größe und Palmenanzahl sind fix auf "Mittel". Insel + Boot + Person sind alle als handgezeichnete SVG-Illustration umgesetzt (kein Foto), inkl. animiertem Boot-Einlaufen, schwimmenden Fischen, Wolken/Sonne je nach Wetter.

---

## 5. Datenmodell & Kernlogik

### Kompass
```js
compassBefore = { x: -1..1, y: -1..1 }   // x: -1=Anspannung … 1=Entspannung
compassAfter  = { x: -1..1, y: -1..1 }   // y: -1=Denken     … 1=Fühlen

dirFromCompass(c)   // → "nord"|"sued"|"west"|"ost", dominante Achse gewinnt
compassWords(c)     // → weicher Satz (siehe COMPASS_COMBOS: 4 Richtungspaare × 3 Intensitäten "leicht/klar/stark", + Sonderfall "ausgeglichen" bei Betrag < 0.15)
compassText(c)      // Prozent-Variante — nur noch intern für den KI-Kontext genutzt, NICHT mehr im UI
```

### Meditationen
```js
DIRS = { nord:"Denken", sued:"Fühlen", west:"Anspannung", ost:"Entspannung" }  // + je ein Erklärsatz

CAT_INFO = {
  mini:   { name:"Mini Insel-Meditationen",     range:"3–6 Min",   … },
  mittel: { name:"Mittlere Insel-Meditationen", range:"7–14 Min",  … },
  tief:   { name:"Tiefe Insel-Meditationen",    range:"15–30 Min", … }
}

MEDITATIONS[] = {
  id, dir ("nord"|"sued"|"west"|"ost"), cat ("mini"|"mittel"|"tief"),
  name, min (Zahl), desc, steps: [ "...", "...", ... ]  // Anleitungstexte, zeitlich verteilt über die Dauer
}
```
- **8 handgeschriebene "Flaggschiff"-Meditationen** (Atem-Anker, Gedanken wie Wolken, Herzraum, Gefühle benennen, Körper lösen, Wellen-Atem, Stille genießen, Dankbarkeit am Strand) — jede mit eigenem, einzigartigem Skript.
- **`generateLibrary()`** füllt jede Kategorie auf 13 Einträge auf (macht insgesamt **39** Meditationen): kombiniert einen Themen-Namen (`THEMES[dir]`, ~13 Begriffe je Richtung, z. B. "Herzenswärme", "Schulter-Fall") mit einem Baukasten aus Anleitungssätzen (`PHRASES[dir] = { open, mid[8], close }`). Pro Kategorie ist die Anzahl der "mid"-Sätze unterschiedlich (mini=1, mittel=3, tief=5), wodurch die Session-Länge zur Dauer passt.
- ⚠️ **Bekannte Einschränkung:** Die 31 generierten Einträge sind inhaltlich stimmig, aber nicht individuell wie die 8 Flaggschiffe. Für Produktionsreife sollten die wichtigsten davon (v. a. die, die oft empfohlen werden) durch echte, einzeln geschriebene Skripte ersetzt werden.

## 5a. Themenvielfalt (Konzept, noch nicht umgesetzt)

**Entscheidung:** Die Insel bleibt das einzige Bild/Branding der App (kein zweites, drittes Landschafts-"Skin"). Die *Meditationen selbst* werden aber inhaltlich viel breiter als bisher — nicht mehr nur Strand/Palmen/Wellen, sondern klassische Themen aus Achtsamkeit, Körperarbeit und Alltagsbewältigung. Die vier Kompass-Richtungen (Denken/Fühlen/Anspannung/Entspannung) bleiben als Zuordnungs-Logik bestehen; jedes neue Thema bekommt weiterhin eine Richtung zugeordnet, damit die Empfehlungslogik unverändert funktioniert.

**Kuratierte Themenliste (Entwurf, 40 Themen)** — als Ersatz/Ergänzung für die generierten Themen aus `THEMES[dir]`, verteilt auf die drei bestehenden Kategorien. Dies ist ein Vorschlag zur Durchsicht, keine finale Liste:

| Kategorie | Themen (Auswahl) |
|---|---|
| **Mini** (3–6 Min) | Atem-Anker · Kurzer Körper-Scan · Erdungsatem · Kurze Lichtmeditation · Dankbarkeits-Blitzlicht · Vertrauens-Anker · Kraft-Impuls · Herz beruhigen · Loslass-Atem · Freundlicher Blick auf mich · Fantasiereise: Ankommen am See (kurz) · Fantasiereise: Insel-Anker (kurz) · Feierabend-Übergang (Arbeit → Zuhause) |
| **Mittel** (7–14 Min) | Herzraum · Gefühle benennen · Wurzelchakra – Erdung · Herzchakra – Weite · Stirnchakra – Klarheit · Vertrauen aufbauen · Innere Stärke · Loslassen, was nicht mehr trägt · Verzeihen – ein erster Schritt · Alltag einer berufstätigen Mutter · Geduld im Umgang mit Kindern · Fantasiereise: Waldlichtung · Tiefenentspannung (progressiv) |
| **Tief** (15–30 Min) | Körper lösen · Wellen-Atem · Chakren-Reise (alle sieben) · Lichtmeditation Ganzkörper · Tiefes Vertrauen · Innere Stärke vertiefen · Grosses Loslassen · Verzeihen – dir selbst und anderen · Schwangerschafts-Reise · Fantasiereise: Bergspitze · Fantasiereise: Winterlandschaft · Fantasiereise: Insel · Yoga-Nidra-artige Tiefenentspannung · Dankbarkeits-Reise (ausführlich) |

**Bildsprache pro Meditation:** Der Foto-Hintergrund von Kompass-, Meditations- und Session-Seite (aktuell überall dasselbe Insel-Foto, siehe §3.4/§2) soll künftig **zur jeweiligen Meditation passen** — eine Fantasiereise "Bergspitze" mit Insel-Hintergrund abzuspielen wäre inhaltlich unstimmig. Konkret geplant:
- Insel-Foto bleibt Standard-Hintergrund für Home, Kompass, Meditationsauswahl, Abschluss (der "Rahmen" der Reise) sowie für alle Insel-thematischen Meditationen.
- Für andere Themen (Wald, See, Winterlandschaft, Bergspitze, Chakren/Licht, …) braucht es **je ein eigenes Foto** für den Session-Hintergrund — diese Fotos liefert die Repo-Inhaberin, sie werden nicht selbst erzeugt/erfunden.
- Bis die zusätzlichen Fotos vorliegen, bleibt der Insel-Hintergrund als Platzhalter für alle Themen bestehen.

**Umsetzung (noch offen):** `MEDITATIONS[]` bräuchte ein Feld `bg` (welches Foto für die Session), `THEMES`/`PHRASES` müssten um die neuen Themenfelder erweitert werden oder ganz durch handgeschriebene Einträge ersetzt werden (siehe bekannte Einschränkung oben — 31 generierte Texte wirken formelhaft, das gilt für neue Themen genauso). Reihenfolge der nächsten Schritte: (1) Themenliste mit der Repo-Inhaberin final abstimmen, (2) passende Fotos je Thema sammeln, (3) Texte je Thema schreiben, (4) Datenmodell um `bg` erweitern.

### Auswahl-Logik
```js
chosenMedIds = []      // Reihenfolge = Playlist-Reihenfolge
desiredCount = 2        // 1..3, von der Person gewählt
maxDuration  = 20        // Minuten, oder 99 = "egal"
completedLog = []        // [{name, min, seconds}], während der Session befüllt
catOpenState = { mini:false, mittel:false, tief:false }  // Accordion-Zustand
```
Erst-Empfehlung: aus allen zur Kompass-Richtung passenden Meditationen werden — sortiert nach kürzester Dauer zuerst — so viele genommen, bis `desiredCount` erreicht oder `maxDuration` überschritten würde.

### Session/Playlist
```js
session = { timer, elapsed, total, paused, queue: MeditationObjekt[], index }
```
`advanceQueue()` schaltet automatisch zur nächsten Übung, `completedLog` wird dabei fortlaufend befüllt (auch bei vorzeitigem Abbruch via "Fertig").

### Steps
```
STEPS = { home, island (optional, nicht im Fluss), compass, meditation, outro }
TAB_FOR_STEP = { home:"home", meditation:"meditation" }  // andere Steps haben keinen Tab
```

---

## 6. KI-Begleiter

- Zwei Chat-Instanzen: eine auf der Meditationsauswahl (`allowRecommend = true`), eine im Abschluss (`false`)
- System-Prompt: warmherziger, kurzer (max. 3 Sätze), unaufdringlicher Begleiter, keine Diagnosen, ermutigt bei ernster Not zu echtem menschlichen Kontakt
- Bekommt vollen Kontext mitgeschickt: Kompass vorher/(nachher), gewünschte Anzahl/Dauer, aktuelle Auswahl bzw. abgeschlossene Meditationen
- Kann in der Auswahl-Ansicht per angehängtem `[EMPFEHLUNG: <exakter Name>]`-Tag eine Übung **zur Mehrfachauswahl hinzufügen** (nicht ersetzen)
- Fallback-Sätze bei API-Fehlern/Offline (kein Absturz, kein sichtbarer Fehler für die Person)

---

## 7. Offene Punkte / nächste Schritte für das neue Repo

1. **Architektur**: von "ein HTML-File mit `data-step`" zu echten Routen/Komponenten migrieren.
2. **Assets**: Fotos aus base64 lösen, als echte Dateien (WebP/AVIF) mit `srcset` einbinden.
3. **Persistenz**: Verlauf und Abo-Testphase liegen inzwischen in `localStorage` (geräte-gebunden, siehe §5 in `index.html`, Schlüssel `myisland.verlauf.v1`/`myisland.abo.v1`) — kein Server, kein geräteübergreifendes Konto. Bei echtem Verkauf braucht es dafür ein richtiges Konto/Backend (siehe Zahlungsanbieter-Hinweis unten).
4. **Meditationstexte**: die 31 generierten Übungen inhaltlich vertiefen (s. o.); dieselbe Einschränkung gilt für die neuen Themen aus §5a.
5. **"Profil"-Tab**: existiert inzwischen (Status-Karte, Insel-Woche, Inselreise, Verlauf löschen). Der "Schlaf"-Tab wurde entfernt statt als Platzhalter stehen zu lassen.
6. **Barrierefreiheit**: Kompass-Drag aktuell nur Pointer-Events — Tastatursteuerung/ARIA fehlt noch.
7. **Mehrsprachigkeit**: Oberfläche Hochdeutsch, Meditationen Schweizerdeutsch, beides hart codiert.
8. **Themenvielfalt** (siehe §5a): Themenliste abstimmen, passende Fotos je Thema beschaffen, Texte schreiben, `bg`-Feld je Meditation einführen.
9. **Bezahlung**: Testphase/Abo-Zustand ist reine Anzeige-Logik ohne echten Zahlungsanbieter — siehe Hinweis auf der Abo-Seite in der App ("noch nicht bezahlbar").

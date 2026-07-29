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
- **Persistente Tab-Bar** unten (`.tabbar`, 70px hoch, dunkel/transparent, während der Session ausgeblendet): 5 Tabs — **Start · Kompass · Für dich · Alle Übungen · Profil**. Die frühere Doppelung "Bibliothek"/"Für dich" (beides klang nach demselben) ist damit aufgelöst: **Für dich** (§3.3) ist die persönliche Auswertung mit Empfehlungen, **Alle Übungen** (§3.3a) die Bibliothek zum Stöbern. Eigene Symbole je Tab (Herz bzw. Buch).
- **Safe-Area:** `--safe-bottom: env(safe-area-inset-bottom)` wird auf `body` (Innenabstand unten) und `.tabbar` (Höhe + Innenabstand) angerechnet. Ohne das verschwanden auf echten iPhones die untersten Buttons hinter der Leiste, obwohl im Test alles passte — der Home-Indikator-Bereich (~34px) fehlte in der Rechnung. Tests können den Wert über `:root{--safe-bottom:34px}` nachstellen.

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

### 3.2 Kompass ("Wie fühlst du dich gerade?")

Als einziger Screen bewusst nach einer **festen visuellen Hierarchie** aufgebaut (Redesign-Auftrag "Premium-Look, Kompass ist das Zentrum"): **1. Kompass → 2. Status → 3. Optionen → 4. Weiter-Button → 5. sekundäre Navigation**. Alle Abstände folgen einem **8-pt-Raster** (8/12/16/24).

- Fotobasierter Nautik-Kompass (echtes Kompass-Foto, kreisförmig zugeschnitten) mit transparentem SVG-Overlay: Vier Wörter statt Himmelsrichtungen, jeweils **mit Symbol davor**: 🧠 Denken (oben), ❤️ Fühlen (unten), 😣 Anspannung (links), 😌 Entspannung (rechts). Die Symbole stehen einzeilig vor dem Wort (`<tspan class="rose-icon">`); übereinander gestapelt gerieten sie in den Aussenring und wirkten unruhig.
- **Selbsterklärender Mittelpunkt:** Ein gestrichelter Kreis (`.rose-calm-zone`, r=25 in SVG-Einheiten) markiert genau die Zone, in der `moodOf()` "ausgeglichen" liefert (Betrag < 0.15). Die Nabe selbst ist eine weisse Scheibe mit dunklem Ring und Kernpunkt statt eines dünnen Kreises — der Bezugspunkt ist damit sofort sichtbar.
- **Bühne (`.compass-stage`):** Titel, Hinweis, Kompass und Status liegen zusammen auf einer hellen, milchigen Fläche (`rgba(255,255,255,.68)` + `blur(24px) saturate(1.25)`, weicher weisser Rand, 32px Radius). Sie hebt den Kompass klar vom Foto ab und ersetzt sowohl den früheren Text-Schein (`text-shadow`) als auch die Titel-Plakette. Der Hintergrund ist auf diesem Schritt zusätzlich stärker weichgezeichnet und abgedunkelt (`body[data-step="compass"]::before/::after`), damit nichts mit der Bühne konkurriert.
- **Text kurz und aufgabenorientiert:** Überschrift **"Wie fühlst du dich gerade?"** (Serif, 1.45rem) + eine Zeile **"Zieh den roten Punkt dorthin, wo du stehst."** — "roten Punkt" ist rot hervorgehoben, damit klar ist, *was* gezogen wird. Beide Zeilen bleiben bewusst einzeilig; jeder Umbruch kostet Höhe, die dem Kompass fehlt.
- **Kompass-Grösse — höhenbewusst statt fester Stufen:** `max-width: min(320px, calc(100dvh - var(--tabbar-h) - var(--safe-bottom) - 475px))`. Der Abzugswert ist die gemessene Höhe alles Übrigen; der Kompass bekommt also auf jedem Gerät automatisch die grösstmögliche Grösse, die noch ohne Scrollen passt (Pro Max 320px, iPhone 14 265px, iPhone SE 207px — auf kurzen Bildschirmen mit eigenem, kleinerem Abzugswert). Damit die Bühne auf schmalen Geräten die volle Breite nutzt, ist die seitliche Polsterung der `.compass-card` hier kleiner (8px); die Luft sitzt innen in der Bühne, wo man sie sieht.
- **Status (`#compassReadout`, `renderMoodStatus()`):** zwei Ebenen statt nur eines Worts.
  1. **Abgestufte Pille** (`.mood-badge`): Emoji + ganzer Satz, dessen Stärke sich live mit der Nadel ändert — "Du fühlst dich **etwas** unruhig" (< 0.42) → "**eher** unruhig" (< 0.72) → "**sehr** unruhig". In der Ruhezone: "Du fühlst dich ausgeglichen". Bewusst **"Du fühlst dich"**, nicht "Du wirkst": die Nadel setzt die Person selbst, das ist eine Selbstaussage und keine Beobachtung von aussen.
  2. **Zwei schlanke Achsen-Spuren** (`.status-axes`) mit denselben Symbolen wie am Kompass (😣—😌 und 🧠—❤️) und je einem Punkt, der die aktuelle Position auf dieser Achse zeigt. Macht die zwei unabhängigen Achsen unmissverständlich und liefert dieselbe Information auch als `aria-label` für Screenreader. Auf kurzen Bildschirmen ausgeblendet — dort zählt jeder Pixel für den Kompass, und die Nadel zeigt dasselbe.
  Der Block wird **einmal** aufgebaut und danach nur noch aktualisiert, damit die Übergänge weich animieren statt bei jedem Ziehen neu zu springen.
- **Mikro-Interaktion beim Ziehen:** Der rote Punkt wächst weich von r=11 auf r=14 und bekommt einen weichen roten Schein (`.rose-needle-halo`, r=0 → 26), das Status-Emoji skaliert leicht mit; alles über `cubic-bezier`-Übergänge von 0.22–0.28s. Zusätzlich ein kurzes haptisches Signal über `navigator.vibrate(8)`, wo das Gerät es unterstützt (iOS ignoriert es stillschweigend).
- **Optionen (`#durationGroupCompass`, `.compass-prefs`) — Zeit zuerst:** "Wie viel Zeit hast du?" (5/10/15/20/30 Min, `#durationOptsV2`) steht **vor** "Wie viele Meditationen?" (`Eine`/`Zwei`/`Drei`, `#countOptsV2`) — die Zeit ist die wichtigere Entscheidung. Die Anzahl heisst ausgeschrieben statt "1/2/3", weil nackte Zahlen ohne Bezug unklar wirkten. Bewusst **untergeordnet gestaltet**: zwei gestapelte Zeilen, kleine Grossbuchstaben-Labels, kompakte Chips mit `flex:1` — jede Gruppe passt garantiert auf **eine** Zeile. Setzen die globalen `desiredCountV2`/`durationV2` für "Für dich" (§3.3a).
- **Aktionen:** "← Zurück" (sekundär) und der grüne CTA **"Meine Meditationen →"** — emotionaler und besitzanzeigend statt des neutralen "Zu den Meditationen". Er führt zur Auswahl, nicht direkt in eine Übung; deshalb bewusst *nicht* "Jetzt starten", das wäre ein falsches Versprechen. Grösse und Stil bleiben identisch zu den CTAs aller anderen Seiten.
- **Vertikale Zentrierung:** Auf hohen Geräten wird der Inhalt mittig gesetzt (`justify-content:center` auf `.compass-page`), sonst blieb unten ein grosses Loch.
- Weiterhin gilt: **alles inklusive der Buttons ganz unten bleibt ohne Scrollen sichtbar**, auf allen drei getesteten Bildschirmgrössen (375×667, 390×844, 430×932) — **und zwar mit eingerechneter Safe-Area** (siehe §2), was vorher gefehlt hat.
- Ein roter Punkt/Zeiger, **frei innerhalb der Scheibe verschiebbar** (nicht nur am Rand!) — wichtig: die beiden Achsen (Denken↔Fühlen, Anspannung↔Entspannung) sind **unabhängig voneinander** wählbar
- Ergebnis wird **nicht in Prozent**, sondern als kurzes Wort ausgegeben (`moodOf()`, siehe §5) — dabei zählt **nur der Winkel**, nicht wie weit gezogen wird: welcher der beiden Pole eines Quadranten (z. B. Fühlen oder Entspannung) näher an der Nadel liegt, bestimmt das Wort
- Speichert `compassBefore = {x, y}` (jeweils −1…1)

### 3.3 "Für dich" — persönliche Empfehlungen (`data-step="meditation"`)

Der Kern-Screen der App. Er war vorher ein Katalog (Akkordeon nach Dauerstufe) und fühlte sich dadurch wie eine Bibliothek an, obwohl davor ein Assessment steht. Jetzt ist die Reihenfolge umgedreht: **erst die Auswertung, dann die Empfehlung, ganz zum Schluss die Kategorien.**

**Aufbau (`.fd-shell`, in genau dieser Reihenfolge):**
1. **Begrüssung + Titel** — `#fdGreeting` wechselt mit der Tageszeit ("Guten Morgen" / "Schön, dass du da bist" / "Guten Abend"), darunter "Das habe ich heute für dich". Der Schweizerdeutsch-Hinweis ist zu einem kleinen Badge (`.fd-badge`, "🇨🇭 Schweizerdeutsch") geschrumpft — vorher war es eine breite Pille, die mehr Gewicht hatte als der Inhalt.
2. **Kompass-Auswertung** (`#fdState`) — Emoji, "Dein Kompass zeigt", das Zustandswort gross, darunter **zwei Beobachtungen** aus `MOODS[...].bullets` ("viele kreisende Gedanken", "innerlich unruhig") und abgetrennt die Begründung aus `.next`. Damit beantwortet die Seite die Frage "warum bekomme ich genau diese Übungen?", bevor sie gestellt wird.
3. **Top-Empfehlung** (`#fdHero`) — eine grosse Karte mit Tag "⭐ Passt zu dir", Name, Dauer, **zwei Gründen mit Häkchen** und einem direkten **"Jetzt starten"**. Ein Tipp, ein Start: kein Auswählen, Anhaken und Bestätigen mehr.
4. **"Auch gut für dich"** (`#fdMore`) — bis zu drei kleinere Karten, jede mit Name, Dauer, Grund und Play-Symbol; Antippen startet sofort.
5. **"Alle Meditationen entdecken"** (`.fd-explore`) — erst hier die vier Kategorien, plus "Ganze Bibliothek ansehen →" zur Bibliothek (§3.3a). Eine Kategorie führt direkt in die passende Bibliotheks-Kategorie.
6. **Begleiter-Chat** und "← Zurück zum Kompass".

**Empfehlungslogik (`empfehlungen()`):** Pool = alle freien Übungen der Kompass-Richtung. Sortiert nach
1. **Passt zur gewählten Zeit** (`durationV2`, ±4 Min) — die Zeitangabe auf der Kompass-Seite ist eine bewusste Ansage und wird jetzt auch hier eingelöst; vorher wirkte sie nur auf die Bibliothek. Die gewählte Zeit steht als "für 10 Min" neben der Überschrift.
2. **Anspannung** — wer angespannt ist (`compassBefore.x < 0`), bekommt kurze, erdende Übungen zuerst (lange stillsitzen fällt dann schwer); wer schon ruhig ist, bekommt die längeren zum Vertiefen. Dadurch unterscheiden sich auch Zustände aus derselben Richtung (grüblerisch ↔ gedankenvoll, aufgewühlt ↔ geborgen).
3. Rest nach Nähe zur Zieldauer, damit die Liste nicht zwischen 30 und 4 Minuten springt.

**Begründungen (`NUTZEN`/`TIEFE`):** abgeleitet aus Richtung und Dauerstufe, die ohnehin an jeder Meditation stehen ("Beruhigt kreisende Gedanken" + "Kurz und sofort spürbar") — statt 40 handgepflegter Texte. Der Begleiter-Chat setzt seine Empfehlung über `empfohlenVomChat` an die erste Stelle.

**Optik:** eigene helle Fläche (`#f6f3ec`) statt Foto-Hintergrund — dunkler Text auf Creme ist deutlich besser lesbar als auf dem hellblauen Bild, und die Seite wirkt aufgeräumter. Weisse Karten mit weichem Schatten, grosse Serif-Überschriften, 8-pt-Abstände.

**Offen:** Die Auswahl ist damit auf "eine Übung pro Start" reduziert. Mehrere Übungen hintereinander kombiniert man weiterhin in der Bibliothek (§3.3a) — dort wirkt auch die Anzahl-Einstellung vom Kompass.

### 3.3a "Alle Übungen" — die Bibliothek (`data-step="meditation2"`)

Zum Stöbern, wenn man nicht der Empfehlung folgen will. Vorher waren hier nur vier Kacheln, hinter denen sich alles versteckte — **zwei Drittel des Screens blieben leer**, und eine Bibliothek, die keine Übungen zeigt, lädt nicht zum Stöbern ein. Jetzt zeigt die Seite den Inhalt selbst.

**Aufbau (`.lib-shell`):**
- **Kopf** — Eyebrow "BIBLIOTHEK" (Salbei, gesperrt), Serif-Titel **"Finde deine Übung"** (2rem), darunter die Bestandszahl: "**40** geführte Übungen · 3–30 Minuten". Die Zahl ist bewusst gesetzt: sie belegt den Umfang und rechtfertigt damit das Abo, wo vorher gar nichts über den Bestand stand.
- **Filter statt Drill-down** (`.lib-filters`, `#libFilters`) — waagrechte, scrollbare Chips: Alle · 🧠 Gedanken beruhigen · ❤️ Gefühle verstehen · 💪 Stress lösen · 🌿 Entspannen. Gleiche Information wie das frühere 2×2-Raster in **einem Sechstel der Höhe**; der aktive Chip ist dunkel gefüllt und scrollt sich selbst in den sichtbaren Bereich.
- **Liste, nach Länge gruppiert** (`.lib-list`) — Abschnitte "Kurz · 3–6 Min · 13", "Mittel", "Tief". Jede Zeile: Auswahlkreis, Name, Kurzbeschreibung (einzeilig abgeschnitten) und die Dauer rechts in Serif — immer an derselben Stelle, damit Vergleichen leichtfällt.
- **"schon gemacht"** — Übungen, die im Verlauf vorkommen (`schonGemacht()` aus `loadHistory()`), bekommen ein kleines Kennzeichen. Echte Daten, nichts Erfundenes; macht die Liste persönlich.
- **Auswahl-Leiste** (`.lib-bar`) — klebt über der Tabbar (`bottom: calc(tabbar + safe + 12px)`), zeigt "2 Übungen · 8 Min" und den Start-Button. Blendet sich weich aus, wenn nichts gewählt ist. Der Start ist damit immer erreichbar, egal wie weit gescrollt wurde.

**Verhalten:** Ein Kategorie-Chip füllt passend zu **Anzahl und Zieldauer** vom Kompass vor (`autoFillV2()`); "Alle" startet leer. Mehrfachauswahl bleibt auf `desiredCountV2` begrenzt (älteste fällt raus). `openCatV2(dir)` — aufgerufen von den Kategorien auf "Für dich" — setzt jetzt nur noch den Filter, statt in eine Unterseite zu springen.

**Farben/Typografie:** wärmere Basis als zuvor, Karten `#fffefb` mit 1px-Rand statt Schatten (ruhiger, hochwertiger), Text `#14211d` für mehr Kontrast, Auswahl in Salbei. Serif nur für Titel und Dauer — das setzt Akzente, ohne verspielt zu wirken.

### 3.4 Session (Vollbild, `body.entered.in-session`)
- Hintergrund: **aktuell überall dasselbe Titel-Foto** (nicht die animierte SVG-Insel), scharf statt verwischt gezeigt
- Unteres Panel: Name + Position ("Meditation 2 von 3"), Fortschritts-Punkte für die Playlist, Anleitungstext (wandert mit der Zeit durch die `steps[]`), Fortschrittsbalken, Timer, Pause/Vorspulen/Fertig
- Playlist spielt die gewählten Übungen **automatisch nacheinander** ab
- ⚠️ Geplant (siehe §5a): der Hintergrund soll künftig zum Thema der jeweiligen Meditation passen, nicht mehr immer die Insel zeigen

### 3.5 Abschluss
- Zweiter Kompass (gleiche Optik/Bedienung inkl. Achsen-Symbolen und Ruhezone), Frage "Wie fühlst du dich jetzt?" → `compassAfter`
- **Deine Reise auf dem Kompass** (`zeichneReise()`): Ein heller, türkis umrandeter Punkt (`.rose-journey-start`) markiert, **wo du angekommen bist**, eine gestrichelte Spur (`.rose-journey`) führt von dort zur aktuellen Nadel. So wird die Bewegung von Anspannung zu Entspannung als persönliche Reise sichtbar, statt nur als zwei Wörter im Rückblick. Bei sehr kleinen Wegen (< 0.08 Gesamtabstand) bleiben Punkt und Spur ausgeblendet — sonst wäre es nur Rauschen. Aktualisiert sich live, während man den zweiten Kompass zieht.
- Derselbe zweistufige Status wie auf der Kompass-Seite (abgestufte Pille + Achsen-Spuren, §3.2/§5) — hier **mit** der Zeile "Ziehe den roten Punkt, um es anzupassen", weil über diesem Kompass kein Hinweis steht.
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
moodOf(c)           // → { emoji, word, next } (siehe MOODS: 4 Richtungspaare × 2 Woerter "vert"/"horiz",
                        //   + Sonderfall MOOD_BALANCED "ausgeglichen" bei Betrag < 0.15). Nur der WINKEL
                        //   entscheidet, welcher der beiden Pole eines Quadranten naeher liegt - wie weit
                        //   man zieht (Laenge) spielt bewusst keine Rolle. "next" ist Christines Formulierung
                        //   dafuer, wohin die Uebungen von genau diesem Stimmungswort aus fuehren (siehe
                        //   #recNote in §3.3) - eigenstaendiger Text pro Wort, unabhaengig von dirFromCompass.
moodHtml(c)         // → "<emoji> wort" - kurze Form fuer Listen/Rueckblick ("Vorher: 😊 ausgeglichen")
MOODS[...].bullets  // zwei kurze Beobachtungen je Zustand ("viele kreisende Gedanken") - werden
                        //   auf "Für dich" (§3.3) als Auswertung angezeigt
NUTZEN[dir]         // "Beruhigt kreisende Gedanken" o.ae. - warum eine Uebung empfohlen wird
TIEFE[cat]          // "Kurz und sofort spuerbar" o.ae. - zweiter Grund je Uebung
KATEGORIEN[]        // { dir, icon, name } - Kategorien nach NUTZEN benannt statt nach Kompass-Achse
empfehlungen()      // Top-4 fuer den aktuellen Zustand: Zieldauer zuerst, dann Anspannung (§3.3)
starteMeditation(id)// startet EINE Uebung direkt - der Kern des Coach-Gefuehls
moodStaerke(c)      // → 0..1, wie weit die Nadel vom Zentrum weg liegt (max(|x|,|y|))
moodSatz(c)         // → "Du fühlst dich etwas|eher|sehr <wort>" - Schwellen 0.42 / 0.72;
                        //   in der Ruhezone "Du fühlst dich ausgeglichen". Selbstaussage, nicht
                        //   Beobachtung von aussen ("Du wirkst ...") - die Nadel setzt die Person selbst.
renderMoodStatus(el, c) // baut den Status-Block EINMAL auf (Pille + zwei Achsen-Spuren + Hinweis)
                        //   und aktualisiert danach nur noch Texte und Punkt-Positionen, damit die
                        //   Uebergaenge weich animieren. Genutzt unter beiden Kompassen (§3.2/§3.5).
zeichneReise()      // Abschluss-Seite: Startpunkt + gestrichelte Spur von compassBefore nach
                        //   compassAfter; unter 0.08 Gesamtabstand ausgeblendet (§3.5)
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

**Umgesetzt — Intensität in der Anzeige:** Die Distanz vom Zentrum zählt inzwischen mit, allerdings zunächst nur für den **angezeigten Zustand**: `moodStaerke()` liefert 0…1, `moodSatz()` macht daraus "etwas" (< 0.42) / "eher" (< 0.72) / "sehr" — genau die Abstufung, die Christine beschrieben hat (sehr angespannt → etwas angespannt → neutral → ruhig → sehr entspannt). Die Ruhezone ist auf dem Kompass zusätzlich als gestrichelter Kreis sichtbar (§3.2). Christines Achsen-Bedeutungen dahinter:
- Gedanken-Achse (Richtung Denken): aussen = sehr viele/rasende Gedanken, Richtung Mitte = ruhige, klare Gedanken.
- Gefühle-Achse (Richtung Fühlen): aussen = sehr belastende/intensive Gefühle, Richtung Mitte = ausgeglichene Gefühle.
- Anspannungs-Achse: Anspannung ↔ Entspannung bleibt ein Pol-zu-Pol-Gegensatz (kein Zentrum-Konzept nötig).

**Teilweise umgesetzt — welche Übung vorgeschlagen wird:** Die Auswahl richtet sich inzwischen nach Kompass-Richtung, gewählter Zeit **und** Anspannungsseite (§3.3, `empfehlungen()`), plus je zwei abgeleiteten Begründungen (`NUTZEN`/`TIEFE`). Damit sieht jeder der acht Zustände eine andere Liste. **Noch offen** bleibt eine echte inhaltliche Klassifizierung je Meditation (welche Übung passt zu welchem Stimmungswort und welcher Intensitätsstufe) — die liefert Christine nach; erst damit liesse sich z. B. "traurig" von "grüblerisch" inhaltlich unterscheiden statt nur über Richtung und Dauer.

### Meditationen
```js
DIRS = { nord:"Denken", sued:"Fühlen", west:"Anspannung", ost:"Entspannung" }  // + je ein Erklärsatz

MEDITATIONS[] = {
  id, dir ("nord"|"sued"|"west"|"ost"), cat ("mini"|"mittel"|"tief"),
  name, min (Zahl), desc, steps: [ "...", "...", ... ]  // Anleitungstexte, zeitlich verteilt über die Dauer
}
```
- **40 handgeschriebene Meditationen insgesamt** (13 mini / 13 mittel / 14 tief) — siehe §5a für die volle Titelliste. Kein Generator mehr: `generateLibrary()`/`THEMES`/`PHRASES` wurden entfernt, jeder Eintrag ist ein einzeln geschriebenes Skript.
- Das Feld `cat` ("mini"/"mittel"/"tief") steuert jetzt die Empfehlungs-Reihenfolge auf "Für dich" (§3.3, kurz-zuerst bei Anspannung) und liefert über `TIEFE[cat]` den zweiten Empfehlungsgrund. Als sichtbare Gliederung wird es nicht mehr benutzt — beide Seiten gruppieren nach Kompass-Richtung bzw. Nutzen-Kategorie.

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
chosenMedIds = []        // Reihenfolge = Playlist-Reihenfolge; auf "Für dich" immer genau eine
empfohlenVomChat = null  // Vorschlag des Begleiters, rutscht in empfehlungen() nach ganz oben
completedLog = []        // [{name, min, seconds}], während der Session befüllt

chosenMedIdsV2  = []     // eigener Auswahl-Zustand für die Bibliothek
currentCatV2    = null   // dort gewählte Kategorie
durationV2      = 10     // Minuten, auf der Kompass-Seite gewählt - wirkt auf BEIDE Seiten
desiredCountV2  = 2      // 1..3, auf der Kompass-Seite gewählt - wirkt nur auf die Bibliothek
```
**"Für dich"** (§3.3): `empfehlungen()` sortiert die Übungen der Kompass-Richtung nach (1) Nähe zur gewählten Zeit, (2) Anspannung (kurz-zuerst wenn angespannt, tief-zuerst wenn ruhig), (3) Restnähe zur Zeit. Die erste Übung wird als grosse Karte gezeigt, die nächsten drei kleiner; ein Antippen startet direkt (`starteMeditation()`). **Bibliothek** (§3.3a): `autoFillV2()` füllt beim Öffnen einer Kategorie bis `desiredCountV2`/`durationV2` auf, Mehrfachauswahl bleibt möglich.

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
10. **Kompass-Empfehlungslogik**: Umgesetzt sind Quadranten-Stimmungswörter, Begründungstexte je Zustand (`next`), die Intensitäts-Abstufung in der Anzeige ("etwas/eher/sehr") und seit dem "Für dich"-Umbau eine echte Empfehlungs-Reihenfolge aus Richtung + gewählter Zeit + Anspannungsseite (§3.3). **Offen** bleibt die inhaltliche Klassifizierung je Meditation von Christine — und damit auch die Yoga-Icons für die Kategorien (aktuell Emoji, siehe §3.3a).
11. **Emotionale Historie ausbauen**: Der Verlauf speichert Vorher/Nachher pro Sitzung bereits (§5, Insel-Woche und Inselreise im Profil), und die Reise einer *einzelnen* Sitzung ist seit dem UX-Durchgang auf dem Abschluss-Kompass sichtbar (§3.5, `zeichneReise()`). Offen: dieselbe Spur-Darstellung auch **über mehrere Sitzungen hinweg** zeigen — z. B. ein kleiner Kompass im Profil, der die letzten Reisen übereinanderlegt. Das war Christines Idee eines "besonderen Features" und ist der nächste sinnvolle Schritt darauf.

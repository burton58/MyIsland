# My Island

Meditations-App rund um eine persönliche "Trauminsel": Man richtet sich über einen
Kompass aus, wählt passende geführte Meditationen aus einer kategorisierten Bibliothek
und bekommt am Ende einen Rückblick, was sich verändert hat.

## Inhalt dieses Repos

| Datei | Beschreibung |
|---|---|
| `insel-gestalter.html` | Der komplette aktuelle Prototyp — ein einzelnes, selbstständiges HTML-File (HTML + CSS + Vanilla JS, kein Build-Step). Alle Fotos sind base64-inline eingebettet. |
| `SPEC.md` | App-Spezifikation: Design-System, Flow, Datenmodell, Kernlogik und offene Punkte für die Migration in ein echtes Repo. |

## Starten

Kein Build, keine Abhängigkeiten — `insel-gestalter.html` einfach im Browser öffnen:

```bash
open insel-gestalter.html       # macOS
xdg-open insel-gestalter.html   # Linux
```

## Hinweis zum KI-Begleiter

Der Chat-Begleiter ruft `https://api.anthropic.com/v1/messages` direkt per `fetch()` auf.
Im File ist **kein API-Key hinterlegt** (und es gehört auch keiner hinein — der wäre im
Client öffentlich sichtbar). Ohne erreichbaren Endpunkt greifen automatisch die
Fallback-Textbausteine, die App läuft also weiterhin ohne Fehler. Für echten Chat-Betrieb
braucht es einen kleinen Server-Proxy, der den Key hält.

## Nächste Schritte

Siehe [`SPEC.md`](SPEC.md) §7 — u. a. Migration zu echten Routen/Komponenten, Fotos als
echte Asset-Dateien, Persistenz, Barrierefreiheit des Kompass-Drags.

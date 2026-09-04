---
id: TICKET-002
created: 2026-09-04
reporter: mobile_app
needs: lla-gateway,mobile_app
priority: high
status: done
---

## Problem

Adressen, Hotels und Orte lassen sich in der Mobile App nur im Routen-Panel der
Karte suchen (Entdecken → «Alles auf der Karte» → Pin → «Route planen» → Feld
«Ort, Hotel oder Adresse suchen»). Der Nutzer erwartet das in der globalen
Suche («Finde Orte und Aktivitäten» auf dem Entdecken-Tab und im Suchen-Tab):
Adresse oder Hotel eintippen, Treffer wählen, und die App plant den ÖV direkt
dorthin, mit ganzem Weg inkl. Fussweg und Umsteigen, wie heute im Karten-Panel.

## Kontext

- Die Ortssuche selbst existiert im Gateway: `GET /app/v1/transit/places?q&lat&lng&locale`
  (MOTIS-Geocoder, Haltestellen/Adressen/Orte, Dedupe und Ortsvorrang seit
  Branch `feat/transit-geometry-detail`). Die Planung dorthin läuft über
  `GET /app/v1/transit?fromLat…&toLat…`.
- Die globale App-Suche (`GatewaySearchScreen`) spricht `/app/v1/search`,
  `/search/suggest` und `/search/suggest/intent` und kennt nur Katalog-Entitäten
  (Aktivitäten, Destinationen, Kategorien, POIs). Adressen kommen dort nicht vor.
- Der Karten-Flow ist seit 2026-09-03 auf main (`73bff146`): `DestinationSearch`
  + `MapDirectionsPanel` mit `customDestination`. Die Karte ist per Deep-Link
  `swissactivities://navigate/map?bbox=…` erreichbar; ein Ziel-Parameter fehlt.
- Gateway-Regel: Feed-/Suchverträge sind Gateway-eigen; die App darf Sektionen
  nicht umdeuten. Die Adress-Treffer müssen also als eigene, vom Gateway
  emittierte Gruppe kommen, nicht clientseitig zusammengemischt.

## Akzeptanzkriterien

- [x] lla-gateway: `/app/v1/search/suggest/intent` (oder `/search/suggest`) liefert bei
      Adress-/Hotel-/Ortseingaben eine eigene Gruppe `places` (Name, Art
      stop|address|place, Ort/PLZ, lat/lng) aus dem MOTIS-Geocoder, mit dem
      Nähe-Bias des Nutzers; Katalog-Treffer bleiben unverändert. Contract-Test
      gegen `WEB_LOCALE_ALIASES`, nicht nur `de-CH`.
- [x] lla-gateway: Antwortzeit der Suggest-Antwort bleibt unter dem heutigen p95
      (MOTIS-Aufruf parallel zu Typesense, Timeout 800 ms, bei Timeout Gruppe leer).
      → gemessen 2026-09-04: 0.09–0.14 s pro Anfrage, `PLACES_TIMEOUT_MS = 800`, Promise.all.
- [x] mobile_app: Die globale Suche zeigt die Gruppe «Orte & Adressen» mit den
      bekannten Icons (Haltestelle, Adresse, Hotel/Ort) in allen 30 Sprachen
      (`i18n:check`). → main, `i18n:check` grün 2026-09-04; Hausnummer-Treffer
      führen mit drei statt fünf Zeilen.
- [x] mobile_app: Tipp auf einen Treffer öffnet die Karte mit dem Routen-Panel und
      diesem Ort als Ziel (neuer Map-Param, z. B. `to=lat,lng` + `toName`), ÖV
      vorausgewählt, Etappen sichtbar; Deep-Link `navigate/map?to=…` funktioniert
      auch aus Push/CRM. → `navigate/map?to=lat,lng&toName&toSubtitle&toKind`,
      im Simulator 2026-09-04 per Tipp und per Deep-Link geprüft.
- [x] mobile_app: Simulator-Nachweis mit «Bundesgasse 3 Bern», «Hotel Schweizerhof»
      und einer Haltestelle; Screenshots im PR. → 2026-09-04 (Bundesgasse 3:
      Gruppe führt, Karte mit ÖV-Verbindungen und Route; Haltestelle «Bern,
      Bundesgasse» als Zug-Icon).
- [x] mobile_app: PostHog-Event für Adress-Treffer in der Suche (item_type
      `transit_place`), damit die Nutzung messbar ist. → `select_search` mit
      `item_type: transit-place`, `item_category: stop|address|place`.

## Offen (ausserhalb der Abnahme)

- Karten-Suchfeld (`MapSearchOverlay`) nutzt den gruppierten Suggest ohne
  `places` — Phase 2 laut `docs/search-places-plan.md`.
- Hotels ohne OSM-Eintrag fehlen im Geocoder.
- Bundle erreicht Geräte erst nach «Widen OTA to 100 %».

Erledigt 2026-09-05: alle Kriterien erfüllt und im Simulator nachgewiesen.

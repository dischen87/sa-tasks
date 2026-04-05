---
id: TICKET-001
created: 2026-04-05
reporter: lla-gateway
needs: DWH-Places, lla-gateway, sync
priority: critical
status: open
---

## Problem

OSSA Operations Dashboard kann keine Aktivitaeten/Offers anzeigen. Gateway Staging liefert leere Listen, weil redis-staging (Gateway) nie von einer Sync-Pipeline befuellt wird. Booking-Chunks und Unified-Cache sind komplett leer.

## Kontext

Redis-Master liegt aktuell auf dem Sync Server (116.202.165.204). Gateway hat eine Replica fuer Production, aber Staging-Redis ist standalone und leer. Es gibt keinen Sync-Job der Staging-Daten (von Staging Booking API + Staging Content API) in den Staging-Redis schreibt.

Architektur-Entscheidung: Redis-Master wird auf DWH Server (178.104.115.236) zentralisiert — sowohl Staging als auch Production. Gleicher Setup fuer beide Environments.

## Akzeptanzkriterien

### DWH-Places
- [ ] redis-staging Service in docker-compose.yml (Port 6379, 4GB, Passwort)
- [ ] redis-production Service in docker-compose.yml (Port 6380, 40GB, Passwort)
- [ ] .env mit echten Passwoertern auf Server gesetzt
- [ ] Beide Redis-Instanzen laufen und sind via Tailscale erreichbar

### sync
- [ ] Neue Resources: redis_dwh_staging, redis_dwh_production (mit Passwoertern)
- [ ] Neue Resources: booking_api_staging, strapi_staging
- [ ] Scripts parametrisch: content_pull, booking_sync, unified, enrich_content, reviews_sync akzeptieren redis_resource Parameter
- [ ] Neuer Flow: staging_sync_pipeline nutzt Staging-APIs + redis_dwh_staging
- [ ] Staging-Sync manuell getriggert: redis_dwh_staging hat content, booking, unified Keys
- [ ] Production-Flows auf redis_dwh_production umgestellt (Phase 2, nach Staging-Validierung)

### lla-gateway
- [ ] redis (Production): replicaof 100.88.39.101 6380 (DWH Production Redis)
- [ ] redis-staging: replicaof 100.88.39.101 6379 (DWH Staging Redis)
- [ ] Passwoerter als Env Vars statt hardcoded
- [ ] Staging Gateway liefert Aktivitaeten via /v2/entity-management/activities
- [ ] Staging Gateway liefert Reference Data via /v2/reference/*

### Verifizierung (End-to-End)
- [ ] DWH redis-staging: unified:de-CH:chunk:0 existiert
- [ ] Gateway redis-staging: repliziert von DWH, hat unified Keys
- [ ] OSSA Staging: Aktivitaeten-Liste zeigt Daten
- [ ] OSSA Staging: Neue Aktivitaet erstellen funktioniert

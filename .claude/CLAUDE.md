# sa-tasks — Cross-Repo Task Management (Meta-Repo)

## Platform Standards (PFLICHTLEKTÜRE)

Dieses Repo ist ein Meta-Repository der SwissActivities Platform — kein Code, nur Tickets als Markdown. Trotzdem gelten die Plattform-Standards aus [`Swiss-Activities/platform-standards`](https://github.com/Swiss-Activities/platform-standards):

- **[ARCHITECTURE.md](https://github.com/Swiss-Activities/platform-standards/blob/main/standards/ARCHITECTURE.md)** — DWH-Places single source of truth · marts.* contract
- **[ERROR-SPEC.md](https://github.com/Swiss-Activities/platform-standards/blob/main/standards/ERROR-SPEC.md)** — 4xx/5xx → `marts.fct_errors` via `@swissactivities/error-reporter`
- **[TESTING-SPEC.md](https://github.com/Swiss-Activities/platform-standards/blob/main/standards/TESTING-SPEC.md)** — Vitest + Playwright + k6, real data only
- **[SUPPORT-TICKETS.md](https://github.com/Swiss-Activities/platform-standards/blob/main/standards/SUPPORT-TICKETS.md)** — User-Support-System + sa-ticket-triage Self-Healing-Loop
- **[ALERT-TRIAGE.md](https://github.com/Swiss-Activities/platform-standards/blob/main/standards/ALERT-TRIAGE.md)** — Unified Alerts-Inbox (errors / pipeline / external-service / user_report)
- **[POSTHOG-OPS.md](https://github.com/Swiss-Activities/platform-standards/blob/main/standards/POSTHOG-OPS.md)** — Self-hosted PostHog Operations

### Beziehung zum Support-Ticket-System

`sa-tasks` ist **NICHT** das User-Support-System. User-Support-Tickets entstehen aus dem FAB-Button in jeder OSSA-App und landen in `support_tickets` in der OSSA-Postgres — diese werden vom `sa-ticket-triage` Loop autonom bearbeitet, siehe [SUPPORT-TICKETS.md](https://github.com/Swiss-Activities/platform-standards/blob/main/standards/SUPPORT-TICKETS.md).

`sa-tasks` ist für **interne Engineering-Tasks** (Refactors, Migrations, Tech-Debt, Feature-Pläne über mehrere Repos hinweg) als Markdown-Files. Wenn ein Task in **einem** Repo bleibt, gehört er in dessen GitHub Issues — nicht hier.

### SwissActivities Developer Cheat Sheet (gilt für alle Repos)

1. **Always deploy via GitHub** — kein manuelles `scp` oder `git pull` auf Server.
2. **Never read/write legacy databases** (`default`, `marketing`, `dashboard`, `analytics`, `datawarehouse`). Apps lesen ausschliesslich von `marts.*`.
3. **Never use mock data** — Tests + Dev nutzen echte `marts.*` / Postgres / Gateway. Fallbacks: `?? 0`, `|| []`.
4. **Apps never push to external APIs directly** — schreibe in eigene Postgres mit `*_dirty` Flag, ein Windmill `sync_*.bun.ts` in [data-pipeline](https://github.com/Swiss-Activities/data-pipeline) macht den eigentlichen Mutate.
5. **Always commit + push your work** — nicht dem User überlassen.

## Übersicht

Git-basiertes Task-Tracking für SwissActivities. Tickets als Markdown-Dateien, Workflow über Verzeichnis-Verschiebung.

## Workflow

```
open/           → Task erstellt
in-progress/    → Task in Bearbeitung
done/           → Task abgeschlossen
```

## Commands

```bash
./scripts/create-ticket.sh    # Neues Ticket erstellen (aus Template)
```

## Konventionen

- Tickets folgen Template aus `templates/ticket.md`
- Dateinamen: `YYYY-MM-DD_kurze-beschreibung.md`
- Jedes Ticket referenziert das Ziel-Repo (welches Repo wird verändert) und ggf. das Quell-Repo (welcher Code triggert den Task)
- Cross-Repo-Tasks bekommen `affected_repos:` im Frontmatter

## Live Docs

Die volle Plattform-Dokumentation (alle 9 OSSA-Apps, Runbooks, Schemas, Server-Inventar, Conventions) lebt unter [ossa.swissactivities.com/docs](https://ossa.swissactivities.com/docs).

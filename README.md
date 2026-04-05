# SA Tasks

Cross-Repo Task Management für Swiss Activities.

## Workflow

1. Ticket als `.md` File in `open/` erstellen (Template siehe `templates/ticket.md`)
2. `needs:` Feld mit betroffenen Repos setzen
3. Betroffene Repos arbeiten ihre Akzeptanzkriterien ab
4. Wenn alle Kriterien erfüllt: File nach `done/` verschieben

## Repos

- `admin` — Admin Panel
- `lla-gateway` — API Gateway
- `data-pipeline` — Daten Pipeline
- `sync` — Sync Service
- `marketing-dashboard` — Marketing Dashboard
- `DWH-Places` — Data Warehouse Places
- `ossa` — OSSA
- `transport-advisory` — Transport Advisory

## Für Agents

Jedes Repo hat in `.cursorrules` eine Anweisung, vor Arbeitsbeginn `sa-tasks/open/` auf relevante Tickets zu prüfen.

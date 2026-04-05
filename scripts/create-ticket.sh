#!/bin/bash
# Usage: ./scripts/create-ticket.sh <reporter-repo> <needs-repos> <priority> <title> <description>
# Example: ./scripts/create-ticket.sh lla-gateway "sync,data-pipeline" high "404 on /api/places/123" "Gateway returns 404..."

REPORTER="$1"
NEEDS="$2"
PRIORITY="$3"
TITLE="$4"
DESCRIPTION="$5"

if [ -z "$REPORTER" ] || [ -z "$NEEDS" ] || [ -z "$PRIORITY" ] || [ -z "$TITLE" ]; then
  echo "Usage: $0 <reporter> <needs> <priority> <title> [description]"
  exit 1
fi

SA_TASKS_DIR="/Users/mathias/swiss_activities/sa-tasks"
DATE=$(date +%Y-%m-%d)

# Auto-increment ticket ID
LAST_ID=$(grep -roh 'id: TICKET-[0-9]*' "$SA_TASKS_DIR"/open/ "$SA_TASKS_DIR"/in-progress/ "$SA_TASKS_DIR"/done/ 2>/dev/null | sed 's/id: TICKET-//' | sort -n | tail -1)
NEXT_ID=$((${LAST_ID:-0} + 1))
TICKET_ID=$(printf "TICKET-%03d" "$NEXT_ID")

# Slugify title for filename
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-60)
FILENAME="${DATE}-${SLUG}.md"

cat > "$SA_TASKS_DIR/open/$FILENAME" <<EOF
---
id: ${TICKET_ID}
created: ${DATE}
reporter: ${REPORTER}
needs: ${NEEDS}
priority: ${PRIORITY}
status: open
---

## Problem

${TITLE}

## Kontext

${DESCRIPTION:-Automatisch erstellt. Bitte Kontext ergänzen.}

## Akzeptanzkriterien

$(echo "$NEEDS" | tr ',' '\n' | while read repo; do
  echo "- [ ] ${repo}: TODO"
done)
EOF

echo "Created: $SA_TASKS_DIR/open/$FILENAME ($TICKET_ID)"

# Auto-commit and push
cd "$SA_TASKS_DIR"
git add "open/$FILENAME"
git commit -m "Add ${TICKET_ID}: ${TITLE}" --quiet 2>/dev/null
git push origin main --quiet 2>/dev/null

echo "Committed and pushed."

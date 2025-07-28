#!/bin/bash

# Generate endpoints.yml from environment variables
# This allows the same container to work in Docker Compose and Knative

ACTIONS_HOST=${ACTIONS_SERVER_HOST:-actions}
ACTIONS_PORT=${ACTIONS_SERVER_PORT:-5055}
ACTION_URL=${ACTION_ENDPOINT_URL:-http://${ACTIONS_HOST}:${ACTIONS_PORT}/webhook}

cat > /app/endpoints.yml << EOF
# Configuration for external services (auto-generated)

# Actions server
action_endpoint:
  url: "${ACTION_URL}"

# Tracker store (uncomment for production)
# tracker_store:
#   type: SQL
#   dialect: "postgresql"
#   url: "localhost"
#   db: "rasa"
#   username: "user"
#   password: "password"

# Event broker (uncomment if needed)
# event_broker:
#   type: kafka
#   url: "localhost:9092"
#   topic: "rasa_events"
EOF

echo "Generated endpoints.yml with action_endpoint.url: ${ACTION_URL}"
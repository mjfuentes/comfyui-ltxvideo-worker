#!/usr/bin/env bash
# Quick health check for the endpoint
set -euo pipefail

ENDPOINT_ID="plpbyovrzzg5t2"
RUNPOD_KEY="${RUNPOD_API_KEY:-$(cat ~/.openclaw/workspace/.runpod_key 2>/dev/null | tr -d '\n')}"

echo "🔍 Checking endpoint health..."
curl -s "https://api.runpod.ai/v2/${ENDPOINT_ID}/health" \
  -H "Authorization: Bearer ${RUNPOD_KEY}" | python3 -m json.tool

echo ""
echo "📊 Endpoint ID: ${ENDPOINT_ID}"
echo "🔗 Run URL:     https://api.runpod.ai/v2/${ENDPOINT_ID}/run"
echo "🔗 RunSync URL: https://api.runpod.ai/v2/${ENDPOINT_ID}/runsync"

#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# RunPod ComfyUI LTX-Video Transition Generator
# Usage: ./run_transition.sh <frame_start> <frame_end> [prompt] [output_dir]
# ============================================================================

ENDPOINT_ID="plpbyovrzzg5t2"
API_BASE="https://api.runpod.ai/v2/${ENDPOINT_ID}"
RUNPOD_KEY="${RUNPOD_API_KEY:-$(cat ~/.openclaw/workspace/.runpod_key 2>/dev/null | tr -d '\n')}"

if [ -z "$RUNPOD_KEY" ]; then
  echo "ERROR: Set RUNPOD_API_KEY or place key in ~/.openclaw/workspace/.runpod_key"
  exit 1
fi

FRAME_START="${1:?Usage: $0 <frame_start> <frame_end> [prompt] [output_dir]}"
FRAME_END="${2:?Usage: $0 <frame_start> <frame_end> [prompt] [output_dir]}"
PROMPT="${3:-A smooth cinematic transition between two scenes, fluid camera movement, professional video production quality}"
OUTPUT_DIR="${4:-.}"

# Encode images to base64
echo "📸 Encoding input frames..."
START_B64=$(base64 -i "$FRAME_START" | tr -d '\n')
END_B64=$(base64 -i "$FRAME_END" | tr -d '\n')

# Read workflow template
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW=$(cat "$SCRIPT_DIR/workflow.json")

# Inject the prompt into the workflow
WORKFLOW=$(echo "$WORKFLOW" | python3 -c "
import json, sys
w = json.load(sys.stdin)
w['5']['inputs']['text'] = '''$PROMPT'''
json.dump(w, sys.stdout)
")

# Build request payload
PAYLOAD=$(python3 -c "
import json, sys

workflow = json.loads('''$(echo "$WORKFLOW" | sed "s/'/\\\\'/g")''')

payload = {
    'input': {
        'workflow': workflow,
        'images': [
            {
                'name': 'frame_start.png',
                'image': 'data:image/png;base64,$START_B64'
            },
            {
                'name': 'frame_end.png',
                'image': 'data:image/png;base64,$END_B64'
            }
        ]
    }
}
json.dump(payload, sys.stdout)
")

echo "🚀 Submitting job to RunPod endpoint ${ENDPOINT_ID}..."
RESPONSE=$(curl -s -X POST "${API_BASE}/run" \
  -H "Authorization: Bearer ${RUNPOD_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

JOB_ID=$(echo "$RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))")

if [ -z "$JOB_ID" ]; then
  echo "ERROR: Failed to submit job"
  echo "$RESPONSE"
  exit 1
fi

echo "📋 Job ID: $JOB_ID"
echo "⏳ Polling for completion..."

# Poll for status
while true; do
  STATUS_RESPONSE=$(curl -s "${API_BASE}/status/${JOB_ID}" \
    -H "Authorization: Bearer ${RUNPOD_KEY}")
  
  STATUS=$(echo "$STATUS_RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status','UNKNOWN'))")
  
  case "$STATUS" in
    COMPLETED)
      echo "✅ Job completed!"
      
      # Extract output images/videos (base64)
      python3 -c "
import json, base64, sys, os
data = json.loads('''$(echo "$STATUS_RESPONSE" | python3 -c "import json,sys; json.dump(json.load(sys.stdin), sys.stdout)")''')
output = data.get('output', {})
images = output.get('images', [])
if not images:
    print('⚠️  No output images/videos found in response')
    print('Raw output:', json.dumps(output, indent=2))
    sys.exit(0)
for i, img in enumerate(images):
    filename = img.get('filename', f'output_{i}.png')
    img_type = img.get('type', 'base64')
    img_data = img.get('data', '')
    outpath = os.path.join('$OUTPUT_DIR', filename)
    if img_type == 'base64':
        with open(outpath, 'wb') as f:
            f.write(base64.b64decode(img_data))
        print(f'💾 Saved: {outpath}')
    elif img_type == 's3_url':
        print(f'🔗 S3 URL: {img_data}')
"
      break
      ;;
    FAILED)
      echo "❌ Job failed!"
      echo "$STATUS_RESPONSE" | python3 -m json.tool
      exit 1
      ;;
    IN_QUEUE|IN_PROGRESS)
      echo "  Status: $STATUS (waiting 5s...)"
      sleep 5
      ;;
    *)
      echo "  Status: $STATUS (waiting 5s...)"
      sleep 5
      ;;
  esac
done

echo "🎬 Done!"

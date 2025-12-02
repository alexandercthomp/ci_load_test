#!/usr/bin/env bash
set -euo pipefail

DURATION="${DURATION:-30s}"
RATE="${RATE:-50}"
OUTPUT_DIR="${OUTPUT_DIR:-loadtest-results}"

mkdir -p "$OUTPUT_DIR"

############################################
# Start kubectl port-forward (CI-safe)
############################################
echo "🔌 Starting port-forward to ingress-nginx..."

kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80 \
  >/tmp/portforward.log 2>&1 &

PF_PID=$!
trap 'kill "$PF_PID" >/dev/null 2>&1 || true' EXIT

INGRESS_URL="http://127.0.0.1:8080"

# Give time for the tunnel to initialize
sleep 3

echo "📈 Running load test"
echo "  Duration: $DURATION"
echo "  Rate: $RATE rps"
echo "  Using ingress at: $INGRESS_URL"

############################################
# Build Vegeta targets file
############################################
cat <<EOF > "$OUTPUT_DIR/targets.txt"
GET ${INGRESS_URL}
Host: foo.localhost

GET ${INGRESS_URL}
Host: bar.localhost
EOF

############################################
# Run Vegeta load test
############################################
vegeta attack \
  -targets="$OUTPUT_DIR/targets.txt" \
  -rate="$RATE" \
  -duration="$DURATION" \
  -timeout=2s \
  | tee "$OUTPUT_DIR/results.bin" \
  | vegeta encode \
  > "$OUTPUT_DIR/results.json"

vegeta report "$OUTPUT_DIR/results.bin" > "$OUTPUT_DIR/results.txt"
vegeta report -type=json "$OUTPUT_DIR/results.bin" > "$OUTPUT_DIR/summary.json"

############################################
# Extract metrics
############################################
REQS_PER_SEC=$(jq -r '.rate' "$OUTPUT_DIR/summary.json")
SUCCESS=$(jq -r '.success' "$OUTPUT_DIR/summary.json")
LAT_MEAN=$(jq -r '.latencies.mean' "$OUTPUT_DIR/summary.json")
LAT_P90=$(jq -r '.latencies.p90' "$OUTPUT_DIR/summary.json")
LAT_P95=$(jq -r '.latencies.p95' "$OUTPUT_DIR/summary.json")

FAILURE_RATE=$(awk "BEGIN {print (1 - $SUCCESS) * 100}")

############################################
# Write Markdown summary
############################################
cat <<EOF > "$OUTPUT_DIR/results.md"
## 🚀 Load Test Results

**Duration:** ${DURATION}  
**Request Rate:** ${RATE} req/s  

### ✅ Throughput
- Requests / second: **${REQS_PER_SEC}**
- Success rate: **$(printf "%.2f" "$(awk "BEGIN {print $SUCCESS * 100}")")%**
- Failure rate: **$(printf "%.2f" "$FAILURE_RATE")%**

### ⏱ Latency
- Average: **${LAT_MEAN} ns**
- P90: **${LAT_P90} ns**
- P95: **${LAT_P95} ns**

### 🔍 Notes
- Traffic was sent to \`foo.localhost\` and \`bar.localhost\`
- Requests routed through ingress **via kubectl port-forward**
- This bypasses NodePort networking issues on GitHub Actions
EOF

echo "✅ Load test complete"
echo "📄 Results written to $OUTPUT_DIR/results.md"

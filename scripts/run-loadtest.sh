#!/usr/bin/env bash
set -euo pipefail

DURATION="${DURATION:-30s}"
RATE="${RATE:-50}"
OUTPUT_DIR="${OUTPUT_DIR:-loadtest-results}"

mkdir -p "$OUTPUT_DIR"

echo "📈 Running load test"
echo "  Duration: $DURATION"
echo "  Rate: $RATE rps"

cat <<EOF > "$OUTPUT_DIR/targets.txt"
GET http://localhost
Host: foo.localhost

GET http://localhost
Host: bar.localhost
EOF

# Randomize traffic evenly
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

# Extract metrics
REQS_PER_SEC=$(jq -r '.rate' "$OUTPUT_DIR/summary.json")
SUCCESS=$(jq -r '.success' "$OUTPUT_DIR/summary.json")
LAT_MEAN=$(jq -r '.latencies.mean' "$OUTPUT_DIR/summary.json")
LAT_P90=$(jq -r '.latencies.p90' "$OUTPUT_DIR/summary.json")
LAT_P95=$(jq -r '.latencies.p95' "$OUTPUT_DIR/summary.json")

FAILURE_RATE=$(awk "BEGIN {print (1 - $SUCCESS) * 100}")

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
- Traffic was evenly distributed between \`foo.localhost\` and \`bar.localhost\`
- Requests routed through ingress-nginx on KinD
EOF

echo "✅ Load test complete"
echo "📄 Results written to $OUTPUT_DIR/results.md"

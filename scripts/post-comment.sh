#!/usr/bin/env bash
set -euo pipefail

RESULTS_FILE="loadtest-results/results.md"

if [[ ! -f "$RESULTS_FILE" ]]; then
  echo "⚠️ Results file not found, posting failure notice"
  COMMENT_BODY="❌ Load test did not produce results. Please check CI logs."
else
  COMMENT_BODY=$(cat "$RESULTS_FILE")
fi

# GitHub Actions environment variables
PR_NUMBER=$(jq -r '.pull_request.number' "$GITHUB_EVENT_PATH")
REPO=$(jq -r '.repository.full_name' "$GITHUB_EVENT_PATH")

if [[ -z "$PR_NUMBER" || -z "$REPO" ]]; then
  echo "❌ Unable to determine PR number or repo name"
  exit 1
fi

echo "💬 Posting comment to PR #${PR_NUMBER} in ${REPO}"

JSON_PAYLOAD=$(jq -n --arg body "$COMMENT_BODY" '{body: $body}')

curl -sSf \
  -X POST \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  "https://api.github.com/repos/${REPO}/issues/${PR_NUMBER}/comments"

echo "✅ PR comment successfully posted"

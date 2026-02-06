#!/usr/bin/env bash
set -euo pipefail

# Detects new channels added to data/channels.json (compared to the previous
# commit) and creates them via the Candebot API.
#
# Required env vars: CANDEBOT_URL, CANDEBOT_API_KEY
# Optional env vars: GITHUB_SERVER_URL, GITHUB_REPOSITORY, GITHUB_SHA (set by GH Actions)

BEFORE=$(git show HEAD~1:data/channels.json 2>/dev/null || echo '[]')
AFTER=$(< data/channels.json)

OLD_NAMES=$(echo "${BEFORE}" | jq -r '.[].name' | sort)
NEW_NAMES=$(echo "${AFTER}" | jq -r '.[].name' | sort)

ADDED=$(comm -13 <(echo "${OLD_NAMES}") <(echo "${NEW_NAMES}"))

if [[ -z "${ADDED}" ]]; then
  echo "No new channels detected."
  exit 0
fi

# Extract PR number from merge commit message (e.g. "Merge pull request #123 ...")
PR_NUMBER=$(git log -1 --pretty=%s | grep -oP '#\d+' | head -1 | tr -d '#' || true)
if [[ -n "${PR_NUMBER}" ]]; then
  PR_LINK="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY}/pull/${PR_NUMBER}"
else
  PR_LINK="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
fi

while IFS= read -r name; do
  [[ -z "${name}" ]] && continue

  description=$(echo "${AFTER}" | jq -r --arg n "${name}" '.[] | select(.name == $n) | .description')

  echo "Creating channel: ${name}"
  response=$(curl -sf -w "\n%{http_code}" \
    -X POST "${CANDEBOT_URL}/api/channels" \
    -H "Authorization: Bearer ${CANDEBOT_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg name "${name}" --arg desc "${description}" --arg pr "${PR_LINK}" \
      '{name: $name, description: $desc, pr_link: $pr}')")

  http_code=$(echo "${response}" | tail -1)
  body=$(echo "${response}" | head -n -1)

  if [[ "${http_code}" -ge 200 ]] && [[ "${http_code}" -lt 300 ]]; then
    echo "Created channel ${name}: ${body}"
  else
    echo "::error::Failed to create channel ${name} (HTTP ${http_code}): ${body}"
    exit 1
  fi
done <<< "${ADDED}"

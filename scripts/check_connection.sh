#!/bin/bash
# Check Yandex Direct API v5 connection

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config

echo "Checking Direct API v5 connection..."
echo ""

# Test with Campaigns.get (minimal request)
response=$(direct_request "campaigns" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Status"],
        "Page": {"Limit": 1}
    }
}')

if echo "$response" | grep -q '"Campaigns"'; then
    echo "Direct API v5: OK"
    echo ""

    # Count campaigns
    if command -v jq &>/dev/null; then
        count=$(echo "$response" | jq '.result.Campaigns | length')
        echo "Campaigns found: $count"
        if [[ "$count" -gt 0 ]]; then
            echo ""
            echo "First campaign:"
            echo "$response" | jq '.result.Campaigns[0]'
        fi
    fi
elif echo "$response" | grep -q '"error"'; then
    error_code=$(json_value "$response" "error_code")
    error_msg=$(echo "$response" | grep -o '"error_string":"[^"]*"' | head -1 | sed 's/.*:"//' | tr -d '"')
    echo "Direct API v5: Error ($error_code)"
    echo "Message: $error_msg"
    exit 1
else
    echo "Direct API v5: Error"
    echo "$response"
    exit 1
fi

echo ""
echo "=== API Mode ==="
if [[ "$YANDEX_DIRECT_SANDBOX" == "true" ]]; then
    echo "Mode: SANDBOX (test data)"
else
    echo "Mode: PRODUCTION (real data)"
fi

echo ""
echo "=== Available services ==="
echo "- Campaigns, AdGroups, Ads, Keywords"
echo "- BidModifiers, KeywordBids"
echo "- Sitelinks, VCards, AdImages, AdExtensions"
echo "- Reports (TSV format)"
echo "- Dictionaries, Changes, Feeds"
echo ""
echo "Token is valid and API is accessible."

#!/bin/bash
# Common functions for Yandex Direct API v5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/.env"
CACHE_DIR="$SCRIPT_DIR/../cache"

# Load config
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    fi

    if [[ -z "$YANDEX_DIRECT_TOKEN" ]]; then
        echo "Error: YANDEX_DIRECT_TOKEN not found."
        echo "Set in config/.env or environment. See config/README.md for instructions."
        exit 1
    fi

    # Set API URL based on sandbox mode
    if [[ "$YANDEX_DIRECT_SANDBOX" == "true" ]]; then
        DIRECT_API="https://api-sandbox.direct.yandex.com/json/v5"
        echo "Note: Using SANDBOX mode" >&2
    else
        DIRECT_API="https://api.direct.yandex.com/json/v5"
    fi
}

# Make Direct API v5 request
# Usage: direct_request "campaigns" '{"method":"get","params":{...}}'
direct_request() {
    local service="$1"
    local body="$2"

    local headers=(
        -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN"
        -H "Content-Type: application/json; charset=utf-8"
        -H "Accept-Language: ru"
    )

    # Add Client-Login header for agency accounts
    if [[ -n "$YANDEX_DIRECT_CLIENT_LOGIN" ]]; then
        headers+=(-H "Client-Login: $YANDEX_DIRECT_CLIENT_LOGIN")
    fi

    curl -s -X POST "${DIRECT_API}/${service}" \
        "${headers[@]}" \
        -d "$body"
}

# Make Direct API v5 report request
# Usage: direct_report '{"params":{...}}'
direct_report() {
    local body="$1"
    local report_name="${2:-auto_report_$(date +%s)}"

    local headers=(
        -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN"
        -H "Content-Type: application/json; charset=utf-8"
        -H "Accept-Language: ru"
        -H "processingMode: auto"
        -H "returnMoneyInMicros: false"
        -H "skipReportHeader: true"
        -H "skipReportSummary: true"
    )

    if [[ -n "$YANDEX_DIRECT_CLIENT_LOGIN" ]]; then
        headers+=(-H "Client-Login: $YANDEX_DIRECT_CLIENT_LOGIN")
    fi

    curl -s -w "\n%{http_code}" -X POST "${DIRECT_API}/reports" \
        "${headers[@]}" \
        -d "$body"
}

# Format JSON output (pretty print if jq available)
format_json() {
    if command -v jq &>/dev/null; then
        jq '.'
    else
        cat
    fi
}

# Extract JSON value using grep/sed (no jq dependency)
json_value() {
    local json="$1"
    local key="$2"
    echo "$json" | grep -o "\"$key\":[^,}]*" | head -1 | sed 's/.*://' | tr -d '"[:space:]'
}

# Format number with thousands separator
format_number() {
    local num="$1"
    printf "%'d" "$num" 2>/dev/null || echo "$num"
}

# Parse API units from response headers
# Direct API returns Units header: used/limit/remaining
parse_units() {
    local units_header="$1"
    echo "API Units: $units_header"
}

# JSON escape
json_escape() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\t'/\\t}"
    echo "$str"
}

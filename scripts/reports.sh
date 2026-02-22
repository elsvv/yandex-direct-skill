#!/bin/bash
# Yandex Direct Report Service — pull statistics reports

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config

REPORT_TYPE="CAMPAIGN_PERFORMANCE_REPORT"
DATE_RANGE="LAST_30_DAYS"
DATE_FROM=""
DATE_TO=""
FIELD_NAMES="CampaignName,Impressions,Clicks,Ctr,AvgCpc,Cost"
FILTER=""
REPORT_NAME="api_report_$(date +%s)"
OUTPUT_FILE=""
FORMAT="TSV"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --type|-t) REPORT_TYPE="$2"; shift 2 ;;
        --date-range|-r) DATE_RANGE="$2"; shift 2 ;;
        --date-from) DATE_FROM="$2"; shift 2 ;;
        --date-to) DATE_TO="$2"; shift 2 ;;
        --fields|-f) FIELD_NAMES="$2"; shift 2 ;;
        --filter) FILTER="$2"; shift 2 ;;
        --name|-n) REPORT_NAME="$2"; shift 2 ;;
        --output|-o) OUTPUT_FILE="$2"; shift 2 ;;
        --format) FORMAT="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: reports.sh [options]"
            echo ""
            echo "Options:"
            echo "  --type, -t       Report type (default: CAMPAIGN_PERFORMANCE_REPORT)"
            echo "  --date-range, -r Date range (default: LAST_30_DAYS)"
            echo "  --date-from      Start date YYYY-MM-DD (for CUSTOM_DATE)"
            echo "  --date-to        End date YYYY-MM-DD (for CUSTOM_DATE)"
            echo "  --fields, -f     Comma-separated field names"
            echo "  --filter         Filter JSON string"
            echo "  --name, -n       Report name"
            echo "  --output, -o     Output file (default: stdout)"
            echo "  --format         TSV or CSV (default: TSV)"
            echo ""
            echo "Report types:"
            echo "  ACCOUNT_PERFORMANCE_REPORT       Account-level stats"
            echo "  CAMPAIGN_PERFORMANCE_REPORT      Campaign-level stats"
            echo "  ADGROUP_PERFORMANCE_REPORT       Ad group level stats"
            echo "  AD_PERFORMANCE_REPORT            Ad-level stats"
            echo "  CRITERIA_PERFORMANCE_REPORT      Keyword/targeting criteria stats"
            echo "  CUSTOM_REPORT                    Custom combinations"
            echo "  SEARCH_QUERY_PERFORMANCE_REPORT  Search query stats"
            echo ""
            echo "Date ranges:"
            echo "  TODAY, YESTERDAY, LAST_7_DAYS, LAST_14_DAYS, LAST_30_DAYS,"
            echo "  LAST_90_DAYS, THIS_MONTH, LAST_MONTH, ALL_TIME, CUSTOM_DATE, AUTO"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Build fields array
fields_json=$(echo "$FIELD_NAMES" | tr ',' '\n' | jq -R . | jq -s .)

# Build selection criteria
if [[ "$DATE_RANGE" == "CUSTOM_DATE" ]]; then
    if [[ -z "$DATE_FROM" || -z "$DATE_TO" ]]; then
        echo "Error: --date-from and --date-to required for CUSTOM_DATE range" >&2
        exit 1
    fi
    selection="{\"DateFrom\": \"$DATE_FROM\", \"DateTo\": \"$DATE_TO\"}"
else
    selection="{}"
fi

# Add filter if provided
if [[ -n "$FILTER" ]]; then
    selection=$(echo "$selection" | jq ". + {\"Filter\": [$FILTER]}")
fi

# Build report definition
body="{
    \"params\": {
        \"SelectionCriteria\": $selection,
        \"FieldNames\": $fields_json,
        \"ReportName\": \"$REPORT_NAME\",
        \"ReportType\": \"$REPORT_TYPE\",
        \"DateRangeType\": \"$DATE_RANGE\",
        \"Format\": \"$FORMAT\",
        \"IncludeVAT\": \"YES\",
        \"IncludeDiscount\": \"NO\"
    }
}"

echo "Requesting report: $REPORT_TYPE ($DATE_RANGE)..." >&2

# Make report request (may need retry for async)
max_retries=10
retry=0

while [[ $retry -lt $max_retries ]]; do
    result=$(direct_report "$body" "$REPORT_NAME")

    # Split response and HTTP code
    http_code=$(echo "$result" | tail -1)
    response=$(echo "$result" | sed '$d')

    case "$http_code" in
        200)
            # Report ready
            if [[ -n "$OUTPUT_FILE" ]]; then
                echo "$response" > "$OUTPUT_FILE"
                lines=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
                echo "Report saved to $OUTPUT_FILE ($lines lines)" >&2
            else
                echo "$response"
            fi
            exit 0
            ;;
        201)
            # Report created, waiting (offline mode)
            echo "Report queued, retrying in 5s... ($((retry+1))/$max_retries)" >&2
            sleep 5
            retry=$((retry + 1))
            ;;
        202)
            # Report in progress
            echo "Report processing, retrying in 10s... ($((retry+1))/$max_retries)" >&2
            sleep 10
            retry=$((retry + 1))
            ;;
        *)
            echo "Error (HTTP $http_code):" >&2
            echo "$response" >&2
            exit 1
            ;;
    esac
done

echo "Error: Report timed out after $max_retries retries" >&2
exit 1

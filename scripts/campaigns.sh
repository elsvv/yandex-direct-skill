#!/bin/bash
# Manage Yandex Direct campaigns

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config

ACTION=""
CAMPAIGN_IDS=""
STATES=""
LIMIT="100"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --action|-a) ACTION="$2"; shift 2 ;;
        --ids|-i) CAMPAIGN_IDS="$2"; shift 2 ;;
        --states|-s) STATES="$2"; shift 2 ;;
        --limit|-l) LIMIT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$ACTION" ]]; then
    echo "Usage: campaigns.sh --action <action> [options]"
    echo ""
    echo "Actions:"
    echo "  list      List campaigns (with optional filters)"
    echo "  get       Get campaign details (requires --ids)"
    echo "  stats     Get campaign stats summary"
    echo "  suspend   Suspend campaigns (requires --ids)"
    echo "  resume    Resume campaigns (requires --ids)"
    echo "  archive   Archive campaigns (requires --ids)"
    echo "  unarchive Unarchive campaigns (requires --ids)"
    echo ""
    echo "Options:"
    echo "  --ids, -i    Comma-separated campaign IDs"
    echo "  --states, -s Filter by states: ON, OFF, SUSPENDED, ENDED, ARCHIVED"
    echo "  --limit, -l  Max results (default: 100)"
    exit 1
fi

# Helper to build IDs array
build_ids_array() {
    local ids="$1"
    echo "$ids" | tr ',' '\n' | jq -R . | jq -s 'map(tonumber)'
}

case "$ACTION" in
    list|stats)
        selection='{}'
        if [[ -n "$STATES" ]]; then
            states_json=$(echo "$STATES" | tr ',' '\n' | jq -R . | jq -s .)
            selection="{\"States\": $states_json}"
        fi
        if [[ -n "$CAMPAIGN_IDS" ]]; then
            ids_json=$(build_ids_array "$CAMPAIGN_IDS")
            selection="{\"Ids\": $ids_json}"
        fi

        fields='"Id","Name","Status","State","Type","StartDate"'
        if [[ "$ACTION" == "stats" ]]; then
            fields='"Id","Name","Status","State","Funds"'
        fi

        response=$(direct_request "campaigns" "{
            \"method\": \"get\",
            \"params\": {
                \"SelectionCriteria\": $selection,
                \"FieldNames\": [$fields],
                \"Page\": {\"Limit\": $LIMIT}
            }
        }")

        if echo "$response" | grep -q '"error"'; then
            echo "Error:"
            echo "$response" | format_json
            exit 1
        fi

        if command -v jq &>/dev/null; then
            if [[ "$ACTION" == "list" ]]; then
                echo "$response" | jq -r '.result.Campaigns[] | "\(.Id)\t\(.Name)\t\(.Status)\t\(.State)\t\(.Type)"' | \
                    column -t -s $'\t'
            else
                echo "$response" | jq '.result.Campaigns[] | {Id, Name, Status, State, Funds}'
            fi
        else
            echo "$response"
        fi
        ;;

    get)
        if [[ -z "$CAMPAIGN_IDS" ]]; then
            echo "Error: --ids required"
            exit 1
        fi

        ids_json=$(build_ids_array "$CAMPAIGN_IDS")

        response=$(direct_request "campaigns" "{
            \"method\": \"get\",
            \"params\": {
                \"SelectionCriteria\": {\"Ids\": $ids_json},
                \"FieldNames\": [\"Id\",\"Name\",\"Status\",\"State\",\"Type\",\"StartDate\",\"EndDate\",\"DailyBudget\",\"NegativeKeywords\",\"Statistics\"]
            }
        }")

        echo "$response" | format_json
        ;;

    suspend)
        if [[ -z "$CAMPAIGN_IDS" ]]; then echo "Error: --ids required"; exit 1; fi
        ids_json=$(build_ids_array "$CAMPAIGN_IDS")
        response=$(direct_request "campaigns" "{\"method\":\"suspend\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    resume)
        if [[ -z "$CAMPAIGN_IDS" ]]; then echo "Error: --ids required"; exit 1; fi
        ids_json=$(build_ids_array "$CAMPAIGN_IDS")
        response=$(direct_request "campaigns" "{\"method\":\"resume\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    archive)
        if [[ -z "$CAMPAIGN_IDS" ]]; then echo "Error: --ids required"; exit 1; fi
        ids_json=$(build_ids_array "$CAMPAIGN_IDS")
        response=$(direct_request "campaigns" "{\"method\":\"archive\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    unarchive)
        if [[ -z "$CAMPAIGN_IDS" ]]; then echo "Error: --ids required"; exit 1; fi
        ids_json=$(build_ids_array "$CAMPAIGN_IDS")
        response=$(direct_request "campaigns" "{\"method\":\"unarchive\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac

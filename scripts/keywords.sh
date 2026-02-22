#!/bin/bash
# Manage Yandex Direct keywords

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config

ACTION=""
CAMPAIGN_IDS=""
ADGROUP_IDS=""
KEYWORD_IDS=""
LIMIT="1000"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --action|-a) ACTION="$2"; shift 2 ;;
        --campaign-ids) CAMPAIGN_IDS="$2"; shift 2 ;;
        --adgroup-ids) ADGROUP_IDS="$2"; shift 2 ;;
        --keyword-ids) KEYWORD_IDS="$2"; shift 2 ;;
        --limit|-l) LIMIT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$ACTION" ]]; then
    echo "Usage: keywords.sh --action <action> [options]"
    echo ""
    echo "Actions:"
    echo "  list      List keywords by campaign or ad group"
    echo "  get       Get keyword details (requires --keyword-ids)"
    echo "  suspend   Suspend keywords (requires --keyword-ids)"
    echo "  resume    Resume keywords (requires --keyword-ids)"
    echo ""
    echo "Options:"
    echo "  --campaign-ids  Comma-separated campaign IDs (filter)"
    echo "  --adgroup-ids   Comma-separated ad group IDs (filter)"
    echo "  --keyword-ids   Comma-separated keyword IDs"
    echo "  --limit, -l     Max results (default: 1000)"
    exit 1
fi

build_ids_array() {
    echo "$1" | tr ',' '\n' | jq -R . | jq -s 'map(tonumber)'
}

case "$ACTION" in
    list|get)
        selection='{}'
        if [[ -n "$CAMPAIGN_IDS" ]]; then
            ids_json=$(build_ids_array "$CAMPAIGN_IDS")
            selection="{\"CampaignIds\": $ids_json}"
        elif [[ -n "$ADGROUP_IDS" ]]; then
            ids_json=$(build_ids_array "$ADGROUP_IDS")
            selection="{\"AdGroupIds\": $ids_json}"
        elif [[ -n "$KEYWORD_IDS" ]]; then
            ids_json=$(build_ids_array "$KEYWORD_IDS")
            selection="{\"Ids\": $ids_json}"
        fi

        response=$(direct_request "keywords" "{
            \"method\": \"get\",
            \"params\": {
                \"SelectionCriteria\": $selection,
                \"FieldNames\": [\"Id\",\"Keyword\",\"AdGroupId\",\"CampaignId\",\"Status\",\"State\",\"Bid\",\"ContextBid\"],
                \"Page\": {\"Limit\": $LIMIT}
            }
        }")

        if echo "$response" | grep -q '"error"'; then
            echo "Error:" && echo "$response" | format_json
            exit 1
        fi

        if command -v jq &>/dev/null; then
            echo "$response" | jq -r '.result.Keywords[] | "\(.Id)\t\(.Keyword)\t\(.Status)\t\(.State)\t\(.CampaignId)"' | \
                column -t -s $'\t'
        else
            echo "$response"
        fi
        ;;

    suspend)
        if [[ -z "$KEYWORD_IDS" ]]; then echo "Error: --keyword-ids required"; exit 1; fi
        ids_json=$(build_ids_array "$KEYWORD_IDS")
        response=$(direct_request "keywords" "{\"method\":\"suspend\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    resume)
        if [[ -z "$KEYWORD_IDS" ]]; then echo "Error: --keyword-ids required"; exit 1; fi
        ids_json=$(build_ids_array "$KEYWORD_IDS")
        response=$(direct_request "keywords" "{\"method\":\"resume\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac

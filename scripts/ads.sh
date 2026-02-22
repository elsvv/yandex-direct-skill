#!/bin/bash
# Manage Yandex Direct ads

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config

ACTION=""
CAMPAIGN_IDS=""
ADGROUP_IDS=""
AD_IDS=""
LIMIT="1000"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --action|-a) ACTION="$2"; shift 2 ;;
        --campaign-ids) CAMPAIGN_IDS="$2"; shift 2 ;;
        --adgroup-ids) ADGROUP_IDS="$2"; shift 2 ;;
        --ad-ids) AD_IDS="$2"; shift 2 ;;
        --limit|-l) LIMIT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$ACTION" ]]; then
    echo "Usage: ads.sh --action <action> [options]"
    echo ""
    echo "Actions:"
    echo "  list      List ads by campaign or ad group"
    echo "  get       Get ad details (requires --ad-ids)"
    echo "  suspend   Suspend ads (requires --ad-ids)"
    echo "  resume    Resume ads (requires --ad-ids)"
    echo "  moderate  Send ads for moderation (requires --ad-ids)"
    echo "  archive   Archive ads (requires --ad-ids)"
    echo ""
    echo "Options:"
    echo "  --campaign-ids  Comma-separated campaign IDs"
    echo "  --adgroup-ids   Comma-separated ad group IDs"
    echo "  --ad-ids        Comma-separated ad IDs"
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
        elif [[ -n "$AD_IDS" ]]; then
            ids_json=$(build_ids_array "$AD_IDS")
            selection="{\"Ids\": $ids_json}"
        fi

        response=$(direct_request "ads" "{
            \"method\": \"get\",
            \"params\": {
                \"SelectionCriteria\": $selection,
                \"FieldNames\": [\"Id\",\"AdGroupId\",\"CampaignId\",\"Status\",\"State\",\"Type\"],
                \"TextAdFieldNames\": [\"Title\",\"Title2\",\"Text\",\"Href\",\"DisplayUrlPath\"],
                \"Page\": {\"Limit\": $LIMIT}
            }
        }")

        if echo "$response" | grep -q '"error"'; then
            echo "Error:" && echo "$response" | format_json
            exit 1
        fi

        if command -v jq &>/dev/null; then
            echo "$response" | jq -r '.result.Ads[] | "\(.Id)\t\(.Type)\t\(.Status)\t\(.State)\t\(.TextAd.Title // "-")\t\(.CampaignId)"' | \
                column -t -s $'\t'
        else
            echo "$response"
        fi
        ;;

    suspend)
        if [[ -z "$AD_IDS" ]]; then echo "Error: --ad-ids required"; exit 1; fi
        ids_json=$(build_ids_array "$AD_IDS")
        response=$(direct_request "ads" "{\"method\":\"suspend\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    resume)
        if [[ -z "$AD_IDS" ]]; then echo "Error: --ad-ids required"; exit 1; fi
        ids_json=$(build_ids_array "$AD_IDS")
        response=$(direct_request "ads" "{\"method\":\"resume\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    moderate)
        if [[ -z "$AD_IDS" ]]; then echo "Error: --ad-ids required"; exit 1; fi
        ids_json=$(build_ids_array "$AD_IDS")
        response=$(direct_request "ads" "{\"method\":\"moderate\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    archive)
        if [[ -z "$AD_IDS" ]]; then echo "Error: --ad-ids required"; exit 1; fi
        ids_json=$(build_ids_array "$AD_IDS")
        response=$(direct_request "ads" "{\"method\":\"archive\",\"params\":{\"SelectionCriteria\":{\"Ids\":$ids_json}}}")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac

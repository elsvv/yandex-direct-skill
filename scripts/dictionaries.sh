#!/bin/bash
# Get Yandex Direct dictionaries

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config

DICT_NAMES=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --names|-n) DICT_NAMES="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$DICT_NAMES" ]]; then
    echo "Usage: dictionaries.sh --names <dict1,dict2,...>"
    echo ""
    echo "Available dictionaries:"
    echo "  GeoRegions         Countries, regions, cities with IDs"
    echo "  Currencies         Supported currencies"
    echo "  TimeZones          Time zones"
    echo "  Constants          API constants and limits"
    echo "  AdCategories       Ad categories"
    echo "  OperationSystemVersions  OS versions"
    echo "  ProductivityAssertions   Productivity assertions"
    echo "  SupplySidePlatforms      SSP platforms"
    echo "  Interests               Interest categories"
    echo "  AudienceCriteriaTypes    Audience criteria types"
    echo ""
    echo "Examples:"
    echo "  bash scripts/dictionaries.sh --names GeoRegions"
    echo "  bash scripts/dictionaries.sh --names Currencies,TimeZones"
    exit 1
fi

# Build DictionaryNames array
names_json=$(echo "$DICT_NAMES" | tr ',' '\n' | jq -R . | jq -s .)

response=$(direct_request "dictionaries" "{
    \"method\": \"get\",
    \"params\": {
        \"DictionaryNames\": $names_json
    }
}")

if echo "$response" | grep -q '"error"'; then
    echo "Error:"
    echo "$response" | format_json
    exit 1
fi

echo "$response" | format_json

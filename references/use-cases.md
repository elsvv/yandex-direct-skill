# Common Use Cases

Complete bash script examples for frequent Yandex Direct API v5 tasks.

## Setup

All scripts assume you have configured `config/.env` with your token. Source the helper:

```bash
source scripts/common.sh && load_config
```

---

## 1. Get Campaign Statistics for Last 30 Days

```bash
#!/bin/bash
source scripts/common.sh && load_config

# Get campaign performance report
response=$(direct_report '{
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["CampaignId", "CampaignName", "Impressions", "Clicks",
                        "Ctr", "AvgCpc", "Cost", "Conversions",
                        "ConversionRate", "CostPerConversion"],
        "ReportName": "Campaign Stats Last 30 Days",
        "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
        "DateRangeType": "LAST_30_DAYS",
        "Format": "TSV",
        "IncludeVAT": "YES",
        "IncludeDiscount": "NO"
    }
}')

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "200" ]]; then
    echo "$body"
elif [[ "$http_code" == "201" || "$http_code" == "202" ]]; then
    echo "Report is being generated, retry in 10 seconds..."
else
    echo "Error (HTTP $http_code): $body"
fi
```

---

## 2. Create a Complete Campaign (Campaign + AdGroup + Ad + Keywords)

```bash
#!/bin/bash
source scripts/common.sh && load_config

echo "=== Step 1: Create campaign ==="
campaign_response=$(direct_request "campaigns" '{
    "method": "add",
    "params": {
        "Campaigns": [{
            "Name": "Widget Store Campaign",
            "StartDate": "2026-03-01",
            "DailyBudget": {
                "Amount": 5000000,
                "Mode": "STANDARD"
            },
            "NegativeKeywords": ["free", "download", "torrent"],
            "TextCampaign": {
                "BiddingStrategy": {
                    "Search": {
                        "BiddingStrategyType": "WB_MAXIMUM_CLICKS",
                        "WbMaximumClicks": {
                            "WeeklySpendLimit": 50000000000,
                            "BidCeiling": 3000000
                        }
                    },
                    "Network": {
                        "BiddingStrategyType": "SERVING_OFF"
                    }
                },
                "Settings": [
                    {"Option": "ADD_METRICA_TAG", "Value": "YES"},
                    {"Option": "ADD_OPENSTAT_TAG", "Value": "NO"},
                    {"Option": "ADD_TO_FAVORITES", "Value": "NO"},
                    {"Option": "ENABLE_AREA_OF_INTEREST_TARGETING", "Value": "YES"},
                    {"Option": "ENABLE_COMPANY_INFO", "Value": "YES"},
                    {"Option": "ENABLE_SITE_MONITORING", "Value": "NO"}
                ]
            }
        }]
    }
}')

echo "$campaign_response" | format_json

# Extract campaign ID (requires jq)
CAMPAIGN_ID=$(echo "$campaign_response" | jq -r '.result.AddResults[0].Id')
echo "Created campaign ID: $CAMPAIGN_ID"

echo ""
echo "=== Step 2: Create ad group ==="
adgroup_response=$(direct_request "adgroups" '{
    "method": "add",
    "params": {
        "AdGroups": [{
            "Name": "Widgets - General",
            "CampaignId": '"$CAMPAIGN_ID"',
            "RegionIds": [225],
            "NegativeKeywords": ["used", "broken"]
        }]
    }
}')

echo "$adgroup_response" | format_json

ADGROUP_ID=$(echo "$adgroup_response" | jq -r '.result.AddResults[0].Id')
echo "Created ad group ID: $ADGROUP_ID"

echo ""
echo "=== Step 3: Create ads ==="
ads_response=$(direct_request "ads" '{
    "method": "add",
    "params": {
        "Ads": [
            {
                "AdGroupId": '"$ADGROUP_ID"',
                "TextAd": {
                    "Title": "Premium Widgets - Sale",
                    "Title2": "Free Shipping on Orders 3000+",
                    "Text": "High quality widgets at great prices. Wide selection. Fast delivery.",
                    "Href": "https://example.com/widgets?utm_source=yandex&utm_medium=cpc",
                    "Mobile": "NO"
                }
            },
            {
                "AdGroupId": '"$ADGROUP_ID"',
                "TextAd": {
                    "Title": "Buy Widgets Online",
                    "Title2": "Official Store",
                    "Text": "Best prices guaranteed. Order now and get 10% off your first purchase!",
                    "Href": "https://example.com/widgets?utm_source=yandex&utm_medium=cpc",
                    "Mobile": "YES"
                }
            }
        ]
    }
}')

echo "$ads_response" | format_json

echo ""
echo "=== Step 4: Add keywords ==="
keywords_response=$(direct_request "keywords" '{
    "method": "add",
    "params": {
        "Keywords": [
            {"Keyword": "buy widgets", "AdGroupId": '"$ADGROUP_ID"', "Bid": 1500000},
            {"Keyword": "widgets online shop", "AdGroupId": '"$ADGROUP_ID"', "Bid": 1200000},
            {"Keyword": "premium widgets", "AdGroupId": '"$ADGROUP_ID"', "Bid": 2000000},
            {"Keyword": "order widgets delivery", "AdGroupId": '"$ADGROUP_ID"', "Bid": 1000000},
            {"Keyword": "\"buy widgets online\"", "AdGroupId": '"$ADGROUP_ID"', "Bid": 2500000}
        ]
    }
}')

echo "$keywords_response" | format_json

echo ""
echo "=== Step 5: Submit ads for moderation ==="
# Get the ad IDs that were just created
AD_IDS=$(echo "$ads_response" | jq -r '[.result.AddResults[].Id] | join(",")')

direct_request "ads" '{
    "method": "moderate",
    "params": {
        "SelectionCriteria": {
            "Ids": ['"$AD_IDS"']
        }
    }
}' | format_json

echo ""
echo "Campaign creation complete!"
echo "Campaign ID: $CAMPAIGN_ID"
echo "AdGroup ID: $ADGROUP_ID"
```

---

## 3. Pause/Resume Campaigns

```bash
#!/bin/bash
source scripts/common.sh && load_config

ACTION="${1:-suspend}"  # suspend or resume
CAMPAIGN_IDS="${2}"     # comma-separated IDs

if [[ -z "$CAMPAIGN_IDS" ]]; then
    echo "Usage: $0 <suspend|resume> <campaign_id1,campaign_id2,...>"
    exit 1
fi

direct_request "campaigns" '{
    "method": "'"$ACTION"'",
    "params": {
        "SelectionCriteria": {
            "Ids": ['"$CAMPAIGN_IDS"']
        }
    }
}' | format_json

echo "Campaigns $ACTION completed."
```

---

## 4. Add Keywords to an Existing Ad Group

```bash
#!/bin/bash
source scripts/common.sh && load_config

ADGROUP_ID="${1}"
KEYWORDS_FILE="${2}"  # One keyword per line

if [[ -z "$ADGROUP_ID" || -z "$KEYWORDS_FILE" ]]; then
    echo "Usage: $0 <adgroup_id> <keywords_file>"
    echo "Keywords file: one keyword per line, optionally with bid (tab-separated)"
    exit 1
fi

# Build JSON array from file
KEYWORDS_JSON="["
FIRST=true
while IFS=$'\t' read -r keyword bid; do
    [[ -z "$keyword" ]] && continue
    bid="${bid:-1000000}"  # Default bid: 1.0 RUB

    if [[ "$FIRST" == "true" ]]; then
        FIRST=false
    else
        KEYWORDS_JSON+=","
    fi

    keyword_escaped=$(json_escape "$keyword")
    KEYWORDS_JSON+="{\"Keyword\":\"$keyword_escaped\",\"AdGroupId\":$ADGROUP_ID,\"Bid\":$bid}"
done < "$KEYWORDS_FILE"
KEYWORDS_JSON+="]"

direct_request "keywords" "{
    \"method\": \"add\",
    \"params\": {
        \"Keywords\": $KEYWORDS_JSON
    }
}" | format_json
```

---

## 5. Get Daily Statistics with Breakdown

```bash
#!/bin/bash
source scripts/common.sh && load_config

DATE_FROM="${1:-$(date -v-7d +%Y-%m-%d)}"
DATE_TO="${2:-$(date -v-1d +%Y-%m-%d)}"

echo "Getting daily stats from $DATE_FROM to $DATE_TO..."

response=$(direct_report '{
    "params": {
        "SelectionCriteria": {
            "DateFrom": "'"$DATE_FROM"'",
            "DateTo": "'"$DATE_TO"'"
        },
        "FieldNames": ["Date", "CampaignName", "AdNetworkType",
                        "Device", "Impressions", "Clicks", "Ctr",
                        "AvgCpc", "Cost", "Conversions"],
        "ReportName": "Daily Stats Breakdown",
        "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
        "DateRangeType": "CUSTOM_DATE",
        "Format": "TSV",
        "IncludeVAT": "YES",
        "IncludeDiscount": "NO"
    }
}')

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "200" ]]; then
    echo "$body"
else
    echo "Status: $http_code"
    echo "$body"
fi
```

---

## 6. Full Account Export (Campaigns + AdGroups + Ads + Keywords)

```bash
#!/bin/bash
source scripts/common.sh && load_config

OUTPUT_DIR="$CACHE_DIR/export_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "=== Exporting account data to $OUTPUT_DIR ==="

# 1. Export campaigns
echo "Exporting campaigns..."
direct_request "campaigns" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Status", "State", "Type",
                        "DailyBudget", "StartDate", "EndDate", "Currency"],
        "Page": {"Limit": 10000}
    }
}' > "$OUTPUT_DIR/campaigns.json"

# Extract campaign IDs
CAMPAIGN_IDS=$(jq -r '[.result.Campaigns[].Id] | join(",")' "$OUTPUT_DIR/campaigns.json")

if [[ -z "$CAMPAIGN_IDS" || "$CAMPAIGN_IDS" == "null" ]]; then
    echo "No campaigns found."
    exit 0
fi

echo "Found campaigns: $CAMPAIGN_IDS"

# 2. Export ad groups
echo "Exporting ad groups..."
direct_request "adgroups" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "CampaignIds": ['"$CAMPAIGN_IDS"']
        },
        "FieldNames": ["Id", "Name", "CampaignId", "Status", "Type",
                        "RegionIds", "NegativeKeywords"],
        "Page": {"Limit": 10000}
    }
}' > "$OUTPUT_DIR/adgroups.json"

# Extract ad group IDs
ADGROUP_IDS=$(jq -r '[.result.AdGroups[].Id] | join(",")' "$OUTPUT_DIR/adgroups.json")

# 3. Export ads
echo "Exporting ads..."
direct_request "ads" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "CampaignIds": ['"$CAMPAIGN_IDS"']
        },
        "FieldNames": ["Id", "AdGroupId", "CampaignId", "State", "Status", "Type"],
        "TextAdFieldNames": ["Title", "Title2", "Text", "Href", "Mobile",
                              "DisplayUrlPath", "SitelinkSetId"],
        "Page": {"Limit": 10000}
    }
}' > "$OUTPUT_DIR/ads.json"

# 4. Export keywords
echo "Exporting keywords..."
direct_request "keywords" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "CampaignIds": ['"$CAMPAIGN_IDS"']
        },
        "FieldNames": ["Id", "Keyword", "AdGroupId", "CampaignId",
                        "Bid", "ContextBid", "State", "Status"],
        "Page": {"Limit": 10000}
    }
}' > "$OUTPUT_DIR/keywords.json"

echo ""
echo "Export complete!"
echo "Files:"
ls -la "$OUTPUT_DIR/"
echo ""
echo "Campaign count: $(jq '.result.Campaigns | length' "$OUTPUT_DIR/campaigns.json")"
echo "AdGroup count: $(jq '.result.AdGroups | length' "$OUTPUT_DIR/adgroups.json")"
echo "Ad count: $(jq '.result.Ads | length' "$OUTPUT_DIR/ads.json")"
echo "Keyword count: $(jq '.result.Keywords | length' "$OUTPUT_DIR/keywords.json")"
```

---

## 7. Check for Changes Since Last Sync

```bash
#!/bin/bash
source scripts/common.sh && load_config

TIMESTAMP_FILE="$CACHE_DIR/last_sync_timestamp"

if [[ -f "$TIMESTAMP_FILE" ]]; then
    LAST_TIMESTAMP=$(cat "$TIMESTAMP_FILE")
    echo "Checking changes since: $LAST_TIMESTAMP"

    response=$(direct_request "changes" '{
        "method": "checkCampaigns",
        "params": {
            "Timestamp": "'"$LAST_TIMESTAMP"'"
        }
    }')
else
    echo "First sync -- getting server timestamp..."
    response=$(direct_request "changes" '{
        "method": "checkDictionaries",
        "params": {}
    }')
fi

echo "$response" | format_json

# Save new timestamp
NEW_TIMESTAMP=$(echo "$response" | jq -r '.result.Timestamp')
if [[ -n "$NEW_TIMESTAMP" && "$NEW_TIMESTAMP" != "null" ]]; then
    echo "$NEW_TIMESTAMP" > "$TIMESTAMP_FILE"
    echo "Saved timestamp: $NEW_TIMESTAMP"
fi
```

---

## 8. Bulk Update Keyword Bids

```bash
#!/bin/bash
source scripts/common.sh && load_config

# Increase all keyword bids by 20% for a specific ad group
ADGROUP_ID="${1}"
MULTIPLIER="${2:-1.2}"  # Default: +20%

if [[ -z "$ADGROUP_ID" ]]; then
    echo "Usage: $0 <adgroup_id> [multiplier]"
    echo "Example: $0 12345678 1.2  (increase by 20%)"
    exit 1
fi

echo "Getting current bids for ad group $ADGROUP_ID..."

current=$(direct_request "keywordbids" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "AdGroupIds": ['"$ADGROUP_ID"']
        },
        "FieldNames": ["KeywordId", "Bid"]
    }
}')

# Build updated bids
new_bids=$(echo "$current" | jq --arg mult "$MULTIPLIER" '
    [.result.KeywordBids[] | {
        KeywordId: .KeywordId,
        SearchBid: ((.Bid // 0) * ($mult | tonumber) | floor)
    }]
')

echo "Updating bids with multiplier $MULTIPLIER..."

direct_request "keywordbids" "{
    \"method\": \"set\",
    \"params\": {
        \"KeywordBids\": $new_bids
    }
}" | format_json

echo "Bid update complete."
```

---

## 9. Search Query Mining (Find New Keywords)

```bash
#!/bin/bash
source scripts/common.sh && load_config

CAMPAIGN_ID="${1}"
MIN_CLICKS="${2:-3}"
DAYS="${3:-30}"

DATE_FROM=$(date -v-${DAYS}d +%Y-%m-%d)
DATE_TO=$(date -v-1d +%Y-%m-%d)

echo "Mining search queries for campaign $CAMPAIGN_ID ($DATE_FROM to $DATE_TO)..."
echo "Min clicks: $MIN_CLICKS"

response=$(direct_report '{
    "params": {
        "SelectionCriteria": {
            "DateFrom": "'"$DATE_FROM"'",
            "DateTo": "'"$DATE_TO"'",
            "Filter": [
                {"Field": "CampaignId", "Operator": "EQUALS", "Values": ["'"$CAMPAIGN_ID"'"]},
                {"Field": "Clicks", "Operator": "GREATER_THAN", "Values": ["'"$MIN_CLICKS"'"]}
            ]
        },
        "FieldNames": ["Query", "Keyword", "MatchType", "Impressions",
                        "Clicks", "Ctr", "Cost", "Conversions"],
        "OrderBy": [{"Field": "Clicks", "SortOrder": "DESCENDING"}],
        "ReportName": "Search Query Mining",
        "ReportType": "SEARCH_QUERY_PERFORMANCE_REPORT",
        "DateRangeType": "CUSTOM_DATE",
        "Format": "TSV",
        "IncludeVAT": "YES"
    }
}')

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "200" ]]; then
    echo "$body"
else
    echo "Status: $http_code"
    echo "$body"
fi
```

---

## 10. Raw Curl (No Dependencies)

For use without the helper scripts:

```bash
# Get campaigns (minimal example)
curl -s -X POST "https://api.direct.yandex.com/json/v5/campaigns" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Accept-Language: en" \
  -d '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Status", "State"],
        "Page": {"Limit": 10}
    }
  }' | python3 -m json.tool

# Get a performance report
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Accept-Language: en" \
  -H "processingMode: auto" \
  -H "returnMoneyInMicros: false" \
  -H "skipReportHeader: true" \
  -H "skipReportSummary: true" \
  -d '{
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Date", "CampaignId", "Impressions", "Clicks", "Cost"],
        "ReportName": "Quick Report",
        "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
        "DateRangeType": "LAST_7_DAYS",
        "Format": "TSV",
        "IncludeVAT": "YES"
    }
  }'

# For agency accounts, add Client-Login header:
curl -s -X POST "https://api.direct.yandex.com/json/v5/campaigns" \
  -H "Authorization: Bearer YOUR_AGENCY_TOKEN" \
  -H "Client-Login: client_login_here" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name"],
        "Page": {"Limit": 10}
    }
  }'

# Sandbox mode (change base URL)
curl -s -X POST "https://api-sandbox.direct.yandex.com/json/v5/campaigns" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name"]
    }
  }'
```

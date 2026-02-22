# Reports Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/reports`

The Reports service is different from other API v5 services. It uses a different request format, returns TSV data (not JSON), and uses special HTTP headers.

## Request Format

Reports use an XML-like body format posted as JSON:

```json
{
    "params": {
        "SelectionCriteria": {
            "DateFrom": "2026-01-01",
            "DateTo": "2026-01-31",
            "Filter": [{
                "Field": "Clicks",
                "Operator": "GREATER_THAN",
                "Values": ["0"]
            }]
        },
        "FieldNames": ["Date", "CampaignId", "Impressions", "Clicks", "Cost"],
        "ReportName": "My Report",
        "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
        "DateRangeType": "CUSTOM_DATE",
        "Format": "TSV",
        "IncludeVAT": "YES",
        "IncludeDiscount": "NO"
    }
}
```

## Request HTTP Headers

| Header | Value | Description |
|--------|-------|-------------|
| `Authorization` | `Bearer TOKEN` | OAuth token (required) |
| `Client-Login` | `login` | Client login (agency only) |
| `Accept-Language` | `ru` or `en` | Language for report header |
| `processingMode` | `auto` / `online` / `offline` | Report generation mode |
| `returnMoneyInMicros` | `true` / `false` | If `false`, monetary values with 2 decimal places; if omitted, values * 1,000,000 |
| `skipReportHeader` | `true` | Omit report name row |
| `skipColumnHeader` | `true` | Omit column names row |
| `skipReportSummary` | `true` | Omit summary row at end |

### Processing Modes

| Mode | Description |
|------|-------------|
| `online` | Synchronous, waits for result (small reports) |
| `offline` | Async, returns 201/202 while processing |
| `auto` | Server chooses mode automatically (recommended) |

## Response HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| `200` | Report ready, body contains TSV data | Parse the data |
| `201` | Report accepted, processing offline | Retry with same request after delay |
| `202` | Report still processing | Retry with same request after delay |
| `400` | Bad request | Fix request parameters |
| `500` | Server error | Retry after delay |

**For 201/202:** Retry the exact same request after waiting. The `retryIn` response header suggests wait time in seconds.

## Report Types

| ReportType | Grouping | Description |
|------------|----------|-------------|
| `ACCOUNT_PERFORMANCE_REPORT` | Entire account | Account-level stats |
| `CAMPAIGN_PERFORMANCE_REPORT` | By CampaignId | Campaign-level stats |
| `ADGROUP_PERFORMANCE_REPORT` | By AdGroupId | Ad group-level stats |
| `AD_PERFORMANCE_REPORT` | By AdId | Individual ad stats |
| `CRITERIA_PERFORMANCE_REPORT` | By CriteriaId | Keyword/targeting criteria stats |
| `CUSTOM_REPORT` | No grouping | Custom report with any fields |
| `SEARCH_QUERY_PERFORMANCE_REPORT` | By AdGroupId + Query | Search query stats |
| `REACH_AND_FREQUENCY_PERFORMANCE_REPORT` | By CampaignId | CPM reach/frequency stats |

## Date Range Types

| DateRangeType | Description |
|---------------|-------------|
| `TODAY` | Current day |
| `YESTERDAY` | Previous day |
| `LAST_3_DAYS` | Last 3 days (excluding today) |
| `LAST_5_DAYS` | Last 5 days (excluding today) |
| `LAST_7_DAYS` | Last 7 days (excluding today) |
| `LAST_14_DAYS` | Last 14 days (excluding today) |
| `LAST_30_DAYS` | Last 30 days (excluding today) |
| `LAST_90_DAYS` | Last 90 days (excluding today) |
| `LAST_365_DAYS` | Last 365 days (excluding today) |
| `THIS_WEEK_MON_TODAY` | Current week Mon-today |
| `THIS_WEEK_SUN_TODAY` | Current week Sun-today |
| `LAST_WEEK` | Last week Mon-Sun |
| `LAST_BUSINESS_WEEK` | Last work week Mon-Fri |
| `LAST_WEEK_SUN_SAT` | Last week Sun-Sat |
| `THIS_MONTH` | Current calendar month |
| `LAST_MONTH` | Last calendar month |
| `ALL_TIME` | All available data (including today) |
| `CUSTOM_DATE` | Custom range (requires `DateFrom`/`DateTo`) |
| `AUTO` | Auto-selected period for updated stats |

When using `CUSTOM_DATE`, include `DateFrom` and `DateTo` in `SelectionCriteria` (format: `YYYY-MM-DD`).

## All Available Field Names

### Dimension Fields (Grouping/Segmentation)

| Field | Description |
|-------|-------------|
| `Date` | Date (YYYY-MM-DD) |
| `Week` | Week start date |
| `Month` | Month (YYYY-MM) |
| `Quarter` | Quarter (YYYY-Q) |
| `Year` | Year |
| `CampaignId` | Campaign ID |
| `CampaignName` | Campaign name |
| `CampaignType` | Campaign type |
| `CampaignUrlPath` | Campaign URL path |
| `AdGroupId` | Ad group ID |
| `AdGroupName` | Ad group name |
| `AdId` | Ad ID |
| `AdUrl` | Ad destination URL |
| `AdFormat` | Ad format |
| `CriteriaId` | Keyword/criteria ID |
| `CriterionId` | Synonym for CriteriaId |
| `Criteria` | Keyword text |
| `Criterion` | Synonym for Criteria |
| `CriteriaType` | Criteria type |
| `CriterionType` | Synonym for CriteriaType |
| `Keyword` | Keyword text (alias) |
| `Query` | Search query (SEARCH_QUERY reports only) |
| `MatchedKeyword` | Matched keyword |
| `MatchType` | Match type (EXACT, PHRASE, BROAD, etc.) |
| `ClientLogin` | Client login |
| `ExternalNetworkName` | External network name |
| `Placement` | Placement |
| `DynamicTextAdTargetId` | Dynamic ad target ID |
| `SmartBannerFilterId` | Smart banner filter ID |
| `SmartAdTargetId` | Smart ad target ID |
| `AudienceTargetId` | Audience target ID |
| `RlAdjustmentId` | Retargeting list adjustment ID |

### Segment Fields

| Field | Description |
|-------|-------------|
| `AdNetworkType` | SEARCH / AD_NETWORK |
| `Device` | DESKTOP / MOBILE / TABLET |
| `ClickType` | Click type |
| `CarrierType` | WIFI / CELLULAR |
| `MobilePlatform` | IOS / ANDROID / OTHER |
| `Gender` | GENDER_MALE / GENDER_FEMALE |
| `Age` | Age group (AGE_0_17, AGE_18_24, AGE_25_34, AGE_35_44, AGE_45_54, AGE_55, etc.) |
| `IncomeGrade` | Income level |
| `Slot` | Ad position slot |
| `TargetingLocationId` | Targeting location ID |
| `TargetingLocationName` | Targeting location name |
| `LocationOfPresenceId` | User location ID |
| `LocationOfPresenceName` | User location name |
| `TargetingCategory` | Targeting category |
| `AutotargetingBrandOption` | Autotargeting brand option |

### Metric Fields

| Field | Description |
|-------|-------------|
| `Impressions` | Number of impressions |
| `Clicks` | Number of clicks |
| `Ctr` | Click-through rate (%) |
| `Cost` | Total cost |
| `AvgCpc` | Average cost per click |
| `AvgCpm` | Average CPM |
| `AvgEffectiveBid` | Average effective bid |
| `AvgClickPosition` | Average click position |
| `AvgImpressionPosition` | Average impression position |
| `AvgTrafficVolume` | Average traffic volume |
| `AvgImpressionFrequency` | Average impression frequency |
| `ImpressionReach` | Unique users reached |
| `ImpressionShare` | Impression share |
| `BounceRate` | Bounce rate (%) |
| `Bounces` | Number of bounces |
| `AvgPageviews` | Average pageviews |
| `Sessions` | Number of sessions |
| `Conversions` | Number of conversions |
| `ConversionRate` | Conversion rate (%) |
| `CostPerConversion` | Cost per conversion |
| `GoalsRoi` | ROI for goals |
| `Revenue` | Revenue |
| `Profit` | Profit |
| `PurchaseRevenue` | Purchase revenue |
| `PurchaseGoals` | Number of purchase goals |
| `PurchaseProfit` | Purchase profit |
| `PurchaseGoalsRoi` | Purchase goals ROI |
| `WeightedCtr` | Weighted CTR |
| `WeightedImpressions` | Weighted impressions |
| `Views` | Views |
| `VideoViews` | Video views |
| `VideoViewsRate` | Video view rate |
| `VideoFirstQuartile` | Video 25% completions |
| `VideoFirstQuartileRate` | Video 25% rate |
| `VideoMidpoint` | Video 50% completions |
| `VideoMidpointRate` | Video 50% rate |
| `VideoThirdQuartile` | Video 75% completions |
| `VideoThirdQuartileRate` | Video 75% rate |
| `VideoComplete` | Video 100% completions |
| `VideoCompleteRate` | Video 100% rate |
| `AvgVideoCompleteCost` | Average cost per video completion |
| `CPV` | Cost per view |

## Filter Operators

| Operator | Description |
|----------|-------------|
| `EQUALS` | Equal to |
| `NOT_EQUALS` | Not equal to |
| `IN` | In list |
| `NOT_IN` | Not in list |
| `LESS_THAN` | Less than |
| `GREATER_THAN` | Greater than |
| `STARTS_WITH_IGNORE_CASE` | Starts with (case-insensitive) |
| `DOES_NOT_START_WITH_IGNORE_CASE` | Does not start with (case-insensitive) |
| `STARTS_WITH_ANY_IGNORE_CASE` | Starts with any (case-insensitive) |
| `DOES_NOT_START_WITH_ALL_IGNORE_CASE` | Does not start with all (case-insensitive) |

## Goals and Attribution

```json
{
    "params": {
        "Goals": [12345],
        "AttributionModels": ["FC"]
    }
}
```

**AttributionModels:**

| Model | Description |
|-------|-------------|
| `FC` | First click |
| `LC` | Last click |
| `LSC` | Last significant click |
| `LYDC` | Last Yandex Direct click |

## Curl Examples

### Basic Campaign Report

```bash
source scripts/common.sh && load_config

direct_report '{
    "params": {
        "SelectionCriteria": {
            "DateFrom": "2026-02-01",
            "DateTo": "2026-02-21"
        },
        "FieldNames": ["Date", "CampaignId", "CampaignName",
                        "Impressions", "Clicks", "Ctr", "Cost", "AvgCpc"],
        "ReportName": "Campaign Stats Feb 2026",
        "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
        "DateRangeType": "CUSTOM_DATE",
        "Format": "TSV",
        "IncludeVAT": "YES",
        "IncludeDiscount": "NO"
    }
}'
```

### Search Query Report

```bash
direct_report '{
    "params": {
        "SelectionCriteria": {
            "DateFrom": "2026-02-01",
            "DateTo": "2026-02-21",
            "Filter": [{
                "Field": "Clicks",
                "Operator": "GREATER_THAN",
                "Values": ["5"]
            }]
        },
        "FieldNames": ["Query", "AdGroupId", "CampaignId", "Impressions",
                        "Clicks", "Ctr", "Cost", "AvgCpc", "Conversions"],
        "ReportName": "Search Queries Report",
        "ReportType": "SEARCH_QUERY_PERFORMANCE_REPORT",
        "DateRangeType": "CUSTOM_DATE",
        "Format": "TSV",
        "IncludeVAT": "YES",
        "IncludeDiscount": "NO"
    }
}'
```

### Account-Level Summary (Last 30 days)

```bash
direct_report '{
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Date", "Impressions", "Clicks", "Ctr", "Cost",
                        "AvgCpc", "Conversions", "ConversionRate",
                        "CostPerConversion", "Revenue"],
        "ReportName": "Account Summary Last 30 Days",
        "ReportType": "ACCOUNT_PERFORMANCE_REPORT",
        "DateRangeType": "LAST_30_DAYS",
        "Format": "TSV",
        "IncludeVAT": "YES",
        "IncludeDiscount": "NO"
    }
}'
```

### Report with Goals

```bash
direct_report '{
    "params": {
        "SelectionCriteria": {
            "DateFrom": "2026-01-01",
            "DateTo": "2026-01-31"
        },
        "Goals": [12345678],
        "AttributionModels": ["LYDC"],
        "FieldNames": ["CampaignId", "CampaignName", "Impressions",
                        "Clicks", "Cost", "Conversions", "ConversionRate",
                        "CostPerConversion", "Revenue", "GoalsRoi"],
        "ReportName": "Goal Performance Report",
        "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
        "DateRangeType": "CUSTOM_DATE",
        "Format": "TSV",
        "IncludeVAT": "YES",
        "IncludeDiscount": "NO"
    }
}'
```

### Full Raw Curl Example (without helpers)

```bash
curl -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Client-Login: client_login" \
  -H "Accept-Language: en" \
  -H "processingMode: auto" \
  -H "returnMoneyInMicros: false" \
  -H "skipReportHeader: true" \
  -H "skipReportSummary: true" \
  -d '{
    "params": {
        "SelectionCriteria": {
            "DateFrom": "2026-02-01",
            "DateTo": "2026-02-21"
        },
        "FieldNames": ["Date", "CampaignId", "CampaignName", "Impressions",
                        "Clicks", "Cost"],
        "ReportName": "My Report",
        "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
        "DateRangeType": "CUSTOM_DATE",
        "Format": "TSV",
        "IncludeVAT": "YES",
        "IncludeDiscount": "NO"
    }
}'
```

### Handling Async Reports (201/202)

```bash
#!/bin/bash
# Script to handle async report generation
source scripts/common.sh && load_config

REPORT_BODY='{
    "params": {
        "SelectionCriteria": { "DateFrom": "2026-01-01", "DateTo": "2026-02-21" },
        "FieldNames": ["Date", "CampaignId", "Impressions", "Clicks", "Cost"],
        "ReportName": "Large Report",
        "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
        "DateRangeType": "CUSTOM_DATE",
        "Format": "TSV",
        "IncludeVAT": "YES"
    }
}'

MAX_RETRIES=20
RETRY_DELAY=10

for i in $(seq 1 $MAX_RETRIES); do
    response=$(direct_report "$REPORT_BODY")
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]]; then
        echo "$body"
        exit 0
    elif [[ "$http_code" == "201" || "$http_code" == "202" ]]; then
        echo "Report is being generated... Attempt $i/$MAX_RETRIES" >&2
        sleep $RETRY_DELAY
    else
        echo "Error (HTTP $http_code): $body" >&2
        exit 1
    fi
done

echo "Timeout: report generation took too long" >&2
exit 1
```

## TSV Output Format

Report data is returned as tab-separated values (TSV):

```
Date	CampaignId	CampaignName	Impressions	Clicks	Cost
2026-02-01	12345678	My Campaign	15234	523	12500.50
2026-02-02	12345678	My Campaign	14102	498	11200.30
```

With `skipReportHeader: true` and `skipReportSummary: true`, you get clean TSV data ready for processing. Without these headers, the output includes:
- Row 1: Report name and date range
- Row 2: Column headers
- Rows 3+: Data
- Last row: Summary totals

## Monetary Values in Reports

By default (without `returnMoneyInMicros` header), monetary values are integers representing the amount multiplied by 1,000,000. Set `returnMoneyInMicros: false` to get readable values with up to 2 decimal places.

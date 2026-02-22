# Other Services

## Dictionaries Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/dictionaries`

**Methods:** get

Returns reference data used throughout the API.

### Available Dictionary Names

| DictionaryName | Description |
|---------------|-------------|
| `GeoRegions` | Geographic regions (countries, cities) |
| `GeoRegionNames` | Region names in specified language |
| `Currencies` | Currency codes and properties |
| `TimeZones` | Timezone identifiers |
| `Constants` | API constants (limits, etc.) |
| `AdCategories` | Ad categories for sensitive content |
| `MetroStations` | Metro station IDs (Moscow, St. Petersburg) |
| `OperationSystemVersions` | OS versions for targeting |
| `ProductivityAssertions` | Ad quality assertions |
| `SupplySidePlatforms` | SSP/exchange platforms |
| `Interests` | Interest categories |
| `AudienceCriteriaTypes` | Audience criteria types |
| `AudienceDemographicProfiles` | Demographic profiles |
| `AudienceInterests` | Audience interest categories |
| `FilterSchemas` | Filter schemas for smart campaigns |

### Dictionaries.get

```bash
source scripts/common.sh && load_config

# Get geographic regions
direct_request "dictionaries" '{
    "method": "get",
    "params": {
        "DictionaryNames": ["GeoRegions"]
    }
}'

# Get currencies
direct_request "dictionaries" '{
    "method": "get",
    "params": {
        "DictionaryNames": ["Currencies"]
    }
}'

# Get multiple dictionaries at once
direct_request "dictionaries" '{
    "method": "get",
    "params": {
        "DictionaryNames": ["GeoRegions", "Currencies", "TimeZones", "Constants"]
    }
}'

# Get ad categories
direct_request "dictionaries" '{
    "method": "get",
    "params": {
        "DictionaryNames": ["AdCategories"]
    }
}'

# Get audience interests
direct_request "dictionaries" '{
    "method": "get",
    "params": {
        "DictionaryNames": ["AudienceInterests", "AudienceDemographicProfiles"]
    }
}'
```

**GeoRegions response structure:**
```json
{
    "GeoRegionId": 225,
    "GeoRegionName": "Russia",
    "GeoRegionType": "COUNTRY",
    "ParentId": null
}
```

**Common GeoRegion IDs:**
- `225` -- Russia
- `1` -- Moscow & Moscow Oblast
- `2` -- St. Petersburg & Leningrad Oblast
- `187` -- Ukraine
- `149` -- Belarus
- `159` -- Kazakhstan

**Currencies response structure:**
```json
{
    "Currency": "RUB",
    "Properties": [
        {"Name": "MinDailyBudget", "Value": "300000000"},
        {"Name": "MinCampaignBudget", "Value": "900000000"}
    ]
}
```

---

## Clients Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/clients`

**Methods:** get, update

### Clients.get

```bash
# Get account info
direct_request "clients" '{
    "method": "get",
    "params": {
        "FieldNames": ["Login", "ClientId", "ClientInfo", "AccountQuality",
                        "Currency", "Phone", "DateRegistered", "VATRate",
                        "Grants", "Notification", "Representatives",
                        "Restrictions", "Settings"]
    }
}'
```

**FieldNames:** `Login`, `ClientId`, `ClientInfo`, `AccountQuality`, `Currency`, `Phone`, `DateRegistered`, `VATRate`, `Grants`, `Notification`, `Representatives`, `Restrictions`, `Settings`, `CounterIds`, `BonusesBalance`, `OverdraftSumAvailable`

### Clients.update

```bash
# Update client notification settings
direct_request "clients" '{
    "method": "update",
    "params": {
        "Clients": [{
            "ClientId": 12345678,
            "Notification": {
                "EmailSubscriptions": [{
                    "Option": "RECEIVE_RECOMMENDATIONS",
                    "Value": "NO"
                }]
            }
        }]
    }
}'
```

---

## AgencyClients Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/agencyclients`

**Methods:** add, update, get

For agencies managing multiple client accounts.

### AgencyClients.get

```bash
direct_request "agencyclients" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Login", "ClientId", "ClientInfo", "AccountQuality",
                        "Currency", "Phone", "DateRegistered", "Grants",
                        "Representatives", "Restrictions", "Settings"],
        "Page": {"Limit": 100}
    }
}'
```

### AgencyClients.add

```bash
# Add a new client under agency
direct_request "agencyclients" '{
    "method": "add",
    "params": {
        "Clients": [{
            "Login": "new-client-login",
            "FirstName": "John",
            "LastName": "Doe",
            "Currency": "RUB",
            "Grants": [{
                "Privilege": "EDIT_CAMPAIGNS",
                "Value": "YES"
            }],
            "Notification": {
                "Lang": "RU",
                "Email": "john@example.com"
            },
            "Settings": [{
                "Option": "CORRECT_TYPOS_AUTOMATICALLY",
                "Value": "YES"
            }]
        }]
    }
}'
```

### AgencyClients.update

```bash
direct_request "agencyclients" '{
    "method": "update",
    "params": {
        "Clients": [{
            "ClientId": 12345678,
            "Grants": [{
                "Privilege": "EDIT_CAMPAIGNS",
                "Value": "YES"
            }]
        }]
    }
}'
```

---

## Changes Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/changes`

**Methods:** check, checkCampaigns, checkDictionaries

Used for efficient data synchronization -- detect what changed before re-downloading.

### Changes.checkDictionaries

Call without timestamp on first launch to get server time. On subsequent calls, pass the returned timestamp.

```bash
# First call: get server timestamp
direct_request "changes" '{
    "method": "checkDictionaries",
    "params": {}
}'
# Response: { "result": { "Timestamp": "2026-02-22T10:00:00Z" } }

# Subsequent calls: check if dictionaries changed since last check
direct_request "changes" '{
    "method": "checkDictionaries",
    "params": {
        "Timestamp": "2026-02-22T10:00:00Z"
    }
}'
```

### Changes.checkCampaigns

```bash
# Check which campaigns changed since a timestamp
direct_request "changes" '{
    "method": "checkCampaigns",
    "params": {
        "Timestamp": "2026-02-21T00:00:00Z"
    }
}'
# Response contains: Timestamp (new), CampaignIds (changed), NotifiedCampaignIds
```

### Changes.check

```bash
# Check detailed changes for specific campaigns
direct_request "changes" '{
    "method": "check",
    "params": {
        "CampaignIds": [12345678, 87654321],
        "AdGroupIds": [11111111],
        "AdIds": [],
        "FieldNames": ["CampaignIds", "AdGroupIds", "AdIds"],
        "Timestamp": "2026-02-21T00:00:00Z"
    }
}'
# Response contains IDs of changed campaigns, ad groups, and ads
```

---

## Feeds Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/feeds`

**Methods:** add, update, delete, get

Feeds are product data files used for dynamic ads and smart banners.

### Feeds.get

```bash
direct_request "feeds" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "BusinessType", "SourceType",
                        "UrlFeed", "FileFeed", "Status", "UpdatedAt",
                        "NumberOfItems", "CampaignIds"]
    }
}'
```

### Feeds.add

```bash
# Add a URL-based feed
direct_request "feeds" '{
    "method": "add",
    "params": {
        "Feeds": [{
            "Name": "Product Feed",
            "BusinessType": "RETAIL",
            "SourceType": "URL",
            "UrlFeed": {
                "Url": "https://example.com/feed.xml",
                "RemoveUtmTags": "NO",
                "Login": "",
                "Password": ""
            }
        }]
    }
}'
```

**BusinessType values:** `RETAIL`, `HOTELS`, `REALTY`, `AUTOMOTIVE`, `FLIGHTS`, `OTHER`

### Feeds.update

```bash
direct_request "feeds" '{
    "method": "update",
    "params": {
        "Feeds": [{
            "Id": 12345,
            "Name": "Updated Feed Name",
            "UrlFeed": {
                "Url": "https://example.com/new-feed.xml"
            }
        }]
    }
}'
```

### Feeds.delete

```bash
direct_request "feeds" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [12345]
        }
    }
}'
```

---

## Strategies Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/strategies`

**Methods:** add, update, get, archive, unarchive

Portfolio strategies are shared bidding strategies that can be applied across multiple campaigns.

### Strategies.get

```bash
direct_request "strategies" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Type", "AttributionModel",
                        "CounterIds", "Status"]
    }
}'
```

### Strategies.add

```bash
direct_request "strategies" '{
    "method": "add",
    "params": {
        "Strategies": [{
            "Name": "Max Clicks Strategy",
            "Type": "AVERAGE_CPC",
            "AttributionModel": "LYDC",
            "AverageCpc": {
                "AverageCpc": 2000000,
                "WeeklySpendLimit": 100000000
            }
        }]
    }
}'
```

---

## NegativeKeywordSharedSets Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/negativekeywordsharedsets`

**Methods:** add, update, delete, get

Shared negative keyword sets can be linked to multiple ad groups.

### NegativeKeywordSharedSets.get

```bash
direct_request "negativekeywordsharedsets" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "NegativeKeywords", "AssociatedAdGroupsCount"]
    }
}'
```

### NegativeKeywordSharedSets.add

```bash
direct_request "negativekeywordsharedsets" '{
    "method": "add",
    "params": {
        "NegativeKeywordSharedSets": [{
            "Name": "Common Negatives",
            "NegativeKeywords": ["free", "download", "torrent", "cheap",
                                  "crack", "pirate"]
        }]
    }
}'
```

### NegativeKeywordSharedSets.update

```bash
direct_request "negativekeywordsharedsets" '{
    "method": "update",
    "params": {
        "NegativeKeywordSharedSets": [{
            "Id": 12345,
            "NegativeKeywords": ["free", "download", "torrent", "cheap",
                                  "crack", "pirate", "hack", "keygen"]
        }]
    }
}'
```

To link a shared negative keyword set to ad groups, use `NegativeKeywordSharedSetIds` in AdGroups.update.

---

## TurboPages Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/turbopages`

**Methods:** get

### TurboPages.get

```bash
direct_request "turbopages" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Href"]
    }
}'
```

---

## Businesses Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/businesses`

**Methods:** get

### Businesses.get

```bash
direct_request "businesses" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Address", "Phone", "Url"]
    }
}'
```

---

## KeywordsResearch Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/keywordsresearch`

**Methods:** hasSearchVolume, deduplicate

### KeywordsResearch.hasSearchVolume

Check if keywords have search volume (useful before adding to campaigns).

```bash
direct_request "keywordsresearch" '{
    "method": "hasSearchVolume",
    "params": {
        "Keywords": [
            {"Keyword": "buy widgets online", "RegionIds": [225]},
            {"Keyword": "cheap widget shop", "RegionIds": [225]},
            {"Keyword": "xyznonexistentkeyword"}
        ]
    }
}'
```

### KeywordsResearch.deduplicate

Remove duplicate keywords from a list.

```bash
direct_request "keywordsresearch" '{
    "method": "deduplicate",
    "params": {
        "Keywords": [
            {"Keyword": "buy widgets"},
            {"Keyword": "widgets buy"},
            {"Keyword": "purchase widgets online"}
        ]
    }
}'
```

---

## Leads Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/leads`

**Methods:** get

Retrieves form submissions from Turbo pages.

### Leads.get

```bash
direct_request "leads" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "DateTimeFrom": "2026-02-01T00:00:00Z",
            "DateTimeTo": "2026-02-22T00:00:00Z"
        },
        "FieldNames": ["Id", "TurboPageId", "TurboPageName", "CampaignId",
                        "AdGroupId", "AdId", "SubmittedAt", "FormData"],
        "Page": {"Limit": 100}
    }
}'
```

---

## Bids Service (Legacy)

**Endpoint:** `https://api.direct.yandex.com/json/v5/bids`

**Methods:** set, setAuto, get

This is the legacy bid management service. Prefer using `KeywordBids` for keyword-specific bid management.

### Bids.get

```bash
direct_request "bids" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "CampaignIds": [12345678]
        },
        "FieldNames": ["KeywordId", "AdGroupId", "CampaignId",
                        "Bid", "ContextBid", "CompetitorsBids", "SearchPrices"]
    }
}'
```

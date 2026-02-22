# Campaign Management Services

## Campaigns Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/campaigns`

**Methods:** add, update, delete, get, suspend, resume, archive, unarchive

### Campaign Types

| Type | Description |
|------|-------------|
| `TEXT_CAMPAIGN` | Text & image ads (search + network) |
| `MOBILE_APP_CAMPAIGN` | Mobile app promotion |
| `DYNAMIC_TEXT_CAMPAIGN` | Dynamic text ads |
| `CPM_BANNER_CAMPAIGN` | Display (CPM) banner campaigns |
| `SMART_CAMPAIGN` | Smart banner campaigns |
| `UNIFIED_CAMPAIGN` | Unified campaigns |

### Campaigns.get

```bash
# Get all campaigns
source scripts/common.sh && load_config
direct_request "campaigns" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Status", "State", "Type", "DailyBudget", "StartDate"]
    }
}'

# Get specific campaigns by IDs
direct_request "campaigns" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Ids": [12345, 67890]
        },
        "FieldNames": ["Id", "Name", "Status", "State", "Type"],
        "TextCampaignFieldNames": ["BiddingStrategy", "Settings"]
    }
}'

# Get campaigns filtered by type and status
direct_request "campaigns" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Types": ["TEXT_CAMPAIGN"],
            "Statuses": ["ACCEPTED"],
            "States": ["ON"]
        },
        "FieldNames": ["Id", "Name", "Status", "State", "Statistics"]
    }
}'
```

**FieldNames for Campaigns.get:**

| Field | Description |
|-------|-------------|
| `Id` | Campaign ID |
| `Name` | Campaign name |
| `ClientInfo` | Client info text |
| `StartDate` | Start date (YYYY-MM-DD) |
| `EndDate` | End date (YYYY-MM-DD) |
| `TimeTargeting` | Time targeting settings |
| `TimeZone` | Timezone |
| `NegativeKeywords` | Negative keywords list |
| `BlockedIps` | Blocked IPs |
| `ExcludedSites` | Excluded sites/networks |
| `DailyBudget` | Daily budget settings |
| `Notification` | Notification settings |
| `Type` | Campaign type |
| `Status` | Moderation status (DRAFT, MODERATION, ACCEPTED, REJECTED) |
| `State` | Campaign state (ARCHIVED, CONVERTED, ENDED, OFF, ON, SUSPENDED, UNKNOWN) |
| `StatusPayment` | Payment status |
| `StatusClarification` | Clarification status |
| `SourceId` | Source campaign ID |
| `Statistics` | Campaign statistics summary |
| `Currency` | Currency code |
| `Funds` | Account funds info |
| `RepresentedBy` | Agency representative |

**Type-specific FieldNames:**
- `TextCampaignFieldNames`: `BiddingStrategy`, `Settings`, `CounterIds`, `RelevantKeywords`, `PriorityGoals`, `AttributionModel`
- `MobileAppCampaignFieldNames`: same pattern
- `DynamicTextCampaignFieldNames`: same pattern
- `CpmBannerCampaignFieldNames`: same pattern
- `SmartCampaignFieldNames`: same pattern

**SelectionCriteria for Campaigns.get:**

| Param | Type | Description |
|-------|------|-------------|
| `Ids` | long[] | Campaign IDs (max 1000) |
| `Types` | enum[] | Campaign types |
| `States` | enum[] | Campaign states |
| `Statuses` | enum[] | Moderation statuses |
| `StatusesPayment` | enum[] | Payment statuses |

### Campaigns.add

```bash
# Create a text campaign
direct_request "campaigns" '{
    "method": "add",
    "params": {
        "Campaigns": [{
            "Name": "My New Campaign",
            "StartDate": "2026-03-01",
            "DailyBudget": {
                "Amount": 3000000,
                "Mode": "STANDARD"
            },
            "NegativeKeywords": ["free", "download"],
            "TextCampaign": {
                "BiddingStrategy": {
                    "Search": {
                        "BiddingStrategyType": "WB_MAXIMUM_CLICKS",
                        "WbMaximumClicks": {
                            "WeeklySpendLimit": 30000000000,
                            "BidCeiling": 1500000
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
                    {"Option": "ENABLE_SITE_MONITORING", "Value": "NO"},
                    {"Option": "REQUIRE_SERVICING", "Value": "NO"},
                    {"Option": "ENABLE_CPC_HOLD", "Value": "NO"}
                ]
            }
        }]
    }
}'
```

**Note on monetary values in add/update:** Amounts are in the advertiser's currency multiplied by 1,000,000. For example, 30 RUB = 30000000.

### Campaigns.update

```bash
# Update campaign name and daily budget
direct_request "campaigns" '{
    "method": "update",
    "params": {
        "Campaigns": [{
            "Id": 12345678,
            "Name": "Updated Campaign Name",
            "DailyBudget": {
                "Amount": 5000000,
                "Mode": "STANDARD"
            }
        }]
    }
}'

# Change bidding strategy
direct_request "campaigns" '{
    "method": "update",
    "params": {
        "Campaigns": [{
            "Id": 12345678,
            "TextCampaign": {
                "BiddingStrategy": {
                    "Search": {
                        "BiddingStrategyType": "WB_MAXIMUM_CLICKS",
                        "WbMaximumClicks": {
                            "WeeklySpendLimit": 50000000000
                        }
                    },
                    "Network": {
                        "BiddingStrategyType": "NETWORK_DEFAULT",
                        "NetworkDefault": {}
                    }
                }
            }
        }]
    }
}'
```

### Campaigns.delete / suspend / resume / archive / unarchive

```bash
# Delete campaigns
direct_request "campaigns" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [12345678, 87654321]
        }
    }
}'

# Suspend campaigns
direct_request "campaigns" '{
    "method": "suspend",
    "params": {
        "SelectionCriteria": {
            "Ids": [12345678]
        }
    }
}'

# Resume campaigns
direct_request "campaigns" '{
    "method": "resume",
    "params": {
        "SelectionCriteria": {
            "Ids": [12345678]
        }
    }
}'

# Archive campaigns (must be stopped first)
direct_request "campaigns" '{
    "method": "archive",
    "params": {
        "SelectionCriteria": {
            "Ids": [12345678]
        }
    }
}'

# Unarchive campaigns
direct_request "campaigns" '{
    "method": "unarchive",
    "params": {
        "SelectionCriteria": {
            "Ids": [12345678]
        }
    }
}'
```

---

## AdGroups Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/adgroups`

**Methods:** add, update, delete, get

### AdGroup Types

| Type | Description |
|------|-------------|
| `TEXT_AD_GROUP` | Text/image ad group |
| `MOBILE_APP_AD_GROUP` | Mobile app ad group |
| `DYNAMIC_TEXT_AD_GROUP` | Dynamic text ad group |
| `CPM_BANNER_AD_GROUP` | CPM banner ad group |
| `CPM_VIDEO_AD_GROUP` | CPM video ad group |
| `SMART_AD_GROUP` | Smart banner ad group |

### AdGroups.get

```bash
# Get ad groups for a campaign
direct_request "adgroups" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "CampaignIds": [12345678]
        },
        "FieldNames": ["Id", "Name", "CampaignId", "Status", "Type", "RegionIds"]
    }
}'

# Get specific ad groups by IDs
direct_request "adgroups" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Ids": [111, 222, 333]
        },
        "FieldNames": ["Id", "Name", "CampaignId", "Status", "Type", "RegionIds",
                        "NegativeKeywords", "TrackingParams"],
        "TextAdGroupFieldNames": ["FeedId", "FeedCategoryIds"]
    }
}'
```

**FieldNames:**
`Id`, `Name`, `CampaignId`, `RegionIds`, `NegativeKeywords`, `NegativeKeywordSharedSetIds`, `TrackingParams`, `Status`, `Type`, `Subtype`, `ServingStatus`

### AdGroups.add

```bash
# Create a text ad group
direct_request "adgroups" '{
    "method": "add",
    "params": {
        "AdGroups": [{
            "Name": "My Ad Group",
            "CampaignId": 12345678,
            "RegionIds": [225],
            "NegativeKeywords": ["cheap", "free"]
        }]
    }
}'
```

**RegionIds:** 225 = Russia, 1 = Moscow & Oblast, 2 = St. Petersburg & Oblast. Use Dictionaries.get with `GeoRegions` for full list.

### AdGroups.update

```bash
direct_request "adgroups" '{
    "method": "update",
    "params": {
        "AdGroups": [{
            "Id": 11111111,
            "Name": "Updated Ad Group Name",
            "RegionIds": [225, 187]
        }]
    }
}'
```

### AdGroups.delete

```bash
direct_request "adgroups" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [11111111]
        }
    }
}'
```

---

## Ads Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/ads`

**Methods:** add, update, delete, get, moderate, suspend, resume, archive, unarchive

### Ad Types

| Type | Description |
|------|-------------|
| `TEXT_AD` | Standard text ad |
| `MOBILE_APP_AD` | Mobile app ad |
| `DYNAMIC_TEXT_AD` | Dynamic text ad |
| `IMAGE_AD` | Image ad |
| `CPC_VIDEO_AD` | CPC video ad |
| `CPM_BANNER_AD` | CPM banner ad |
| `CPM_VIDEO_AD` | CPM video ad |
| `SMART_AD` | Smart banner ad |
| `SHOPPING_AD` | Shopping ad |
| `LISTING_AD` | Listing ad |

### Ads.get

```bash
# Get ads for an ad group
direct_request "ads" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "AdGroupIds": [11111111]
        },
        "FieldNames": ["Id", "AdGroupId", "CampaignId", "State", "Status", "Type"],
        "TextAdFieldNames": ["Title", "Title2", "Text", "Href", "DisplayUrlPath",
                             "Mobile", "VCardId", "SitelinkSetId", "AdImageHash",
                             "AdExtensionIds"]
    }
}'

# Get ads filtered by state
direct_request "ads" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "CampaignIds": [12345678],
            "States": ["ON"],
            "Types": ["TEXT_AD"]
        },
        "FieldNames": ["Id", "State", "Status", "Type", "StatusClarification"],
        "TextAdFieldNames": ["Title", "Text", "Href"]
    }
}'
```

**FieldNames (general):** `Id`, `AdGroupId`, `CampaignId`, `State`, `Status`, `StatusClarification`, `Type`, `Subtype`

**TextAdFieldNames:** `Title`, `Title2`, `Text`, `Href`, `Mobile`, `DisplayUrlPath`, `VCardId`, `AdImageHash`, `SitelinkSetId`, `AdExtensionIds`, `VideoExtension`, `TurboPageId`, `BusinessId`, `PreferVCardOverBusiness`

**MobileAppAdFieldNames:** `Title`, `Text`, `TrackingUrl`, `Action`, `AdImageHash`, `Features`

**DynamicTextAdFieldNames:** `Text`, `VCardId`, `AdImageHash`, `SitelinkSetId`, `AdExtensionIds`

### Ads.add

```bash
# Create a text ad
direct_request "ads" '{
    "method": "add",
    "params": {
        "Ads": [{
            "AdGroupId": 11111111,
            "TextAd": {
                "Title": "Buy Widgets Online",
                "Title2": "Free Shipping Today",
                "Text": "High quality widgets at great prices. Order now!",
                "Href": "https://example.com/widgets",
                "Mobile": "NO"
            }
        }]
    }
}'

# Create a mobile app ad
direct_request "ads" '{
    "method": "add",
    "params": {
        "Ads": [{
            "AdGroupId": 22222222,
            "MobileAppAd": {
                "Title": "Download Our App",
                "Text": "The best app for widget shopping",
                "TrackingUrl": "https://tracking.example.com/click",
                "Action": "DOWNLOAD"
            }
        }]
    }
}'
```

**MobileAppAd Action values:** `DOWNLOAD`, `GET`, `INSTALL`, `MORE`, `OPEN`, `UPDATE`, `PLAY`, `BUY_AUTODETECT`

### Ads.moderate / suspend / resume / archive / unarchive

```bash
# Submit ads for moderation
direct_request "ads" '{
    "method": "moderate",
    "params": {
        "SelectionCriteria": {
            "Ids": [33333333]
        }
    }
}'

# Suspend ads
direct_request "ads" '{
    "method": "suspend",
    "params": {
        "SelectionCriteria": {
            "Ids": [33333333]
        }
    }
}'

# Resume ads
direct_request "ads" '{
    "method": "resume",
    "params": {
        "SelectionCriteria": {
            "Ids": [33333333]
        }
    }
}'
```

---

## Keywords Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/keywords`

**Methods:** add, update, delete, get, suspend, resume

### Keywords.get

```bash
# Get keywords for an ad group
direct_request "keywords" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "AdGroupIds": [11111111]
        },
        "FieldNames": ["Id", "Keyword", "AdGroupId", "CampaignId", "Bid",
                        "ContextBid", "State", "Status", "ServingStatus",
                        "UserParam1", "UserParam2"]
    }
}'

# Get keywords by IDs
direct_request "keywords" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Ids": [44444444, 55555555]
        },
        "FieldNames": ["Id", "Keyword", "Bid", "State", "Status", "StatisticsSearchAndContext"]
    }
}'
```

**FieldNames:** `Id`, `Keyword`, `AdGroupId`, `CampaignId`, `Bid`, `ContextBid`, `StrategyPriority`, `State`, `Status`, `ServingStatus`, `UserParam1`, `UserParam2`, `StatisticsSearchAndContext`, `ProductivityL10nValue`

### Keywords.add

```bash
# Add keywords to an ad group
direct_request "keywords" '{
    "method": "add",
    "params": {
        "Keywords": [
            {
                "Keyword": "buy widgets online",
                "AdGroupId": 11111111,
                "Bid": 1500000,
                "ContextBid": 500000
            },
            {
                "Keyword": "cheap widgets",
                "AdGroupId": 11111111,
                "Bid": 1000000
            },
            {
                "Keyword": "\"exact match widgets\"",
                "AdGroupId": 11111111
            }
        ]
    }
}'
```

**Keyword match types:**
- `buy widgets` -- broad match
- `"buy widgets"` -- phrase match (quotes)
- Negative keywords are set at AdGroup or Campaign level

### Keywords.update

```bash
direct_request "keywords" '{
    "method": "update",
    "params": {
        "Keywords": [{
            "Id": 44444444,
            "Bid": 2000000,
            "ContextBid": 800000
        }]
    }
}'
```

### Keywords.suspend / resume / delete

```bash
# Suspend keywords
direct_request "keywords" '{
    "method": "suspend",
    "params": {
        "SelectionCriteria": {
            "Ids": [44444444]
        }
    }
}'

# Resume keywords
direct_request "keywords" '{
    "method": "resume",
    "params": {
        "SelectionCriteria": {
            "Ids": [44444444]
        }
    }
}'

# Delete keywords
direct_request "keywords" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [44444444, 55555555]
        }
    }
}'
```

---

## BidModifiers Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/bidmodifiers`

**Methods:** add, set, delete, get

### BidModifier Types

| Type | Description |
|------|-------------|
| `MOBILE_ADJUSTMENT` | Mobile device adjustment |
| `DESKTOP_ADJUSTMENT` | Desktop adjustment |
| `DEMOGRAPHICS_ADJUSTMENT` | Age/gender adjustment |
| `RETARGETING_ADJUSTMENT` | Retargeting list adjustment |
| `REGIONAL_ADJUSTMENT` | Regional (geo) adjustment |
| `VIDEO_ADJUSTMENT` | Video adjustment |
| `SMART_AD_ADJUSTMENT` | Smart ad adjustment |
| `INCOME_GRADE_ADJUSTMENT` | Income grade adjustment |

### BidModifiers.get

```bash
direct_request "bidmodifiers" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "CampaignIds": [12345678]
        },
        "FieldNames": ["Id", "CampaignId", "AdGroupId", "Type", "Level"],
        "MobileAdjustmentFieldNames": ["BidModifier"],
        "DemographicsAdjustmentFieldNames": ["Gender", "Age", "BidModifier"],
        "RetargetingAdjustmentFieldNames": ["RetargetingConditionId", "BidModifier"],
        "RegionalAdjustmentFieldNames": ["RegionId", "BidModifier"]
    }
}'
```

### BidModifiers.add

```bash
# Add mobile bid modifier
direct_request "bidmodifiers" '{
    "method": "add",
    "params": {
        "BidModifiers": [{
            "CampaignId": 12345678,
            "MobileAdjustment": {
                "BidModifier": 50
            }
        }]
    }
}'

# Add demographics bid modifier
direct_request "bidmodifiers" '{
    "method": "add",
    "params": {
        "BidModifiers": [{
            "CampaignId": 12345678,
            "DemographicsAdjustment": [{
                "Gender": "MALE",
                "Age": "AGE_25_34",
                "BidModifier": 120
            }]
        }]
    }
}'
```

**BidModifier values:** percentage 0-1300 (0 = do not show, 100 = no change, 120 = +20%, 50 = -50%)

### BidModifiers.set

```bash
direct_request "bidmodifiers" '{
    "method": "set",
    "params": {
        "BidModifiers": [{
            "Id": 66666666,
            "BidModifier": 150
        }]
    }
}'
```

---

## KeywordBids Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/keywordbids`

**Methods:** set, setAuto, get

### KeywordBids.get

```bash
direct_request "keywordbids" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "AdGroupIds": [11111111]
        },
        "FieldNames": ["KeywordId", "AdGroupId", "CampaignId", "Bid",
                        "ContextBid", "StrategyPriority", "ServingStatus",
                        "CompetitorsBids", "SearchPrices"]
    }
}'
```

### KeywordBids.set

```bash
# Set manual bids
direct_request "keywordbids" '{
    "method": "set",
    "params": {
        "KeywordBids": [
            {
                "KeywordId": 44444444,
                "SearchBid": 2500000,
                "NetworkBid": 1000000
            },
            {
                "KeywordId": 55555555,
                "SearchBid": 3000000
            }
        ]
    }
}'
```

### KeywordBids.setAuto

```bash
# Set auto bids (wizard)
direct_request "keywordbids" '{
    "method": "setAuto",
    "params": {
        "KeywordBids": [
            {
                "KeywordId": 44444444,
                "SearchAutoStrategy": {
                    "GoalId": 0,
                    "MaxBid": 5000000,
                    "TargetTrafficVolume": 70
                }
            }
        ]
    }
}'
```

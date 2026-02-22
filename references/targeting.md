# Targeting Services

## AudienceTargets Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/audiencetargets`

**Methods:** add, delete, suspend, resume, get, setBids

Audience targets link ad groups to retargeting lists or mobile app audience interests.

### AudienceTargets.get

```bash
source scripts/common.sh && load_config

# Get audience targets for campaigns
direct_request "audiencetargets" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "CampaignIds": [12345678]
        },
        "FieldNames": ["Id", "AdGroupId", "CampaignId", "RetargetingListId",
                        "InterestId", "State", "ContextBid", "StrategyPriority"]
    }
}'

# Get by ad group
direct_request "audiencetargets" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "AdGroupIds": [11111111]
        },
        "FieldNames": ["Id", "AdGroupId", "RetargetingListId", "State",
                        "ContextBid", "StrategyPriority"]
    }
}'
```

**FieldNames:** `Id`, `AdGroupId`, `CampaignId`, `RetargetingListId`, `InterestId`, `State`, `ContextBid`, `StrategyPriority`

### AudienceTargets.add

```bash
# Add audience target linking ad group to retargeting list
direct_request "audiencetargets" '{
    "method": "add",
    "params": {
        "AudienceTargets": [{
            "AdGroupId": 11111111,
            "RetargetingListId": 77777777,
            "ContextBid": 1500000,
            "StrategyPriority": "LOW"
        }]
    }
}'
```

**StrategyPriority values:** `LOW`, `NORMAL`, `HIGH`

### AudienceTargets.setBids

```bash
# Set bids for audience targets (max 10000 per request)
direct_request "audiencetargets" '{
    "method": "setBids",
    "params": {
        "Bids": [
            {
                "Id": 88888888,
                "ContextBid": 2000000,
                "StrategyPriority": "HIGH"
            }
        ]
    }
}'
```

### AudienceTargets.suspend / resume / delete

```bash
# Suspend audience targets
direct_request "audiencetargets" '{
    "method": "suspend",
    "params": {
        "SelectionCriteria": {
            "Ids": [88888888]
        }
    }
}'

# Resume audience targets
direct_request "audiencetargets" '{
    "method": "resume",
    "params": {
        "SelectionCriteria": {
            "Ids": [88888888]
        }
    }
}'

# Delete audience targets
direct_request "audiencetargets" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [88888888]
        }
    }
}'
```

---

## RetargetingLists Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/retargetinglists`

**Methods:** add, update, delete, get

### RetargetingLists.get

```bash
# Get all retargeting lists
direct_request "retargetinglists" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Description", "IsAvailable",
                        "ForTargetsInAdGroupTypes", "Rules"]
    }
}'

# Get specific retargeting lists by IDs
direct_request "retargetinglists" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Ids": [77777777]
        },
        "FieldNames": ["Id", "Name", "Description", "Rules"]
    }
}'
```

**FieldNames:** `Id`, `Name`, `Description`, `IsAvailable`, `ForTargetsInAdGroupTypes`, `Rules`

### RetargetingLists.add

```bash
# Create a retargeting list with rules
direct_request "retargetinglists" '{
    "method": "add",
    "params": {
        "RetargetingLists": [{
            "Name": "Visited product page",
            "Description": "Users who visited product pages in last 30 days",
            "Rules": [{
                "Operator": "ALL",
                "Goals": [{
                    "GoalId": 12345,
                    "GoalType": "GOAL",
                    "Period": 30,
                    "Operator": "GREATER_THAN_OR_EQUAL",
                    "Value": 1
                }]
            }]
        }]
    }
}'
```

**GoalType values:** `GOAL`, `SEGMENT`, `AUDIENCE`, `AB_SEGMENT`

**Rule Operator values:** `ALL` (AND between goals), `ANY` (OR between goals), `NONE` (NOT)

### RetargetingLists.update

```bash
direct_request "retargetinglists" '{
    "method": "update",
    "params": {
        "RetargetingLists": [{
            "Id": 77777777,
            "Name": "Updated retargeting list name",
            "Rules": [{
                "Operator": "ALL",
                "Goals": [{
                    "GoalId": 12345,
                    "GoalType": "GOAL",
                    "Period": 90,
                    "Operator": "GREATER_THAN_OR_EQUAL",
                    "Value": 1
                }]
            }]
        }]
    }
}'
```

### RetargetingLists.delete

```bash
direct_request "retargetinglists" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [77777777]
        }
    }
}'
```

---

## DynamicTextAdTargets Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/dynamictextadtargets`

**Methods:** add, delete, get, resume, setBids, suspend

Used for managing targeting conditions for dynamic text ads (webpage-based dynamic ads).

### DynamicTextAdTargets.get

```bash
direct_request "dynamictextadtargets" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "AdGroupIds": [11111111]
        },
        "FieldNames": ["Id", "AdGroupId", "CampaignId", "Name", "Bid",
                        "ContextBid", "StrategyPriority", "State", "Conditions",
                        "ConditionType"]
    }
}'
```

### DynamicTextAdTargets.add

```bash
# Add a dynamic ad target with URL conditions
direct_request "dynamictextadtargets" '{
    "method": "add",
    "params": {
        "Webpages": [{
            "AdGroupId": 11111111,
            "Name": "Product pages",
            "Bid": 1500000,
            "StrategyPriority": "NORMAL",
            "Conditions": [{
                "Operand": "URL",
                "Operator": "URL_CONTAINS",
                "Arguments": ["/products/"]
            }]
        }]
    }
}'
```

**Condition Operands:** `DOMAIN`, `URL`, `PAGE_TITLE`, `PAGE_CONTENT`

**Condition Operators:** `URL_CONTAINS`, `URL_NOT_CONTAINS`, `URL_EQUALS`, `CONTAINS_ALL`, `CONTAINS_ANY`, `NOT_CONTAINS_ALL`, `NOT_CONTAINS_ANY`, `EQUALS_ANY`, `NOT_EQUALS_ANY`

### DynamicTextAdTargets.setBids / suspend / resume / delete

```bash
# Set bids
direct_request "dynamictextadtargets" '{
    "method": "setBids",
    "params": {
        "Bids": [{
            "Id": 99999999,
            "Bid": 2000000,
            "ContextBid": 1000000
        }]
    }
}'

# Suspend
direct_request "dynamictextadtargets" '{
    "method": "suspend",
    "params": { "SelectionCriteria": { "Ids": [99999999] } }
}'

# Resume
direct_request "dynamictextadtargets" '{
    "method": "resume",
    "params": { "SelectionCriteria": { "Ids": [99999999] } }
}'

# Delete
direct_request "dynamictextadtargets" '{
    "method": "delete",
    "params": { "SelectionCriteria": { "Ids": [99999999] } }
}'
```

---

## SmartAdTargets Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/smartadtargets`

**Methods:** add, update, delete, get, resume, setBids, suspend

Used for managing targeting filters for smart banner campaigns (feed-based).

### SmartAdTargets.get

```bash
direct_request "smartadtargets" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "AdGroupIds": [11111111]
        },
        "FieldNames": ["Id", "AdGroupId", "CampaignId", "Name", "Bid",
                        "ContextBid", "StrategyPriority", "State",
                        "Conditions", "ConditionType", "AvailableItemsOnly"]
    }
}'
```

### SmartAdTargets.add

```bash
direct_request "smartadtargets" '{
    "method": "add",
    "params": {
        "SmartAdTargets": [{
            "AdGroupId": 11111111,
            "Name": "Expensive products",
            "Bid": 2000000,
            "StrategyPriority": "HIGH",
            "Conditions": [{
                "Operand": "PRICE",
                "Operator": "RANGE",
                "Arguments": ["5000", "50000"]
            }],
            "AvailableItemsOnly": "YES"
        }]
    }
}'
```

### SmartAdTargets.update

```bash
direct_request "smartadtargets" '{
    "method": "update",
    "params": {
        "SmartAdTargets": [{
            "Id": 99999999,
            "Name": "Updated filter name",
            "Bid": 2500000
        }]
    }
}'
```

### SmartAdTargets.setBids / suspend / resume / delete

```bash
# Set bids
direct_request "smartadtargets" '{
    "method": "setBids",
    "params": {
        "Bids": [{
            "Id": 99999999,
            "Bid": 3000000,
            "ContextBid": 1500000
        }]
    }
}'

# Suspend / resume / delete follow the same pattern as DynamicTextAdTargets
```

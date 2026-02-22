# Yandex Direct Skill for Claude Code

A Claude Code skill for working with the [Yandex Direct API v5](https://yandex.com/dev/direct/) — campaign management, ads, keywords, bids, reports, dictionaries.

## Installation

```bash
claude skill install elsvv/yandex-direct-skill
```

Or add manually to `~/.claude/skills/`:

```bash
git clone https://github.com/elsvv/yandex-direct-skill.git ~/.claude/skills/yandex-direct
```

## Setup

1. Register an app at [oauth.yandex.ru/client/new](https://oauth.yandex.ru/client/new) with `direct:api` permission.

2. Run the token setup:
```bash
bash ~/.claude/skills/yandex-direct/scripts/get_token.sh --client-id YOUR_CLIENT_ID
```

3. Verify connection:
```bash
bash ~/.claude/skills/yandex-direct/scripts/check_connection.sh
```

## What's Included

### Scripts
| Script | Purpose |
|--------|---------|
| `check_connection.sh` | Verify API token |
| `campaigns.sh` | List, get, suspend, resume, archive campaigns |
| `ads.sh` | List, get, suspend, resume, moderate, archive ads |
| `keywords.sh` | List, get, suspend, resume keywords |
| `reports.sh` | Pull statistics reports (async, TSV format) |
| `dictionaries.sh` | Get reference data (regions, currencies, etc.) |

### Campaign Stats
```bash
bash scripts/campaigns.sh --action list
bash scripts/campaigns.sh --action list --states ON,SUSPENDED
```

### Reports
```bash
bash scripts/reports.sh --type CAMPAIGN_PERFORMANCE_REPORT --date-range LAST_30_DAYS
bash scripts/reports.sh --type SEARCH_QUERY_PERFORMANCE_REPORT \
  --fields "Query,Impressions,Clicks,Ctr,AvgCpc,Cost" \
  --date-range LAST_7_DAYS
```

### Dictionaries
```bash
bash scripts/dictionaries.sh --names GeoRegions
bash scripts/dictionaries.sh --names Currencies,TimeZones
```

## API Coverage

Covers all 30 Yandex Direct API v5 services:

- **Campaign Management**: Campaigns, AdGroups, Ads, Keywords, BidModifiers, KeywordBids
- **Targeting**: AudienceTargets, RetargetingLists, DynamicTextAdTargets, SmartAdTargets
- **Extensions**: Sitelinks, AdExtensions, VCards, AdImages, AdVideos, Creatives
- **Reports**: All 8 report types, 80+ fields, async processing, TSV/CSV
- **Other**: Dictionaries, Clients, AgencyClients, Changes, Feeds, Strategies, NegativeKeywordSharedSets, TurboPages, Businesses, KeywordsResearch, Leads

See [references/](references/) for detailed API documentation:
- [campaigns.md](references/campaigns.md) — Campaigns, AdGroups, Ads, Keywords, BidModifiers, KeywordBids
- [targeting.md](references/targeting.md) — AudienceTargets, RetargetingLists, Dynamic/Smart targets
- [extensions.md](references/extensions.md) — Sitelinks, Callouts, VCards, Images, Videos, Creatives
- [reports.md](references/reports.md) — Report service, field names, date ranges, filters
- [other-services.md](references/other-services.md) — Dictionaries, Changes, Feeds, Strategies, etc.
- [use-cases.md](references/use-cases.md) — Complete bash script examples

## Requirements

- `curl` and `jq` (for formatted output and JSON processing)
- Yandex OAuth token with `direct:api` permission

## Features

- Production and Sandbox mode support
- Agency account support (Client-Login header)
- Units tracking (API rate limit points)
- Async report handling (HTTP 201/202 retry logic)

## Triggers

This skill activates on: Yandex Direct, Direct API, campaigns API, ad management API, keyword bids, Yandex advertising API, Direct reports, Direct statistics.

## License

MIT

# Extensions Services

## Sitelinks Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/sitelinks`

**Methods:** add, delete, get

Sitelinks are additional links shown with ads. Each set contains up to 8 sitelinks (links 1-4 are shown on desktop, 5-8 on mobile). Max text length: 66 characters per sitelink.

### Sitelinks.get

```bash
source scripts/common.sh && load_config

# Get all sitelink sets
direct_request "sitelinks" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Ids": [11111111, 22222222]
        },
        "FieldNames": ["Id"],
        "SitelinkFieldNames": ["Title", "Href", "Description"]
    }
}'
```

**FieldNames:** `Id`

**SitelinkFieldNames:** `Title`, `Href`, `Description`, `TurboPageId`

### Sitelinks.add

```bash
# Add a sitelink set
direct_request "sitelinks" '{
    "method": "add",
    "params": {
        "SitelinksSets": [{
            "Sitelinks": [
                {
                    "Title": "About Us",
                    "Href": "https://example.com/about",
                    "Description": "Learn more about our company"
                },
                {
                    "Title": "Pricing",
                    "Href": "https://example.com/pricing",
                    "Description": "View our pricing plans"
                },
                {
                    "Title": "Contact",
                    "Href": "https://example.com/contact",
                    "Description": "Get in touch with us"
                },
                {
                    "Title": "FAQ",
                    "Href": "https://example.com/faq",
                    "Description": "Frequently asked questions"
                }
            ]
        }]
    }
}'
```

### Sitelinks.delete

```bash
direct_request "sitelinks" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [11111111]
        }
    }
}'
```

---

## AdExtensions Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/adextensions`

**Methods:** add, delete, get

AdExtensions are callout extensions -- short phrases displayed below ads (e.g., "Free shipping", "24/7 support"). Max 25 characters per callout.

### AdExtensions.get

```bash
direct_request "adextensions" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Ids": [33333333, 44444444]
        },
        "FieldNames": ["Id", "Type", "Status", "StatusClarification",
                        "Associated"],
        "CalloutFieldNames": ["CalloutText"]
    }
}'
```

**FieldNames:** `Id`, `Type`, `Status`, `StatusClarification`, `Associated`

**CalloutFieldNames:** `CalloutText`

### AdExtensions.add

```bash
# Add callout extensions
direct_request "adextensions" '{
    "method": "add",
    "params": {
        "AdExtensions": [
            {
                "Callout": {
                    "CalloutText": "Free Shipping"
                }
            },
            {
                "Callout": {
                    "CalloutText": "24/7 Support"
                }
            },
            {
                "Callout": {
                    "CalloutText": "Money Back Guarantee"
                }
            }
        ]
    }
}'
```

### AdExtensions.delete

```bash
direct_request "adextensions" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [33333333]
        }
    }
}'
```

**Linking callouts to ads:** Set the `AdExtensionIds` field when creating/updating a TextAd:
```json
{
    "TextAd": {
        "Title": "...",
        "Text": "...",
        "Href": "...",
        "Mobile": "NO",
        "AdExtensionIds": [33333333, 44444444, 55555555]
    }
}
```

---

## VCards Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/vcards`

**Methods:** add, delete, get

VCards are virtual business cards displayed with ads -- containing phone number, address, working hours, etc.

### VCards.get

```bash
direct_request "vcards" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Ids": [55555555]
        },
        "FieldNames": ["Id", "Country", "City", "CompanyName", "Phone",
                        "Street", "House", "WorkTime", "ExtraMessage"]
    }
}'

# Get all VCards for the account
direct_request "vcards" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Country", "City", "CompanyName", "Phone",
                        "WorkTime"]
    }
}'
```

**FieldNames:** `Id`, `Country`, `City`, `CompanyName`, `Phone`, `Street`, `House`, `Building`, `Apartment`, `WorkTime`, `InstantMessenger`, `ExtraMessage`, `OgrAddress`, `MetroStationId`, `PointOnMap`, `ContactPerson`, `ContactEmail`

### VCards.add

```bash
# Add a vCard
direct_request "vcards" '{
    "method": "add",
    "params": {
        "VCards": [{
            "Country": "Russia",
            "City": "Moscow",
            "CompanyName": "My Company LLC",
            "WorkTime": "0;5;09;00;18;00",
            "Phone": {
                "CountryCode": "+7",
                "CityCode": "495",
                "PhoneNumber": "1234567",
                "Extension": ""
            },
            "Street": "Tverskaya st.",
            "House": "1",
            "ExtraMessage": "We are located in the city center"
        }]
    }
}'
```

**WorkTime format:** `start_day;end_day;start_hour;start_min;end_hour;end_min`
- Days: 0=Monday, 6=Sunday
- Example: `0;4;09;00;18;00` = Mon-Fri 09:00-18:00

**Linking VCard to ad:** Set `VCardId` when creating/updating TextAd.

### VCards.delete

```bash
direct_request "vcards" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "Ids": [55555555]
        }
    }
}'
```

---

## AdImages Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/adimages`

**Methods:** add, delete, get

### AdImages.get

```bash
direct_request "adimages" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Associated": "YES"
        },
        "FieldNames": ["AdImageHash", "OriginalUrl", "PreviewUrl", "Name",
                        "Type", "Subtype", "Associated"]
    }
}'

# Get specific images by hash
direct_request "adimages" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "AdImageHashes": ["abc123hash"]
        },
        "FieldNames": ["AdImageHash", "Name", "Type", "Associated"]
    }
}'
```

**FieldNames:** `AdImageHash`, `OriginalUrl`, `PreviewUrl`, `Name`, `Type`, `Subtype`, `Associated`

### AdImages.add

```bash
# Add image by URL
direct_request "adimages" '{
    "method": "add",
    "params": {
        "AdImages": [{
            "ImageData": null,
            "Name": "Product Banner",
            "AdImageUploadUrl": "https://example.com/images/banner.jpg"
        }]
    }
}'

# Add image from base64-encoded data
direct_request "adimages" '{
    "method": "add",
    "params": {
        "AdImages": [{
            "ImageData": "BASE64_ENCODED_IMAGE_DATA_HERE",
            "Name": "Product Logo"
        }]
    }
}'
```

**Image requirements:**
- Minimum 450x450 px for standard images
- Supported formats: JPEG, PNG, GIF (first frame)
- Max file size: 10 MB
- Widescreen images: min 1080x607 px (16:9 ratio)

**Linking image to ad:** Set `AdImageHash` when creating/updating TextAd.

### AdImages.delete

```bash
direct_request "adimages" '{
    "method": "delete",
    "params": {
        "SelectionCriteria": {
            "AdImageHashes": ["abc123hash"]
        }
    }
}'
```

---

## AdVideos Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/advideos`

**Methods:** add, delete, get

### AdVideos.get

```bash
direct_request "advideos" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {},
        "FieldNames": ["Id", "Name", "Url", "PreviewUrl", "Status", "Type"]
    }
}'
```

---

## Creatives Service

**Endpoint:** `https://api.direct.yandex.com/json/v5/creatives`

**Methods:** get (read-only)

Creatives are banner/video creatives created in the Yandex Direct interface or Creative Builder.

### Creatives.get

```bash
direct_request "creatives" '{
    "method": "get",
    "params": {
        "SelectionCriteria": {
            "Types": ["CPM_VIDEO_CREATIVE", "CPC_VIDEO_CREATIVE",
                      "CPM_HTML5_CREATIVE", "SMART_CREATIVE",
                      "TEXT_CREATIVE", "CANVAS_CREATIVE"]
        },
        "FieldNames": ["Id", "Name", "Type", "PreviewUrl",
                        "Width", "Height", "ThumbnailUrl"]
    }
}'
```

**Creative Types:** `CPM_VIDEO_CREATIVE`, `CPC_VIDEO_CREATIVE`, `CPM_HTML5_CREATIVE`, `SMART_CREATIVE`, `TEXT_CREATIVE`, `CANVAS_CREATIVE`

**FieldNames:** `Id`, `Name`, `Type`, `PreviewUrl`, `Width`, `Height`, `ThumbnailUrl`, `VideoId`, `DurationSeconds`

# doppler/http-handler

This module is the API server responsible for queuing up registrations.

### Environments

DEV = https://dev.${DOMAIN_NAME}

PROD = https://${DOMAIN_NAME}

### APIs

#### Registration

```
POST /v1/reg
```

```json
{
  "appId": "5e97220f1c9d440000f034e2",
  "wmukid": "4b7bee66-f977-4c60-a5da-be570d75d15b",
  "attuuid": "173ec1ee-3f30-478b-8d55-79c5934d6ff1",
  "wmhhid": "m1c8f4tyq2ixux5ggodwak",
  "wminid": "sg0ire3zkjhrsgwm3xwd3r",
  "brand": "example",
  "subBrand": "store",
  "domain": "example.org",
  "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:75.0) Gecko/20100101 Firefox/75.0",
  "platform": "web",
  "ip": "127.0.0.1",
  "city": "MARIETTA",
  "state": "GA",
  "zips": ["30066"],
  "country": "US",
  "library": {
    "name": "dopplerLib",
    "version": "1.0"
  },
  "cookies": {
    "portmeirion_id": "61b128b6-677e-4cf3-961b-7fbf12a6466b",
    "br_user_type": "Anonymous"
  },
  "ids": {
    // these are examples id's and not the definitive naming convention
    "kruxid": "123",
    "mid": "abc"
  },
  "session": {
    "sessionid": "000000000-00000000-00000000000-000001",
    "sessionDuration": 390820389423,
    "psmLastActiveTimestamp": "2021-03-17T20:01:45.525Z",
    "psmSessionStart": "2021-03-17T20:01:45.525Z",
    "isSessionStart": true,
    "previousSession": {
      "sessionid": "000000000-00000000-00000000000-000000",
      "sessionDuration": 390820389422,
      "psmLastActiveTimestamp": "2021-03-17T20:01:45.522Z",
      "psmSessionStart": "2021-03-17T20:01:45.522Z",
      "isSessionStart": false,
    }
  },
  "contentMetadata": {
    "page": {
      "section": "asdf",
      "author": "asdf"
    },
    "video": {
      "title": "asdf"
    }
  },
  "hhidVersion": 8
}
```

##### required fields

- `wmukid`

##### all other fields are optional fields

##### responses

```
missing or unsupported content type
- unsupported media type with a 400 returned

content size too small or too large
- invalid ContentLength with a 400 returned

missing request body
- unable to read body with a 400 returned

missing wmukid or appid
- missing required field with a 400 returned

completed successfully
- no message with a 201 returned
```

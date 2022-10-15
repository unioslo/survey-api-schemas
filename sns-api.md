
# Endpoints

This described the legacy Nettskjema-TSD API.

## Uploading data

```txt
PUT /v1/{pnum}/sns/{gpg-key-id}/{formid}
Authorization: Bearer $import_token

... mutlipart/form-data ...
```

## HTTP error responses

The follow errors can arise during data upload (not including the access token request).

### 400 - Bad Request

* Causes:
  * Empty file body
  * Malformed URI
* What to do:
  * Ensure file body is present
  * Supply correct URI

### 401 - Not Authorized

* Causes:
  * Missing `Authorization` header, or token
  * Expired token
  * Wrong project
  * Token was issued to a process with a different IP and User-Agent
* What to do:
  * Obtain a valid token for the project
  * Do not share access tokens across processes which have different client IP and User-Agent values - tokens are sender constrained

### 403 - Forbidden

* Causes:
  * HTTP method not allowed, e.g. `DELETE`
* What to do:
  * Do not use the HTTP method

### 500 - Internal Server Error

* Causes:
  * The server is down, or cannot process the request
* What to do:
  * ping in the `WEB-TSD` mattermost channel

### 503 - Service Temporarily Unavailable

* Causes:
  * The project area's NFS mount has not been made available to the API - often happens when new projects start data collection
  * Rate limiting
* What to do:
  * ping in the `WEB-TSD` mattermost channel
  * Send fewer request per second

### 504 - Gateway timeout

* Causes:
  * Too high load
* What to do:
  * ping in the `WEB-TSD` mattermost channel

### 507 - Insufficient Storage

* Causes:
  * The project's storage quota has been exceeded
* What to do:
  * ping in the `WEB-TSD` mattermost channel - fixing requires user action

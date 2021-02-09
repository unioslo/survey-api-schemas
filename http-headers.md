
## Custom HTTP headers

For efficient asynchronous data processing in TSD, programs need to be able to incrementally process new submissions. To enable this, the following headers should be included in each request involving a unique submission:

```txt
Resource-Key: metaData.submissionId
Resource-Key-Id: {submissionId}
```

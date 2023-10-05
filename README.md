
# tsd-nettskjema-integration

Documentation for the integration.

## Dev

### Update bundle

Entries of the Submission schema are split into separate files to support standalone use. A bundled file `Submission.bundle.json` is build from the individiual files.

To update the bundle:

```
make bundle
```

or

```
make podman_bundle
```

#### Requirements

* make
* node+npm or podman

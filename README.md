
# tsd-nettskjema-integration

Documentation for the integration.

## Updating new versions
One should discuss if the changes should be a version upgrade or not. If it does need a version upgrade, first make a pull request copying the old version. Then make the changes to that to prevent a huge diff which makes it harder to read where the changes is.

Regardless of editing the Form.json or Submission.json, when done updating. The version, and version_minor in both files should be updated to match each other.

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

# Update form metadata inside DB

Inserts updated metadata into tables that are missing the `generatedDate` field.

## notes

### dump test db

```
/tmp/psql/bin/pg_dump --schema "p(11|ublic)" <db url> | gzip > /tmp/pg_tsd_test_survey_db_p11.dump.gz
/tmp/psql/bin/pg_dump <db url> | gzip > /tmp/pg_tsd_test_survey_db.dump.gz
```

### local DB

```
mkdir -p pgdata
podman run -ti --rm --network host --name postgres -e POSTGRES_USER=tsd_backend_utv_auth_user -e POSTGRES_PASSWORD=password -p 5432:5432 -v ${PWD}/pgdata:/var/lib/postgresql/data docker.io/library/postgres:15.6
```

### load dump

```
podman run -ti --rm --network host -e POSTGRES_USER=tsd_backend_utv_auth_user -e POSTGRES_PASSWORD=password -v ${PWD}:/app -w /app docker.io/library/postgres:15.6 psql -U tsd_backend_utv_auth_user -h localhost -f pg_tsd_test_survey_db.dump
```

### update metadata

```
podman run -ti --rm --network host -e POSTGRES_USER=tsd_backend_utv_auth_user -e POSTGRES_PASSWORD=password -v ${PWD}:/app -w /app docker.io/library/postgres:15.6 psql -U tsd_backend_utv_auth_user -h localhost -f update_metadata.sql | tee >(gzip > update_metadata_log_$(date +"%Y%m%d").txt.gz)
```

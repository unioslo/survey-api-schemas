/* 
    This script loops through all forms for all projects
    It then looks through all of the answers, looking for
    an item in answer with the value "undefined". Any results
    are added to the results table. After all forms are queried
    it loops through the results table, and then does a query
    to find the element-type of the found items, updating the
    results table
*/

DROP TABLE undefined_fix_results;
CREATE TABLE undefined_fix_results (
    id SERIAL PRIMARY KEY,
    submission_id TEXT,
    key TEXT,
    value TEXT,
    element_type TEXT,
    project_id TEXT,
    form_id TEXT
);


-- Loop through all projects and forms. Put any "undefined" in undefined_fix_results table
DO $$
DECLARE
    project_id TEXT;
    form_id TEXT;
    query TEXT;
BEGIN
    FOR project_id IN
        SELECT nspname as project_id
        FROM pg_namespace
        WHERE nspname ~ '^p[0-9]+$'
    LOOP
        FOR form_id IN
            SELECT table_name as form_id
            FROM information_schema.tables
            WHERE table_schema = project_id
              AND table_name ~ '^[0-9]+$'
        LOOP
            query := FORMAT(
                $fmt$
                INSERT INTO undefined_fix_results (submission_id, key, value, project_id, form_id)
                SELECT data->'metadata'->'submission_id' as submission_id, n.key as key, n.value as value, %L as project_id, %L as form_id
                FROM %I.%I,
                     jsonb_each(data->'answers') AS n(key, value)
                WHERE n.value = '"undefined"';
                $fmt$,
                project_id, form_id, project_id, form_id
            );

            EXECUTE query;
        END LOOP;
    END LOOP;
END $$;

-- Loop through undefined_fix_results, lookup element-type of affected elements, then update row.
DO $$
DECLARE
    rec RECORD;
    query TEXT;
    elem_type TEXT;
BEGIN
    FOR rec IN
        SELECT *
        FROM undefined_fix_results
    LOOP
        query := FORMAT(
            $fmt$
            SELECT value->'elementType' as element_type from %I."%s/metadata",
                LATERAL jsonb_array_elements(data->'elements') as elem
                    WHERE elem->'externalElementId' = '"%s"' AND data ? 'generatedDate' ORDER BY data->'generatedDate' DESC LIMIT 1;
            $fmt$,
            rec.project_id, rec.form_id, rec.key
        );
        RAISE NOTICE '%', query;
        EXECUTE query INTO elem_type;

        UPDATE undefined_fix_results
        SET element_type = elem_type
        WHERE id = rec.id;
    END LOOP;
END $$;

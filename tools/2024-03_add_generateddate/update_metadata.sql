-- return NULL if metadata is fine already - return an updated JSON entry otherwise
create or replace function get_updated_metadata_entry(project_id text, form_id text)
returns jsonb as $$
declare
  all_metadata_jsonb jsonb;
  updated_metadata_jsonb jsonb;
  has_generated_date boolean;
  -- some constants
  key_generated_date text := 'generatedDate';
  key_modified_date text := 'modifiedDate';
  value_new_generated_date text := '2023-11-11T11:11:11.111Z';
begin
  execute format (
    $fmt$
      select array_to_json(array_agg(data)) from %s."%s_metadata"
    $fmt$
    , project_id
    , form_id
  ) into all_metadata_jsonb; -- note: result will be NULL, if num.rows == 0
  -- do we have any metadata entries?
  if (all_metadata_jsonb is null) or jsonb_array_length(all_metadata_jsonb) = 0 then
    -- raise notice 'no metadata %', form_id;
    return null;
  end if;
  -- do we already have a metadata entry with a 'generatedDate'?
  select count(*) > 0 from jsonb_array_elements(all_metadata_jsonb) metadata 
    where metadata ? key_generated_date 
    into has_generated_date;
  if (has_generated_date) then
    -- raise notice 'has_generated_date %', has_generated_date;
    return null;
  end if;
  -- now we are sure that we need to edit the metadata
  --
  -- identify the the most recent metadata entry
  select metadata from jsonb_array_elements(all_metadata_jsonb) metadata
    -- we select by modfiedDate and use a default modfiedDate whenever it's missing
    order by (('{"' || key_modified_date || '": "1970-01-01T00:00:00.000+0100"}')::jsonb || metadata) -> key_modified_date desc
    limit 1
    into updated_metadata_jsonb;
  return updated_metadata_jsonb || ('{"' || key_generated_date || '": "' || value_new_generated_date || '"}')::jsonb;
end;
$$
language plpgsql;



-- list all metadata tables for a project
create or replace function get_formids(project_id text)
returns table (form_id text) as $$
  select substring(table_name, '^(.*)_metadata$') 
    from information_schema.tables 
    where table_schema = project_id and table_name ~ '_metadata$';
$$
language sql;


-- helper type
drop type if exists e_project_source cascade;
create type e_project_source as enum ('tsd', 'ec');
-- func list all projects
create or replace function get_projectids(project_source e_project_source)
returns table (project_id text) as $$
  select schema_name
    from information_schema.schemata 
    where case when project_source = 'tsd' then schema_name ~  '^p[0-9]+$'
               when project_source = 'ec'  then schema_name ~ '^ec[0-9]+$'
               else false
          end
$$
language sql;


-- just print form IDs that need an update
create or replace procedure loop_projects(project_source e_project_source, dry_run boolean)
language plpgsql
as $$
declare temprow record;
begin
  
  for temprow in
  (
    select * from 
    (
      with project_ids(project_id) as (
        select get_projectids('tsd')
        -- values('p11')
      )
      select formids.form_id, project_id, get_updated_metadata_entry(project_id, form_id) as info 
      from (
        select project_id, get_formids(project_id) from project_ids
        -- values ('p11', '1209610')
      ) as formids(project_id, form_id)
    ) as tmp_inner
    where info is not null
  )
  loop
    raise notice ' dry_run=% project=% form=% updated_metadata=%', dry_run, temprow.project_id, temprow.form_id, temprow.info;
    if (dry_run is not true) then
      execute format (
        $fmt$
          insert into %s."%s_metadata" ("data") values ('%s')
        $fmt$
        , temprow.project_id
        , temprow.form_id
        , temprow.info
      );
    end if;
  end loop;
end
$$;

create or replace procedure update_all_metadata(project_source e_project_source)
language plpgsql
as $$
begin 
  call loop_projects(project_source, false);
end
$$;

create or replace procedure make_report(project_source e_project_source)
language plpgsql
as $$
begin 
  call loop_projects(project_source, true);
end
$$;



call make_report('tsd');
-- call update_all_metadata('tsd');



drop type if exists e_project_source cascade;
drop procedure if exists update_all_metadata cascade;
drop procedure if exists make_report cascade;
drop function if exists get_formids cascade;
drop function if exists get_projectids cascade;
drop function if exists get_updated_metadata_entry cascade;

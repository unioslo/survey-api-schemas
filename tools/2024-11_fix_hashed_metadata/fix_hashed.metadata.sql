-- Type used for outputting results
drop type if exists respondent_count_type cascade;
create type respondent_count_type as (
	project_id text,
	form_id text,
	respondent_count_before integer,
	respondent_count_after integer

);

-- Function removes all respondents from data for submissions for the given project and submission.
-- It outputs the count of respondents before and after running. 
-- If run with dry_run = true, it will not perform the update.
create or replace function fix_respondent_in_metadata(project_id text, form_id text, dry_run boolean)
returns respondent_count_type as $$
declare 
	result respondent_count_type;
	before_count integer;
	after_count integer;
begin
	execute format(
		$fmt$
			select count(0) from %s."%s"
				where data ? 'metadata' and ( data -> 'metadata' ? 'respondent')
		$fmt$
		, project_id
		, form_id
	) into before_count;
	if (dry_run is not true) then
		raise notice 'Stripping respondent for project % form %', project_id, form_id;
		execute format(
			$fmt$
				update %s."%s"
				set data = data::jsonb #- '{metadata,respondent}' 
				where data ? 'metadata' 
					and ( data -> 'metadata' ? 'respondent')
			$fmt$
			, project_id
			, form_id
		);
	end if;

	execute format(
		$fmt$
			select count(0) from %s."%s"
				where data ? 'metadata' and ( data -> 'metadata' ? 'respondent')
		$fmt$
		, project_id
		, form_id
	) into after_count;

	return (project_id, form_id, before_count, after_count);
end $$ language plpgsql;


-- p896
select * from fix_respondent_in_metadata('p896', '344335', true);
select * from fix_respondent_in_metadata('p896', '347973', true);
select * from fix_respondent_in_metadata('p896', '386498', true);

-- p1336
select * from fix_respondent_in_metadata('p1336', '205339', true);
select * from fix_respondent_in_metadata('p1336', '220418', true);
select * from fix_respondent_in_metadata('p1336', '221197', true);
select * from fix_respondent_in_metadata('p1336', '358479', true);
select * from fix_respondent_in_metadata('p1336', '358484', true);
select * from fix_respondent_in_metadata('p1336', '358486', true);

-- p2731
select * from fix_respondent_in_metadata('p2731', '367084', true);
select * from fix_respondent_in_metadata('p2731', '367277', true);

-- p2525
select * from fix_respondent_in_metadata('p2525', '371198', true);
select * from fix_respondent_in_metadata('p2525', '377224', true);
select * from fix_respondent_in_metadata('p2525', '377898', true);
select * from fix_respondent_in_metadata('p2525', '388300', true);
select * from fix_respondent_in_metadata('p2525', '388303', true);
select * from fix_respondent_in_metadata('p2525', '394394', true);
select * from fix_respondent_in_metadata('p2525', '394397', true);
select * from fix_respondent_in_metadata('p2525', '394398', true);
select * from fix_respondent_in_metadata('p2525', '394400', true);
select * from fix_respondent_in_metadata('p2525', '415005', true);

-- Cleanup
drop function if exists fix_respondent_in_metadata;
drop type if exists respondent_count_type;


CREATE
OR REPLACE FUNCTION public.me(hasura_session json) RETURNS SETOF volunteer LANGUAGE sql STABLE AS $function$
select
  *
from
  volunteer
where
  uid = (hasura_session ->> 'x-hasura-user-id') :: uuid $function$;

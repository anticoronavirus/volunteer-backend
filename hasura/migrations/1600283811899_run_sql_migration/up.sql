CREATE or replace FUNCTION check_if_satisfied(hpr_row hospital_profession_requirement, hasura_session json)
RETURNS BOOLEAN AS $$
SELECT EXISTS (
    SELECT 1
    FROM volunteer_hospital_requirement
    WHERE volunteer_hospital_requirement.volunteer_id = (hasura_session ->> 'x-hasura-user-id')::uuid
    AND volunteer_hospital_requirement.hospital_id = hpr_row.hospital_id
    AND volunteer_hospital_requirement.requirement_id = hpr_row.requirement_id
);
$$ LANGUAGE sql STABLE;

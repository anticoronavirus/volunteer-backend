
CREATE OR REPLACE VIEW "public"."me" AS 
 SELECT volunteer.uid,
    volunteer.fname,
    volunteer.mname,
    volunteer.lname,
    volunteer.phone,
    volunteer.email,
    volunteer.role,
    volunteer.password,
    volunteer.hospital_id,
    volunteer.comment,
    volunteer.created_at,
    volunteer.updated_at,
    volunteer.is_hatching,
    volunteer.profession,
    volunteer.car,
    volunteer.licenceplate
   FROM volunteer;
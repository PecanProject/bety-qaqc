SELECT
    count(*)
FROM
	traits_and_yields_view_private
WHERE
	treatment_id IS NOT NULL
AND treatment_id != 0
AND NOT EXISTS (
	SELECT
		1
	FROM
		treatments
	WHERE
		ID = treatment_id
);

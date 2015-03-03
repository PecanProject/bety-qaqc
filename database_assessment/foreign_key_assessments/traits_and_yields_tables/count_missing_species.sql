SELECT
    count(*)
FROM
	traits_and_yields_view_private
WHERE
	species_id IS NOT NULL
AND species_id != 0
AND NOT EXISTS (
	SELECT
		1
	FROM
		species
	WHERE
		ID = species_id
);

SELECT
    count(*)
FROM
	traits_and_yields_view_private
WHERE
	cultivar_id IS NOT NULL
AND cultivar_id != 0
AND NOT EXISTS (
	SELECT
		1
	FROM
		cultivars
	WHERE
		ID = cultivar_id
);

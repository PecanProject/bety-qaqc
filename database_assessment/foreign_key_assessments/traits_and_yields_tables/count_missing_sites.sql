SELECT
    count(*)
FROM
	traits_and_yields_view_private
WHERE
	site_id IS NOT NULL
AND site_id != 0
AND NOT EXISTS (
	SELECT
		1
	FROM
		sites
	WHERE
		ID = site_id
);

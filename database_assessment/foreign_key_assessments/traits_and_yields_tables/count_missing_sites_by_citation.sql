SELECT
	citation_id AS "Citation id", author, year, count(*), array_agg(distinct site_id) AS "List of site ids", array_agg(distinct login) AS "List of user logins"
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
)
GROUP BY
    citation_id, author, year
ORDER BY
    author,
	year;

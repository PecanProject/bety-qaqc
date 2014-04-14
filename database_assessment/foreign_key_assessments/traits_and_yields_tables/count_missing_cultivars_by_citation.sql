SELECT
	citation_id AS "Citation id", author, year, count(*), array_agg(distinct cultivar_id) AS "List of cultivar ids", array_agg(distinct login) AS "List of user logins"
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
)
GROUP BY
    citation_id, author, year
ORDER BY
    author,
	year;

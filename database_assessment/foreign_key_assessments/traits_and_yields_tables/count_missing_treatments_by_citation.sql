SELECT
	citation_id AS "Citation id", author, citation_year AS year, count(*), array_agg(distinct treatment_id) AS "List of treatment ids", array_agg(distinct login) AS "List of user logins"
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
)
GROUP BY
    citation_id, author, citation_year
ORDER BY
    author,
	year;

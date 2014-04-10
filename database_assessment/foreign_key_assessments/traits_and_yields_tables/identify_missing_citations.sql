SELECT
	citation_id AS "Citation ID", sitename AS "Site Name", city AS "Site city", scientificname AS "Species", trait, year, month, name, login, email, checked
FROM
	traits_and_yields_view_private
WHERE
	citation_id IS NOT NULL
AND NOT EXISTS (
	SELECT
		1
	FROM
		citations
	WHERE
		ID = citation_id
);

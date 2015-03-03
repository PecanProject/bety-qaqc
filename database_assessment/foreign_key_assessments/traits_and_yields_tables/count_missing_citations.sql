SELECT
	count(*)
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

\t
SELECT 'This is a list of groups of citations having matching author, year, and title showing lists of the ids of the associated rows from other tables.';
\t
\x
SELECT c.id, c.author, c.year, c.title,
    ARRAY_AGG(DISTINCT cs.site_id) AS "sites",
    ARRAY_AGG(DISTINCT ct.treatment_id) AS "treatments",
    ARRAY_AGG(DISTINCT m.id) AS "managements",
    ARRAY_AGG(DISTINCT me.id) AS "methods",
    ARRAY_AGG(DISTINCT p.id) AS "priors",
    ARRAY_AGG(DISTINCT t.id) AS "traits",
    ARRAY_AGG(DISTINCT y.id) AS "yields"
FROM
    (SELECT * FROM citations ccc WHERE EXISTS( SELECT 1 FROM citations cc WHERE cc.id!=ccc.id AND cc.author = ccc.author AND cc.year = ccc.year AND cc.title = ccc.title)) AS c
        LEFT JOIN citations_sites cs ON cs.citation_id = c.id
        LEFT JOIN citations_treatments ct ON ct.citation_id = c.id
        LEFT JOIN managements m ON m.citation_id = c.id
        LEFT JOIN methods me ON me.citation_id = c.id
        LEFT JOIN priors p ON p.citation_id = c.id
        LEFT JOIN traits t ON t.citation_id = c.id
        LEFT JOIN yields y ON y.citation_id = c.id
GROUP BY c.id, c.author, c.year, c.title
ORDER BY c.author, c.year, c.title, c.id;

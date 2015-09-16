\t
SELECT 'This is a list of groups of citations having matching author, year, and title showing the number of associated rows from other tables.';
\t
SELECT c.id, c.author, c.year, SUBSTRING(c.title, 1, 10) AS "title",
    COUNT(DISTINCT cs.site_id) AS "sites",
    COUNT(DISTINCT ct.treatment_id) AS "treatments",
    COUNT(DISTINCT m.id) AS "managements",
    COUNT(DISTINCT me.id) AS "methods",
    COUNT(DISTINCT p.id) AS "priors",
    COUNT(DISTINCT t.id) AS "traits",
    COUNT(DISTINCT y.id) AS "yields"
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

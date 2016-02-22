# Queries

```` sql
SELECT judge ,count(DISTINCT id) AS page_count
FROM utah_court_calendar_page_headers
GROUP BY 1
ORDER BY 2 DESC; -- 235 rows
````

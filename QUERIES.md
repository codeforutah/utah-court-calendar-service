# Queries

```` sql
SELECT judge ,count(DISTINCT id) AS page_count
FROM utah_court_calendar_page_headers
GROUP BY 1
ORDER BY 2 DESC; -- 235 rows
````

```` sql
SELECT
 c.type AS court_type
 ,c.name AS court_name
 ,cals.url AS calendar_url
 ,cals.created_at::DATE AS calendar_date
 ,cals.page_count AS calendar_page_count
 ,e.court_room
 ,e.date AS court_date
 ,e.time AS court_time
 ,e.hearing_type
  ,e.case_number
  ,e.case_type
  ,e.prosecution
  ,e.prosecuting_attorney
  ,e.prosecuting_agency_number
  ,e.defendant
  ,e.defense_attorney
  ,e.defendant_offender_tracking_number
  ,e.defendant_date_of_birth
  ,e.citation_number
  ,e.sheriff_number
  ,e.law_enforcement_agency_number
  ,e.case_efiled
  ,e.domestic_violence
  ,e.warrant_outstanding
  ,e.small_claims_amount
FROM utah_courts c
JOIN utah_court_calendars cals ON cals.utah_court_id = c.id
JOIN utah_court_calendar_events e ON e.utah_court_calendar_id = cals.id
WHERE c.name LIKE '%Salt Lake%'
  AND e.court_room IS NOT NULL
  AND e.prosecuting_attorney NOT LIKE '%[%'
  AND e.defense_attorney NOT LIKE '%[%'
  AND e.case_number NOT LIKE '%ATTY%'
  AND e.defendant != e.defense_attorney
  AND (e.time LIKE '%AM%' OR e.time LIKE '%PM%')
  AND e.case_type NOT LIKE '%,%'
  AND e.prosecuting_agency_number NOT LIKE '%CASE EFILED%'
  AND e.prosecuting_agency_number NOT LIKE '%LEA%'
  AND length(e.time) = 8
LIMIT 250;
````

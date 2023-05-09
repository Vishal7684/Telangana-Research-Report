use telangana;

#Query 1
# Finding top 10 districts that have highest number of domestic visitors (2016 - 2019)
SELECT district, SUM(visitors) as total_visitors, year
FROM domestic_visitors_telangana
GROUP BY district, year
ORDER BY total_visitors DESC
LIMIT 10;

#Query 2
#CAGR from 2016-2019 (3 years)
#CAGR formula is (FV/IV)^(1/n) -1   n = 2019 -2016 = 3

# Finding CAGR for Domestic Visitors
with Domestic_CAGR as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as Intial_value,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as Future_value	 #all the visitors from 2019 district wise
from domestic_visitors_telangana
group by district
)
select district,Intial_value,Future_value, round((power((Future_value/Intial_value),1/3)-1)*100,2) as CAGR
from Domestic_CAGR
order by CAGR desc limit 3;


# Finding CAGR for Foreign Visitors
with Foreign_CAGR as(
select district, 
sum(case when year = 2016 then visitors else 0 End) as Intial_value, #All visitors from 2016
sum(case when year = 2019 then visitors else 0 End) as Future_value #All visitors from 2019
from foreign_visitors_telangana
Group by district)
select district, Intial_value, Future_value, round((power((Future_value/Intial_value),1/3)) * 100,2) as CAGR
from Foreign_CAGR
Order by CAGR desc
limit 3;


# Finding Districts that are declining in terms of CAGR. ( Domestic Visitors)
WITH Domestic_CAGR AS (
  SELECT 
    district,
    SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS Intial_value, -- All visitors from 2016
    SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS Future_value -- All visitors from 2019
  FROM domestic_visitors_telangana
  GROUP BY district
),
Domestic_CAGR2 AS (
  SELECT 
    district, 
    Intial_value, 
    Future_value, 
    ROUND((POWER((Future_value/Intial_value),1/3) - 1) * 100,2) AS CAGR
  FROM Domestic_CAGR
)
SELECT * 
FROM Domestic_CAGR2
WHERE CAGR IS NOT NULL
ORDER BY CAGR 
LIMIT 3;


# Finding Districts that are declining in terms of CAGR. (Foreign Visitors)
WITH Foreign_CAGR AS (
  SELECT 
    district,
    SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS Intial_value, -- All visitors from 2016
    SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS Future_value -- All visitors from 2019
  FROM Foreign_visitors_telangana
  GROUP BY district
),
Foreign_CAGR2 AS (
  SELECT 
    district, 
    Intial_value, 
    Future_value, 
    ROUND((POWER((Future_value/Intial_value),1/3) - 1) * 100,2) AS CAGR
  FROM Foreign_CAGR
)
SELECT * 
FROM Foreign_CAGR2
WHERE CAGR IS NOT NULL
ORDER BY CAGR 
LIMIT 3;

# Query 3
#Peak season months for hyderabad from 2016-2019 ( foreign_visitors_telangana)
SELECT month,Sum(visitors) as peak_seasons
From foreign_visitors_telangana
Where district =  'Hyderabad'
Group by month
Order by peak_seasons desc
limit 3;

# Peak season months for hyderabad from 2016-2019 ( domestic_visitors_telangana)
SELECT month, SUM(visitors) as peak_season
From domestic_visitors_telangana
Where district =  'Hyderabad'
Group by month
Order by peak_season desc
limit 3;

# low season for domestic visitors (hyderabad)
SELECT month, SUM(visitors) as low_season
From domestic_visitors_telangana
Where district =  'Hyderabad'
Group by month
Order by low_season ASC
limit 3;

#Query 4
#Finding top domestic to foreign ratio districts
WITH DtoF AS (
  SELECT 
    domestic_visitors_telangana.district, 
    SUM(domestic_visitors_telangana.visitors) AS Domestic_visitors,
    SUM(foreign_visitors_telangana.visitors) AS Foreign_visitors
  FROM 
    domestic_visitors_telangana 
    JOIN foreign_visitors_telangana 
      ON domestic_visitors_telangana.district = foreign_visitors_telangana.district 
        AND domestic_visitors_telangana.year = foreign_visitors_telangana.year 
        AND domestic_visitors_telangana.month = foreign_visitors_telangana.month
  GROUP BY 
    domestic_visitors_telangana.district
)
SELECT 
  district, 
  Domestic_visitors, 
  Foreign_visitors, 
  DtoF_Ratio
FROM (
  SELECT 
    *, 
    ROUND(Domestic_visitors/Foreign_visitors) AS DtoF_Ratio 
  FROM 
    DtoF 
  ORDER BY 
    DtoF_Ratio ASC
) AS sorted_data
WHERE DtoF_Ratio is Not Null
Limit 3;


#Finding bottom domestic to foreign ratio districts
WITH DtoF AS (
  SELECT 
    domestic_visitors_telangana.district, 
    SUM(domestic_visitors_telangana.visitors) AS Domestic_visitors,
    SUM(foreign_visitors_telangana.visitors) AS Foreign_visitors
  FROM 
    domestic_visitors_telangana 
    JOIN foreign_visitors_telangana 
      ON domestic_visitors_telangana.district = foreign_visitors_telangana.district 
        AND domestic_visitors_telangana.year = foreign_visitors_telangana.year 
        AND domestic_visitors_telangana.month = foreign_visitors_telangana.month
  GROUP BY 
    domestic_visitors_telangana.district
)
SELECT 
  district, 
  Domestic_visitors, 
  Foreign_visitors, 
  DtoF_Ratio
FROM (
  SELECT 
    *, 
    ROUND(Domestic_visitors/Foreign_visitors) AS DtoF_Ratio 
  FROM 
    DtoF 
  ORDER BY 
    DtoF_Ratio DESC
) AS subquery
WHERE DtoF_Ratio is Not Null
Limit 3;

#Query 5 Population to tourist footfall ratio in 2019
#Query 6 Estimate population for hyderabad in 2025
#2019 Population - 38427769, 2011 Population - 35286757
# To estimate population growth from 2011 to 2019:
-- 2019_population - 2011_population = increase_population

# To calculate annual growth rate:
-- increase_population / 2011_population = growth_rate

# To convert growth rate to percentage:
-- (growth_rate * 100) / years = annual_growth_percentage

# For example, with 8 years of growth:
-- (growth_rate * 100) / 8 = annual_growth_percentage
# To estimate population for a future year (e.g. 2025) with yearly growth rate of 1.11%:

#Adding new columns
UPDATE population_2011 
SET Estimated_2019 = ROUND(Population_2011 * POWER(1.11, 8)), # Creating new column Estimated population for 2019
    Estimated_2025 = ROUND(Population_2011 * POWER(1.11, 14));  # Creating new column Estimated population for 2025

# Merging both domestic and foreign to find footfall ration for both
SELECT district, year, visitors
FROM domestic_visitors_telangana
UNION ALL
SELECT district, year, visitors
FROM foreign_visitors_telangana;

#Query 5
#Population to tourist 'Footfall Ratio' in 2019 -> Ratio = TotalVisitors/TotalPopulation in 2019 (Top 3)
SELECT 
  population_2011.District, 
  (SUM(domestic_visitors_telangana.visitors) + SUM(foreign_visitors_telangana.visitors)) / population_2011.Estimated_2019 AS footfall_ratio
FROM domestic_visitors_telangana
JOIN population_2011 ON population_2011.District = domestic_visitors_telangana.district
JOIN foreign_visitors_telangana ON domestic_visitors_telangana.district = foreign_visitors_telangana.district AND domestic_visitors_telangana.year = foreign_visitors_telangana.year
WHERE domestic_visitors_telangana.year = 2019
GROUP BY population_2011.District, population_2011.Estimated_2019
ORDER BY footfall_ratio DESC
LIMIT 3;

#Population to tourist 'Footfall Ratio' in 2019 -> Ratio = TotalVisitors/TotalPopulation in 2019 (bottom 3)
SELECT 
  domestic_visitors_telangana.district, 
  (SUM(domestic_visitors_telangana.visitors) + SUM(foreign_visitors_telangana.visitors)) / population_2011.Estimated_2019 AS footfall_ratio
FROM domestic_visitors_telangana
JOIN population_2011 ON domestic_visitors_telangana.district = population_2011.District
JOIN foreign_visitors_telangana ON domestic_visitors_telangana.district = foreign_visitors_telangana.district AND domestic_visitors_telangana.year = foreign_visitors_telangana.year
WHERE domestic_visitors_telangana.year = 2019
GROUP BY domestic_visitors_telangana.district, population_2011.Estimated_2019
Having footfall_ratio > 1
ORDER BY footfall_ratio ASC
LIMIT 3;

# Query 6 Projected  number of domestic visitors and project number of revenue from them
WITH cte AS (
  SELECT 
    district,
    SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS visitors_2016, -- all visitors from 2016 district wise
    SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS visitors_2019 -- all visitors from 2019 district wise
  FROM domestic_visitors_telangana
  GROUP BY district
  HAVING district = 'Hyderabad'
),
cte2 AS (
  SELECT 
    visitors_2019 AS dom_visitors_2019,
    (POWER((visitors_2019/visitors_2016),(1/3))-1) AS AGR -- AGR = -0.16
  FROM cte
)
SELECT 
  dom_visitors_2019 as Visitors_2019,
  dom_visitors_2019 * 1200 AS Revenue_2019,
  ROUND(dom_visitors_2019 * POWER((1-0.16),6)) AS Visitors_2025,
  ROUND(dom_visitors_2019 * POWER((1-0.16),6)) * 1200 AS Revenue_2025
FROM cte2;


#Projected  number of foreign visitors and project number of revenue from them
WITH cte AS (
  SELECT 
    district,
    SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS visitors_2016, -- all visitors from 2016 district wise
    SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS visitors_2019 -- all visitors from 2019 district wise
  FROM foreign_visitors_telangana
  GROUP BY district
  HAVING district = 'Hyderabad'
),
cte2 AS (
  SELECT 
    visitors_2019 AS Foreign_visitors_2019,
    (POWER((visitors_2019/visitors_2016),(1/3))-1) AS AGR -- AGR = -0.16
  FROM cte
)
SELECT 
  Foreign_visitors_2019 as Visitors_2019,
  Foreign_visitors_2019 * 1200 AS Revenue_2019,
  ROUND(Foreign_visitors_2019 * POWER((1-0.16),6)) AS Visitors_2025,
  ROUND(Foreign_visitors_2019 * POWER((1-0.16),6)) * 1200 AS Revenue_2025
FROM cte2;







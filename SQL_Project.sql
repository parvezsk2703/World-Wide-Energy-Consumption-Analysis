CREATE DATABASE ENERGYDB;
USE ENERGYDB;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;



-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

-- Creating relationships with country
ALTER TABLE emission_3
add foreign key (country) references country(Country);

ALTER TABLE population
add foreign key (countries) references country(Country);

ALTER TABLE production
add foreign key (country) references country(Country);

ALTER TABLE gdp_3
add foreign key (country) references country(Country);

ALTER TABLE consumption
add foreign key (Country) references country(Country);

-- General & Comparative Analysis
-- 1)What is the total emission per country for the most recent year available?
select country,sum(emission) as total_emission
from emission_3
where year=(select max(year) from emission_3)
group by country
order by total_emission DESC;

-- 2)What are the top 5 countries by GDP in the most recent year?
select country,value from gdp_3
where year=(select max(year) from gdp_3)
order by value DESC
limit 5;

-- 3)Compare energy production and consumption by country and year. 
select p.country,p.year,sum(p.production) as total_production,
sum(c.consumption) as total_consumption 
from production p
join consumption c
on p.country=c.country AND p.year=c.year
group by p.country,p.year;

-- 4)Which energy types contribute most to emissions across all countries?
select energy_type, sum(emission) as total_emission
from emission_3
group by energy_type
order by total_emission DESC;


-- Trend Analysis Over Time
-- 1)How have global emissions changed year over year?
SELECT YEAR, 
	   SUM(EMISSION) FROM EMISSION_3
group by YEAR
order by YEAR;


-- 2)What is the trend in GDP for each country over the given years?
select country,year,value from gdp_3
order by country,year;


-- 3)How has population growth affected total emissions in each country?
select e.country, e.year,p.value as population,
sum(e.emission) as total_emission
from emission_3 e
join population p
on e.country = p.countries AND e.year=p.year
group by e.country,e.year,p.value
order by e.country,e.year;


-- 4)Has energy consumption increased or decreased over the years for major economies?
select country,year,sum(consumption) AS total_consumption
from consumption
where country in ('United States','China','India','Germany','Japan')
GROUP BY country, year
ORDER BY country, year;


-- 5)What is the average yearly change in emissions per capita for each country?
select country,avg(per_capita_emission) AS avg_per_capita_emission
from emission_3
GROUP BY country
ORDER BY avg_per_capita_emission DESC;


-- Ratio & Per Capita Analysis
-- 1)What is the emission-to-GDP ratio for each country by year?
SELECT e.country,e.year,SUM(e.emission) / g.value AS emission_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
ON e.country = g.country AND e.year = g.year
GROUP BY e.country, e.year, g.value
ORDER BY emission_gdp_ratio DESC;


-- 2)What is the energy consumption per capita for each country over the last decade?
SELECT c.country,c.year,SUM(c.consumption) / p.value AS consumption_per_capita
FROM consumption c
JOIN population p
ON c.country = p.countries AND c.year = p.year
WHERE c.year >= (SELECT MAX(year) - 10 FROM consumption)
GROUP BY c.country, c.year, p.value
ORDER BY c.country, c.year;

-- 3)How does energy production per capita vary across countries?
SELECT pr.country,pr.year,SUM(pr.production) / p.value AS production_per_capita
FROM production pr
JOIN population p
ON pr.country = p.countries AND pr.year = p.year
GROUP BY pr.country, pr.year, p.value
ORDER BY production_per_capita DESC;

-- 4)Which countries have the highest energy consumption relative to GDP?
SELECT c.country,c.year,SUM(c.consumption) / g.value AS consumption_gdp_ratio
FROM consumption c
JOIN gdp_3 g
ON c.country = g.country AND c.year = g.year
GROUP BY c.country, c.year, g.value
ORDER BY consumption_gdp_ratio DESC;

-- 5)What is the correlation between GDP growth and energy production growth?
SELECT g.country,g.year,g.value AS gdp,SUM(p.production) AS total_production
FROM gdp_3 g
JOIN production p
ON g.country = p.country AND g.year = p.year
GROUP BY g.country, g.year, g.value
ORDER BY g.country, g.year;


-- Global Comparisons

-- 1)What are the top 10 countries by population and how do their emissions compare?
SELECT p.countries,p.value AS population,SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e
ON p.countries = e.country AND p.year = e.year
GROUP BY p.countries, p.value
ORDER BY population DESC
LIMIT 10;

-- 2)Which countries have improved (reduced) their per capita emissions the most over the last decade?
SELECT country,MAX(per_capita_emission) - MIN(per_capita_emission) AS emission_reduction
FROM emission_3
WHERE year >= (SELECT MAX(year) - 10 FROM emission_3)
GROUP BY country
ORDER BY emission_reduction DESC;

-- 3)What is the global share (%) of emissions by country?
SELECT country,
	   SUM(emission) * 100 / 
       (SELECT SUM(emission) FROM emission_3) AS emission_share_percentage
FROM emission_3
GROUP BY country
ORDER BY emission_share_percentage DESC;

-- 4)What is the global average GDP, emission, and population by year?
SELECT g.year,AVG(g.value) AS avg_gdp,AVG(e.emission) AS avg_emission,AVG(p.value) AS avg_population
FROM gdp_3 g
JOIN emission_3 e
ON g.country = e.country AND g.year = e.year
JOIN population p
ON g.country = p.countries AND g.year = p.year
GROUP BY g.year
ORDER BY g.year;



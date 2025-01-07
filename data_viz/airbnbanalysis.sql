-- SAN DIEGO AIRBNB ANALYSIS

-- Questions of Interest:
-- 1. Which neighborhoods have the highest and lowest listings?
-- 2. What are the most expensive and least expensive neighborhoods?
-- 3. Who is the host with the most listings?
-- 4. Which months are the most popular to book?

select * from listings;

-- which neighborhoods have the highest and lowest listings **
SELECT neighbourhood_cleansed, count(*) AS num_listings
FROM listings
GROUP BY neighbourhood_cleansed
ORDER BY num_listings DESC;

-- what are the most expensive and least expensive neighborhoods **
SELECT neighbourhood_cleansed,
       AVG(CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS DECIMAL(10, 2))) AS avg_price
FROM listings
GROUP BY neighbourhood_cleansed
ORDER BY avg_price DESC;

-- hosts with most listings **
SELECT host_id, host_name, host_neighbourhood,
	count(*) as num_listings
FROM listings
GROUP BY host_neighbourhood, host_id, host_name
ORDER BY num_listings DESC;

-- which months are the most popular to book in top 5 neighborhoods?
SELECT 
    MONTH(last_review) AS month,
    COUNT(name) AS num_reviews
FROM 
    listings
WHERE
    last_review IS NOT NULL
    AND neighbourhood_cleansed IN ('La Jolla', 'Mission Bay', 'North Hills', 'Ocean Beach', 'Pacific Beach')
GROUP BY 
    MONTH(last_review)
ORDER BY 
    num_reviews DESC;

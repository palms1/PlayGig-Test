-- Step 1: Filter purchases from the past 30 days and join with Players to get country
WITH recent_purchases AS (
    SELECT 
        players.country,
        COALESCE(purchases.amount, 0) AS amount  -- Handle potential NULL values in amount
    FROM 
        purchases
    JOIN 
        players ON purchases.player_id = players.player_id
    WHERE 
        purchases.purchase_time::date > CURRENT_DATE - INTERVAL '30 days'
),
amount_country AS (
-- Step 2: Sum purchase amounts by country
SELECT 
    country,
    SUM(amount) AS total_revenue
FROM 
    recent_purchases
WHERE
    country IS NOT NULL  -- Exclude records with NULL country
GROUP BY 
    country
),
-- Step 3: Rank Countries by total revenue Descending
ranking_country AS (
SELECT
	country,
	total_revenue,
	ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as Ranking
FROM
	amount_country
)
-- Step 4: Select Countries ranked above 10
SELECT
 country,
 total_revenue
FROM 
	ranking_country
WHERE 
	ranking <= 10;
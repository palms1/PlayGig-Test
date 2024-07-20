-- Step 1: Filter purchases from the past 30 days, calculate ARPU and group by Purchase_Date
SELECT 
	purchase_time::date as Purchase_Date,
    SUM(COALESCE(purchases.amount, 0)) / COUNT(DISTINCT player_id) AS ARPU  -- Handle potential NULL values in amount
FROM 
    purchases
WHERE 
    purchase_time::date > CURRENT_DATE - INTERVAL '30 days'
GROUP BY 
	Purchase_Date
ORDER BY 
	Purchase_Date DESC;
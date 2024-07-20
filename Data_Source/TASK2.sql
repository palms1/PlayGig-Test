-- Step 1: Select player signups and convert signup_date to a date type
WITH signups AS (
    SELECT 
        player_id, 
        signup_date::date AS signup_date
    FROM 
        players
),

-- Step 2: Select player sessions and convert start_time to a date type
sessions AS (
    SELECT 
        player_id, 
        start_time::date AS session_date
    FROM 
        sessions
),

-- Step 3: Calculate retention metrics by month
retention AS (
    SELECT 
        -- Convert signup_date to YYYYMM format to aggregate by month
        TO_CHAR(signup_date, 'YYYYMM') as signup_month,
        
        COUNT(DISTINCT s.player_id) AS signups,

        -- Calculate 1-day retention: players who return exactly 1 day after signup
        COUNT(DISTINCT CASE WHEN sess.session_date = s.signup_date + INTERVAL '1 day' THEN s.player_id END) AS day_1_retention,

        -- Calculate 7-day retention: players who return exactly 7 days after signup
        COUNT(DISTINCT CASE WHEN sess.session_date = s.signup_date + INTERVAL '7 days' THEN s.player_id END) AS day_7_retention,

        -- Calculate 30-day retention: players who return exactly 30 days after signup
        COUNT(DISTINCT CASE WHEN sess.session_date = s.signup_date + INTERVAL '30 days' THEN s.player_id END) AS day_30_retention
    FROM 
        signups s
    LEFT JOIN 
        sessions sess 
        ON s.player_id = sess.player_id 
        AND sess.session_date BETWEEN s.signup_date AND s.signup_date + INTERVAL '30 days'
    GROUP BY 
        signup_month
)

-- Step 4: Select the retention rates and calculate them as percentages
SELECT 
    signup_month,
    
    signups,
    
    -- Number of players retained after 1 day
    day_1_retention,    
    -- Calculate 1-day retention rate as a percentage
    (day_1_retention::float / signups) * 100 AS day_1_retention_rate,
    
    -- Number of players retained after 7 days
    day_7_retention,    
    -- Calculate 7-day retention rate as a percentage
    (day_7_retention::float / signups) * 100 AS day_7_retention_rate,
    
    -- Number of players retained after 30 days
    day_30_retention,    
    -- Calculate 30-day retention rate as a percentage
    (day_30_retention::float / signups) * 100 AS day_30_retention_rate
FROM 
    retention
ORDER BY 
    signup_month DESC;

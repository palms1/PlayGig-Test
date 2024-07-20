-- Step 1: Filter sessions from the past 30 days and convert start_time to date
WITH recent_sessions AS (
    SELECT 
        player_id, 
        start_time::date AS session_date
    FROM 
        Sessions
    WHERE 
        start_time::date > CURRENT_DATE - INTERVAL '30 days'
)

-- Step 2: Group by session_date and count unique player_ids for each day
SELECT 
    session_date, 
    COUNT(DISTINCT player_id) AS daily_active_users
FROM 
    recent_sessions
GROUP BY 
    session_date
ORDER BY 
    session_date DESC;
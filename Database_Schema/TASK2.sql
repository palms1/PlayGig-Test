-- Step 1: Filter sessions from the past 30 days and calculate session duration in minutes
WITH recent_sessions AS (
    SELECT 
        player_id, 
        GREATEST(0, EXTRACT(EPOCH FROM (end_time - start_time)) / 60) AS session_duration_minutes --Prevent negative session durations
    FROM 
        Sessions
    WHERE 
        start_time::date > CURRENT_DATE - INTERVAL '30 days'
          AND end_time IS NOT NULL  -- Ensure end_time is not NULL
)

-- Step 2: Group by player_id and calculate average session duration
SELECT 
    player_id, 
    AVG(session_duration_minutes) AS average_session_duration_minutes
FROM 
    recent_sessions
GROUP BY 
    player_id
ORDER BY 
    player_id;
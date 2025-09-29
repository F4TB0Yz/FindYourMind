CREATE OR REPLACE FUNCTION get_habits_with_progress()
RETURNS TABLE (
    habit_id UUID,
    title TEXT,
    description TEXT,
    icon TEXT,
    type TEXT,
    daily_goal INT,
    initial_date TIMESTAMP,
    progress_id UUID,
    progress_date DATE,
    progress_daily_goal INT,
    progress_daily_counter INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.id AS habit_id,
        h.title,
        h.description,
        h.icon,
        h.type,
        h.daily_goal,
        h.initial_date,
        hp.id AS progress_id,
        hp.date AS progress_date,
        hp.daily_goal AS progress_daily_goal,
        hp.daily_counter AS progress_daily_counter
    FROM 
        habits h
    LEFT JOIN 
        habit_progress hp ON h.id = hp.habit_id;
END;
$$ LANGUAGE plpgsql;
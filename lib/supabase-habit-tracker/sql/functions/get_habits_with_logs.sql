CREATE OR REPLACE FUNCTION get_habits_with_logs()
RETURNS TABLE (
    id TEXT,
    user_id TEXT,
    title TEXT,
    description TEXT,
    icon TEXT,
    category TEXT,
    tracking_type TEXT,
    target_value INT,
    initial_date TEXT,
    created_at TEXT,
    updated_at TEXT,
    log_id TEXT,
    log_date TEXT,
    log_value INT
)
LANGUAGE sql
AS $$
    SELECT
        h.id,
        h.user_id,
        h.title,
        h.description,
        h.icon,
        h.category,
        h.tracking_type,
        h.target_value,
        h.initial_date,
        h.created_at,
        h.updated_at,
        hl.id AS log_id,
        hl.date AS log_date,
        hl.value AS log_value
    FROM habits h
    LEFT JOIN habit_logs hl ON h.id = hl.habit_id;
$$;

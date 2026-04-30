CREATE TABLE IF NOT EXISTS habits (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'none',
    tracking_type TEXT NOT NULL DEFAULT 'single',
    target_value INTEGER NOT NULL DEFAULT 1,
    initial_date TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    synced INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS habit_logs (
    id TEXT PRIMARY KEY,
    habit_id TEXT NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    date TEXT NOT NULL,
    value INTEGER NOT NULL DEFAULT 0,
    synced INTEGER NOT NULL DEFAULT 0,
    UNIQUE(habit_id, date)
);

CREATE INDEX IF NOT EXISTS idx_habits_user_initial_date
    ON habits(user_id, initial_date DESC);

CREATE INDEX IF NOT EXISTS idx_habit_logs_habit_id
    ON habit_logs(habit_id);

CREATE INDEX IF NOT EXISTS idx_habit_logs_date
    ON habit_logs(date);

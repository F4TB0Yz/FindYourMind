CREATE TABLE habits (
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

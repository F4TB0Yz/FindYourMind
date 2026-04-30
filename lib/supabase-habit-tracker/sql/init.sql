-- FindYourMind: Supabase Schema v2 (without synced column)

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
    updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS habit_logs (
    id TEXT PRIMARY KEY,
    habit_id TEXT NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    date TEXT NOT NULL,
    value INTEGER NOT NULL DEFAULT 0,
    UNIQUE(habit_id, date)
);

CREATE INDEX IF NOT EXISTS idx_habits_user_initial_date
    ON habits(user_id, initial_date DESC);

CREATE INDEX IF NOT EXISTS idx_habit_logs_habit_id
    ON habit_logs(habit_id);

CREATE INDEX IF NOT EXISTS idx_habit_logs_date
    ON habit_logs(date);

ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_logs ENABLE ROW LEVEL SECURITY;

-- Policies for habits table
CREATE POLICY "habits_select_policy" ON habits
    FOR SELECT USING (user_id::uuid = auth.uid());

CREATE POLICY "habits_insert_policy" ON habits
    FOR INSERT WITH CHECK (user_id::uuid = auth.uid());

CREATE POLICY "habits_update_policy" ON habits
    FOR UPDATE USING (user_id::uuid = auth.uid());

CREATE POLICY "habits_delete_policy" ON habits
    FOR DELETE USING (user_id::uuid = auth.uid());

-- Policies for habit_logs table (transitive ownership via habits)
CREATE POLICY "habit_logs_select_policy" ON habit_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM habits
            WHERE habits.id = habit_logs.habit_id
            AND habits.user_id::uuid = auth.uid()
        )
    );

CREATE POLICY "habit_logs_insert_policy" ON habit_logs
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM habits
            WHERE habits.id = habit_logs.habit_id
            AND habits.user_id::uuid = auth.uid()
        )
    );

CREATE POLICY "habit_logs_update_policy" ON habit_logs
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM habits
            WHERE habits.id = habit_logs.habit_id
            AND habits.user_id::uuid = auth.uid()
        )
    );

CREATE POLICY "habit_logs_delete_policy" ON habit_logs
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM habits
            WHERE habits.id = habit_logs.habit_id
            AND habits.user_id::uuid = auth.uid()
        )
    );
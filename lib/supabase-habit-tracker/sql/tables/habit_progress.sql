CREATE TABLE habit_progress (
    id SERIAL PRIMARY KEY,
    habit_id INTEGER NOT NULL,
    date DATE NOT NULL,
    daily_goal INTEGER NOT NULL,
    daily_counter INTEGER NOT NULL,
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
);
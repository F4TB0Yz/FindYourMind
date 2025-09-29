-- Este archivo se utiliza para inicializar la base de datos y crear las tablas necesarias.

-- Crear la tabla habits
CREATE TABLE IF NOT EXISTS habits (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(255),
    type VARCHAR(50) NOT NULL,
    daily_goal INT NOT NULL,
    initial_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Crear la tabla habit_progress
CREATE TABLE IF NOT EXISTS habit_progress (
    id SERIAL PRIMARY KEY,
    habit_id INT REFERENCES habits(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    daily_goal INT NOT NULL,
    daily_counter INT NOT NULL
);

-- Insertar datos iniciales (opcional)
INSERT INTO habits (title, description, icon, type, daily_goal, initial_date) VALUES
('Beber agua', 'Beber al menos 2 litros de agua al día', 'assets/icons/water.svg', 'Salud', 8, CURRENT_TIMESTAMP),
('Ejercicio', 'Hacer ejercicio al menos 30 minutos al día', 'assets/icons/exercise.svg', 'Salud', 1, CURRENT_TIMESTAMP);

-- Crear índices (opcional)
CREATE INDEX idx_habit_progress_habit_id ON habit_progress(habit_id);
CREATE INDEX idx_habit_progress_date ON habit_progress(date);
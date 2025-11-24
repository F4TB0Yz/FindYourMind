-- ============================================================================
-- FIX: Hacer columna 'nombre' opcional en tabla users
-- ============================================================================
-- Ejecutar en: Supabase Dashboard > SQL Editor

-- Permitir NULL en la columna nombre
ALTER TABLE public.users 
ALTER COLUMN nombre DROP NOT NULL;

-- Verificar el cambio
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'users' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

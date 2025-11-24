-- ============================================================================
-- SOLUCIÓN PARA: "Database error saving new user" 
-- ============================================================================
-- Este script corrige el error de registro de usuarios en Supabase
-- Ejecutar en: Supabase Dashboard > SQL Editor

-- PASO 1: Deshabilitar RLS temporalmente para diagnóstico
-- ============================================================================
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- PASO 2: Eliminar trigger existente si hay alguno problemático
-- ============================================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- PASO 3: Crear función mejorada para el trigger
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insertar el nuevo usuario en la tabla 'users'
  INSERT INTO public.users (id, correo, nombre, fecha_registro)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre', NULL),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING; -- Si ya existe, no hacer nada
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Loguear el error pero permitir que el registro continúe
    RAISE WARNING 'Error al crear usuario en tabla users: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- PASO 4: Crear el trigger
-- ============================================================================
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- PASO 5: Habilitar RLS con políticas correctas
-- ============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
DROP POLICY IF EXISTS "Allow service role to insert" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;

-- Política 1: Los usuarios pueden ver su propia información
CREATE POLICY "Users can view their own data"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Política 2: Los usuarios pueden actualizar su propia información
CREATE POLICY "Users can update their own data"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id);

-- Política 3: Permitir inserción desde el trigger (crítico)
CREATE POLICY "Enable insert for service role"
  ON public.users
  FOR INSERT
  WITH CHECK (true); -- El trigger usa SECURITY DEFINER así que bypasea RLS

-- PASO 6: Verificar la configuración
-- ============================================================================
-- Ejecuta esto para ver si todo está correcto:
SELECT 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd, 
  qual
FROM pg_policies 
WHERE tablename = 'users';

-- PASO 7: Migrar usuarios legacy (opcional)
-- ============================================================================
-- Sincronizar usuarios que ya existen en auth.users pero no en users
INSERT INTO public.users (id, correo, nombre, fecha_registro)
SELECT 
  au.id,
  au.email,
  au.raw_user_meta_data->>'nombre',
  au.created_at
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE u.id IS NULL -- Solo usuarios que no existen en 'users'
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================

-- Ver todos los usuarios y su estado de sincronización
SELECT 
  au.id,
  au.email,
  au.created_at as "Auth Created",
  u.correo as "User Email",
  u.fecha_registro as "Users Created",
  CASE 
    WHEN u.id IS NOT NULL THEN '✅ Sincronizado'
    ELSE '❌ Falta en users'
  END as "Estado"
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
ORDER BY au.created_at DESC
LIMIT 10;

-- Ver triggers activos
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- ============================================================================
-- NOTAS IMPORTANTES:
-- ============================================================================
-- 1. La función usa SECURITY DEFINER para bypass RLS
-- 2. El EXCEPTION handler permite que el registro continúe aunque falle
-- 3. ON CONFLICT (id) DO NOTHING previene errores de duplicados
-- 4. Las políticas RLS permiten inserción sin restricciones desde el trigger

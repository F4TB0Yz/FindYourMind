# 🔄 Sincronización Automática de Usuarios en Supabase

## 📋 Resumen
Este documento explica cómo configurar Supabase para sincronizar automáticamente los usuarios entre `auth.users` y tu tabla personalizada `users`.

## ✅ Cambios Implementados en la Aplicación

### 1. **Datasource de Usuarios** (`users_remote_datasource.dart`)
- ✅ Creado datasource para interactuar con la tabla `users`
- ✅ Métodos: `createUser()`, `userExists()`, `updateUser()`

### 2. **Repositorio de Autenticación** (`auth_repository_impl.dart`)
- ✅ Al registrarse (`signUpWithEmail`): Crea usuario en `auth.users` Y en `users`
- ✅ Al iniciar sesión (`signInWithEmail`): Verifica y crea el usuario en `users` si no existe (usuarios legacy)

### 3. **Inyección de Dependencias** (`dependency_injection.dart`)
- ✅ Agregado `UsersRemoteDataSource` al contenedor de dependencias

## 🗄️ Estructura de la Tabla `users`

Según tu esquema actual:
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre TEXT,
  correo TEXT NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🚀 Configuración Recomendada: Trigger en Supabase (OPCIONAL)

Para garantizar que **todos** los usuarios registrados (incluso desde otros métodos) se sincronicen automáticamente, puedes crear un trigger en Supabase:

### Paso 1: Ir al SQL Editor de Supabase

1. Abre tu proyecto en [supabase.com](https://supabase.com)
2. Ve a **SQL Editor**
3. Crea una nueva query

### Paso 2: Crear la Función del Trigger

```sql
-- Función que se ejecutará automáticamente cuando se cree un usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insertar el nuevo usuario en la tabla 'users'
  INSERT INTO public.users (id, correo, nombre, fecha_registro)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'nombre', -- Si guardas el nombre en metadata
    NOW()
  )
  ON CONFLICT (id) DO NOTHING; -- Si ya existe, no hacer nada
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Paso 3: Crear el Trigger

```sql
-- Trigger que se dispara cuando se inserta un usuario en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### Paso 4: Verificar que funcione

Registra un nuevo usuario y verifica que aparezca automáticamente en ambas tablas:

```sql
-- Verificar que el usuario esté en ambas tablas
SELECT 
  au.id,
  au.email,
  au.created_at as auth_created,
  u.correo,
  u.fecha_registro as users_created
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
ORDER BY au.created_at DESC
LIMIT 10;
```

## 🔐 Políticas de Seguridad (RLS)

Asegúrate de que tu tabla `users` tenga Row Level Security habilitada:

```sql
-- Habilitar RLS en la tabla users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver su propia información
CREATE POLICY "Users can view their own data"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Política: Los usuarios pueden actualizar su propia información
CREATE POLICY "Users can update their own data"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id);

-- Política: Permitir inserción desde el trigger (SECURITY DEFINER)
-- Esta política permite que el trigger cree registros
CREATE POLICY "Allow service role to insert"
  ON public.users
  FOR INSERT
  WITH CHECK (true);
```

## 📝 Migraciones de Usuarios Legacy

Si ya tienes usuarios en `auth.users` que no están en `users`, ejecuta este script para sincronizarlos:

```sql
-- Insertar usuarios legacy que faltan en la tabla 'users'
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
```

## 🧪 Probar la Sincronización

### Desde la Aplicación Flutter:

1. **Nuevo usuario**: 
   - Registrarse con email y contraseña
   - Verificar que aparece en ambas tablas

2. **Usuario existente (legacy)**:
   - Iniciar sesión con un usuario antiguo
   - El sistema lo detectará y lo creará automáticamente en `users`

### Desde Supabase Dashboard:

```sql
-- Ver todos los usuarios y su estado de sincronización
SELECT 
  au.id,
  au.email,
  au.created_at as "Registrado en Auth",
  CASE 
    WHEN u.id IS NOT NULL THEN '✅ Sincronizado'
    ELSE '❌ Falta en users'
  END as "Estado"
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
ORDER BY au.created_at DESC;
```

## 🐛 Troubleshooting

### Problema: Usuario no aparece en `users` después del registro

**Solución 1**: Verificar que el trigger esté activo:
```sql
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
```

**Solución 2**: Verificar logs de errores:
```sql
-- En Supabase, ve a Logs > Postgres Logs
```

**Solución 3**: Verificar permisos:
```sql
-- La función debe tener SECURITY DEFINER
SELECT proname, prosecdef 
FROM pg_proc 
WHERE proname = 'handle_new_user';
```

### Problema: Error "permission denied for table users"

**Solución**: Verificar que las políticas RLS permitan la inserción desde el trigger.

## 📊 Ventajas de esta Implementación

✅ **Doble Seguridad**: 
- Si el trigger falla, la app lo maneja
- Si la app falla, el trigger lo respalda

✅ **Usuarios Legacy**: 
- Se sincronizan automáticamente al iniciar sesión

✅ **Escalable**: 
- Funciona con cualquier método de autenticación (email, OAuth, etc.)

✅ **Sin Duplicados**: 
- `ON CONFLICT DO NOTHING` previene errores

## 🎯 Próximos Pasos

1. ✅ Implementar trigger en Supabase (opcional pero recomendado)
2. ✅ Migrar usuarios legacy con el script SQL
3. ✅ Probar registro e inicio de sesión
4. ✅ Verificar políticas de seguridad
5. 📝 Considerar agregar más campos a `users` (foto de perfil, preferencias, etc.)

---

**Última actualización**: 15 de noviembre de 2025

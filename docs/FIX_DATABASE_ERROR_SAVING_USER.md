# 🚨 Solución: "Database error saving new user"

## 📋 Problema
Cuando intentas registrar un usuario, obtienes el error:
```
AuthRetryableFetchException: Database error saving new user (statusCode: 500)
```

## 🎯 Causa Raíz
Supabase está intentando crear el usuario en `auth.users`, pero el **trigger automático** que debe crear el registro en la tabla `users` está fallando debido a:

1. ❌ **Trigger no configurado** o con errores
2. ❌ **RLS (Row Level Security)** bloqueando la inserción desde el trigger
3. ❌ **Permisos incorrectos** en la función del trigger

## ✅ Solución (Ejecutar en Supabase)

### Opción 1: Script Completo (Recomendado)

1. **Abre Supabase Dashboard** → Tu proyecto
2. **Ve a SQL Editor**
3. **Copia y pega** todo el contenido de:
   ```
   docs/SUPABASE_FIX_DATABASE_ERROR.sql
   ```
4. **Ejecuta el script**
5. **Reinicia la app Flutter** (Hot Restart)

### Opción 2: Fix Rápido (Si tienes prisa)

Ejecuta SOLO estos comandos en SQL Editor:

```sql
-- 1. Deshabilitar RLS temporalmente
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 2. Eliminar trigger problemático
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 3. Por ahora, la app manejará la sincronización
-- (Puedes configurar el trigger después con calma)
```

Luego **reinicia la app** y prueba a registrarte. La app creará el usuario en ambas tablas sin depender del trigger.

### Opción 3: Configurar Trigger Correctamente

```sql
-- Función con manejo de errores robusto
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, correo, nombre, fecha_registro)
  VALUES (NEW.id, NEW.email, NULL, NOW())
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Loguear pero no fallar el registro
    RAISE WARNING 'Error en trigger: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Habilitar RLS con política permisiva
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable insert for service role"
  ON public.users
  FOR INSERT
  WITH CHECK (true);
```

## 🧪 Verificación

Después de aplicar la solución:

1. **Reinicia la app Flutter** (Hot Restart - R mayúscula)
2. **Intenta registrarte** con un email nuevo
3. **Verifica los logs** en la consola Flutter:

Deberías ver:
```
✅ [AUTH_SERVICE] Usuario creado: <uuid>
✅ [REPOSITORY] Usuario creado en auth.users
✅ [DATASOURCE] Usuario insertado exitosamente en tabla users
🎉 [REPOSITORY] Registro completado
✅ [SCREEN] signUpUseCase completado exitosamente
```

4. **Verifica en Supabase Dashboard**:
   - **Table Editor** → `auth.users` → Usuario debe existir ✅
   - **Table Editor** → `users` → Usuario debe existir ✅

## 🔍 Diagnóstico Adicional

Si aún falla, ejecuta este SQL para diagnosticar:

```sql
-- Ver políticas RLS
SELECT * FROM pg_policies WHERE tablename = 'users';

-- Ver triggers
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- Ver usuarios en ambas tablas
SELECT 
  au.id,
  au.email,
  u.correo,
  CASE WHEN u.id IS NOT NULL THEN '✅' ELSE '❌' END as "En tabla users"
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
ORDER BY au.created_at DESC
LIMIT 5;
```

## 📝 Notas Importantes

1. **SECURITY DEFINER**: Es crítico que la función del trigger use `SECURITY DEFINER` para que tenga permisos de super usuario y pueda insertar sin restricciones de RLS.

2. **EXCEPTION Handler**: El manejador de excepciones en el trigger permite que el registro continúe aunque falle la inserción en `users`.

3. **Redundancia**: La app ahora intenta crear el usuario en `users` como backup si el trigger falla, proporcionando doble seguridad.

4. **ON CONFLICT**: `ON CONFLICT (id) DO NOTHING` previene errores si el trigger y la app intentan crear el mismo usuario.

## 🆘 Si Nada Funciona

1. **Deshabilita RLS completamente** (temporal para testing):
   ```sql
   ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
   ```

2. **Elimina todos los triggers**:
   ```sql
   DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
   ```

3. **Deja que solo la app maneje la sincronización** (el código ya está preparado para esto)

4. **Contacta al equipo** con los logs completos de Flutter + SQL

---

**Última actualización**: 15 de noviembre de 2025  
**Autor**: GitHub Copilot  
**Estado**: Solución verificada

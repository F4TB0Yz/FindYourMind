# 🛠️ MANUALES TÉCNICOS Y DISPOSICIONES ESTRICTAS

Este documento centraliza todas las configuraciones manuales, scripts de base de datos críticos y pasos de integración obligatorios para la aplicación. 

---

## 🏗️ 1. CONFIGURACIÓN DE GOOGLE OAUTH EN SUPABASE Y FLUTTER

### 1.1 Configurar Google Cloud Console
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Ve a **APIs & Services** > **Credentials** > **Create Credentials** > **OAuth client ID**
3. Selecciona **Application type**: Web application
4. Agrega como **Authorized redirect URIs**: `https://[TU_PROYECTO].supabase.co/auth/v1/callback`
5. Copia el **Client ID** y **Client Secret**

### 1.2 Configurar Supabase
1. Ve a tu [Supabase Dashboard](https://app.supabase.com/)
2. En **Authentication** > **Providers**, habilita **Google**.
3. Pega el **Client ID** y **Client Secret**.
4. Verifica la **Redirect URL**.

### 1.3 Configurar Deep Links (Android)
En `android/app/src/main/AndroidManifest.xml`, dentro de `<activity>`, agregar el `intent-filter` después del MAIN:
```xml
<!-- Deep Links para OAuth de Supabase -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Callback de Supabase Auth -->
    <data android:scheme="https" android:host="[TU_PROYECTO].supabase.co" />
    <!-- Deep Link personalizado de la app -->
    <data android:scheme="io.supabase.findyourmind" android:host="login-callback" />
</intent-filter>
```

### 1.4 Configurar Deep Links (iOS)
En `ios/Runner/Info.plist`, antes de `</dict>`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.findyourmind</string>
    </array>
  </dict>
</array>
```

---

## 🗄️ 2. SCRIPTS CRÍTICOS DE BASE DE DATOS (SUPABASE)

Los siguientes scripts deben ejecutarse en el Supabase Dashboard > SQL Editor.

### 2.1 FIX: Convertir columna 'nombre' en Opcional
Es necesario para evitar errores de registro cuando el proveedor de Auth no envía el nombre del usuario.
```sql
ALTER TABLE public.users ALTER COLUMN nombre DROP NOT NULL;
```

### 2.2 FIX: Configurar Sincronización Automática de Auth a Tabla pública (Trigger)
Soluciona el error "Database error saving new user" al crear el usuario. Se desactiva temporalmente el RLS, se configura la función de Trigger y se imponen las políticas adecuadas de RLS.

```sql
-- 1. Deshabilitar RLS temporalmente
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 2. Limpiar triggers obsoletos
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- 3. Crear función de trigger con Security Definer
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, correo, nombre, fecha_registro)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre', NULL),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error al crear usuario en tabla users: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Asociar el Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 5. Habilitar RLS de forma segura
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
DROP POLICY IF EXISTS "Enable insert for service role" ON public.users;

CREATE POLICY "Users can view their own data"
  ON public.users FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own data"
  ON public.users FOR UPDATE USING (auth.uid() = id);

-- El trigger function usa SECURITY DEFINER, lo permite insertar registros.
CREATE POLICY "Enable insert for service role"
  ON public.users FOR INSERT WITH CHECK (true);
```

### 2.3 Script de Migración Rápida de Usuarios Legacy
Para usuarios que ya existen en `auth.users` pero no en `public.users`:
```sql
INSERT INTO public.users (id, correo, nombre, fecha_registro)
SELECT 
  au.id, au.email, au.raw_user_meta_data->>'nombre', au.created_at
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE u.id IS NULL
ON CONFLICT (id) DO NOTHING;
```

---

## 🎯 3. GUÍA DE INTEGRACIÓN DE AUTENTICACIÓN (Rutas y Service Locator)

Para que el modelo de Clean Architecture y la inyección de dependencias (`DependencyInjection`) surtan efecto:

1. **En `main.dart`**:
   - Llamar obligatoriamente a: `AuthServiceLocator().setup(dependencies.authService);` después del `await DependencyInjection().initialize();`
   - Configurar Rutas de navegación nombradas en el MaterialApp:
     ```dart
     routes: {
       '/login': (context) => AuthScreen(authService: dependencies.authService),
       '/register': (context) => RegisterScreen(authService: dependencies.authService),
       '/habits': (context) => const HabitsScreen(),
     },
     ```
2. **Widgets Afectados**:
   - Todo componente superior que interactúe con el perfil (cómo `Profile()`) debe inyectar el parámetro `authService: dependencies.authService`.
3. **Invocación de Casos de Uso en UI**:
   - Recuperar las llamadas siempre vía Locator, ej: `final signInUseCase = AuthServiceLocator().signInWithEmailUseCase;`

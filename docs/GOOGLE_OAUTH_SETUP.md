# Configuración de Google OAuth para FindYourMind

## ⚠️ Error Actual
```
{"code":400,"error_code":"validation_failed","msg":"Unsupported provider: missing OAuth secret"}
```

Este error indica que **Google OAuth no está configurado** en tu proyecto de Supabase.

---

## 📋 Pasos para Configurar Google OAuth

### 1️⃣ Configurar Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Ve a **APIs & Services** > **Credentials**
4. Haz clic en **Create Credentials** > **OAuth client ID**
5. Selecciona **Application type**: Web application
6. Agrega las siguientes **Authorized redirect URIs**:
   ```
   https://TU_PROYECTO.supabase.co/auth/v1/callback
   ```
   Reemplaza `TU_PROYECTO` con tu URL de Supabase (ejemplo: `kknnrfktfisgtxigckaq`)

7. Copia el **Client ID** y **Client Secret**

### 2️⃣ Configurar Supabase

1. Ve a tu [Supabase Dashboard](https://app.supabase.com/)
2. Selecciona tu proyecto
3. Ve a **Authentication** > **Providers**
4. Busca **Google** en la lista
5. Habilita el provider de Google
6. Pega el **Client ID** y **Client Secret** de Google Cloud
7. Verifica que la **Redirect URL** sea correcta:
   ```
   https://TU_PROYECTO.supabase.co/auth/v1/callback
   ```
8. Guarda los cambios

### 3️⃣ Configurar Deep Links en Flutter (Android)

1. Abre `android/app/src/main/AndroidManifest.xml`
2. Dentro de `<activity>`, después del intent-filter de MAIN/LAUNCHER, agrega:

```xml
<!-- Deep Links para OAuth de Supabase -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <!-- Callback de Supabase Auth -->
    <data
        android:scheme="https"
        android:host="TU_PROYECTO.supabase.co" />
        
    <!-- Deep Link personalizado de la app -->
    <data
        android:scheme="io.supabase.findyourmind"
        android:host="login-callback" />
</intent-filter>
```

**Reemplaza `TU_PROYECTO`** con tu proyecto de Supabase (ejemplo: `kknnrfktfisgtxigckaq`)

### 4️⃣ Configurar Deep Links en Flutter (iOS)

1. Abre `ios/Runner/Info.plist`
2. Agrega antes de `</dict>`:

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

## 🧪 Probar la Configuración

1. Ejecuta la aplicación
2. Toca el botón **"Continuar con Google"**
3. Deberías ver:
   - ✅ Se abre el navegador con el login de Google
   - ✅ Después de autenticarte, regresa a la app
   - ✅ Ves el mensaje "¡Autenticación con Google exitosa!"

---

## ❌ Solución de Problemas

### Error: "validation_failed: missing OAuth secret"
- ✅ Verifica que hayas habilitado Google en Supabase
- ✅ Verifica que hayas agregado Client ID y Client Secret
- ✅ Verifica que la Redirect URL esté correcta

### Error: "Unable to open URL"
- ✅ Verifica que los deep links estén configurados en Android/iOS
- ✅ Verifica que el esquema sea `io.supabase.findyourmind`

### La app no regresa después de autenticarse
- ✅ Verifica los deep links en AndroidManifest.xml
- ✅ Verifica el esquema en Info.plist (iOS)
- ✅ Asegúrate de que el redirectTo en el código coincida

---

## 📝 Notas Adicionales

### Arquitectura Implementada
El código ya está completamente implementado siguiendo Clean Architecture:
- ✅ `SignInWithGoogleUseCase` - Caso de uso
- ✅ `AuthRepository.signInWithGoogle()` - Contrato
- ✅ `AuthRepositoryImpl.signInWithGoogle()` - Implementación
- ✅ `SupabaseAuthService.signInWithGoogle()` - Servicio
- ✅ Botones conectados en Login y Register

### URLs Importantes
- Dashboard Supabase: https://app.supabase.com/
- Google Cloud Console: https://console.cloud.google.com/
- Documentación OAuth Supabase: https://supabase.com/docs/guides/auth/social-login/auth-google

---

## ✅ Checklist de Configuración

- [ ] Proyecto creado en Google Cloud Console
- [ ] OAuth Client ID creado (Web application)
- [ ] Redirect URI agregada en Google Cloud
- [ ] Google provider habilitado en Supabase
- [ ] Client ID y Secret agregados en Supabase
- [ ] Deep links configurados en Android (AndroidManifest.xml)
- [ ] Deep links configurados en iOS (Info.plist)
- [ ] Probado en dispositivo/emulador

---

Una vez completados estos pasos, el botón de Google funcionará correctamente. 🎉

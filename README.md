# 🧠 FindYourMind

Aplicación de seguimiento de hábitos personales construida con Flutter y Supabase. Permite crear, gestionar y registrar el progreso de tus hábitos diarios con soporte offline y sincronización en la nube.

---

## ✨ Características

- 📋 **Gestión de hábitos** — Crea, edita y elimina hábitos personalizados
- 📈 **Seguimiento de progreso** — Registra avances diarios con incremento/decremento
- 🔐 **Autenticación** — Inicio de sesión con correo/contraseña y Google OAuth (PKCE)
- 📶 **Offline-first** — Funciona sin internet y sincroniza automáticamente al conectarse
- 🌙 **Tema oscuro/claro** — Cambia el tema desde el perfil
- 👤 **Perfil de usuario** — Gestión básica de la cuenta

---

## 🛠️ Tech Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.8+ |
| Lenguaje | Dart |
| Backend / Auth | [Supabase](https://supabase.com/) (PostgreSQL) |
| Base de datos local | SQLite (sqflite + Drift) |
| Estado | Provider |
| Arquitectura | Clean Architecture |
| Fuente tipográfica | Nunito |

---

## 📋 Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.8.1`
- Cuenta en [Supabase](https://supabase.com/) con un proyecto creado
- (Opcional) Cuenta en [Google Cloud Console](https://console.cloud.google.com/) para OAuth con Google

---

## 🚀 Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/F4TB0Yz/FindYourMind.git
cd FindYourMind
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

Copia el archivo de ejemplo y rellena tus credenciales de Supabase:

```bash
cp .env.example .env
```

Edita `.env` con los valores de tu proyecto de Supabase (los encontrarás en **Project Settings → API**):

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anonima
```

> ⚠️ **Nunca subas el archivo `.env` al repositorio.** Ya está incluido en `.gitignore`.

### 4. Configurar Supabase

#### Tablas necesarias

Ejecuta el siguiente SQL en el editor de Supabase (**SQL Editor**):

```sql
-- Tabla de usuarios
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  correo text not null unique,
  nombre text,
  fecha_registro timestamptz default now()
);

-- Tabla de hábitos
create table if not exists public.habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  description text,
  goal integer default 1,
  progress integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Habilitar Row Level Security
alter table public.users enable row level security;
alter table public.habits enable row level security;

-- Políticas para users
create policy "Users can view own data" on public.users
  for select using (auth.uid() = id);
create policy "Users can insert own data" on public.users
  for insert with check (auth.uid() = id);
create policy "Users can update own data" on public.users
  for update using (auth.uid() = id);

-- Políticas para habits
create policy "Users can manage own habits" on public.habits
  for all using (auth.uid() = user_id);
```

### 5. (Opcional) Configurar Google OAuth

Sigue los pasos en [`docs/GOOGLE_OAUTH_SETUP.md`](docs/GOOGLE_OAUTH_SETUP.md) para habilitar el inicio de sesión con Google.

En resumen:
1. Crea un **OAuth Client ID** en [Google Cloud Console](https://console.cloud.google.com/) (tipo: Web application)
2. Agrega `https://tu-proyecto.supabase.co/auth/v1/callback` como Redirect URI
3. Habilita el proveedor de Google en **Supabase → Authentication → Providers** y pega el Client ID y Client Secret
4. Configura los deep links en `android/app/src/main/AndroidManifest.xml` e `ios/Runner/Info.plist` (ver doc enlazada)

### 6. Ejecutar la aplicación

```bash
# Android / iOS
flutter run

# Windows
flutter run -d windows

# Web (las variables de entorno en --dart-define quedan visibles en el historial del shell;
# para mayor seguridad usa variables de entorno del sistema o un script que no las exponga)
flutter run -d chrome --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co --dart-define=SUPABASE_ANON_KEY=tu-clave-anonima

# Listar dispositivos disponibles
flutter devices
```

---

## 📁 Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── config/
│   └── theme/                   # Configuración del tema
├── core/
│   ├── config/
│   │   ├── dependency_injection.dart   # Inyección de dependencias
│   │   ├── supabase_config.dart        # Carga de credenciales
│   │   └── database_helper.dart        # Inicialización de SQLite
│   ├── services/                # Servicios de autenticación y sincronización
│   ├── constants/               # Constantes globales
│   ├── error/                   # Manejo de errores (Failures/Exceptions)
│   └── utils/                   # Utilidades
├── features/
│   ├── auth/                    # Módulo de autenticación
│   ├── habits/                  # Módulo principal de hábitos
│   └── profile/                 # Módulo de perfil
└── shared/                      # Componentes y providers compartidos
```

---

## 🔑 Variables de entorno

| Variable | Descripción | Dónde obtenerla |
|----------|-------------|-----------------|
| `SUPABASE_URL` | URL del proyecto Supabase | Supabase → Project Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Clave anónima pública | Supabase → Project Settings → API → anon/public key |

> Para compilación web puedes usar `--dart-define` en lugar del archivo `.env`.

---

## 📄 Licencia

Este proyecto es de uso privado. Todos los derechos reservados.

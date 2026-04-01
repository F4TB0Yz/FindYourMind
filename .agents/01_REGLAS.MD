# 🎯 REGLAS MAESTRAS DE FINDYOURMIND (INMUTABLE)

**Misión:** Desarrollar una aplicación de gestion personal "Offline-first" robusta, escalable y con sincronización automática.

## 🛠️ TECH STACK ESTRICTO
- **Framework:** Flutter 3.8+ con Dart.
- **Backend:** Supabase (PostgreSQL) para la nube.
- **Base de Datos Local:** SQLite (sqflite + Drift).
- **Gestión de Estado:** Provider.

## 🏗️ ARQUITECTURA LIMPIA (CLEAN ARCHITECTURE)
1. **Arquitectura Orientada a Features (Feature-first):** La Clean Architecture debe estar subdividida por Features (Módulos). Es decir, lib/features/auth/domain/..., lib/features/auth/presentation/.... En lugar de agrupar todos los dominios juntos, lo que hace el proyecto inescalable cuando tienes 100 pantallas.
2. **No strings ni colores mágicos (Hardcoding):** Prohibido quemar textos, colores o tamaños (padding) directamente en la UI. Todo debe venir de un Design System centralizado (ej. AppColors, AppTextStyles, AppDimens) o de los archivos de Internacionalización (AppLocalizations).
3. **Importaciones Absolutas vs Relativas:** Usar siempre importaciones absolutas (import 'package:find_your_mind/features/auth/...') en toda la aplicación para evitar problemas de resolución de dependencias internos.

## OPTIMIZACIÓN DE LA APP
1. **Tiempo de Construccion de un Widget:** Los widgets no deben tener procesos pesados en el build, solamente lo necesario. Utiliza el initState para inicializar procesos pesados.
2. **Widget por clase**: Un widget no puede ser devuelto NUNCA por un metodo, siempre debe ser una clase por rendimiento.
3. **Uso estricto e inflexible de const**: Obligatorio usar constructores constantes en todos los widgets y variables de configuración (margins, paddings) para evitar reconstrucciones innecesarias del Virtual DOM de Flutter. Activar la regla del linter prefer_const_constructors.
4. **Selector en lugar de Provider global**: Para evitar redibujar pantallas enteras cuando un estado mínimo cambia, es obligatorio el uso de Consumer o Selector de Provider en lugar de escuchar todo el modelo en el inicio del build.

## 🛑 REGLAS DE DESARROLLO Y SEGURIDAD
1. **Inyección de Dependencias:** Usar siempre el patrón Service Locator (`DependencyInjection()` y `AuthServiceLocator()`) para acceder a repositorios y casos de uso.
2. **Offline-First:** Asume siempre que no hay internet. Todo se lee/escribe primero en SQLite de forma instantánea, y la sincronización (SyncService) ocurre en segundo plano de forma silenciosa.
3. **Testing:** PROHIBIDO hacer `git commit` si el código rompe la arquitectura o si no pasa las pruebas locales.
4. **Manejo de Errores y Logging (Crucial)**
    *   **Gestión Centralizada de Errores (Failures):** La capa Domain no debe lanzar excepciones crudas (ej. SocketException o SqliteException). Todos los errores deben capturarse en la capa Data y mapearse a un modelo de negocio (ej. usar patrones funcionales como un Either<Failure, Success> usando paquetes como fpdart o dartz, o usar clases de Fallos personalizadas).
    *   **Nunca mostrar errores crudos en UI:** Prohibido mostrar errores directamente del backend o base de datos al usuario final. Todo mensaje de error en la Presentation Layer debe ser amigable.
    *   **Logging en lugar de Prints:** Queda prohibido usar print(). Todo registro debe usar una herramienta de Logging (ej. el package logger), separando por niveles (INFO, DEBUG, ERROR) para que, en producción, se guarden los errores en la base para analíticas o debugeo futuro en remoto.

5. **Cultura de Desarrollo (Git y Linting)**
    *   **Commits Convencionales:** Todo commit debe seguir la estructura estándar y debe ser en español (feat:, fix:, chore:, refactor:, docs:). Nada de commits diciendo "arregle un bug de pantalla".
    *   **Cero Warnings de Linter:** El código no puede subirse al repo si el comando flutter analyze o dart analyze reporta algún Warning, no solo errores. Se recomiendan activar las reglas de flutter_lints (o very_good_analysis).

==================================================
🛑 ALTO: LÍMITE DEL SISTEMA. NO MODIFICAR NI RESUMIR NADA POR ENCIMA DE ESTA LÍNEA 🛑
==================================================
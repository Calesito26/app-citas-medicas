# App Citas Medicas

Aplicacion Flutter para gestionar citas medicas en un centro de salud. Permite registrar disponibilidad por especialidad, reservar citas, atender pacientes y consultar reportes usando una base de datos SQLite local.

## Funcionalidades

- Registro de especialidades medicas.
- Configuracion de disponibilidad diaria por especialidad.
- Registro de citas segun cupos disponibles.
- Atencion de citas con doctor, sintomas y diagnostico.
- Reporte de citas por especialidad.
- Anulacion de citas registradas.
- Persistencia local con SQLite.

## Plataformas soportadas

El proyecto esta preparado para ejecutarse en:

- Android
- Windows
- Linux
- macOS
- Web con Chrome o Edge

En Android/iOS se usa `sqflite`. En escritorio se usa `sqflite_common_ffi`. En Web se usa `sqflite_common_ffi_web` con almacenamiento en IndexedDB del navegador.

## Requisitos

Antes de clonar y ejecutar el proyecto, instala:

- Flutter SDK
- Dart SDK incluido con Flutter
- Android Studio o Android SDK, si vas a probar en celular Android
- Git
- Chrome o Edge, si vas a probar en Web

Verifica tu instalacion con:

```powershell
flutter doctor
```

## Clonar el repositorio

```powershell
git clone https://github.com/Calesito26/app-citas-medicas.git
cd app-citas-medicas
```

Instala las dependencias:

```powershell
flutter pub get
```

## Ejecutar en Android

Activa la depuracion USB en tu celular y conectalo por cable. Luego verifica que Flutter lo detecte:

```powershell
flutter devices
```

Ejecuta la app usando el ID de tu dispositivo:

```powershell
flutter run -d ID_DEL_DISPOSITIVO
```

Ejemplo:

```powershell
flutter run -d R5CY63XZT2L
```

## Ejecutar en Windows

```powershell
flutter run -d windows
```

## Ejecutar en Web

```powershell
flutter run -d chrome
```

Para conservar los datos Web entre ejecuciones, usa siempre el mismo puerto:

```powershell
flutter run -d chrome --web-port 8080
```

Nota: en Web la base de datos se guarda en el almacenamiento del navegador. Si cambias el puerto, limpias los datos del sitio o abres otro navegador, puedes ver una base diferente.

## Compilar APK Android

```powershell
flutter build apk --debug
```

El APK se genera en:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Para instalarlo manualmente:

```powershell
C:\Android\sdk\platform-tools\adb.exe install -r build\app\outputs\flutter-apk\app-debug.apk
```

## Validar el proyecto

Antes de subir cambios al repositorio, ejecuta:

```powershell
flutter analyze
flutter test
```

## Estructura principal

```text
lib/
  db/        Configuracion y acceso a SQLite
  model/     Modelos de datos
  vistas/    Pantallas de la aplicacion
  main.dart  Punto de entrada
```

## Subir cambios a GitHub

Si ya tienes el remoto configurado:

```powershell
git status
git add .
git commit -m "Actualizar documentacion del proyecto"
git push
```

Si GitHub rechaza el push por permisos, revisa que estes autenticado con la cuenta que tiene acceso al repositorio.

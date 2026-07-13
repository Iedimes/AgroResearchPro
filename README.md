# AgroResearch Pro

Aplicación **Flutter** de apoyo a la **investigación agronómica (I+D)**, con
almacenamiento **offline-first** (Hive) y **sincronización bidireccional con
Firebase / Firestore**. Pensada para registrar y consultar ensayos de campo,
evaluaciones de enfermedades, control experimental, mantenimiento y resultados
de laboratorio, tanto desde el teléfono como desde la web.

> Enfoque exclusivo en I+D agronómica: **no** incluye ventas, carrito ni precios.

📖 **Manual de usuario (presentación web):** abrí [`manual.html`](manual.html) en el navegador.

---

## Índice
1. [Requisitos](#requisitos)
2. [Paso a paso para usar la app (modo usuario)](#paso-a-paso-para-usar-la-app-modo-usuario)
3. [Configurar la nube (Firebase)](#configurar-la-nube-firebase)
4. [Cómo usar cada módulo](#cómo-usar-cada-módulo)
5. [Sincronización (ida y vuelta)](#sincronización-ida-y-vuelta)
6. [Panel de Investigación](#panel-de-investigación)
7. [Solución de problemas](#solución-de-problemas)
8. [Desarrollo y build automático](#desarrollo-y-build-automático)

---

## Requisitos
- **Flutter 3.44.x** (canal stable) instalado y en el `PATH`.
- **Git**.
- Para correr en dispositivo físico: Android/iOS con los permisos correspondientes.
- Para correr en la web: Google Chrome.
- Una cuenta de **Firebase** (solo si se quiere usar la nube; la app funciona
  igualmente solo en el dispositivo).

---

## Paso a paso para usar la app (modo usuario)

### 1. Clonar el repositorio
```bash
git clone https://github.com/Iedimes/AgroResearchPro.git
cd AgroResearchPro
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Ejecutar la app
- **En la web (Chrome)** – la opción más simple en escritorio:
  ```bash
  flutter run -d chrome
  ```
- **En Android** (dispositivo conectado o emulador):
  ```bash
  flutter run -d android
  ```
- **En Windows** (app de escritorio):
  ```bash
  flutter run -d windows
  ```

La aplicación funciona de inmediato: los datos se guardan **localmente** en el
dispositivo aunque no se configure ninguna nube.

---

## Configurar la nube (Firebase)

La configuración de Firebase **ya viene incluida** en el repositorio
(`lib/firebase_options.dart` y `android/app/google-services.json`), por lo que
en web/Android funciona sin pasos extra. Para habilitar la sincronización:

1. Entrá a la [Firebase Console](https://console.firebase.google.com/) y abrí el
   proyecto **agroresearch-pro**.
2. **Authentication → Sign-in method → Anonymous**: habilitarlo.
3. **Firestore Database → Create database** (modo producción o test, según
   corresponda).
4. Desplegá las reglas de Firestore incluidas en el repo (desde una terminal en
   la carpeta del proyecto, con la CLI de Firebase autenticada):
   ```bash
   firebase use agroresearch-pro
   firebase deploy --only firestore
   ```
   Las reglas permiten leer/escribir siempre que haya una sesión autenticada.

> Si clonás el proyecto en una máquina nueva y querés regenerar la config,
> ejecutá `flutterfire configure` (requiere la Firebase CLI y `flutter pub
> global activate flutterfire_cli`).

---

## Cómo usar cada módulo

Desde el inicio (`Panel de Investigación` es el primero) accedés a los 6 módulos.
En cada lista tocás el botón **+** para crear y tocás un registro para editarlo.

1. **Gestión de Ensayos** – nombre, cultivo (Soja, Trigo, Maíz, Sorgo),
   responsable, repeticiones, parcelas, ubicación GPS (botón “Usar mi
   ubicación”) y dirección/lote.
2. **Evaluación de Enfermedades** – asociás el ensayo, cultivo, fecha,
   enfermedad, **severidad (%)** e **incidencia (%)**, parcela y notas.
3. **Control Experimental** – aplicaciones (barra experimental, fungicida,
   fertilizante, otro) con producto, dosis, volumen de caldo, parcela y
   operario.
4. **Bitácora de Mantenimiento** – acciones (control de plaga, limpieza,
   riego, fertilización, otro) con producto, dosis y operario.
5. **Resultados de Laboratorio** – código de muestra, cultivo, análisis,
   parámetro, valor, unidad y laboratorio.

Cada registro muestra su estado de sincronización:
`Pendiente de subida`, `Sincronizado` o `Local (sin sincronizar)`.

---

## Sincronización (ida y vuelta)

El botón ☁ (nube) en la barra superior hace la sincronización completa:

1. **Sube** a Firestore todo lo que esté pendiente en este dispositivo.
2. **Baja** de Firestore lo que haya en la nube y lo mezcla con lo local,
   sin borrar nunca tus registros del dispositivo. Si un registro existe en
   ambos lados, se queda con la versión más reciente (`updatedAt`).

Además, al **abrir la app** se ejecuta una sincronización automática para que
lo local refleje lo mismo que tenés en la nube.

Para **recuperar** lo que ya tenías en la nube (por ejemplo, si borraste los
datos locales del navegador/dispositivo): simplemente abrí la app o tocá ☁; los
registros de Firestore volverán a aparecer.

---

## Panel de Investigación

Muestra tarjetas con totales (Ensayos, Evaluaciones, Aplicaciones,
Mantenimiento, Laboratorio) y dos gráficos:

- **Evolución de Severidad (% en el tiempo)** para el ensayo seleccionado.
- **Evaluaciones por enfermedad** (barras).

Usá el selector de ensayo para filtrar los gráficos.

---

## Solución de problemas

| Síntoma | Causa probable | Solución |
|--------|----------------|----------|
| "Firebase no configurado" al sincronizar | La app no pudo inicializar Firebase | Verificá Auth anónimo y que `lib/firebase_options.dart` exista |
| "Error: …" al sincronizar | Firestore rechaza la escritura/lectura | Habilitá Auth anónimo y desplegá `firebase deploy --only firestore` |
| No veo mis registros en la nube | Aún no sincronicé o falló el upload | Tocá ☁ y revisá el mensaje; desplegá las reglas |
| Datos perdidos localmente | Se limpió el almacenamiento del dispositivo | Sincronizá para recuperar desde la nube |
| `flutter run` pide "Developer Mode" (Windows) | Faltan permisos de symlink | Usá `-d chrome` o activá el Modo Desarrollador de Windows |

---

## Desarrollo y build automático

- **Análisis y tests**:
  ```bash
  flutter analyze
  flutter test
  ```
- **Build web**:
  ```bash
  flutter build web --release
  ```
  El resultado queda en `build/web` (se publica como artefacto en CI).

### GitHub Actions
El repo incluye `.github/workflows/build.yml`, que ante cada `push`/`pull_request`
sobre `main` hace: `flutter pub get` → `flutter analyze` (informativo) →
`flutter test` → `flutter build web --release` y sube `build/web` como artefacto
`web-release`.

### Estructura
```
lib/
├── core/        # router (go_router), theme, utils
├── features/    # los 5 módulos + dashboard (cada uno: modelos, pantallas, formularios)
├── models/      # entidades (Trial, DiseaseAssessment, ExperimentalApplication, MaintenanceLog, LabResult)
├── services/
│   ├── storage/ # Hive (offline)
│   ├── repository/ # repositorio genérico + providers
│   └── sync/    # SyncService (LocalOnly / Firebase) + SyncNotifier
└── widgets/     # EntityListScreen, TrialPicker
```

---

## Licencia
Uso interno / I+D. Consultá al administrador del proyecto para permisos.

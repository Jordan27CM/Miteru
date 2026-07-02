# Miteru

Miteru es una aplicacion de visualizacion y busqueda de anime diseñada con una interfaz moderna y responsiva. Permite a los usuarios explorar los animes mas populares de la actualidad, ver detalles profundos de cada serie (incluyendo sinopsis traducidas al español), buscar titulos especificos y guardar sus animes favoritos en la nube mediante un sistema de perfiles de usuario.

## Tecnologias Utilizadas

El proyecto fue construido utilizando un stack moderno para el desarrollo multiplataforma:

- Flutter: Framework de desarrollo para construir la interfaz grafica y la logica multiplataforma.
- Dart: Lenguaje de programacion utilizado por Flutter.
- Firebase Authentication: Para el registro e inicio de sesion de los usuarios.
- Firebase Realtime Database: Para el almacenamiento en la nube de los animes favoritos de cada usuario.
- GraphQL: Para consultar la informacion de los animes desde la API de AniList de forma eficiente.
- AniList API: Proveedor principal de la base de datos de animes (portadas, generos, calificaciones).
- HTTP & Translator: Paquetes de Dart para manejar las peticiones a internet y traducir las sinopsis al español en tiempo real.

## Estructura del Proyecto

La arquitectura del proyecto sigue una organizacion clara y modular dentro del directorio `lib/`:

- `main.dart`: Punto de entrada principal de la aplicacion e inicializacion de Firebase.
- `models/`
  - `anime_model.dart`: Definicion de la estructura de datos del Anime.
- `screens/`
  - `main_layout.dart`: Estructura principal que contiene la barra de navegacion (responsiva para PC y celular).
  - `home_screen.dart`: Pantalla de inicio con el carrusel de destacados y la grilla de populares.
  - `search_screen.dart`: Buscador en tiempo real con sistema de retardo (debounce) para optimizar peticiones.
  - `details_screen.dart`: Pantalla de informacion detallada del anime con diseño adaptable.
  - `my_list_screen.dart`: Pantalla que carga y visualiza los animes guardados en Firebase.
  - `profile_screen.dart`: Interfaz de inicio de sesion, registro y gestion de sesion del usuario.
- `services/`
  - `anilist_service.dart`: Logica de comunicacion con la API de AniList mediante GraphQL.
  - `firebase_service.dart`: Logica centralizada para la autenticacion y operaciones de lectura/escritura en Realtime Database.

## Guia de Instalacion y Ejecucion

A continuacion se detallan los pasos para ejecutar este proyecto desde cero en una computadora que no tiene nada instalado.

### 1. Requisitos Previos

Antes de descargar el proyecto, necesitas instalar las siguientes herramientas fundamentales en tu sistema:

1. Instalar Git: Descarga e instala Git desde git-scm.com.
2. Instalar Flutter SDK: Sigue la guia oficial en docs.flutter.dev/get-started/install para tu sistema operativo. Asegurate de agregar la ruta `flutter/bin` a las variables de entorno de tu sistema.
3. Instalar un Editor de Codigo: Se recomienda Visual Studio Code. Una vez instalado, agregale la extension oficial de "Flutter" y "Dart".
4. Navegador o Emulador: Para probar la aplicacion, puedes usar Google Chrome (modo web) o configurar un emulador de Android/iOS usando Android Studio.

### 2. Descargar el Proyecto

Abre una terminal o consola de comandos y ejecuta:

```bash
git clone <URL_DE_TU_REPOSITORIO>
cd Miteru
```

### 3. Instalar Dependencias

Una vez dentro de la carpeta del proyecto, descarga todos los paquetes necesarios ejecutando:

```bash
flutter pub get
```

### 4. Configuracion de Firebase

Por motivos de seguridad, las credenciales de la base de datos no se incluyen en el repositorio publico. Debes vincular el proyecto a tu propio proyecto de Firebase:

1. Crea un proyecto en la consola web de Firebase (console.firebase.google.com).
2. Habilita "Authentication" (Correo/Contraseña) y "Realtime Database" en tu proyecto de Firebase.
3. Instala Firebase CLI en tu computadora siguiendo las instrucciones oficiales.
4. En la terminal de tu proyecto Miteru, ejecuta:
   ```bash
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
5. Selecciona el proyecto que creaste en el paso 1. Esto generara automaticamente el archivo `lib/firebase_options.dart` y los archivos de configuracion nativos necesarios.

### 5. Ejecutar la Aplicacion

Con todo configurado, puedes lanzar la aplicacion en tu navegador o emulador conectado:

```bash
flutter run
```

Si deseas especificar la plataforma (por ejemplo, para correrlo directamente en Google Chrome):

```bash
flutter run -d chrome
```

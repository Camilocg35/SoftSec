# SoftSec – Manual de Usuario

Bienvenido/a a **SoftSec**, la herramienta que facilita la administración, soporte y optimización de equipos con Windows. Aquí encontrarás una guía paso a paso para aprovechar al máximo sus funciones.

---

## Índice

1. [¿Qué es SoftSec?](#qué-es-softsec)
2. [Requisitos y Preparación](#requisitos-y-preparación)
3. [Instalación y Primer Inicio](#instalación-y-primer-inicio)
4. [Vista General de la Interfaz](#vista-general-de-la-interfaz)
5. [Módulos y Funcionalidades](#módulos-y-funcionalidades)
    - [Gestión de usuarios locales](#gestión-de-usuarios-locales)
    - [Administración de servicios](#administración-de-servicios)
    - [Optimización del sistema](#optimización-del-sistema)
    - [Recuperación de archivos](#recuperación-de-archivos)
    - [Información del sistema](#información-del-sistema)
    - [Administración de red](#administración-de-red)
    - [Configuración de red](#configuración-de-red)
6. [Preguntas Frecuentes (FAQ)](#preguntas-frecuentes-faq)
7. [Solución de Problemas](#solución-de-problemas)
8. [Contacto y Soporte](#contacto-y-soporte)

---

## ¿Qué es SoftSec?

**SoftSec** es una aplicación que centraliza las tareas de administración, soporte y optimización del sistema operativo Windows, permitiendo a técnicos y usuarios avanzados realizar acciones comunes desde una interfaz sencilla y segura.

---

## Requisitos y Preparación

- **Sistema operativo:** Windows 10, 11 o superior.
- **Permisos:** Se recomienda ejecutar como Administrador.
- **Dependencias:** PowerShell 5.1 o superior. Para funciones avanzadas de recuperación, WinFR debe estar instalado.
- **Espacio en disco:** Al menos 100 MB libres.

---

## Instalación y Primer Inicio

1. Descarga SoftSec desde el repositorio oficial o fuente confiable.
2. Extrae los archivos en una carpeta local.
3. Haz clic derecho sobre `SoftSec.ps1` o el ejecutable, y selecciona **"Ejecutar como administrador"**.
4. Si el sistema solicita permisos, acepta para un funcionamiento completo.

---

## Vista General de la Interfaz

La ventana principal de SoftSec está dividida en módulos accesibles desde un menú lateral o pestañas superiores:

- Botones principales para acceder a cada módulo.
- Mensajes de advertencia y confirmación antes de ejecutar acciones críticas.
- Información clara y resúmenes en pantalla.

---

## Módulos y Funcionalidades

### Gestión de usuarios locales

- **Listar usuarios:** Muestra todos los usuarios locales, su estado y último inicio de sesión.
- **Agregar usuario:** Permite crear una cuenta nueva y asignar contraseña.
- **Eliminar usuario:** Elimina cuentas seleccionadas (no permite borrar cuentas protegidas por seguridad).
- **Cambiar contraseña:** Modifica la contraseña de un usuario existente.

### Administración de servicios

- **Ver servicios:** Lista todos los servicios del sistema, su estado y tipo de inicio.
- **Filtrar servicios:** Por estado o tipo de inicio.
- **Iniciar/Detener/Reiniciar:** Acciones sobre servicios seleccionados.

### Optimización del sistema

- **Limpiar archivos temporales:** Elimina archivos innecesarios para liberar espacio.
- **Limpiar caché:** Borra caché de navegadores y aplicaciones compatibles.
- **Liberar memoria RAM:** Finaliza procesos inactivos para optimizar el uso de memoria.

### Recuperación de archivos

- **Recuperar archivos eliminados:** Integra WinFR para restaurar archivos borrados.  
  Siga las instrucciones en pantalla para seleccionar la unidad origen/destino y tipo de archivo a recuperar.

### Información del sistema

- **Hardware:** CPU, RAM, almacenamiento y uso.
- **Sistema operativo:** Versión, nombre del equipo, usuario activo.
- **Red:** Direcciones IP, adaptadores, tiempo de actividad.

## Preguntas Frecuentes (FAQ)

**¿Debo ser administrador para usar SoftSec?**  
Se recomienda, ya que muchas funciones requieren permisos elevados.

**¿Puedo dañar mi sistema por error?**  
Las acciones críticas incluyen confirmaciones y validaciones de seguridad.

**¿Puedo usar SoftSec en Windows 7 o versiones antiguas?**  
No está garantizada la compatibilidad ni todas las funciones.

**¿Qué pasa si una función falla?**  
Consulta la sección [Solución de Problemas](#solución-de-problemas) o revisa los mensajes de error detallados en pantalla.

---

## Solución de Problemas

- **SoftSec no inicia:** Verifica que tienes permisos de administrador y PowerShell actualizado.
- **No se puede eliminar un usuario:** Puede ser una cuenta protegida o en uso.
- **Error en recuperación de archivos:** Revisa que WinFR esté instalado y ejecuta como administrador.

---

## Contacto y Soporte

Para reportar errores, sugerencias o solicitar ayuda:
- Abre un issue en el repositorio oficial de SoftSec
- Escribe a [email de soporte o canal de contacto]

---

> **SoftSec** – Tu aliado para una administración segura y eficiente de Windows.
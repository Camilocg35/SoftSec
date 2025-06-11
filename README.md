# SoftSec

**SoftSec** es una herramienta integral para la administración, soporte y optimización de sistemas Windows, diseñada para técnicos y usuarios avanzados que buscan centralizar tareas críticas de mantenimiento, seguridad y diagnóstico desde una interfaz gráfica intuitiva.

---

## Características principales

- **Gestión de usuarios locales:**  
  Crear, eliminar y modificar cuentas de usuario de Windows de manera segura.
- **Administración de servicios:**  
  Visualizar, filtrar, iniciar, detener y reiniciar servicios del sistema.
- **Optimización del sistema:**  
  Limpieza de archivos temporales, caché y liberación de memoria RAM.
- **Recuperación de archivos:**  
  Integración guiada con Windows File Recovery (WinFR).
- **Información del sistema:**  
  Visualización de hardware, uso de disco, red, tiempo de actividad y más.
- **Interfaz gráfica amigable:**  
  Navegación sencilla, mensajes claros, validaciones y protección contra acciones peligrosas.

---

## Casos de uso

### 1. Soporte técnico en empresas
Un técnico recibe un reporte por lentitud en una PC. Con SoftSec, limpia archivos temporales, libera memoria RAM, revisa servicios en ejecución y restablece contraseñas olvidadas, todo desde una sola aplicación.

### 2. Mantenimiento de laboratorios informáticos
El administrador utiliza SoftSec para listar usuarios, eliminar cuentas de alumnos antiguos y limpiar cachés de navegadores antes de cada ciclo escolar.

### 3. Recuperación de archivos importantes
Al eliminar accidentalmente documentos, el usuario ejecuta la función de recuperación, que opera WinFR de manera guiada, facilitando la restauración sin necesidad de comandos complejos.

### 4. Optimización preventiva en casa u oficina
El usuario avanzado programa limpiezas periódicas con SoftSec, manteniendo el equipo ágil y seguro, consultando el estado de hardware y red para planificar actualizaciones.

---

## Requisitos

- **Sistema operativo:** Windows 10/11
- **Permisos:** Se recomienda ejecutar como administrador
- **Dependencias:** PowerShell 5.1+, módulos integrados de Windows
- **(Opcional)**: WinFR para recuperación avanzada

---

## Instalación

1. Descarga el paquete SoftSec desde el repositorio oficial.
2. Extrae los archivos en una carpeta local.
3. Ejecuta `SoftSec.ps1` o el lanzador proporcionado, preferentemente como administrador.

---

## Extensibilidad y futuras mejoras

SoftSec está pensado para crecer. Puedes proponer o desarrollar módulos para:
- Administración avanzada de red (escaneo de dispositivos, cambio de IP/DNS, etc.)
- Gestión de impresoras y hardware
- Integración con Active Directory o políticas de grupo
- Auditoría y bitácora de acciones

---

## Licencia

Este proyecto se distribuye bajo la licencia MIT.  
**Toda copia o redistribución debe mantener el nombre del autor original: Camilo CG**  
Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

## Preguntas frecuentes

**¿SoftSec puede dañar mi sistema?**  
No, todas las acciones incluyen validaciones robustas y advertencias ante operaciones críticas.

**¿Puedo ejecutar SoftSec sin ser administrador?**  
Algunas funciones requieren permisos elevados. Se recomienda ejecutarlo como administrador.

**¿Es seguro limpiar archivos y memoria con SoftSec?**  
Sí, las operaciones de limpieza eliminan solo archivos temporales y memoria no esencial.

---

## Contacto y contribuciones

¿Quieres colaborar o tienes sugerencias?  
Abre un *issue* en el repositorio o contacta a los mantenedores mediante la sección de issues de GitHub.

---

> **SoftSec**: Tu aliada para la administración eficiente y segura de Windows.

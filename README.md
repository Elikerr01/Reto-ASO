# -- Descripción del proyecto --

El proyecto consiste en crear un Sistema de Gestión de Servidores completo en ShellScript, permitiendo gestionar múltiples servidores de forma automatizada.

# -- Instrucciones de instalación y uso --

## Pasos a seguir:

Primer paso: Clonar el repositorio o descargar los archivos en un directorio local.

Segundo paso: Dar permisos de ejecución a los scripts principales.

Tercer paso: Ejecutar el sistema desde la terminal.

# -- Explicación de cada módulo --

## Menú Principal Interactivo

Archivo principal que muestra un menú interactivo usando select. Permite navegar por todas las funcionalidades del sistema, en este caso:

-Gestión de servidores

-Monitoreo del sistema

-Copias de seguridad

-Gestión de logs

-Configuración

-Salir

## Funciones_servidor.sh

En este script podremos gestionar los servidores que tenemos, las funciones principales que tiene son:

-añadir_servidor(): Añade un nuevo servidor.

-listar_servidores(): Muestra todos los servidores.

-buscar_servidor(): Busca servidores por nombre, IP o estado.

-modificar_servidor(): Edita la información de un servidor.

-eliminar_servidor(): Borra un servidor de la lista.

-ordenar_servidores(): Ordena los servidores alfabéticamente.

## Monitoreo.sh

Con este script podemos monitorear los servidores y el sistema, las funciones principales que tiene son:

-monitorear_servidores(): Verifica la conectividad del servidor que le hemos dado usando un ping y genera un informe de estado (activo/inactivo).
-estadisticas_sistema(): Muestra información del sistema local, cuenta servidores activos y inactivos y calcula el porcentaje de disponibilidad.

## backup.sh

Sistema de copias de seguridad de la configuración y datos del sistema, sus funciones son:

crear_backup(): Crea un directorio de backup con fecha, copia archivos de configuración y los comprime en .tar.gz. Y genera un log del backup.

restaurar_backup(): Lista los backups disponibles y permite seleccionar y restaurar un backup.

## configuracion.conf

Archivo de configuración donde se definen parámetros generales del sistema, como rutas de archivos, formatos de logs y ajustes de backup.


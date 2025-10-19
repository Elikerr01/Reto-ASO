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

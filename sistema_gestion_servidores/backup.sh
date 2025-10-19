#!/bin/bash
# =====================================================
# Script: backup.sh
# Descripción: Crear y restaurar backups del archivo "servidores.txt".
# Incluye un log con las operaciones realizadas.
# =====================================================

# --- VARIABLES GLOBALES ---
BACKUP_DIR="./backups"      # Carpeta donde se guardarán los backups
LOG_FILE="./backup.log"     # Archivo donde se registrarán los eventos (logs)
ARCHIVO_ORIGEN="servidores.txt"  # Archivo a respaldar

# ---------------------------------------------
# FUNCIÓN: crear_backup
# Crea un backup comprimido del archivo servidores.txt
# ---------------------------------------------
crear_backup() {
    FECHA=$(date +"%Y-%m-%d_%H-%M-%S")              # Genera la fecha y hora actual (para el nombre del backup)
    NOMBRE_BACKUP="backup_$FECHA.tar.gz"            # Nombre del archivo de backup con fecha
    RUTA_BACKUP="$BACKUP_DIR/$NOMBRE_BACKUP"        # Ruta completa donde se guardará el backup

    echo "Iniciando backup..."
    mkdir -p "$BACKUP_DIR"                          # Crea el directorio de backups si no existe

    # Verifica si el archivo a respaldar existe
    if [ -f "$ARCHIVO_ORIGEN" ]; then
        tar -czf "$RUTA_BACKUP" "$ARCHIVO_ORIGEN"   # Crea un archivo comprimido (tar.gz) del archivo original
        # Registra en el log el éxito
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup creado: $NOMBRE_BACKUP" >> "$LOG_FILE"
        echo "✅ Backup creado correctamente: $RUTA_BACKUP"
    else
        # Si no se encuentra el archivo, se muestra advertencia y se registra error
        echo "⚠️ No se encontró el archivo $ARCHIVO_ORIGEN"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: No se encontró $ARCHIVO_ORIGEN" >> "$LOG_FILE"
    fi
}

# ---------------------------------------------
# FUNCIÓN: restaurar_backup
# Permite al usuario elegir un backup y restaurarlo
# ---------------------------------------------
restaurar_backup() {
    echo "Backups disponibles:"
    echo "--------------------"

    # Verifica si existe el directorio de backups
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "⚠️ No existe el directorio de backups."
        return
    fi

    # Obtiene lista de archivos .tar.gz ordenados del más nuevo al más viejo
    BACKUPS=($(ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null))

    # Si no hay archivos, se muestra advertencia
    if [ ${#BACKUPS[@]} -eq 0 ]; then
        echo "⚠️ No hay backups disponibles."
        return
    fi

    # Muestra una lista numerada de los backups encontrados
    for i in "${!BACKUPS[@]}"; do
        echo "$((i+1)). ${BACKUPS[$i]}"
    done

    echo
    # Solicita al usuario que elija qué backup restaurar
    read -p "Ingresa 'servidores.txt' para restaurar el último backup o el número del que quieras: " OPCION

    # Si el usuario deja vacío o escribe 'servidores.txt', se restaura el más reciente
    if [ "$OPCION" = "servidores.txt" ] || [ -z "$OPCION" ]; then
        ARCHIVO_SELECCIONADO="${BACKUPS[0]}"
        echo "🔄 Restaurando el último backup: $(basename "$ARCHIVO_SELECCIONADO")"
    # Si el usuario ingresa un número válido dentro del rango
    elif [[ "$OPCION" =~ ^[0-9]+$ ]] && [ "$OPCION" -le "${#BACKUPS[@]}" ]; then
        ARCHIVO_SELECCIONADO="${BACKUPS[$((OPCION-1))]}"
        echo "🔄 Restaurando backup: $(basename "$ARCHIVO_SELECCIONADO")"
    else
        # Si no cumple ninguna condición, opción inválida
        echo "⚠️ Opción inválida."
        return
    fi

    # Extrae el archivo seleccionado en el directorio actual
    tar -xzf "$ARCHIVO_SELECCIONADO" -C ./

    # Verifica si la extracción fue exitosa
    if [ $? -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup restaurado: $(basename "$ARCHIVO_SELECCIONADO")" >> "$LOG_FILE"
        echo "✅ Backup restaurado correctamente en el directorio principal."
    else
        echo "⚠️ Error al restaurar el backup."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR al restaurar $(basename "$ARCHIVO_SELECCIONADO")" >> "$LOG_FILE"
    fi
}

# ---------------------------------------------
# MENÚ PRINCIPAL
# Muestra las opciones al usuario en un bucle infinito hasta que elija salir
# ---------------------------------------------
while true; do
    clear                                           # Limpia la pantalla
    echo "============================"
    echo "     GESTIÓN DE BACKUPS"
    echo "============================"
    echo "1) Crear backup"
    echo "2) Restaurar backup"
    echo "3) Ver log de backups"
    echo "4) Salir"
    echo "----------------------------"
    read -p "Selecciona una opción: " OPCION        # Espera la entrada del usuario

    # Dependiendo de la opción elegida, ejecuta la función correspondiente
    case $OPCION in
        1) crear_backup ;;                          # Llama a la función crear_backup
        2) restaurar_backup ;;                      # Llama a la función restaurar_backup
        3) echo; cat "$LOG_FILE"; read -p "Presiona Enter para continuar..." ;;  # Muestra el contenido del log
        4) echo "Saliendo..."; exit 0 ;;            # Sale del script
        *) echo "Opción inválida." ;;               # Cualquier otra entrada es inválida
    esac
done


#!/bin/bash

# =====================================================
# Script: backup.sh
# Descripción: Crear y restaurar backups de servidores.txt
# =====================================================

BACKUP_DIR="./backups"
LOG_FILE="./backup.log"
ARCHIVO_ORIGEN="servidores.txt"

# ---------------------------------------------
# Función: crear_backup
# ---------------------------------------------
crear_backup() {
    FECHA=$(date +"%Y-%m-%d_%H-%M-%S")
    NOMBRE_BACKUP="backup_$FECHA.tar.gz"
    RUTA_BACKUP="$BACKUP_DIR/$NOMBRE_BACKUP"

    echo "Iniciando backup..."
    mkdir -p "$BACKUP_DIR"

    if [ -f "$ARCHIVO_ORIGEN" ]; then
        tar -czf "$RUTA_BACKUP" "$ARCHIVO_ORIGEN"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup creado: $NOMBRE_BACKUP" >> "$LOG_FILE"
        echo "✅ Backup creado correctamente: $RUTA_BACKUP"
    else
        echo "⚠️ No se encontró el archivo $ARCHIVO_ORIGEN"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: No se encontró $ARCHIVO_ORIGEN" >> "$LOG_FILE"
    fi
}

# ---------------------------------------------
# Función: restaurar_backup
# ---------------------------------------------
restaurar_backup() {
    echo "Backups disponibles:"
    echo "--------------------"

    if [ ! -d "$BACKUP_DIR" ]; then
        echo "⚠️ No existe el directorio de backups."
        return
    fi

    BACKUPS=($(ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null))
    if [ ${#BACKUPS[@]} -eq 0 ]; then
        echo "⚠️ No hay backups disponibles."
        return
    fi

    for i in "${!BACKUPS[@]}"; do
        echo "$((i+1)). ${BACKUPS[$i]}"
    done

    echo
    read -p "Ingresa 'servidores.txt' para restaurar el último backup o el número del que quieras: " OPCION

    if [ "$OPCION" = "servidores.txt" ] || [ -z "$OPCION" ]; then
        ARCHIVO_SELECCIONADO="${BACKUPS[0]}"
        echo "🔄 Restaurando el último backup: $(basename "$ARCHIVO_SELECCIONADO")"
    elif [[ "$OPCION" =~ ^[0-9]+$ ]] && [ "$OPCION" -le "${#BACKUPS[@]}" ]; then
        ARCHIVO_SELECCIONADO="${BACKUPS[$((OPCION-1))]}"
        echo "🔄 Restaurando backup: $(basename "$ARCHIVO_SELECCIONADO")"
    else
        echo "⚠️ Opción inválida."
        return
    fi

    tar -xzf "$ARCHIVO_SELECCIONADO" -C ./
    if [ $? -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup restaurado: $(basename "$ARCHIVO_SELECCIONADO")" >> "$LOG_FILE"
        echo "✅ Backup restaurado correctamente en el directorio principal."
    else
        echo "⚠️ Error al restaurar el backup."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR al restaurar $(basename "$ARCHIVO_SELECCIONADO")" >> "$LOG_FILE"
    fi
}

# ---------------------------------------------
# Menú principal
# ---------------------------------------------
while true; do
    clear
    echo "============================"
    echo "     GESTIÓN DE BACKUPS"
    echo "============================"
    echo "1) Crear backup"
    echo "2) Restaurar backup"
    echo "3) Ver log de backups"
    echo "4) Salir"
    echo "----------------------------"
    read -p "Selecciona una opción: " OPCION

    case $OPCION in
        1) crear_backup ;;
        2) restaurar_backup ;;
        3) echo; cat "$LOG_FILE"; read -p "Presiona Enter para continuar..." ;;
        4) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción inválida." ;;
    esac
done

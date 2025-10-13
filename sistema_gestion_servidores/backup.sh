#!/bin/bash

DIR_CONFIG="/etc"                   # Directorio con archivos de configuración (puedes cambiarlo)
DIR_BACKUP="$HOME/backups_config"  # Directorio base para backups
LOG_BACKUP="$DIR_BACKUP/backup.log"

crear_backup() {
    fecha=$(date +%Y-%m-%d_%H-%M-%S)
    dir_backup_fecha="$DIR_BACKUP/backup_$fecha"

    mkdir -p "$dir_backup_fecha"

    echo "[$(date)] Iniciando backup..." | tee -a "$LOG_BACKUP"

    # Copiar archivos de configuración
    cp -r "$DIR_CONFIG"/* "$dir_backup_fecha/"

    # Comprimir el backup
    archivo_comprimido="$DIR_BACKUP/backup_$fecha.tar.gz"
    tar -czf "$archivo_comprimido" -C "$DIR_BACKUP" "backup_$fecha"

    # Eliminar la carpeta temporal después de comprimir
    rm -rf "$dir_backup_fecha"

    echo "[$(date)] Backup completado: $archivo_comprimido" | tee -a "$LOG_BACKUP"
}

restaurar_backup() {
    echo "Backups disponibles:"
    backups=("$DIR_BACKUP"/backup_*.tar.gz)

    if [ ${#backups[@]} -eq 0 ]; then
        echo "No se encontraron backups."
        return 1
    fi

    for i in "${!backups[@]}"; do
        echo "$i) ${backups[$i]}"
    done

    read -rp "Selecciona el número del backup a restaurar: " opcion

    if ! [[ "$opcion" =~ ^[0-9]+$ ]] || [ "$opcion" -ge "${#backups[@]}" ]; then
        echo "Opción inválida."
        return 1
    fi

    archivo_seleccionado="${backups[$opcion]}"

    echo "Restaurando backup desde $archivo_seleccionado..."

    # Descomprimir directamente en el directorio de configuración (con precaución)
    tar -xzf "$archivo_seleccionado" -C "$DIR_BACKUP"

    carpeta_extraida=$(basename "$archivo_seleccionado" .tar.gz)
    src_backup="$DIR_BACKUP/$carpeta_extraida"

    if [ ! -d "$src_backup" ]; then
        echo "Error: carpeta extraída no encontrada."
        return 1
    fi

    # Copiar archivos restaurados al directorio original (requiere permisos)
    sudo cp -r "$src_backup"/* "$DIR_CONFIG"/

    # Limpiar carpeta extraída
    rm -rf "$src_backup"

    echo "Restauración completada."
}

# Para probar puedes descomentar estas líneas:

# crear_backup
# restaurar_backup

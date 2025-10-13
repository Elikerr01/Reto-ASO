#!/bin/bash

source configuracion.conf

crear_backup() {
    fecha=$(date +"%Y%m%d_%H%M%S")
    backup_dir="${DIR_BACKUPS}/backup_${fecha}"
    mkdir -p "$backup_dir"

    # Copiar archivos relevantes (configuración y lista de servidores)
    cp configuracion.conf "$backup_dir/"
    cp "$ARCHIVO_SERVIDORES" "$backup_dir/" 2>/dev/null || touch "$backup_dir/servidores.txt"
    cp "$ARCHIVO_ESTADO" "$backup_dir/" 2>/dev/null || touch "$backup_dir/estado_servidores.log"

    # Comprimir backup
    tar -czf "${backup_dir}.tar.gz" -C "$DIR_BACKUPS" "backup_${fecha}"

    # Eliminar carpeta temporal
    rm -rf "$backup_dir"

    # Log de backup
    echo "Backup creado en ${backup_dir}.tar.gz el $(date)" >> backup.log

    echo "Backup creado correctamente: ${backup_dir}.tar.gz"
}

restaurar_backup() {
    if [ ! -d "$DIR_BACKUPS" ]; then
        echo "No existen backups."
        return
    fi

    echo "Backups disponibles:"
    ls -1 "$DIR_BACKUPS"/*.tar.gz 2>/dev/null | nl -w2 -s'. '

    read -rp "Seleccione número de backup a restaurar: " num
    backup_sel=$(ls -1 "$DIR_BACKUPS"/*.tar.gz 2>/dev/null | sed -n "${num}p")

    if [ -z "$backup_sel" ]; then
        echo "Selección inválida."
        return
    fi

    echo "Restaurando backup: $backup_sel"
    tar -xzf "$backup_sel" -C "$DIR_BACKUPS"
    backup_folder=$(basename "$backup_sel" .tar.gz)

    # Copiar archivos restaurados a raíz
    cp "$DIR_BACKUPS/$backup_folder/configuracion.conf" .
    cp "$DIR_BACKUPS/$backup_folder/$(basename $ARCHIVO_SERVIDORES)" .
    cp "$DIR_BACKUPS/$backup_folder/$(basename $ARCHIVO_ESTADO)" .

    echo "Backup restaurado correctamente."
}


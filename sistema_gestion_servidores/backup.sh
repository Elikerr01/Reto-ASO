#!/bin/bash
DIR_BACKUP="backups"
mkdir -p "$DIR_BACKUP"
LOG_BACKUP="backup.log"

crear_backup() {
    fecha=$(date +%Y-%m-%d_%H-%M-%S)
    destino="$DIR_BACKUP/backup_$fecha.tar.gz"
    tar -czf "$destino" servidores.txt
    echo "[$fecha] Backup creado: $destino" >> "$LOG_BACKUP"
    echo "Backup creado exitosamente."
}

restaurar_backup() {
    echo "Backups disponibles:"
    select archivo in "$DIR_BACKUP"/backup_*.tar.gz "Cancelar"; do
        [[ "$archivo" == "Cancelar" ]] && break
        if [[ -f "$archivo" ]]; then
            tar -xzf "$archivo"
            echo "Backup restaurado desde $archivo"
            break
        fi
    done
}

menu_backup() {
    select op in "Crear backup" "Restaurar backup" "Volver"; do
        case $REPLY in
            1) crear_backup ;;
            2) restaurar_backup ;;
            3) break ;;
            *) echo "Opción inválida" ;;
        esac
    done
}

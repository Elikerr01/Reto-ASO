#!/bin/bash
LOG_SISTEMA="/var/log/syslog"  # Cambia si usas otro sistema

ver_logs() {
    read -rp "Filtrar por fecha (opcional): " fecha
    read -rp "Filtrar por tipo (ERROR, INFO, etc.): " tipo

    if [[ -n "$fecha" || -n "$tipo" ]]; then
        grep "$fecha" "$LOG_SISTEMA" | grep -i "$tipo"
    else
        tail -n 50 "$LOG_SISTEMA"
    fi

    echo "Líneas con 'error':"
    grep -ic "error" "$LOG_SISTEMA"
}

limpiar_logs() {
    mkdir -p logs_archivados
    find /var/log -name "*.log" -size +0 -mtime +7 -exec mv {} logs_archivados/ \;
    find /var/log -name "*.log" -size 0 -delete
    echo "Logs antiguos archivados y logs vacíos eliminados."
}

menu_logs() {
    select op

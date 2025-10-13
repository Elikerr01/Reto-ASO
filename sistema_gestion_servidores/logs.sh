#!/bin/bash

source configuracion.conf

ver_logs() {
    echo "Logs disponibles:"
    ls -1 *.log 2>/dev/null
    read -rp "Ingrese el nombre del log a visualizar: " log_file

    if [ ! -f "$log_file" ]; then
        echo "Archivo de log no encontrado."
        return
    fi

    echo "Opciones de filtro:"
    echo "1) Mostrar todo"
    echo "2) Filtrar por fecha (YYYY-MM-DD)"
    echo "3) Filtrar por tipo (error, warning, info)"
    read -rp "Seleccione opción: " opcion

    case $opcion in
        1)
            cat "$log_file"
            ;;
        2)
            read -rp "Ingrese fecha (YYYY-MM-DD): " fecha
            grep "$fecha" "$log_file"
            ;;
        3)
            read -rp "Ingrese tipo (error/warning/info): " tipo
            grep -i "$tipo" "$log_file"
            ;;
        *)
            echo "Opción inválida."
            ;;
    esac

    echo ""
    echo "Número de líneas que contienen 'error':"
    grep -ic "error" "$log_file"
}

limpiar_logs() {
    echo "Archivando logs antiguos (más de 30 días)..."
    find . -name "*.log" -type f -mtime +30 -exec gzip {} \;

    echo "Eliminando logs vacíos..."
    find . -name "*.log" -type f -empty -delete

    echo "Limpieza de logs completada."


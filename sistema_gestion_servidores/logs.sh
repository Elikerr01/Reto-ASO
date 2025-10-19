#!/bin/bash

LOG_DIR="./logs"
ARCHIVE_DIR="./logs_archivo"

# Crear carpetas si no existen
mkdir -p "$LOG_DIR"
mkdir -p "$ARCHIVE_DIR"

ver_logs() {
    local fecha="$1"
    local tipo="$2"
    local total_errores=0

    echo "=== Mostrando logs del sistema ==="
    echo "Filtro fecha: ${fecha:-Ninguno}"
    echo "Filtro tipo: ${tipo:-Ninguno}"
    echo "---------------------------------"

    for archivo in "$LOG_DIR"/*; do
        [ -f "$archivo" ] || continue

        # Filtro por fecha en el nombre del archivo
        if [ -n "$fecha" ] && [[ "$archivo" != *"$fecha"* ]]; then
            continue
        fi

        while IFS= read -r linea; do
            # Filtrar por tipo (error, info, debug, etc.)
            if [ -z "$tipo" ] || echo "$linea" | grep -qi "$tipo"; then
                echo "$linea"
            fi

            # Contar líneas con error
            if echo "$linea" | grep -qi "error"; then
                ((total_errores++))
            fi
        done < "$archivo"
    done

    echo "---------------------------------"
    echo "Total de líneas con error: $total_errores"
}

limpiar_logs() {
    local dias_antiguos="${1:-7}"

    echo "=== Limpiando logs ==="
    echo "Archivando logs con más de $dias_antiguos días..."

    # Mover logs antiguos al archivo
    find "$LOG_DIR" -type f -mtime +$dias_antiguos -exec mv {} "$ARCHIVE_DIR" \;

    echo "Eliminando logs vacíos..."
    find "$LOG_DIR" -type f -empty -delete

    echo "Limpieza completada."
}

# === Menú principal ===
case "$1" in
    ver)
        ver_logs "$2" "$3"
        ;;
    limpiar)
        limpiar_logs "$2"
        ;;
    *)
        echo "Uso: $0 {ver [fecha] [tipo] | limpiar [dias]}"
        echo "Ejemplos:"
        echo "  $0 ver                     # Muestra todos los logs"
        echo "  $0 ver 2025-10-19 error     # Filtra por fecha y tipo"
        echo "  $0 limpiar 10              # Archiva logs con más de 10 días"
        ;;
esac


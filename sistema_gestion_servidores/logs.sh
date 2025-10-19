#!/bin/bash

# ==============================
# CONFIGURACIÓN
# ==============================
LOG_DIR="./logs"
ARCHIVE_DIR="./logs_archivo"
mkdir -p "$LOG_DIR" "$ARCHIVE_DIR"


# ==============================
# FUNCIONES DE GESTIÓN DE LOGS
# ==============================

ver_logs() {
    clear
    echo "===== VER LOGS ====="
    echo "¿Deseas filtrar por fecha? (ejemplo: 2025-10-19) o deja vacío para no filtrar:"
    read -p "Fecha: " fecha
    echo "¿Deseas filtrar por tipo (error, info, debug...)? o deja vacío:"
    read -p "Tipo: " tipo
    echo
    echo "=== Mostrando logs ==="
    echo "Filtro fecha: ${fecha:-Ninguno}"
    echo "Filtro tipo: ${tipo:-Ninguno}"
    echo "---------------------------------"

    local total_errores=0

    for archivo in "$LOG_DIR"/*; do
        [ -f "$archivo" ] || continue

        # Filtrar por fecha (en el nombre del archivo)
        if [ -n "$fecha" ] && [[ "$archivo" != *"$fecha"* ]]; then
            continue
        fi

        while IFS= read -r linea; do
            # Filtro por tipo
            if [ -z "$tipo" ] || echo "$linea" | grep -qi "$tipo"; then
                echo "$linea"
            fi

            # Contar errores
            if echo "$linea" | grep -qi "error"; then
                ((total_errores++))
            fi
        done < "$archivo"
    done

    echo "---------------------------------"
    echo "Total de líneas con error: $total_errores"
    echo
    read -p "Presiona Enter para volver al menú..."
}

limpiar_logs() {
    clear
    echo "===== LIMPIAR LOGS ====="
    read -p "Introduce los días a conservar (por defecto 7): " dias
    dias=${dias:-7}

    echo "Archivando logs con más de $dias días..."
    find "$LOG_DIR" -type f -mtime +$dias -exec mv {} "$ARCHIVE_DIR" \;

    echo "Eliminando logs vacíos..."
    find "$LOG_DIR" -type f -empty -delete

    echo "Limpieza completada."
    echo
    read -p "Presiona Enter para volver al menú..."
}


# ==============================
# MENÚS
# ==============================

menu_gestion_logs() {
    while true; do
        clear
        echo "===== GESTIÓN DE LOGS ====="
        echo "1) Ver logs"
        echo "2) Limpiar logs"
        echo "3) Volver al menú principal"
        echo "============================"
        read -p "Elige una opción: " opcion_logs

        case $opcion_logs in
            1) ver_logs ;;
            2) limpiar_logs ;;
            3) break ;;
            *) echo "Opción inválida."; sleep 1 ;;
        esac
    done
}


menu_principal() {
    while true; do
        clear
        echo "========= MENÚ PRINCIPAL ========="
        echo "1) Gestión de Logs"
        echo "2) Salir"
        echo "=================================="
        read -p "Selecciona una opción: " opcion

        case $opcion in
            1) menu_gestion_logs ;;
            2) echo "Saliendo..."; exit 0 ;;
            *) echo "Opción inválida."; sleep 1 ;;
        esac
    done
}


# ==============================
# INICIO DEL PROGRAMA
# ==============================
menu_principal


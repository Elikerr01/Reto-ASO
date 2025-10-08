#!/bin/bash

# ===============================================
# Menú principal interactivo con select
# ===============================================

# -------- Funciones del menú --------

gestion_servidores() {
    echo "=== Gestión de Servidores ==="
    echo "Aquí podrías listar, agregar o eliminar servidores."
    # Simulación de acción
    sleep 1
}

monitoreo_sistema() {
    echo "=== Monitoreo del Sistema ==="
    echo "Mostrando uso de CPU, RAM y espacio en disco..."
    echo
    echo "CPU:" $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')"% usado"
    echo "RAM:" $(free -m | awk '/Mem:/ {print $3 "MB usados de " $2 "MB"}')
    echo "Disco:" $(df -h / | awk 'NR==2 {print $5 " usado"}')
    sleep 2
}

copias_seguridad() {
    echo "=== Copias de Seguridad ==="
    echo "Ejecutando respaldo simulado..."
    sleep 1
    echo "✅ Copia completada."
}

gestion_logs() {
    echo "=== Gestión de Logs ==="
    echo "Mostrando últimos 5 registros del syslog..."
    sudo tail -n 5 /var/log/syslog 2>/dev/null || echo "No se puede acceder al syslog."
}

configuracion() {
    echo "=== Configuración del Sistema ==="
    echo "Aquí podrías editar parámetros del sistema."
    sleep 1
}

salir() {
    echo "Saliendo del programa..."
    exit 0
}

# -------- Menú principal --------

while true; do
    echo
    echo "===== MENÚ PRINCIPAL ====="
    PS3="Seleccione una opción (1-6): "

    options=("Gestión de servidores" "Monitoreo del sistema" "Copias de seguridad" "Gestión de logs" "Configuración" "Salir")

    select opt in "${options[@]}"; do
        case $REPLY in
            1) gestion_servidores; break ;;
            2) monitoreo_sistema; break ;;
            3) copias_seguridad; break ;;
            4) gestion_logs; break ;;
            5) configuracion; break ;;
            6) salir ;;
            *) echo "❌ Opción inválida. Intente de nuevo."; break ;;
        esac
    done
done


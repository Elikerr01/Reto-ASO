 #!/bin/bash

# ===============================================
# Menú principal interactivo con select
# ===============================================

# -------- Funciones del menú --------

gestion_servidores() {
    echo "=== Gestión de Servidores ==="
    ./funciones_servidor.sh
}

monitoreo_sistema() {
    echo "=== Monitoreo del Sistema ==="
    ./monitoreo.sh
}

copias_seguridad() {
    echo "=== Copias de Seguridad ==="
    ./backup.sh
}

gestion_logs() {
    echo "=== Gestión de Logs ==="
    ./logs.sh
}

configuracion() {
    echo "=== Configuración del Sistema ==="
    cat configuracion.conf
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


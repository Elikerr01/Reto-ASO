#!/bin/bash

# Cargar configuración
source configuracion.conf
source funciones_servidor.sh
source monitoreo.sh
source backup.sh
source logs.sh

clear
echo "=== Sistema de Gestión de Servidores ==="

PS3="Seleccione una opción: "
options=("Gestión de servidores" "Monitoreo del sistema" "Copias de seguridad" "Gestión de logs" "Configuración" "Salir")

select opt in "${options[@]}"; do
    case $REPLY in
        1) menu_gestion_servidores ;;
        2) menu_monitoreo ;;
        3) menu_backup ;;
        4) menu_logs ;;
        5) nano configuracion.conf ;;
        6) echo "Saliendo..."; exit ;;
        *) echo "Opción inválida. Intente nuevamente." ;;
    esac
done

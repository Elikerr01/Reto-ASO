#!/bin/bash
LOG_ESTADO="estado_servidores.log"

monitorear_servidores() {
    echo "Estado de servidores:" > "$LOG_ESTADO"
    while IFS="#" read -r nombre ip puerto estado desc; do
        if ping -c 1 -W 1 "$ip" &>/dev/null; then
            echo "$nombre#$ip#activo" >> "$LOG_ESTADO"
        else
            echo "$nombre#$ip#inactivo" >> "$LOG_ESTADO"
        fi
    done < servidores.txt
    echo "Monitoreo completado. Resultados en $LOG_ESTADO"
}

estadisticas_sistema() {
    total=$(wc -l < "$LOG_ESTADO")
    activos=$(grep -c "activo" "$LOG_ESTADO")
    inactivos=$(grep -c "inactivo" "$LOG_ESTADO")
    porcentaje=$(echo "scale=2; $activos / $total * 100" | bc)
    echo "Total: $total | Activos: $activos | Inactivos: $inactivos | Disponibilidad: $porcentaje%"
}

menu_monitoreo() {
    select op in "Monitorear servidores" "Ver estadísticas" "Volver"; do
        case $REPLY in
            1) monitorear_servidores ;;
            2) estadisticas_sistema ;;
            3) break ;;
            *) echo "Opción inválida" ;;
        esac
    done
}

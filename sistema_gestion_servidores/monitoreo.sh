#!/bin/bash

ARCHIVO_SERVIDORES="servidores.txt"
ARCHIVO_ESTADO="estado_servidores.log"

monitorear_servidores() {
    > "$ARCHIVO_ESTADO"  # Limpiar archivo de estado

    while IFS= read -r servidor || [[ -n "$servidor" ]]; do
        if ping -c 1 -W 1 "$servidor" &>/dev/null; then
            echo "$servidor activo" >> "$ARCHIVO_ESTADO"
        else
            echo "$servidor inactivo" >> "$ARCHIVO_ESTADO"
        fi
    done < "$ARCHIVO_SERVIDORES"
}

estadisticas_sistema() {
    echo "Información del sistema:"
    uname -a

    total=$(wc -l < "$ARCHIVO_ESTADO")
    activos=$(grep -c "activo" "$ARCHIVO_ESTADO")
    inactivos=$(grep -c "inactivo" "$ARCHIVO_ESTADO")

    echo "Servidores totales: $total"
    echo "Servidores activos: $activos"
    echo "Servidores inactivos: $inactivos"

    if [[ $total -gt 0 ]]; then
        porcentaje=$(echo "scale=2; ($activos / $total) * 100" | bc)
        echo "Porcentaje de disponibilidad: $porcentaje %"
    else
        echo "No hay servidores para monitorear."
    fi
}

# Ejecutar funciones
monitorear_servidores
estadisticas_sistema

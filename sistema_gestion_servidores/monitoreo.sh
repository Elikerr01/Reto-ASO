#!/bin/bash
#
# monitoreo.sh
# Funciones:
# - monitorear_servidores: comprueba conectividad TCP al puerto (usa nc) y guarda resultados.
# - estadisticas_sistema: muestra estadísticas y porcentaje de disponibilidad.
#

# Cargar configuración (ARCHIVO_SERVIDORES, ARCHIVO_ESTADO, etc.)
source configuracion.conf

# Archivo donde guardaremos resultados de monitoreo
# ARCHIVO_ESTADO debe venir de configuracion.conf; si no, usamos por defecto
ARCHIVO_ESTADO="${ARCHIVO_ESTADO:-estado_servidores.log}"

# monitorear_servidores:
# Lee ARCHIVO_SERVIDORES y para cada entrada intenta conexión TCP con nc.
# Guarda un informe con formato: nombre#ip#puerto#estado_actual#descripcion
monitorear_servidores() {
    if [ ! -s "$ARCHIVO_SERVIDORES" ]; then
        echo "No hay servidores registrados para monitorear."
        return
    fi

    # Cabecera con fecha
    echo "Estado de servidores (fecha: $(date '+%Y-%m-%d %H:%M:%S'))" > "$ARCHIVO_ESTADO"
    echo "-----------------------------------" >> "$ARCHIVO_ESTADO"

    # Leer cada servidor y comprobar puerto con nc (-z: scan, -w: timeout)
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        # Intentamos conexión TCP usando nc con timeout 2 segundos
        # nc -z -w 2 IP PUERTO devuelve 0 si se conecta correctamente
        if nc -z -w 2 "$ip" "$puerto" >/dev/null 2>&1; then
            estado_actual="activo"
        else
            estado_actual="inactivo"
        fi

        # Guardar resultado en el archivo de estado
        echo "${nombre}#${ip}#${puerto}#${estado_actual}#${descripcion}" >> "$ARCHIVO_ESTADO"
    done < "$ARCHIVO_SERVIDORES"

    echo "Monitoreo completado. Resultados guardados en $ARCHIVO_ESTADO"
}

# estadisticas_sistema:
# - Cuenta servidores totales, activos e inactivos en ARCHIVO_ESTADO
# - Calcula porcentaje de disponibilidad
# - Muestra info básica del sistema local
estadisticas_sistema() {
    if [ ! -s "$ARCHIVO_ESTADO" ]; then
        echo "No hay datos de estado para mostrar estadísticas. Ejecute monitorear_servidores primero."
        return
    fi

    # Contar líneas útiles (ignorar 2 primeras de cabecera si existen)
    total_lineas=$(grep -c "^" "$ARCHIVO_ESTADO")
    # Si el archivo tiene cabecera de 2 líneas, lo consideramos
    if [ "$total_lineas" -ge 2 ]; then
        total=$((total_lineas - 2))
    else
        total=$total_lineas
    fi

    # Contar activos por aparición de '#activo#' en la línea
    activos=$(grep -c "#activo#" "$ARCHIVO_ESTADO" || true)
    inactivos=$((total - activos))

    # Evitar división por cero
    if [ "$total" -gt 0 ]; then
        # bc para cálculo con decimales
        porcentaje=$(echo "scale=2; ($activos / $total) * 100" | bc 2>/dev/null)
    else
        porcentaje="0.00"
    fi

    echo "Estadísticas del sistema:"
    echo "Servidores totales: $total"
    echo "Servidores activos: $activos"
    echo "Servidores inactivos: $inactivos"
    echo "Porcentaje de disponibilidad: ${porcentaje}%"
    echo ""

    # Información local del sistema
    echo "Información local del sistema:"
    uname -a
    echo "Uptime: $(uptime -p 2>/dev/null)"
    echo "Memoria (free -h):"
    free -h 2>/dev/null || echo "(comando free no disponible)"
}


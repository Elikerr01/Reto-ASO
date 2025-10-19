#!/bin/bash
# =====================================================
# Script: monitoreo.sh
# Descripción: Simula un ping a los servidores definidos
# en "servidores.txt" y muestra estadísticas del sistema.
# =====================================================

# Archivos usados
ARCHIVO_SERVIDORES="servidores.txt"  # Archivo donde se almacenan los servidores
ARCHIVO_ESTADO="servidores.txt"      # (Se usa el mismo archivo para obtener estadísticas)

# ---------------------------------------------
# FUNCIÓN: simular_ping
# Simula un "ping" comprobando si el puerto del servidor está accesible.
# ---------------------------------------------
simular_ping() {
    echo "=== Simular ping ==="
    
    # Verifica que el archivo de servidores exista
    if [[ ! -f "$ARCHIVO_SERVIDORES" ]]; then
        echo "Error: No se encontró el archivo $ARCHIVO_SERVIDORES"
        return 1  # Sale con error si no existe el archivo
    fi
    
    # Solicita el nombre del servidor a comprobar
    read -p "Nombre del servidor para hacer ping: " nombre
    
    # Busca en el archivo una línea que empiece con el nombre (separador '#')
    linea=$(grep "^$nombre#" "$ARCHIVO_SERVIDORES")
    
    # Si no se encuentra coincidencia, muestra mensaje y termina
    if [[ -z "$linea" ]]; then
        echo "Servidor no encontrado."
        return
    fi
    
    # Divide la línea encontrada en variables separadas por "#"
    # Ejemplo: nombre#ip#puerto#estado#descripcion
    IFS='#' read -r srv_nombre srv_ip srv_puerto srv_estado srv_desc <<< "$linea"
    
    # Muestra información del servidor que se va a "pinguear"
    echo "Simulando ping a $srv_nombre ($srv_ip) puerto $srv_puerto..."
    
    # Usamos netcat (nc) para probar la conexión al puerto con un timeout de 3 segundos
    # -z : modo de escaneo de puertos sin enviar datos
    # -w 3 : establece un tiempo máximo de espera de 3 segundos
    if nc -z -w 3 "$srv_ip" "$srv_puerto"; then
        echo "Ping simulado: ¡Conexión exitosa!"
    else
        echo "Ping simulado: No se pudo conectar."
    fi
}

# ---------------------------------------------
# FUNCIÓN: estadisticas_sistema
# Muestra información del sistema y estadísticas sobre los servidores.
# ---------------------------------------------
estadisticas_sistema() {
    echo "=== Información del sistema ==="
    uname -a  # Muestra información general del sistema operativo y kernel

    # Cuenta el número total de líneas en servidores.txt (uno por servidor)
    total=$(wc -l < "$ARCHIVO_ESTADO")

    # Cuenta cuántos servidores están marcados como "activo" o "inactivo"
    activos=$(grep -c "activo" "$ARCHIVO_ESTADO")
    inactivos=$(grep -c "inactivo" "$ARCHIVO_ESTADO")

    # Muestra las cifras en pantalla
    echo "Servidores totales: $total"
    echo "Servidores activos: $activos"
    echo "Servidores inactivos: $inactivos"

    # Si hay servidores, calcula el porcentaje de disponibilidad
    if [[ $total -gt 0 ]]; then
        # Usa 'bc' (calculadora de consola) para obtener el porcentaje con dos decimales
        porcentaje=$(echo "scale=2; ($activos / $total) * 100" | bc)
        echo "Porcentaje de disponibilidad: $porcentaje %"

        # Guarda los resultados en un archivo de log
        echo Totales:"$total" Activos:"$activos" Inactivos:"$inactivos" > estado_servidores.log
    else
        echo "No hay servidores para monitorear."
    fi
}

# ---------------------------------------------
# EJECUCIÓN DEL SCRIPT
# Llama automáticamente a las funciones principales
# ---------------------------------------------
simular_ping          # Ejecuta la simulación de ping
estadisticas_sistema  # Luego muestra las estadísticas


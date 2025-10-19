#!/bin/bash

ARCHIVO_SERVIDORES="servidores.txt"
ARCHIVO_ESTADO="estado_servidores.log"

# Simular ping: verificamos si el puerto está abierto en la IP del servidor
simular_ping() {
    echo "=== Simular ping ==="
    
    # Verificamos que el archivo exista
    if [[ ! -f "$ARCHIVO_SERVIDORES" ]]; then
        echo "Error: No se encontró el archivo $ARCHIVO_SERVIDORES"
        return 1
    fi
    
    read -p "Nombre del servidor para hacer ping: " nombre
    linea=$(grep "^$nombre#" "$ARCHIVO_SERVIDORES")
    if [[ -z "$linea" ]]; then
        echo "Servidor no encontrado."
        return
    fi
    
    IFS='#' read -r srv_nombre srv_ip srv_puerto srv_estado srv_desc <<< "$linea"
    echo "Simulando ping a $srv_nombre ($srv_ip) puerto $srv_puerto..."
    
    # Usamos nc (netcat) para verificar conexión al puerto (timeout 3 segundos)
    if nc -z -w 3 "$srv_ip" "$srv_puerto"; then
        echo "Ping simulado: ¡Conexión exitosa!"
    else
        echo "Ping simulado: No se pudo conectar."
    fi
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
simular_ping
estadisticas_sistema

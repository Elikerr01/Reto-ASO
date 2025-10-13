#!/bin/bash

archivo="servidores.txt"

# Validar puerto permitido
validar_puerto() {
    local puerto=$1
    if [[ "$puerto" == "8080" || "$puerto" == "2222" || "$puerto" == "3026" ]]; then
        return 0
    else
        return 1
    fi
}

añadir_servidor() {
    echo "=== Añadir nuevo servidor ==="
    read -p "Nombre del servidor: " nombre
    read -p "IP: " ip
    
    while true; do
        read -p "Puerto (8080, 2222, 3026): " puerto
        if validar_puerto "$puerto"; then
            break
        else
            echo "Puerto inválido. Solo se permiten 8080, 2222 o 3026."
        fi
    done
    
    read -p "Estado: " estado
    read -p "Descripción: " descripcion
    echo "$nombre#$ip#$puerto#$estado#$descripcion" >> "$archivo"
    echo "Servidor añadido correctamente."
}

listar_servidores() {
    echo "=== Lista de servidores ==="
    if [[ -f "$archivo" ]]; then
        cat "$archivo"
    else
        echo "No hay servidores registrados."
    fi
}

buscar_servidor() {
    echo "=== Buscar servidor ==="
    read -p "Buscar por (nombre/IP/estado): " termino
    resultado=$(grep -i "$termino" "$archivo")
    if [[ -z "$resultado" ]]; then
        echo "No se encontraron coincidencias."
    else
        echo "$resultado"
    fi
}

modificar_servidor() {
    echo "=== Modificar servidor ==="
    read -p "Nombre del servidor a modificar: " nombre
    linea_antigua=$(grep "^$nombre#" "$archivo")
    if [[ -z "$linea_antigua" ]]; then
        echo "Servidor no encontrado."
        return
    fi
    echo "Datos actuales: $linea_antigua"
    
    read -p "Nuevo nombre: " nuevo_nombre
    read -p "Nueva IP: " nueva_ip
    
    while true; do
        read -p "Nuevo puerto (8080, 2222, 3026): " nuevo_puerto
        if validar_puerto "$nuevo_puerto"; then
            break
        else
            echo "Puerto inválido. Solo se permiten 8080, 2222 o 3026."
        fi
    done
    
    read -p "Nuevo estado: " nuevo_estado
    read -p "Nueva descripción: " nueva_desc
    linea_nueva="$nuevo_nombre#$nueva_ip#$nuevo_puerto#$nuevo_estado#$nueva_desc"
    sed -i "s|$linea_antigua|$linea_nueva|" "$archivo"
    echo "Servidor modificado correctamente."
}

eliminar_servidor() {
    echo "=== Eliminar servidor ==="
    read -p "Nombre del servidor a eliminar: " nombre
    if grep -q "^$nombre#" "$archivo"; then
        sed -i "/^$nombre#/d" "$archivo"
        echo "Servidor eliminado correctamente."
    else
        echo "Servidor no encontrado."
    fi
}

ordenar_servidores() {
    echo "=== Ordenar servidores alfabéticamente ==="
    if [[ -f "$archivo" ]]; then
        sort "$archivo" -o "$archivo"
        echo "Servidores ordenados correctamente."
    else
        echo "No hay servidores para ordenar."
    fi
}

# Simular ping: verificamos si el puerto está abierto en la IP del servidor
simular_ping() {
    echo "=== Simular ping ==="
    read -p "Nombre del servidor para hacer ping: " nombre
    linea=$(grep "^$nombre#" "$archivo")
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

mostrar_menu() {
    while true; do
        echo ""
        echo "===== Gestión de Servidores ====="
        echo "1. Añadir servidor"
        echo "2. Listar servidores"
        echo "3. Buscar servidor"
        echo "4. Modificar servidor"
        echo "5. Eliminar servidor"
        echo "6. Ordenar servidores"
        echo "7. Simular ping"
        echo "0. Salir"
        read -p "Seleccione una opción: " opcion
        echo ""

        case $opcion in
            1) añadir_servidor ;;
            2) listar_servidores ;;
            3) buscar_servidor ;;
            4) modificar_servidor ;;
            5) eliminar_servidor ;;
            6) ordenar_servidores ;;
            7) simular_ping ;;
            0) echo "Saliendo..."; break ;;
            *) echo "Opción inválida. Intente de nuevo." ;;
        esac
    done
}

mostrar_menu

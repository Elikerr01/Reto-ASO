#!/bin/bash
#
# funciones_servidor.sh
# Funciones para gestión de servidores:
# añadir, listar, buscar, modificar, eliminar, ordenar
# Incluye simulación de servidor con nc (netcat) para puertos permitidos.
#

# Cargar la configuración global (debe definir ARCHIVO_SERVIDORES, etc.)
# Asegúrate de que configuracion.conf está en el mismo directorio o ajusta la ruta.
source configuracion.conf

# Directorio donde guardamos PIDs de simulaciones locales
SIMULADOS_DIR="simulados"
mkdir -p "$SIMULADOS_DIR"

# ===== Funciones de manejo de simulación con nc =====

# start_simulado nombre ip puerto
# Inicia un listener nc en background y guarda su PID en simulados/<nombre>.pid
start_simulado() {
    local nombre="$1"
    local ip="$2"
    local puerto="$3"

    # Solo simulamos si la IP es localhost (evitar abrir puertos en red real)
    if [[ "$ip" != "127.0.0.1" && "$ip" != "localhost" ]]; then
        echo "IP $ip no es localhost: no se inicia simulación para $nombre:$puerto"
        return
    fi

    # Comprobar que el puerto es uno de los permitidos
    if [[ "$puerto" != "8080" && "$puerto" != "2222" && "$puerto" != "3306" ]]; then
        echo "Puerto $puerto no permitido para simulación."
        return
    fi

    # Si ya hay un proceso para este nombre, no arrancar otro
    local pidfile="$SIMULADOS_DIR/${nombre}.pid"
    if [ -f "$pidfile" ]; then
        local oldpid
        oldpid=$(cat "$pidfile")
        if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
            echo "Simulación ya corriendo para $nombre (PID $oldpid)."
            return
        else
            # PID stale — removemos
            rm -f "$pidfile"
        fi
    fi

    # Comprobar si puerto está libre (nc -z probará)
    if nc -z localhost "$puerto" >/dev/null 2>&1; then
        echo "Puerto $puerto ya ocupado: no se inicia simulador para $nombre."
        return
    fi

    # Lanzar nc en modo listen persistente.
    # Nota: sintaxis -lk funciona en muchas versiones (GNU netcat, ncat). Si falla, deberá ajustarse.
    # Redirigimos salida a /dev/null y lo ejecutamos en background.
    nc -lk "$puerto" >/dev/null 2>&1 &
    local pid=$!

    # Guardar PID
    echo "$pid" > "$pidfile"
    echo "Simulación iniciada para $nombre en localhost:$puerto (PID $pid)."
}

# stop_simulado nombre
# Detiene el listener asociado (si existe)
stop_simulado() {
    local nombre="$1"
    local pidfile="$SIMULADOS_DIR/${nombre}.pid"

    if [ ! -f "$pidfile" ]; then
        # Nada que hacer
        return
    fi

    local pid
    pid=$(cat "$pidfile")
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" && echo "Simulación para $nombre (PID $pid) detenida."
    else
        echo "PID $pid para $nombre no existe; limpiando archivo PID."
    fi

    rm -f "$pidfile"
}

# ===== Funciones de gestión de servidores (archivo: ARCHIVO_SERVIDORES) =====

# Añadir nuevo servidor con validación y simulación si corresponde
añadir_servidor() {
    # Pedimos datos al usuario
    read -rp "Nombre servidor: " nombre
    read -rp "IP: " ip

    # Validar puerto permitido
    while true; do
        read -rp "Puerto (solo 8080, 2222 o 3306): " puerto
        if [[ "$puerto" == "8080" || "$puerto" == "2222" || "$puerto" == "3306" ]]; then
            break
        else
            echo "Puerto inválido. Debe ser 8080, 2222 o 3306."
        fi
    done

    read -rp "Estado (activo/inactivo): " estado
    read -rp "Descripción: " descripcion

    # Guardar la entrada en el archivo (formato: nombre#ip#puerto#estado#descripcion)
    echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$ARCHIVO_SERVIDORES"
    echo "Servidor añadido correctamente a $ARCHIVO_SERVIDORES."

    # Intentar iniciar simulación si la IP es local
    start_simulado "$nombre" "$ip" "$puerto"
}

# Listar todos los servidores registrados en el archivo
listar_servidores() {
    if [ ! -s "$ARCHIVO_SERVIDORES" ]; then
        echo "No hay servidores registrados."
        return
    fi

    echo -e "Nombre\tIP\tPuerto\tEstado\tDescripción"
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        # Mostramos cada registro con formato de columnas (tabs)
        echo -e "${nombre}\t${ip}\t${puerto}\t${estado}\t${descripcion}"
    done < "$ARCHIVO_SERVIDORES"
}

# Buscar servidores por nombre, ip o estado
buscar_servidor() {
    read -rp "Buscar por (nombre/ip/estado): " campo
    campo=$(echo "$campo" | tr '[:upper:]' '[:lower:]')
    if [[ "$campo" != "nombre" && "$campo" != "ip" && "$campo" != "estado" ]]; then
        echo "Campo inválido."
        return
    fi

    read -rp "Valor a buscar: " valor

    case $campo in
        nombre) columna=1 ;;
        ip) columna=2 ;;
        estado) columna=4 ;;
    esac

    echo "Resultados de la búsqueda:"
    # awk hace la búsqueda insensible a mayúsculas/minúsculas
    awk -F"#" -v col="$columna" -v val="$valor" 'tolower($col) ~ tolower(val) {print $0}' "$ARCHIVO_SERVIDORES" | \
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        echo -e "${nombre}\t${ip}\t${puerto}\t${estado}\t${descripcion}"
    done
}

# Modificar información de un servidor existente
modificar_servidor() {
    read -rp "Ingrese el nombre del servidor a modificar: " nombre_buscar

    # Verificar existencia
    if ! grep -iq "^${nombre_buscar}#" "$ARCHIVO_SERVIDORES"; then
        echo "Servidor no encontrado."
        return
    fi

    tmpfile=$(mktemp)

    # Recorremos línea a línea
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        if [[ "$nombre" == "$nombre_buscar" ]]; then
            echo "Modificando servidor: $nombre"

            # Guardamos valores antiguos para gestionar la simulación
            old_nombre="$nombre"
            old_ip="$ip"
            old_puerto="$puerto"

            read -rp "Nuevo nombre [$nombre]: " nuevo_nombre
            read -rp "Nueva IP [$ip]: " nueva_ip

            # Validar puerto nuevo o mantener el anterior
            while true; do
                read -rp "Nuevo puerto [$puerto] (solo 8080, 2222 o 3306): " nuevo_puerto
                if [[ -z "$nuevo_puerto" ]]; then
                    nuevo_puerto=$puerto
                    break
                elif [[ "$nuevo_puerto" == "8080" || "$nuevo_puerto" == "2222" || "$nuevo_puerto" == "3306" ]]; then
                    break
                else
                    echo "Puerto inválido. Debe ser 8080, 2222 o 3306."
                fi
            done

            read -rp "Nuevo estado [$estado]: " nuevo_estado
            read -rp "Nueva descripción [$descripcion]: " nueva_desc

            # Si el nombre cambia, generamos nuevo nombre, etc.
            nombre="${nuevo_nombre:-$nombre}"
            ip="${nueva_ip:-$ip}"
            puerto="$nuevo_puerto"
            estado="${nuevo_estado:-$estado}"
            descripcion="${nueva_desc:-$descripcion}"

            # Detener simulación previa (si existía)
            stop_simulado "$old_nombre"

            # Escribir línea modificada en el temporal
            echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$tmpfile"

            # Iniciar simulación para los nuevos datos si procede
            start_simulado "$nombre" "$ip" "$puerto"
        else
            # Copiar línea sin modificar
            echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$tmpfile"
        fi
    done < "$ARCHIVO_SERVIDORES"

    # Reemplazar el archivo original
    mv "$tmpfile" "$ARCHIVO_SERVIDORES"
    echo "Modificación completada."
}

# Eliminar servidor por nombre (y detener simulación si existía)
eliminar_servidor() {
    read -rp "Ingrese el nombre del servidor a eliminar: " nombre_eliminar

    if ! grep -iq "^${nombre_eliminar}#" "$ARCHIVO_SERVIDORES"; then
        echo "Servidor no encontrado."
        return
    fi

    # Detener simulación (si existe)
    stop_simulado "$nombre_eliminar"

    # Eliminar la línea del archivo (insensible a mayúsculas)
    grep -iv "^${nombre_eliminar}#" "$ARCHIVO_SERVIDORES" > servidores.tmp && mv servidores.tmp "$ARCHIVO_SERVIDORES"
    echo "Servidor eliminado."
}

# Ordenar servidores alfabéticamente por nombre
ordenar_servidores() {
    sort -t "#" -k1,1 "$ARCHIVO_SERVIDORES" -o "$ARCHIVO_SERVIDORES"
    echo "Archivo ordenado alfabéticamente por nombre."
}

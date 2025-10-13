#!/bin/bash

ARCHIVO="servidores.txt"

# Añadir nuevo servidor
añadir_servidor() {
    read -rp "Nombre servidor: " nombre
    read -rp "IP: " ip
    read -rp "Puerto: " puerto
    read -rp "Estado (activo/inactivo): " estado
    read -rp "Descripción: " descripcion

    echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$ARCHIVO"
    echo "Servidor añadido correctamente."
}

# Listar todos los servidores
listar_servidores() {
    if [ ! -s "$ARCHIVO" ]; then
        echo "No hay servidores registrados."
        return
    fi

    echo "Listado de servidores:"
    echo "Nombre\tIP\tPuerto\tEstado\tDescripción"
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        echo -e "${nombre}\t${ip}\t${puerto}\t${estado}\t${descripcion}"
    done < "$ARCHIVO"
}

# Buscar servidor por nombre, IP o estado
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
    grep -i "^" "$ARCHIVO" | awk -F"#" -v col="$columna" -v val="$valor" 'tolower($col) ~ tolower(val) {print $0}' | \
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        echo -e "${nombre}\t${ip}\t${puerto}\t${estado}\t${descripcion}"
    done
}

# Modificar información de servidor
modificar_servidor() {
    read -rp "Ingrese el nombre del servidor a modificar: " nombre_buscar

    if ! grep -iq "^${nombre_buscar}#" "$ARCHIVO"; then
        echo "Servidor no encontrado."
        return
    fi

    tmpfile=$(mktemp)

    while IFS="#" read -r nombre ip puerto estado descripcion; do
        if [[ "$nombre" == "$nombre_buscar" ]]; then
            echo "Modificando servidor: $nombre"
            read -rp "Nuevo nombre [$nombre]: " nuevo_nombre
            read -rp "Nueva IP [$ip]: " nueva_ip
            read -rp "Nuevo puerto [$puerto]: " nuevo_puerto
            read -rp "Nuevo estado [$estado]: " nuevo_estado
            read -rp "Nueva descripción [$descripcion]: " nueva_desc

            nombre="${nuevo_nombre:-$nombre}"
            ip="${nueva_ip:-$ip}"
            puerto="${nuevo_puerto:-$puerto}"
            estado="${nuevo_estado:-$estado}"
            descripcion="${nueva_desc:-$descripcion}"

            echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$tmpfile"
        else
            echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$tmpfile"
        fi
    done < "$ARCHIVO"

    mv "$tmpfile" "$ARCHIVO"
    echo "Modificación completada."
}

# Eliminar servidor
eliminar_servidor() {
    read -rp "Ingrese el nombre del servidor a eliminar: " nombre_eliminar

    if ! grep -iq "^${nombre_eliminar}#" "$ARCHIVO"; then
        echo "Servidor no encontrado."
        return
    fi

    grep -iv "^${nombre_eliminar}#" "$ARCHIVO" > servidores.tmp && mv servidores.tmp "$ARCHIVO"
    echo "Servidor eliminado."
}

# Ordenar servidores alfabéticamente por nombre
ordenar_servidores() {
    sort -t "#" -k1,1 "$ARCHIVO" -o "$ARCHIVO"
    echo "Archivo ordenado alfabéticamente por nombre."
}

# Menú simple para probar funciones
menu() {
    while true; do
        echo ""
        echo "Gestión de Servidores"
        echo "1) Añadir servidor"
        echo "2) Listar servidores"
        echo "3) Buscar servidor"
        echo "4) Modificar servidor"
        echo "5) Eliminar servidor"
        echo "6) Ordenar servidores"
        echo "7) Salir"
        read -rp "Elige una opción: " opcion

        case $opcion in
            1) añadir_servidor ;;
            2) listar_servidores ;;
            3) buscar_servidor ;;
            4) modificar_servidor ;;
            5) eliminar_servidor ;;
            6) ordenar_servidores ;;
            7) echo "Saliendo..."; break ;;
            *) echo "Opción inválida." ;;
        esac
    done
}

# Ejecutar menú
menu

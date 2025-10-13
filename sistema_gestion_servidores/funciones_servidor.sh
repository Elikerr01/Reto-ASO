#!/bin/bash

ARCHIVO="servidores.txt"

# -------------------------
# Función: Añadir servidor
# -------------------------
añadir_servidor() {
    read -rp "Nombre del servidor: " nombre
    read -rp "Dirección IP: " ip
    read -rp "Puerto SSH: " puerto
    read -rp "Estado (activo/inactivo): " estado
    read -rp "Descripción: " descripcion

    echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$ARCHIVO"
    echo "Servidor añadido correctamente."
}

# -------------------------
# Función: Listar servidores
# -------------------------
listar_servidores() {
    if [[ ! -s "$ARCHIVO" ]]; then
        echo "No hay servidores registrados."
        return
    fi

    echo -e "Nombre\t\tIP\t\tPuerto\tEstado\tDescripción"
    echo "-----------------------------------------------------------"
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        echo -e "${nombre}\t${ip}\t${puerto}\t${estado}\t${descripcion}"
    done < "$ARCHIVO"
}

# -------------------------
# Función: Buscar servidor
# -------------------------
buscar_servidor() {
    read -rp "Buscar por (nombre/ip/estado): " campo
    read -rp "Valor a buscar: " valor

    case $campo in
        nombre) columna=1 ;;
        ip) columna=2 ;;
        estado) columna=4 ;;
        *) echo "Campo inválido"; return ;;
    esac

    echo -e "Resultados encontrados:\n"
    awk -F"#" -v col="$columna" -v val="$valor" 'tolower($col) ~ tolower(val)' "$ARCHIVO" |
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        echo -e "${nombre}\t${ip}\t${puerto}\t${estado}\t${descripcion}"
    done
}

# -------------------------
# Función: Modificar servidor
# -------------------------
modificar_servidor() {
    read -rp "Nombre del servidor a modificar: " nombre_buscar

    if ! grep -q "^$nombre_buscar#" "$ARCHIVO"; then
        echo "Servidor no encontrado."
        return
    fi

    tmpfile=$(mktemp)

    while IFS="#" read -r nombre ip puerto estado descripcion; do
        if [[ "$nombre" == "$nombre_buscar" ]]; then
            echo "Modificando $nombre:"
            read -rp "Nuevo nombre [$nombre]: " nuevo_nombre
            read -rp "Nueva IP [$ip]: " nueva_ip
            read -rp "Nuevo puerto [$puerto]: " nuevo_puerto
            read -rp "Nuevo estado [$estado]: " nuevo_estado
            read -rp "Nueva descripción [$descripcion]: " nueva_desc

            nombre="${nuevo_nombre:-$nombre}"
            ip="${nueva_ip:-$ip}"
            puerto="${nuevo_puerto:-$puerto}"
            estado="${nuevo_estado:-$estado}"
            descripcion="${nuevo_desc:-$descripcion}"
        fi
        echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$tmpfile"
    done < "$ARCHIVO"

    mv "$tmpfile" "$ARCHIVO"
    echo "Servidor modificado correctamente."
}

# -------------------------
# Función: Eliminar servidor
# -------------------------
eliminar_servidor() {
    read -rp "Nombre del servidor a eliminar: " nombre

    if ! grep -q "^$nombre#" "$ARCHIVO"; then
        echo "Servidor no encontrado."
        return
    fi

    grep -v "^$nombre#" "$ARCHIVO" > temp && mv temp "$ARCHIVO"
    echo "Servidor eliminado correctamente."
}

# -------------------------
# Función: Ordenar servidores alfabéticamente por nombre
# -------------------------
ordenar_servidores() {
    sort -t "#" -k1,1 "$ARCHIVO" -o "$ARCHIVO"
    echo "Servidores ordenados alfabéticamente."
}

# -------------------------
# Menú principal
# -------------------------
menu() {
    while true; do
        echo ""
        echo "=== Gestión de Servidores ==="
        echo "1) Añadir servidor"
        echo "2) Listar servidores"
        echo "3) Buscar servidor"
        echo "4) Modificar servidor"
        echo "5) Eliminar servidor"
        echo "6) Ordenar servidores alfabéticamente"
        echo "7) Salir"
        read -rp "Seleccione una opción: " opcion

        case $opcion in
            1) añadir_servidor ;;
            2) listar_servidores ;;
            3) buscar_servidor ;;
            4) modificar_servidor ;;
            5) eliminar_servidor ;;
            6) ordenar_servidores ;;
            7) echo "Saliendo..."; break ;;
            *) echo "Opción inválida. Intente de nuevo." ;;
        esac
    done
}

# Iniciar el menú
menu

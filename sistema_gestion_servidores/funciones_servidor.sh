#!/bin/bash
source configuracion.conf

# Añadir nuevo servidor
añadir_servidor() {
    echo "Ingrese nombre del servidor:"
    read nombre
    echo "Ingrese IP:"
    read ip
    echo "Ingrese puerto:"
    read puerto
    echo "Ingrese estado (activo/inactivo):"
    read estado
    echo "Ingrese descripción:"
    read descripcion

    echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$SERVIDORES_FILE"
    echo "Servidor añadido correctamente."
}

# Listar todos los servidores
listar_servidores() {
    if [ ! -s "$SERVIDORES_FILE" ]; then
        echo "No hay servidores registrados."
        return
    fi
    echo -e "Nombre\tIP\tPuerto\tEstado\tDescripción"
    echo "-------------------------------------------------------------"
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        echo -e "$nombre\t$ip\t$puerto\t$estado\t$descripcion"
    done < "$SERVIDORES_FILE"
}

# Buscar servidor por nombre, IP o estado
buscar_servidor() {
    echo "Buscar por: 1) Nombre 2) IP 3) Estado"
    read opcion
    case $opcion in
        1)
            echo "Ingrese nombre:"
            read criterio
            grep -i "^$criterio#" "$SERVIDORES_FILE" || echo "No encontrado."
            ;;
        2)
            echo "Ingrese IP:"
            read criterio
            grep -i "#$criterio#" "$SERVIDORES_FILE" || echo "No encontrado."
            ;;
        3)
            echo "Ingrese estado (activo/inactivo):"
            read criterio
            grep -i "#$criterio#" "$SERVIDORES_FILE" || echo "No encontrado."
            ;;
        *)
            echo "Opción inválida."
            ;;
    esac
}

# Modificar servidor
modificar_servidor() {
    echo "Ingrese el nombre del servidor a modificar:"
    read nombre_mod

    if ! grep -q "^$nombre_mod#" "$SERVIDORES_FILE"; then
        echo "Servidor no encontrado."
        return
    fi

    # Extraemos la línea actual
    linea=$(grep "^$nombre_mod#" "$SERVIDORES_FILE")

    IFS="#" read -r nombre ip puerto estado descripcion <<< "$linea"

    echo "Valores actuales (Enter para mantener):"
    read -p "IP [$ip]: " nuevo_ip
    read -p "Puerto [$puerto]: " nuevo_puerto
    read -p "Estado [$estado]: " nuevo_estado
    read -p "Descripción [$descripcion]: " nueva_descripcion

    nuevo_ip=${nuevo_ip:-$ip}
    nuevo_puerto=${nuevo_puerto:-$puerto}
    nuevo_estado=${nuevo_estado:-$estado}
    nueva_descripcion=${nueva_descripcion:-$descripcion}

    sed -i "/^$nombre_mod#/c\\
$nombre_mod#$nuevo_ip#$nuevo_puerto#$nuevo_estado#$nueva_descripcion
" "$SERVIDORES_FILE"

    echo "Servidor modificado."
}

# Eliminar servidor
eliminar_servidor() {
    echo "Ingrese el nombre del servidor a eliminar:"
    read nombre_del

    if grep -q "^$nombre_del#" "$SERVIDORES_FILE"; then
        sed -i "/^$nombre_del#/d" "$SERVIDORES_FILE"
        echo "Servidor eliminado."
    else
        echo "Servidor no encontrado."
    fi
}

# Ordenar servidores alfabéticamente
ordenar_servidores() {
    sort -t '#' -k1,1 "$SERVIDORES_FILE" -o "$SERVIDORES_FILE"
    echo "Servidores ordenados alfabéticamente."
}

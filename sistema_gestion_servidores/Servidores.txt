#!/bin/bash

archivo="servidores.txt"

añadir_servidor() {
    read -p "Nombre del servidor: " nombre
    read -p "IP: " ip
    read -p "Puerto: " puerto
    read -p "Estado: " estado
    read -p "Descripción: " descripcion
    echo "$nombre#$ip#$puerto#$estado#$descripcion" >> "$archivo"
}

listar_servidores() {
    if [[ -f "$archivo" ]]; then
        cat "$archivo"
    fi
}

buscar_servidor() {
    read -p "Buscar por (nombre/IP/estado): " termino
    grep -i "$termino" "$archivo"
}

modificar_servidor() {
    read -p "Nombre del servidor a modificar: " nombre
    linea_antigua=$(grep "^$nombre#" "$archivo")
    if [[ -z "$linea_antigua" ]]; then
        echo "Servidor no encontrado"
        return
    fi
    read -p "Nuevo nombre: " nuevo_nombre
    read -p "Nueva IP: " nueva_ip
    read -p "Nuevo puerto: " nuevo_puerto
    read -p "Nuevo estado: " nuevo_estado
    read -p "Nueva descripción: " nueva_desc
    linea_nueva="$nuevo_nombre#$nueva_ip#$nuevo_puerto#$nuevo_estado#$nueva_desc"
    sed -i "s|$linea_antigua|$linea_nueva|" "$archivo"
}

eliminar_servidor() {
    read -p "Nombre del servidor a eliminar: " nombre
    sed -i "/^$nombre#/d" "$archivo"
}

ordenar_servidores() {
    sort "$archivo" -o "$archivo"
}

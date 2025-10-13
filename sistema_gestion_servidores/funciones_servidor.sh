#!/bin/bash
ARCHIVO_SERVIDORES="servidores.txt"

añadir_servidor() {
    read -rp "Nombre: " nombre
    read -rp "IP: " ip
    read -rp "Puerto: " puerto
    read -rp "Estado (activo/inactivo): " estado
    read -rp "Descripción: " descripcion
    echo "$nombre#$ip#$puerto#$estado#$descripcion" >> "$ARCHIVO_SERVIDORES"
    echo "Servidor añadido."
}

listar_servidores() {
    echo "Listado de servidores:"
    column -t -s "#" "$ARCHIVO_SERVIDORES"
}

buscar_servidor() {
    read -rp "Buscar por (nombre/ip/estado): " campo
    read -rp "Valor: " valor
    awk -F"#" -v campo="$campo" -v val="$valor" '
    {
        if ((campo == "nombre" && tolower($1) ~ tolower(val)) ||
            (campo == "ip" && tolower($2) ~ tolower(val)) ||
            (campo == "estado" && tolower($4) ~ tolower(val)))
            print $0
    }' "$ARCHIVO_SERVIDORES" | column -t -s "#"
}

modificar_servidor() {
    read -rp "Nombre del servidor a modificar: " nombre
    if ! grep -q "^$nombre#" "$ARCHIVO_SERVIDORES"; then
        echo "Servidor no encontrado."
        return
    fi

    tmpfile=$(mktemp)
    while IFS="#" read -r n ip puerto estado desc; do
        if [[ "$n" == "$nombre" ]]; then
            read -rp "Nuevo nombre [$n]: " new_n
            read -rp "Nueva IP [$ip]: " new_ip
            read -rp "Nuevo puerto [$puerto]: " new_puerto
            read -rp "Nuevo estado [$estado]: " new_estado
            read -rp "Nueva descripción [$desc]: " new_desc
            echo "${new_n:-$n}#${new_ip:-$ip}#${new_puerto:-$puerto}#${new_estado:-$estado}#${new_desc:-$desc}" >> "$tmpfile"
        else
            echo "$n#$ip#$puerto#$estado#$desc" >> "$tmpfile"
        fi
    done < "$ARCHIVO_SERVIDORES"
    mv "$tmpfile" "$ARCHIVO_SERVIDORES"
    echo "Servidor modificado."
}

eliminar_servidor() {
    read -rp "Nombre del servidor a eliminar: " nombre
    grep -v "^$nombre#" "$ARCHIVO_SERVIDORES" > tmp && mv tmp "$ARCHIVO_SERVIDORES"
    echo "Servidor eliminado."
}

ordenar_servidores() {
    sort -t "#" -k1,1 "$ARCHIVO_SERVIDORES" -o "$ARCHIVO_SERVIDORES"
    echo "Servidores ordenados por nombre."
}

menu_gestion_servidores() {
    echo "== Gestión de Servidores =="
    select op in "Añadir" "Listar" "Buscar" "Modificar" "Eliminar" "Ordenar" "Volver"; do
        case $REPLY in
            1) añadir_servidor ;;
            2) listar_servidores ;;
            3) buscar_servidor ;;
            4) modificar_servidor ;;
            5) eliminar_servidor ;;
            6) ordenar_servidores ;;
            7) break ;;
            *) echo "Opción inválida" ;;
        esac
    done
}

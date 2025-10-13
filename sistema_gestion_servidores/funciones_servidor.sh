#!/bin/bash

ARCHIVO="servidores.txt"  # Archivo donde se guardan los datos de los servidores

# Añadir nuevo servidor
añadir_servidor() {
    read -rp "Nombre servidor: " nombre
    read -rp "IP: " ip
    
    # Solicitar puerto y validar que sea uno de los permitidos
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

    # Guardar la información del servidor en el archivo, separando campos con #
    echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$ARCHIVO"
    echo "Servidor añadido correctamente."
}

# Listar todos los servidores almacenados
listar_servidores() {
    # Comprobar si el archivo está vacío o no existe
    if [ ! -s "$ARCHIVO" ]; then
        echo "No hay servidores registrados."
        return
    fi

    echo "Listado de servidores:"
    echo "Nombre\tIP\tPuerto\tEstado\tDescripción"
    
    # Leer línea por línea, separando por #
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        # Mostrar los datos con tabulaciones para mejor formato
        echo -e "${nombre}\t${ip}\t${puerto}\t${estado}\t${descripcion}"
    done < "$ARCHIVO"
}

# Buscar servidor por nombre, IP o estado
buscar_servidor() {
    read -rp "Buscar por (nombre/ip/estado): " campo
    campo=$(echo "$campo" | tr '[:upper:]' '[:lower:]')  # Convertir a minúsculas para evitar errores
    
    # Validar campo de búsqueda
    if [[ "$campo" != "nombre" && "$campo" != "ip" && "$campo" != "estado" ]]; then
        echo "Campo inválido."
        return
    fi

    read -rp "Valor a buscar: " valor

    # Determinar la columna del campo para la búsqueda
    case $campo in
        nombre) columna=1 ;;
        ip) columna=2 ;;
        estado) columna=4 ;;
    esac

    echo "Resultados de la búsqueda:"
    # Buscar en el archivo ignorando mayúsculas/minúsculas y mostrar coincidencias
    grep -i "^" "$ARCHIVO" | awk -F"#" -v col="$columna" -v val="$valor" 'tolower($col) ~ tolower(val) {print $0}' | \
    while IFS="#" read -r nombre ip puerto estado descripcion; do
        echo -e "${nombre}\t${ip}\t${puerto}\t${estado}\t${descripcion}"
    done
}

# Modificar información de un servidor existente
modificar_servidor() {
    read -rp "Ingrese el nombre del servidor a modificar: " nombre_buscar

    # Verificar si el servidor existe
    if ! grep -iq "^${nombre_buscar}#" "$ARCHIVO"; then
        echo "Servidor no encontrado."
        return
    fi

    tmpfile=$(mktemp)  # Archivo temporal para modificaciones

    while IFS="#" read -r nombre ip puerto estado descripcion; do
        if [[ "$nombre" == "$nombre_buscar" ]]; then
            echo "Modificando servidor: $nombre"
            read -rp "Nuevo nombre [$nombre]: " nuevo_nombre
            read -rp "Nueva IP [$ip]: " nueva_ip

            # Validar puerto nuevo, si se introduce uno nuevo
            while true; do
                read -rp "Nuevo puerto [$puerto] (solo 8080, 2222 o 3306): " nuevo_puerto
                # Si no se escribe nada, mantiene el anterior
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

            # Asignar los valores nuevos o los antiguos si no se modificaron
            nombre="${nuevo_nombre:-$nombre}"
            ip="${nueva_ip:-$ip}"
            puerto="$nuevo_puerto"
            estado="${nuevo_estado:-$estado}"
            descripcion="${nueva_desc:-$descripcion}"

            # Escribir la línea modificada en el archivo temporal
            echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$tmpfile"
        else
            # Copiar las líneas que no se modifican tal cual
            echo "${nombre}#${ip}#${puerto}#${estado}#${descripcion}" >> "$tmpfile"
        fi
    done < "$ARCHIVO"

    mv "$tmpfile" "$ARCHIVO"  # Reemplazar el archivo original con el modificado
    echo "Modificación completada."
}

# Eliminar servidor por nombre
eliminar_servidor() {
    read -rp "Ingrese el nombre del servidor a eliminar: " nombre_eliminar

    # Verificar si el servidor existe
    if ! grep -iq "^${nombre_eliminar}#" "$ARCHIVO"; then
        echo "Servidor no encontrado."
        return
    fi

    # Filtrar y eliminar la línea que coincide con el nombre
    grep -iv "^${nombre_eliminar}#" "$ARCHIVO" > servidores.tmp && mv servidores.tmp "$ARCHIVO"
    echo "Servidor eliminado."
}

# Ordenar servidores alfabéticamente por nombre
ordenar_servidores() {
    sort -t "#" -k1,1 "$ARCHIVO" -o "$ARCHIVO"
    echo "Archivo ordenado alfabéticamente por nombre."
}

# Menú interactivo para usar las funciones
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

# Ejecutar el menú principal
menu

}

# Ejecutar menú
menu

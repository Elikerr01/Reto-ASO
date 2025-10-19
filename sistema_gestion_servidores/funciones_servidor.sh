#!/bin/bash
# =====================================================
# Script: funciones_servidor.sh
# Descripción: Gestiona un archivo "servidores.txt"
# con funciones para añadir, listar, buscar, modificar,
# eliminar y ordenar servidores.
# =====================================================

# Archivo donde se almacenarán los servidores
archivo="servidores.txt"

# ---------------------------------------------
# FUNCIÓN: validar_puerto
# Comprueba si el puerto ingresado está dentro de los permitidos.
# ---------------------------------------------
validar_puerto() {
    local puerto=$1  # Captura el primer argumento recibido
    if [[ "$puerto" == "8080" || "$puerto" == "2222" || "$puerto" == "3026" ]]; then
        return 0     # 0 significa "válido" en Bash
    else
        return 1     # 1 significa "inválido"
    fi
}

# ---------------------------------------------
# FUNCIÓN: validar_estado
# Verifica si el estado ingresado es 'activo' o 'inactivo'.
# ---------------------------------------------
validar_estado() {
    local estado=$1
    if [[ "$estado" == "activo" || "$estado" == "inactivo" ]]; then
        return 0
    else
        return 1
    fi
}

# ---------------------------------------------
# FUNCIÓN: añadir_servidor
# Pide datos al usuario y los guarda en servidores.txt
# ---------------------------------------------
añadir_servidor() {
    echo "=== Añadir nuevo servidor ==="
    read -p "Nombre del servidor: " nombre
    read -p "IP: " ip
    
    # Validar puerto permitido
    while true; do
        read -p "Puerto (8080, 2222, 3026): " puerto
        if validar_puerto "$puerto"; then
            break
        else
            echo "Puerto inválido. Solo se permiten 8080, 2222 o 3026."
        fi
    done
    
    # Validar estado permitido
    while true; do
        read -p "Estado (activo, inactivo): " estado
        if validar_estado "$estado"; then
            break
        else
            echo "Estado inválido. Solo se permiten activo o inactivo."
        fi
	done
    
    # Solicita una descripción opcional
    read -p "Descripción: " descripcion
    
    # Guarda todos los datos en el archivo, separados por "#"
    echo "$nombre#$ip#$puerto#$estado#$descripcion" >> "$archivo"
    echo "Servidor añadido correctamente."
}

# ---------------------------------------------
# FUNCIÓN: listar_servidores
# Muestra el contenido de servidores.txt (si existe)
# ---------------------------------------------
listar_servidores() {
    echo "=== Lista de servidores ==="
    if [[ -f "$archivo" ]]; then        # Verifica si el archivo existe
        cat "$archivo"                  # Muestra su contenido
    else
        echo "No hay servidores registrados."
    fi
}

# ---------------------------------------------
# FUNCIÓN: buscar_servidor
# Busca coincidencias por nombre, IP o estado.
# ---------------------------------------------
buscar_servidor() {
    echo "=== Buscar servidor ==="
    read -p "Buscar por (nombre/IP/estado): " termino
    resultado=$(grep -i "$termino" "$archivo")   # grep -i busca sin distinguir mayúsculas
    if [[ -z "$resultado" ]]; then               # Si el resultado está vacío
        echo "No se encontraron coincidencias."
    else
        echo "$resultado"
    fi
}

# ---------------------------------------------
# FUNCIÓN: modificar_servidor
# Permite editar los datos de un servidor existente.
# ---------------------------------------------
modificar_servidor() {
    echo "=== Modificar servidor ==="
    read -p "Nombre del servidor a modificar: " nombre
    linea_antigua=$(grep "^$nombre#" "$archivo")  # Busca la línea exacta que empieza con el nombre
    if [[ -z "$linea_antigua" ]]; then            # Si no existe, muestra error
        echo "Servidor no encontrado."
        return
    fi
    echo "Datos actuales: $linea_antigua"
    
    # Solicita nuevos valores
    read -p "Nuevo nombre: " nuevo_nombre
    read -p "Nueva IP: " nueva_ip
    
    # Valida nuevamente el puerto
    while true; do
        read -p "Nuevo puerto (8080, 2222, 3026): " nuevo_puerto
        if validar_puerto "$nuevo_puerto"; then
            break
        else
            echo "Puerto inválido. Solo se permiten 8080, 2222 o 3026."
        fi
    done
    
    # Valida nuevamente el estado
    while true; do
        read -p "Estado (activo, inactivo): " nuevo_estado
        if validar_estado "$nuevo_estado"; then
            break
        else
            echo "Estado inválido. Solo se permiten activo o inactivo."
        fi
	done
	
    # Solicita una nueva descripción
    read -p "Nueva descripción: " nueva_desc
    
    # Crea la línea con los nuevos datos
    linea_nueva="$nuevo_nombre#$nueva_ip#$nuevo_puerto#$nuevo_estado#$nueva_desc"
    
    # Reemplaza la línea vieja por la nueva usando sed
    sed -i "s|$linea_antigua|$linea_nueva|" "$archivo"
    echo "Servidor modificado correctamente."
}

# ---------------------------------------------
# FUNCIÓN: eliminar_servidor
# Borra un servidor del archivo por nombre.
# ---------------------------------------------
eliminar_servidor() {
    echo "=== Eliminar servidor ==="
    read -p "Nombre del servidor a eliminar: " nombre
    if grep -q "^$nombre#" "$archivo"; then      # grep -q solo devuelve estado (no imprime)
        sed -i "/^$nombre#/d" "$archivo"         # sed -i elimina líneas que comiencen con ese nombre
        echo "Servidor eliminado correctamente."
    else
        echo "Servidor no encontrado."
    fi
}

# ---------------------------------------------
# FUNCIÓN: ordenar_servidores
# Ordena alfabéticamente las líneas del archivo.
# ---------------------------------------------
ordenar_servidores() {
    echo "=== Ordenar servidores alfabéticamente ==="
    if [[ -f "$archivo" ]]; then
        sort "$archivo" -o "$archivo"            # sort ordena y guarda el resultado en el mismo archivo (-o)
        echo "Servidores ordenados correctamente."
    else
        echo "No hay servidores para ordenar."
    fi
}

# ---------------------------------------------
# FUNCIÓN: mostrar_menu
# Menú principal interactivo del sistema.
# ---------------------------------------------
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
        echo "0. Salir"
        read -p "Seleccione una opción: " opcion
        echo ""

        # Evalúa la opción ingresada por el usuario
        case $opcion in
            1) añadir_servidor ;;     # Llama a la función de añadir
            2) listar_servidores ;;   # Llama a la función de listar
            3) buscar_servidor ;;     # Llama a la función de buscar
            4) modificar_servidor ;;  # Llama a la función de modificar
            5) eliminar_servidor ;;   # Llama a la función de eliminar
            6) ordenar_servidores ;;  # Llama a la función de ordenar
            0) echo "Saliendo..."; break ;;  # Termina el bucle (salir)
            *) echo "Opción inválida. Intente de nuevo." ;;  # Entrada no válida
        esac
    done
}

# Llamada final: inicia el menú principal
mostrar_menu

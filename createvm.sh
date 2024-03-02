#!/bin/bash

# Función para solicitar datos con ejemplos
get_input() {
    local prompt="$1"
    local example="$2"
    local input

    read -p "$prompt (ejemplo: $example): " input

    # Utilizar el valor proporcionado o el ejemplo si no se proporciona ninguno
    echo "${input:-$example}"
}

# Solicitar datos para la máquina virtual
NOMBRE_MV=$(get_input "Ingrese el nombre de la máquina virtual" "MiMV")
TIPO_SO=$(get_input "Ingrese el tipo de sistema operativo que soportará" "Linux")

# Solicitar datos para la configuración de la máquina virtual
CPUS=$(get_input "Ingrese el número de CPUs" "1")
RAM_GB=$(get_input "Ingrese el tamaño de memoria RAM (GB)" "2")
VRAM_MB=$(get_input "Ingrese el tamaño de VRAM (MB)" "64")

# Solicitar datos para el disco duro virtual
TAMANO_HDD_GB=$(get_input "Ingrese el tamaño del disco duro virtual (GB)" "30")

# Solicitar nombre del controlador SATA
CONTROLADOR_SATA=$(get_input "Ingrese el nombre del controlador SATA" "SATA_Controller")

# Solicitar nombre del controlador IDE
CONTROLADOR_IDE=$(get_input "Ingrese el nombre del controlador IDE" "IDE_Controller")

# Crear y configurar la máquina virtual
VBoxManage createvm --name "$NOMBRE_MV" --ostype "$TIPO_SO" --register

# Configurar los componentes de la máquina virtual
VBoxManage modifyvm "$NOMBRE_MV" --cpus "$CPUS" --memory "$((RAM_GB * 1024))" --vram "$VRAM_MB"

# Crear y configurar el disco duro virtual
VBoxManage createhd --filename "$NOMBRE_MV.vdi" --size "$((TAMANO_HDD_GB * 1024))" --variant Standard

# Crear y configurar el controlador SATA
VBoxManage storagectl "$NOMBRE_MV" --name "$CONTROLADOR_SATA" --add sata --bootable on
VBoxManage storageattach "$NOMBRE_MV" --storagectl "$CONTROLADOR_SATA" --port 0 --device 0 --type hdd --medium "$NOMBRE_MV.vdi"

# Crear y configurar el controlador IDE
VBoxManage storagectl "$NOMBRE_MV" --name "$CONTROLADOR_IDE" --add ide
VBoxManage storageattach "$NOMBRE_MV" --storagectl "$CONTROLADOR_IDE" --port 0 --device 0 --type dvddrive

# Imprimir la configuración
echo "Configuración creada y asociada:"
VBoxManage showvminfo "$NOMBRE_MV"

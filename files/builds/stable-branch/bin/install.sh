#!/bin/bash

############################################################################################################################
# Name:         Autodesk Fusion 360 - Setup Wizard (Linux)                                                                 #
# Description:  With this file you can install Autodesk Fusion 360 on different Linux distributions.                       #
# Author:       Steve Zabka                                                                                                #
# Author URI:   https://cryinkfly.com                                                                                      #
# License:      MIT                                                                                                        #
# Time/Date:    xx:xx/xx.xx.2023                                                                                           #
# Version:      1.9.0                                                                                                      #
# Requires:     "dialog", "wget", "lsb-release", "coreutils", "glxinfo", "pkexec" <-- Minimum for the installer!           #
# Optional:     Python version: "3.5<" and pip version: "20.3<" <-- Support Vosk (Speech recognition toolkit)              #
############################################################################################################################

###############################################################################################################################################################
# IMPORTANT INFORMATION FOR USERS:                                                                                                                            #
###############################################################################################################################################################

# ...                                                                                                                                                         

##############################################################################################################################################################################
# CONFIGURATION OF THE COLOR SCHEME:                                                                                                                                         #
##############################################################################################################################################################################

function SP_LOAD_COLOR_SHEME {
    RED=$'\033[0;31m'
    YELLOW=$'\033[0;33m'
    GREEN=$'\033[0;32m'
    NOCOLOR=$'\033[0m'
}

##############################################################################################################################################################################
# CONFIGURATION OF THE DIRECTORY STRUCTURE:                                                                                                                                  #
##############################################################################################################################################################################

function SP_ADD_DIRECTORIES { 
    SP_PATH="$HOME/.fusion360"
    mkdir -p $SP_PATH/{bin,config,locale/{cs-CZ,de-DE,en-US,es-ES,fr-FR,it-IT,ja-JP,ko-KR,zh-CN},wineprefixes,resources/{extensions,graphics,music,downloads},logs,cache}
}

##############################################################################################################################################################################
# RECORDING OF THE INSTALLATION:                                                                                                                                             #
##############################################################################################################################################################################

function SP_LOG_INSTALLATION {
    exec 5> "$SP_PATH/logs/setupact.log"
    BASH_XTRACEFD="5"
    set -x
}

##############################################################################################################################################################################
# CHECK THE REQUIRED PACKAGES FOR THE INSTALLER:                                                                                                                             #
##############################################################################################################################################################################

function SP_CHECK_REQUIRED_PACKAGES {
    SP_REQUIRED_COMMANDS=("dialog" "wget" "lsb-release" "coreutils" "glxinfo" "pkexec")
    for cmd in "${SP_REQUIRED_COMMANDS[@]}"; do
        echo "Testing presence of ${cmd} ..."
        local path="$(command -v "${cmd}")"
        if [ -n "${path}" ]; then
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
            SP_DOWNLOAD_LOCALE_INDEX
            SP_CONFIG_LOCALE
            SP_CHECK_RAM
            SP_CHECK_VRAM
            SP_CHECK_DISC_SPACE
        else
            clear
            echo -e "${RED}The required packages not installed or founded on your system!${NOCOLOR}"
            read -p "${YELLOW}Would you like to install these packages on your system to continue the installation of Autodesk Fusion 360? (y/n)${NOCOLOR}" yn
            case $yn in 
	            y ) SP_INSTALL_REQUIRED_PACKAGES;
	                SP_REQUIRED_COMMANDS;;
	            n ) echo -e "${RED}The installer has been terminated!${NOCOLOR}";
		             exit;;
	            * ) echo -e "${RED}The installer was terminated for inexplicable reasons!${NOCOLOR}";
		            exit 1;;
            esac
        fi
    done;
}

##############################################################################################################################################################################
# INSTALLATION OF THE REQUIRED PACKAGES FOR THE INSTALLER:                                                                                                                   #
##############################################################################################################################################################################

function SP_INSTALL_REQUIRED_PACKAGES {    
    DISTRO_VERSION=$(lsb_release -ds) # Check which Linux Distro is used!
        if [[ $DISTRO_VERSION == *"Arch"*"Linux"* ]] || [[ $DISTRO_VERSION == *"Manjaro"*"Linux"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo pacman -S dialog wget lsb-release coreutils mesa-demos polkit
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"Debian"*"10"* ]] || [[ $DISTRO_VERSION == *"Debian"*"11"* ]] || [[ $DISTRO_VERSION == *"Debian"*"Sid"* ]] || [[ $DISTRO_VERSION == *"Ubuntu"*"18.04"* ]] \
        || [[ $DISTRO_VERSION == *"Linux Mint"*"19"* ]] || [[ $DISTRO_VERSION == *"Ubuntu"*"20.04"* ]] || [[ $DISTRO_VERSION == *"Linux Mint"*"20"* ]] \
        || [[ $DISTRO_VERSION == *"Ubuntu"*"22.04"* ]] || [[ $DISTRO_VERSION == *"Linux Mint"*"21"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo apt-get install -y dialog wget lsb-release coreutils mesa-utils policykit-1 
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"Fedora"*"37"* ]] || [[ $DISTRO_VERSION == *"Fedora"*"38"* ]] || [[ $DISTRO_VERSION == *"Fedora"*"Rawhide"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo dnf install -y dialog wget lsb-release coreutils mesa-utils polkit
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"Gentoo"*"Linux"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo emerge -q dev-util/dialog net-misc/wget sys-apps/lsb-release sys-apps/coreutils x11-apps/mesa-progs sys-auth/polkit
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"nixos"* ]] || [[ $DISTRO_VERSION == *"NixOS"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo nix-env -iA nixos.dialog nixos.wget nixos.lsb_release nixos.coreutils nixos.mesa-utils nixos.polkit
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"openSUSE"*"15.4"* ]] || [[ $DISTRO_VERSION == *"openSUSE"*"15.5"* ]] || [[ $DISTRO_VERSION == *"openSUSE"*"Tumbleweed"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo zypper install -y dialog wget lsb-release coreutils Mesa-demo-x polkit
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"Red Hat Enterprise Linux"*"8"* ]] || [[ $DISTRO_VERSION == *"Red Hat Enterprise Linux"*"9"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo dnf install -y dialog wget lsb-release coreutils mesa-utils policykit-1
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"Solus"*"Linux"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo eopkg -y install dialog wget lsb-release coreutils mesa-utils polkit
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"Void"*"Linux"* ]]; then
            echo -e "${YELLOW}All required packages for the installer will be installed!${NOCOLOR}"
            sudo xbps-install -Sy dialog wget lsb-release coreutils mesa-demos polkit
            echo -e "${GREEN}All required packages for the installer are installed!${NOCOLOR}"
        else
            echo -e "${YELLOW}The installer doesn't support your current Linux distribution ($DISTRO_VERSION) at this time!${NOCOLOR}"; 
            echo -e "${RED}The installer has been terminated!${NOCOLOR}"
            exit;
        fi
}

##############################################################################################################################################################################
# DOWNLOADING THE LANGUAGE PACKS FOR THE INSTALLER:                                                                                                                          #
##############################################################################################################################################################################

function SP_DOWNLOAD_LOCALE_INDEX {   
    wget -N -P "$SP_PATH/locale" --progress=dot "https://github.com/cryinkfly/Autodesk-Fusion-360-for-Linux/raw/main/files/builds/stable-branch/locale/locale.sh" 2>&1 |\
    grep "%" |\
    sed -u -e "s,\.,,g" | awk '{print $2}' | sed -u -e "s,\%,,g"  | dialog --backtitle "$SP_TITLE" --gauge "Downloading the language index file ..." 10 100
    chmod +x "$SP_PATH/locale/locale.sh"
    sleep 1
    source "$SP_PATH/locale/locale.sh" # shellcheck source=../locale/locale.sh
    clear
    SP_LOCALE=$(echo $LANG)
}

##############################################################################################################################################################################
# CONFIGURATION OF THE LANGUAGE PACKS FOR THE INSTALLER:                                                                                                                     #
##############################################################################################################################################################################

function SP_CONFIG_LOCALE { 
    if [[ $SP_LOCALE = "01" ]] || [[ $SP_LOCALE == *"zh"*"CN"* ]]; then
        source "$SP_PATH/locale/zh-CN/locale-zh.sh" # shellcheck source=../locale/zh-CN/locale-zh.sh
        SP_LICENSE_FILE="$SP_PATH/locale/zh-CN/license-zh.txt"
    elif [[ $SP_LOCALE = "02" ]] || [[ $SP_LOCALE == *"cs"*"CZ"* ]]; then
        source "$SP_PATH/locale/cs-CZ/locale-cs.sh" # shellcheck source=../locale/cs-CZ/locale-cs.sh
        SP_LICENSE_FILE="$SP_PATH/locale/cs-CZ/license-cs.txt"
    elif [[ $SP_LOCALE = "04" ]] || [[ $SP_LOCALE == *"fr"*"FR"* ]]; then
        source "$SP_PATH/locale/fr-FR/locale-fr.sh" # shellcheck source=../locale/fr-FR/locale-fr.sh
        SP_LICENSE_FILE="$SP_PATH/locale/fr-FR/license-fr.txt"
    elif [[ $SP_LOCALE = "05" ]] || [[ $SP_LOCALE == *"de"*"DE"* ]]; then
        source "$SP_PATH/locale/de-DE/locale-de.sh" # shellcheck source=../locale/de-DE/locale-de.sh
        SP_LICENSE_FILE="$SP_PATH/locale/de-DE/license-de.txt"
    elif [[ $SP_LOCALE = "06" ]] || [[ $SP_LOCALE == *"it"*"IT"* ]]; then
        source "$SP_PATH/locale/it-IT/locale-it.sh" # shellcheck source=../locale/it-IT/locale-it.sh
        SP_LICENSE_FILE="$SP_PATH/locale/it-IT/license-it.txt"
    elif [[ $SP_LOCALE = "07" ]] || [[ $SP_LOCALE == *"ja"*"JP"* ]]; then
        source "$SP_PATH/locale/ja-JP/locale-ja.sh" # shellcheck source=../locale/ja-JP/locale-ja.sh
        SP_LICENSE_FILE="$SP_PATH/locale/ja-JP/license-ja.txt"
    elif [[ $SP_LOCALE = "08" ]] || [[ $SP_LOCALE == *"ko"*"KR"* ]]; then
        source "$SP_PATH/locale/ko-KR/locale-ko.sh" # shellcheck source=../locale/ko-KR/locale-ko.sh
        SP_LICENSE_FILE="$SP_PATH/locale/ko-KR/license-ko.txt"
    elif [[ $SP_LOCALE = "09" ]] || [[ $SP_LOCALE == *"es"*"ES"* ]]; then
        source "$SP_PATH/locale/es-ES/locale-es.sh" # shellcheck source=../locale/es-ES/locale-es.sh
        SP_LICENSE_FILE="$SP_PATH/locale/es-ES/license-es.txt"
    else
        source "$SP_PATH/locale/en-US/locale-en.sh" # shellcheck source=../locale/en-US/locale-en.sh
        SP_LICENSE_FILE="$SP_PATH/locale/en-US/license-en.txt"
    fi
}

##############################################################################################################################################################################
# CHECKING THE MINIMUM RAM (RANDOM ACCESS MEMORY) REQUIREMENT:                                                                                                               #
##############################################################################################################################################################################

function SP_CHECK_RAM {
    GET_RAM_KILOBYTES=$(grep MemTotal /proc/meminfo | awk '{print $2}') # Get total RAM space in kilobytes
    CONVERT_RAM_GIGABYTES=$(echo "scale=2; $GET_RAM_KILOBYTES / 1024 / 1024" | bc) # Convert kilobytes to gigabytes
    if (( $(echo "$CONVERT_RAM_GIGABYTES > 4" | bc -l) )); then # Check if RAM is greater than 4 GB
        echo -e "${GREEN}The total RAM (Random Access Memory) is greater than 4 GByte ($CONVERT_RAM_GIGABYTES GByte) and Fusion 360 will run more stable later!${NOCOLOR}"
    else
        echo -e "${RED}The total RAM (Random Access Memory) is not greater than 4 GByte ($CONVERT_RAM_GIGABYTES GByte) and Fusion 360 may run unstable later with insufficient RAM memory!${NOCOLOR}"
        read -p "${YELLOW}Are you sure you want to continue with the installation? (y/n)${NOCOLOR}" yn
            case $yn in 
	            y ) ...;;
	            n ) echo -e "${RED}The installer has been terminated!${NOCOLOR}";
		             exit;;
	            * ) echo -e "${RED}The installer was terminated for inexplicable reasons!${NOCOLOR}";
		            exit 1;;
            esac
    fi
}

##############################################################################################################################################################################
# CHECKING THE MINIMUM VRAM (VIDEO RAM) REQUIREMENT:                                                                                                                         #
##############################################################################################################################################################################

function SP_CHECK_VRAM {
    # Get the total memory of the graphics card
    GET_VRAM_MEGABYTES=$(dmesg | grep -o -P -i "(?<=vram:).*(?=M 0x)")
    # Check if the total memory is greater than 1 GByte
    if [ "$GET_VRAM_MEGABYTES" -gt 1024 ]; then
        echo -e "${GREEN}The total VRAM (Video RAM) is greater than 1 GByte ($CONVERT_RAM_GIGABYTES GByte) and Fusion 360 will run more stable later!${NOCOLOR}"
    else
        echo -e "${RED}The total VRAM (Video RAM) is not greater than 1 GByte ($CONVERT_RAM_GIGABYTES GByte) and Fusion 360 may run unstable later with insufficient RAM memory!${NOCOLOR}"
        read -p "${YELLOW}Are you sure you want to continue with the installation? (y/n)${NOCOLOR}" yn
            case $yn in 
	            y ) ...;;
	            n ) echo -e "${RED}The installer has been terminated!${NOCOLOR}";
		             exit;;
	            * ) echo -e "${RED}The installer was terminated for inexplicable reasons!${NOCOLOR}";
		            exit 1;;
            esac
    fi
}

##############################################################################################################################################################################
# CHECKING THE MINIMUM DISK SPACE (DEFAULT: HOME-PARTITION) REQUIREMENT:                                                                                                     #
##############################################################################################################################################################################

function SP_CHECK_DISK_SPACE {
    # Get the free disk memory size in GB
    GET_DISK_SPACE=$(df -h /home | awk '{print $4}' | tail -1)
    echo -e "${GREEN}The free disk memory size is: $GET_DISK_SPACE${NOCOLOR}"
    if [[ $GET_DISK_SPACE > 10G ]]; then # Check if the home size is greater than 10GB
        echo -e "${GREEN}The free disk memory size is greater than 10GB.${NOCOLOR}"
    else
        echo -e "${YELLOW}There is not enough disk free memory to continue installing Fusion 360 on your system!${NOCOLOR}"
        echo -e "${YELLOW}Make more space in your home partition or select a different hard drive.${NOCOLOR}"
        echo -e "${RED}The installer has been terminated!${NOCOLOR}"
        exit;
    fi
}

##############################################################################################################################################################################
# CHECK THE GRAPHICS CARD DRIVER:                                                                                                                                            #
##############################################################################################################################################################################

function SP_CHECK_GPU_DRIVER {
    if [[ $(glxinfo | grep -A 10 -B 1 Vendor) == *"AMD"* ]]; then
        GPU_DRIVER="amd"
        SP_INSTALL_GPU_DRIVER
    elif [[ $(glxinfo | grep -A 10 -B 1 Vendor) == *"Intel"* ]]; then
        GPU_DRIVER="intel"
        SP_INSTALL_GPU_DRIVER
    elif [[ $(glxinfo | grep -A 10 -B 1 Vendor) == *"NVIDIA"* ]]; then
        GPU_DRIVER="nvidia"
        SP_INSTALL_GPU_DRIVER
    else
        echo -e "${YELLOW}The graphics card analysis failed because your graphics card was not detected!${NOCOLOR}"
        echo -e "${RED}The installer has been terminated!${NOCOLOR}"
        exit;
    fi
    SP_INSTALL_GPU_DRIVER
}

##############################################################################################################################################################################
# INSTALLATION OF THE GRAPHICS CARD DRIVER:                                                                                                                                  #
##############################################################################################################################################################################

function SP_INSTALL_GPU_DRIVER {    
    DISTRO_VERSION=$(lsb_release -ds) # Check which Linux Distro is used!
        if [[ $DISTRO_VERSION == *"Arch"*"Linux"* ]] || [[ $DISTRO_VERSION == *"Manjaro"*"Linux"* ]]; then
            if grep -q '^\[multilib\]$' /etc/pacman.conf ; then
                echo -e "${GREEN}The multilib repository exists on your computer.${NOCOLOR}"
            else
                echo -e "${YELLOW}The multilib repository will be enable in the [multilib] section in /etc/pacman.conf!${NOCOLOR}"
                echo "[multilib]" | sudo tee -a /etc/pacman.conf
                echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
            fi
            if [[ $GPU_DRIVER == *"amd"* ]]; then
                if [[ $(pacman -Qe) == *"mesa"*"lib32-mesa"*"mesa-vdpau"*"lib32-mesa-vdpau"*"lib32-vulkan-radeon"*"vulkan-radeon"*"glu"*"lib32-glu"*"vulkan-icd-loader"*"lib32-vulkan-icd-loader"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo pacman -Syu && sudo pacman -Syy
                    sudo pacman -S --needed mesa lib32-mesa mesa-vdpau lib32-mesa-vdpau lib32-vulkan-radeon vulkan-radeon glu lib32-glu vulkan-icd-loader lib32-vulkan-icd-loader
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                fi
            elif [[ $GPU_DRIVER == *"intel"* ]]; then
                if [[ $(pacman -Qe) == *"lib32-mesa"*"vulkan-inte"*"lib32-vulkan-intel"*"vulkan-icd-loader"*"lib32-vulkan-icd-loader"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo pacman -Syu && sudo pacman -Syy
                    sudo pacman -S --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                fi
            else
                if [[ $(pacman -Qe) == *"nvidia-dkms"*"nvidia-utils"*"lib32-nvidia-utils"*"nvidia-settings"*"vulkan-icd-loader"*"lib32-vulkan-icd-loader"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo pacman -Syu && sudo pacman -Syy
                    sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
            fi
        elif [[ $DISTRO_VERSION == *"Debian"* ]] || [[ $DISTRO_VERSION == *"Ubuntu"* ]] || [[ $DISTRO_VERSION == *"Linux Mint"* ]]; then
            if [[ $GPU_DRIVER == *"amd"* ]]; then
                if [[ $(apt list --installed) == *"software-properties-common"*"firmware-linux"*"firmware-linux-nonfree"*"libdrm-amdgpu1"*"xserver-xorg-video-amdgpu"*"mesa-vulkan-drivers"*"libvulkan1"*"vulkan-tools"*"vulkan-utils"*"vulkan-validationlayers"*"mesa-opencl-icd"*]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    if [[ $DISTRO_VERSION == *"Debian"* ]]; then
                        if [[ $(grep ^[^#] /etc/apt/sources.list /etc/apt/sources.list.d/*) == *"contrib"* ]] && [[ $(grep ^[^#] /etc/apt/sources.list /etc/apt/sources.list.d/*) == *"non-free"* ]]; then
                            sudo apt-get update && sudo apt-get install -y software-properties-common
                            sudo apt-add-repository contrib && sudo apt-add-repository non-free # The package "software-properties-common" must be installed before!
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y firmware-linux firmware-linux-nonfree libdrm-amdgpu1 xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers mesa-opencl-icd
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        else
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y software-properties-common firmware-linux firmware-linux-nonfree libdrm-amdgpu1 xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers mesa-opencl-icd
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    else
                        if [[ $(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://ppa.launchpadcontent.net/oibaf/graphics-drivers/ubuntu"* ]]; then
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y firmware-linux firmware-linux-nonfree libdrm-amdgpu1 xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers mesa-opencl-icd
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        else
                            sudo add-apt-repository ppa:oibaf/graphics-drivers
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y firmware-linux firmware-linux-nonfree libdrm-amdgpu1 xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers mesa-opencl-icd
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        fi
                    fi
                fi
            elif [[ $GPU_DRIVER == *"intel"* ]]; then
                if [[ $(apt list --installed) == *"mesa-utils"*"libegl1-mesa"*"mesa-vulkan-drivers"*"mesa-vulkan-drivers"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    if [[ $DISTRO_VERSION == *"Debian"* ]]; then
                        if [[ $(grep ^[^#] /etc/apt/sources.list /etc/apt/sources.list.d/*) == *"contrib"* ]] && [[ $(grep ^[^#] /etc/apt/sources.list /etc/apt/sources.list.d/*) == *"non-free"* ]]; then
                            sudo apt-get update && sudo apt-get install -y software-properties-common
                            sudo apt-add-repository contrib && sudo apt-add-repository non-free # The package "software-properties-common" must be installed before!
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y mesa-utils libgl1-mesa mesa-vulkan-drivers
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        else
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y software-properties-common mesa-utils libgl1-mesa mesa-vulkan-drivers
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    else
                        if [[$(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://ppa.launchpadcontent.net/graphics-drivers/ppa/ubuntu"* ]]; then
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y mesa-utils libgl1-mesa mesa-vulkan-drivers
                            echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                        else
                            sudo add-apt-repository ppa:graphics-drivers/ppa
                            sudo apt-install -y mesa-utils libgl1-mesa mesa-vulkan-drivers
                            echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                        fi
                    fi
                fi
            else
                if [[ $(apt list --installed) == *"nvidia-driver"*"vulkan-utils"*"libvulkan1"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    if [[ $DISTRO_VERSION == *"Debian"* ]]; then
                        if [[ $(grep ^[^#] /etc/apt/sources.list /etc/apt/sources.list.d/*) == *"contrib"* ]] && [[ $(grep ^[^#] /etc/apt/sources.list /etc/apt/sources.list.d/*) == *"non-free"* ]]; then
                            sudo apt-get update && sudo apt-get install -y software-properties-common
                            sudo apt-add-repository contrib && sudo apt-add-repository non-free # The package "software-properties-common" must be installed before!
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y nvidia-driver vulkan-utils libvulkan1
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        else
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-install -y software-properties-common nvidia-driver vulkan-utils libvulkan1
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    else
                        if [[$(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://ppa.launchpadcontent.net/graphics-drivers/ppa/ubuntu"* ]]; then
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-get install -y nvidia-driver vulkan-utils libvulkan1
                            echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                        else
                            sudo apt-get purge nvidia*
                            sudo add-apt-repository ppa:graphics-drivers/ppa
                            sudo apt-get update && sudo ubuntu-drivers autoinstall
                            sudo apt-get install -y nvidia-driver vulkan-utils libvulkan1
                            echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                        fi
                    fi
                fi
            fi
        elif [[ $DISTRO_VERSION == *"Fedora"* ]]; then
            if [[ $GPU_DRIVER == *"amd"* ]]; then
                echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
            elif [[ $GPU_DRIVER == *"intel"* ]]; then
                echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
            else
                if [[ $(sudo dnf list installed) == *"akmod-nvidia"*"xorg-x11-drv-nvidia-cuda"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    if [[ $(sudo dnf repolist all) == *"rpmfusion-free-release"* ]] && [[ $(sudo dnf repolist all) == *"rpmfusion-nonfree-release"* ]]; then
                        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
                        echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    else
                        sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
                        sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
                        echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
            fi
        elif [[ $DISTRO_VERSION == *"Gentoo"*"Linux"* ]]; then
            if [[ $GPU_DRIVER == *"amd"* ]]; then
                if [[ $(equery list '*') == *"x11-drivers/xf86-video-amdgpu"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo emerge --ask --quiet x11-drivers/xf86-video-amdgpu
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                fi
            elif [[ $GPU_DRIVER == *"intel"* ]]; then
                if [[ $(equery list '*') == *"x11-drivers/xf86-video-intel"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo emerge --ask --quiet x11-drivers/xf86-video-intel
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                fi
            else
                if [[ $(equery list '*') == *"x11-drivers/nvidia-drivers"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo emerge --ask --quiet x11-drivers/nvidia-drivers
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                fi
            fi
        elif [[ $DISTRO_VERSION == *"nixos"* ]] || [[ $DISTRO_VERSION == *"NixOS"* ]]; then
            if [[ $GPU_DRIVER == *"amd"* ]]; then
                if [[ $(nix-env -qa --installed "*") == *"nixos.amdgpu"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo nix-env -iA nixos.amdgpu
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                fi
            elif [[ $GPU_DRIVER == *"intel"* ]]; then
                if [[ $(nix-env -qa --installed "*") == *"nixos.intel-video-acc"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo nix-env -iA nixos.intel-video-acc
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                fi
            else
                if [[ $(nix-env -qa --installed "*") == *"nixos.nvidia"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                else
                    echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                    sudo nix-env -iA nixos.nvidia
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                fi
            fi
        elif [[ $DISTRO_VERSION == *"openSUSE"* ]]; then
            if [[ $DISTRO_VERSION == *"openSUSE"*"15.4"* ]]; then
                if [[ $GPU_DRIVER == *"amd"* ]]; then
                    if [[ $(zypper search --installed-only) == *"kernel-firmware-amdgpu"*"libdrm_amdgpu1"*"libdrm_amdgpu1-32bit"*"libdrm_radeon1"*"libdrm_radeon1-32bit"*"libvulkan_radeon"*"libvulkan_radeon-32bit"*"libvulkan1"*"libvulkan1-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                        sudo zypper in -y kernel-firmware-amdgpu libdrm_amdgpu1 libdrm_amdgpu1-32bit libdrm_radeon1 libdrm_radeon1-32bit libvulkan_radeon libvulkan_radeon-32bit libvulkan1 libvulkan1-32bit
                        echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    fi
                elif [[ $GPU_DRIVER == *"intel"* ]]; then
                    if [[ $(zypper search --installed-only) == *"kernel-firmware-intel"*"libdrm_intel1"*"libdrm_intel1-32bit"*"libvulkan1"*"libvulkan1-32bit"*"libvulkan_intel"*"libvulkan_intel-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                        sudo zypper in -y kernel-firmware-intel libdrm_intel1 libdrm_intel1-32bit libvulkan1 libvulkan1-32bit libvulkan_intel libvulkan_intel-32bit
                        echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    fi
                else
                    if [[ $(zypper search --installed-only) == *"x11-video-nvidiaG05"*"libvulkan1"*"libvulkan1-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        if [[ $(zypper lr -u) == *"https://download.nvidia.com/opensuse/leap/15.4/"*]] || [[ $(zypper lr -u) == *"https://developer.download.nvidia.com/compute/cuda/repos/opensuse15/x86_64/cuda-opensuse15.repo"*]]; then
                            sudo zypper in -y x11-video-nvidiaG05 libvulkan1 libvulkan1-32bit
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        else
                            sudo zypper addrepo --refresh 'https://download.nvidia.com/opensuse/leap/$releasever' NVIDIA
                            sudo zypper in -y x11-video-nvidiaG05 libvulkan1 libvulkan1-32bit
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        fi
                    fi
                fi
            elif [[ $DISTRO_VERSION == *"openSUSE"*"15.5"* ]]; then
                if [[ $GPU_DRIVER == *"amd"* ]]; then
                    if [[ $(zypper search --installed-only) == *"kernel-firmware-amdgpu"*"libdrm_amdgpu1"*"libdrm_amdgpu1-32bit"*"libdrm_radeon1"*"libdrm_radeon1-32bit"*"libvulkan_radeon"*"libvulkan_radeon-32bit"*"libvulkan1"*"libvulkan1-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                        sudo zypper in -y kernel-firmware-amdgpu libdrm_amdgpu1 libdrm_amdgpu1-32bit libdrm_radeon1 libdrm_radeon1-32bit libvulkan_radeon libvulkan_radeon-32bit libvulkan1 libvulkan1-32bit
                        echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    fi
                elif [[ $GPU_DRIVER == *"intel"* ]]; then
                    if [[ $(zypper search --installed-only) == *"kernel-firmware-intel"*"libdrm_intel1"*"libdrm_intel1-32bit"*"libvulkan1"*"libvulkan1-32bit"*"libvulkan_intel"*"libvulkan_intel-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                        sudo zypper in -y kernel-firmware-intel libdrm_intel1 libdrm_intel1-32bit libvulkan1 libvulkan1-32bit libvulkan_intel libvulkan_intel-32bit
                        echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    fi
                else
                    if [[ $(zypper search --installed-only) == *"x11-video-nvidiaG05"*"libvulkan1"*"libvulkan1-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        if [[ $(zypper lr -u) == *"https://download.nvidia.com/opensuse/leap/15.5/"*]] || [[ $(zypper lr -u) == *"https://developer.download.nvidia.com/compute/cuda/repos/opensuse15/x86_64/cuda-opensuse15.repo"*]]; then
                            sudo zypper in -y x11-video-nvidiaG05 libvulkan1 libvulkan1-32bit
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        else
                            sudo zypper addrepo --refresh 'https://download.nvidia.com/opensuse/leap/$releasever' NVIDIA
                            sudo zypper in -y x11-video-nvidiaG05 libvulkan1 libvulkan1-32bit
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        fi
                    fi
                fi
            elif [[ $DISTRO_VERSION == *"openSUSE"*"Tumbleweed"* ]]; then
                if [[ $GPU_DRIVER == *"amd"* ]]; then
                    if [[ $(zypper search --installed-only) == *"kernel-firmware-amdgpu"*"libdrm_amdgpu1"*"libdrm_amdgpu1-32bit"*"libdrm_radeon1"*"libdrm_radeon1-32bit"*"libvulkan_radeon"*"libvulkan_radeon-32bit"*"libvulkan1"*"libvulkan1-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                        sudo zypper in -y kernel-firmware-amdgpu libdrm_amdgpu1 libdrm_amdgpu1-32bit libdrm_radeon1 libdrm_radeon1-32bit libvulkan_radeon libvulkan_radeon-32bit libvulkan1 libvulkan1-32bit
                        echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    fi
                elif [[ $GPU_DRIVER == *"intel"* ]]; then
                    if [[ $(zypper search --installed-only) == *"kernel-firmware-intel"*"libdrm_intel1"*"libdrm_intel1-32bit"*"libvulkan1"*"libvulkan1-32bit"*"libvulkan_intel"*"libvulkan_intel-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                        sudo zypper in -y kernel-firmware-intel libdrm_intel1 libdrm_intel1-32bit libvulkan1 libvulkan1-32bit libvulkan_intel libvulkan_intel-32bit
                        echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    fi
                else
                    if [[ $(zypper search --installed-only) == *"x11-video-nvidiaG05"*"libvulkan1"*"libvulkan1-32bit"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        if [[ $(zypper lr -u) == *"https://download.nvidia.com/opensuse/tumbleweed"*]]; then
                            sudo zypper in -y x11-video-nvidiaG05 libvulkan1 libvulkan1-32bit
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        else
                            sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
                            sudo zypper in -y x11-video-nvidiaG05 libvulkan1 libvulkan1-32bit
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        fi
                    fi
                fi
            fi
        elif [[ $DISTRO_VERSION == *"Red Hat Enterprise Linux"* ]]; then
            if [[ $DISTRO_VERSION == *"Red Hat Enterprise Linux"*"8"* ]]; then
                if [[ $GPU_DRIVER == *"amd"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                elif [[ $GPU_DRIVER == *"intel"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                else
                    if [[ $(dnf list installed) == *"nvidia-driver:latest-dkms"*"cuda"* ]]; then
                        echo -e "${GREEN}The latest graphics card driver is already installed.${NOCOLOR}"
                    else
                        echo -e "${YELLOW}The latest graphics card driver will be installed!${NOCOLOR}"
                        if [[ $(dnf repolist) == *"https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo"*]]
                            sudo dnf -y module install nvidia-driver:latest-dkms
                            sudo dnf -y install cuda
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                        else
                            sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
                            sudo dnf clean all
                            sudo dnf -y module install nvidia-driver:latest-dkms
                            sudo dnf -y install cuda
                            echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                    fi
                fi
            fi
        elif [[ $DISTRO_VERSION == *"Solus"*"Linux"* ]]; then
            if [[ $GPU_DRIVER == *"amd"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                elif [[ $GPU_DRIVER == *"intel"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                else
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
        elif [[ $DISTRO_VERSION == *"Void"*"Linux"* ]]; then
            if [[ $GPU_DRIVER == *"amd"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                elif [[ $GPU_DRIVER == *"intel"* ]]; then
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
                else
                    echo -e "${GREEN}The latest graphics card driver is installed!${NOCOLOR}"
        else
            echo -e "${YELLOW}The graphics card driver installation has failed!${NOCOLOR}";
            echo -e "${RED}The installer has been terminated!${NOCOLOR}"
            exit;
        fi
}

##############################################################################################################################################################################
# INSTALLATION OF THE PACKAGES OF WINE & WINETRICKS:                                                                                                                         #
##############################################################################################################################################################################

function SP_CHECK_WINE_VERSION {    
    DISTRO_VERSION=$(lsb_release -ds) # Check which Linux Distro is used!
        if [[ $DISTRO_VERSION == *"Arch"*"Linux"* ]] || [[ $DISTRO_VERSION == *"Manjaro"*"Linux"* ]]; then
            if [[ $(pacman -Qe) == *"wine"*"wine-mono"*"wine_gecko"*"winetricks"*"p7zip"*"curl"*"cabextract"*"samba"*"ppp"* ]]; then
                echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                sudo pacman -Syu && sudo pacman -Syy
                sudo pacman -S --needed wine wine-mono wine_gecko winetricks p7zip curl cabextract samba ppp
                echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
            fi
        elif [[ $DISTRO_VERSION == *"Debian"* ]]; then
            if [[ $(apt list --installed) == *"p7zip"*"p7zip-full"*"p7zip-rar"*"curl"*"winbind"*"cabextract"*"winehq-staging"* ]]; then
                echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                sudo apt-get --allow-releaseinfo-change update # Some systems require this command for all repositories to work properly and for the packages to be downloaded for installation!
                sudo dpkg --add-architecture i386 # Added i386 support for wine!
                if [[ $DISTRO_VERSION == *"Debian"*"10"* ]]; then
                    if [[ $(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://dl.winehq.org/wine-builds/debian/"* ]]; then
                        sudo apt-add-repository -r 'deb https://dl.winehq.org/wine-builds/debian/ buster main'
                    else
                        if [[ $(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/"* ]]; then
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-get install -y p7zip p7zip-full p7zip-rar curl winbind cabextract
                            sudo apt-get install -y --install-recommends winehq-staging
                            echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                        else
                            wget -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10//Release.key -O Release.key -O- | sudo apt-key add -
                            sudo apt-add-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/ ./'
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-get install -y p7zip p7zip-full p7zip-rar curl winbind cabextract
                            sudo apt-get install -y --install-recommends winehq-staging
                            echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                        fi
                    fi
                elif [[ $DISTRO_VERSION == *"Debian"*"11"* ]]; then
                    if [[ $(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://dl.winehq.org/wine-builds/debian/"* ]]; then
                        sudo apt-add-repository -r 'deb https://dl.winehq.org/wine-builds/debian/ buster main'
                    else
                        if [[ $(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_11/"* ]]; then
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-get install -y p7zip p7zip-full p7zip-rar curl winbind cabextract
                            sudo apt-get install -y --install-recommends winehq-staging
                            echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                        else
                            wget -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_11//Release.key -O Release.key -O- | sudo apt-key add -
                            sudo apt-add-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_11/ ./'
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-get install -y p7zip p7zip-full p7zip-rar curl winbind cabextract
                            sudo apt-get install -y --install-recommends winehq-staging
                            echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                        fi
                    fi
                elif [[ $DISTRO_VERSION == *"Debian"*"Sid"* ]]; then
                    if [[ $(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://dl.winehq.org/wine-builds/debian/"* ]]; then
                        sudo apt-add-repository -r 'deb https://dl.winehq.org/wine-builds/debian/ buster main'
                        if [[ $(sudo grep -rhE ^deb /etc/apt/sources.list*) == *"https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_Testing_standard/"* ]]; then
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-get install -y p7zip p7zip-full p7zip-rar curl winbind cabextract
                            sudo apt-get install -y --install-recommends winehq-staging
                            echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                        else
                            wget -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_Testing_standard//Release.key -O Release.key -O- | sudo apt-key add -
                            sudo apt-add-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_Testing_standard/ ./'
                            sudo apt-get update && sudo apt-get upgrade
                            sudo apt-get install -y p7zip p7zip-full p7zip-rar curl winbind cabextract
                            sudo apt-get install -y --install-recommends winehq-staging
                            echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                        fi
                    fi
                else
                    echo -e "${YELLOW}The installer doesn't support your current Linux distribution ($DISTRO_VERSION) at this time!${NOCOLOR}";
                    echo -e "${RED}The installer has been terminated!${NOCOLOR}"
                    exit; 
            fi
        elif [[ $DISTRO_VERSION == *"Fedora"* ]]; then
            if [[ $(sudo dnf list installed) == *"p7zip"*"p7zip-plugins"*"curlcabextract"*"wine"* ]]; then
                echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                if [[ $DISTRO_VERSION == *"Fedora"*"37"* ]]; then
                    if [[ $(sudo dnf repolist all) == *"rpmfusion-free-release"*]] && [[ $(sudo dnf repolist all) == *"rpmfusion-nonfree-release"*]] && [[ $(sudo dnf repolist all) == *"wine"*]]; then
                        sudo dnf update && sudo dnf upgrade
                        sudo dnf install p7zip p7zip-plugins curl cabextract wine
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    else
                        sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
                        sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                        sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/Emulators:/Wine:/Fedora/Fedora_37/Emulators:Wine:Fedora.repo
                        sudo dnf update && sudo dnf upgrade
                        sudo dnf install p7zip p7zip-plugins curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    fi
                elif [[ $DISTRO_VERSION == *"Fedora"*"38"* ]]; then
                    if [[ $(sudo dnf repolist all) == *"rpmfusion-free-release"*]] && [[ $(sudo dnf repolist all) == *"rpmfusion-nonfree-release"*]] && [[ $(sudo dnf repolist all) == *"wine"*]]; then
                        sudo dnf update && sudo dnf upgrade
                        sudo dnf install p7zip p7zip-plugins curl cabextract wine
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    else
                        sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
                        sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                        sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/Emulators:/Wine:/Fedora/Fedora_38/Emulators:Wine:Fedora.repo
                        sudo dnf update && sudo dnf upgrade
                        sudo dnf install p7zip p7zip-plugins curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    fi
                elif [[ $DISTRO_VERSION == *"Fedora"*"Rawhide"* ]]; then
                    if [[ $(sudo dnf repolist all) == *"rpmfusion-free-release"*]] && [[ $(sudo dnf repolist all) == *"rpmfusion-nonfree-release"*]] && [[ $(sudo dnf repolist all) == *"wine"*]]; then
                        sudo dnf update && sudo dnf upgrade
                        sudo dnf install p7zip p7zip-plugins curl cabextract wine
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    else
                        sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
                        sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                        sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/Emulators:/Wine:/Fedora/Fedora_Rawhide/Emulators:Wine:Fedora.repo
                        sudo dnf update && sudo dnf upgrade
                        sudo dnf install p7zip p7zip-plugins curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    fi
                else
                    echo -e "${YELLOW}The installer doesn't support your current Linux distribution ($DISTRO_VERSION) at this time!${NOCOLOR}";
                    echo -e "${RED}The installer has been terminated!${NOCOLOR}"
                    exit;   
                fi
            fi
        elif [[ $DISTRO_VERSION == *"Gentoo"*"Linux"* ]]; then
            if [[ $(equery list '*') == *"virtual/wine app-emulation/winetricks"*"app-emulation/wine-mono"*"app-emulation/wine-gecko"*"app-arch/p7zip"*"app-arch/cabextract"*"net-misc/curl"*"net-fs/samba"*"net-dialup/ppp"* ]]; then
                echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                sudo emerge -nav virtual/wine app-emulation/winetricks app-emulation/wine-mono app-emulation/wine-gecko app-arch/p7zip app-arch/cabextract net-misc/curl net-fs/samba net-dialup/ppp
                echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
            fi
        elif [[ $DISTRO_VERSION == *"nixos"* ]] || [[ $DISTRO_VERSION == *"NixOS"* ]]; then
            if [[ $(nix-env -qa --installed "*") == *"nixos.curl"*"nixos.cabextract"*"nixos.p7zip"*"nixos.wine-staging"* ]]; then
                echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                sudo nix-env -iA nixos.curl nixos.cabextract nixos.p7zip nixos.wine-staging
                echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
            fi
        elif [[ $DISTRO_VERSION == *"openSUSE"* ]]; then
            if [[ $(zypper search --installed-only) == *"p7zip-full"*"curl"*"wine"*"cabextract"* ]]; then
                echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                if [[ $DISTRO_VERSION == *"openSUSE"*"15.4"* ]]; then
                    if [[ $(zypper lr -u) == *"https://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Leap_15.4/"*]]
                        sudo zypper install -y p7zip-full curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    else
                        sudo zypper ar -cfp 95 https://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Leap_15.4/ wine
                        sudo zypper install p7zip-full curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    fi
                elif [[ $DISTRO_VERSION == *"openSUSE"*"15.5"* ]]; then
                    if [[ $(zypper lr -u) == *"https://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Leap_15.5/"*]]
                        sudo zypper install -y p7zip-full curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    else
                        sudo zypper ar -cfp 95 https://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Leap_15.5/ wine
                        sudo zypper install p7zip-full curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    fi
                elif [[ $DISTRO_VERSION == *"openSUSE"*"Tumbleweed"* ]]; then
                    if [[ $(zypper lr -u) == *"https://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/"*]]
                        sudo zypper install -y p7zip-full curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    else
                        sudo zypper ar -cfp 95 https://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
                        sudo zypper install p7zip-full curl wine cabextract
                        echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                    fi
                else
                    echo -e "${YELLOW}The installer doesn't support your current Linux distribution ($DISTRO_VERSION) at this time!${NOCOLOR}"; 
                    echo -e "${RED}The installer has been terminated!${NOCOLOR}"
                    exit;
                fi
            fi
        elif [[ $DISTRO_VERSION == *"Red Hat Enterprise Linux"* ]]; then
            if [[ $(dnf list installed) == *"curl"*"cabextract"*"wine"*"p7zip"*"p7zip-plugins"* ]]; then
                echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                if [[ $DISTRO_VERSION == *"Red Hat Enterprise Linux"*"8"* ]]; then
                    sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
                    sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
                    sudo dnf update && sudo dnf upgrade
                    sudo dnf install curl cabextract p7zip p7zip-plugins wine
                    echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                elif [[ $DISTRO_VERSION == *"Red Hat Enterprise Linux"*"9"* ]]; then
                    sudo subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms
                    sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
                    sudo dnf update && sudo dnf upgrade
                    sudo dnf install curl cabextract p7zip p7zip-plugins wine
                    echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
                else
                    echo -e "${YELLOW}The installer doesn't support your current Linux distribution ($DISTRO_VERSION) at this time!${NOCOLOR}"; 
                    echo -e "${RED}The installer has been terminated!${NOCOLOR}"
                    exit;
                fi
            fi
        elif [[ $DISTRO_VERSION == *"Solus"*"Linux"* ]]; then
            if [[ $(eopkg li -l) == *"wine"*"winetricks"*"p7zip"*"curl"*"cabextract"*"samba"*"ppp"* ]]; then
                echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                sudo eopkg install -y wine winetricks p7zip curl cabextract samba ppp
                echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
            fi
        elif [[ $DISTRO_VERSION == *"Void"*"Linux"* ]]; then
            if [[ $(xbps-query -l | awk '{ print $2 }' | xargs -n1 xbps-uhelper getpkgname) == *"wine"*"wine-mono"*"wine-gecko"*"winetricks"*"p7zip"*"curl"*"cabextract"*"samba"*"ppp"* ]]; then
               echo -e "${GREEN}The latest wine version is already installed.${NOCOLOR}"
            else
                echo -e "${YELLOW}The latest wine version will be installed!${NOCOLOR}"
                sudo xbps-install -Sy wine wine-mono wine-gecko winetricks p7zip curl cabextract samba ppp
                echo -e "${GREEN}The latest wine version is installed!${NOCOLOR}"
            fi
        else
            echo -e "${YELLOW}The installer doesn't support your current Linux distribution ($DISTRO_VERSION) at this time!${NOCOLOR}"; 
            echo -e "${RED}The installer has been terminated!${NOCOLOR}"
            exit;
        fi
}

###############################################################################################################################################################
# ALL DIALOGS ARE ARRANGED HERE:                                                                                                                              #
###############################################################################################################################################################



##############################################################################################################################################################################
# THE INSTALLATION PROGRAM IS STARTED HERE:                                                                                                                                  #
##############################################################################################################################################################################

SP_LOAD_COLOR_SHEME
SP_ADD_DIRECTORIES
SP_LOG_INSTALLATION
SP_CHECK_REQUIRED_COMMANDS





















###############################################################################################################################################################
# IMPORTANT NOTICE FOR THE USER:                                                                                                                              #
###############################################################################################################################################################
# With the command: "glxinfo | grep -A 10 -B 1 Vendor"                                                                                                        #
# It automatically detects which graphics card (if AMD, INTEL or NVIDIA) is currently being used for image output and calculation of the applications.        #
# This means that if two graphics cards are installed, it will be checked which one is being used!                                                            #
###############################################################################################################################################################






















###############################################################################################################################################################
# ALL GRAPHICAL DIALOGUES ARE ARRANGED HERE:                                                                                                                  #
###############################################################################################################################################################

# Default function to show download progress:
function SP_DOWNLOAD_FILE {
    wget -N -P "$SP_DOWNLOAD_FILE_DIRECTORY" --progress=dot "$SP_DOWNLOAD_FILE_URL" 2>&1 |\
    grep "%" |\
    sed -u -e "s,\.,,g" | awk '{print $2}' | sed -u -e "s,\%,,g"  | dialog --backtitle "$SP_TITLE" --gauge "$SP_DOWNLOAD_FILE_TEXT" 10 100
    sleep 1 
}

###############################################################################################################################################################

# Welcome window for a complete new installation:
function SP_WELCOME {
    SP_LOCALE=$(dialog --backtitle "$SP_TITLE" \
        --title "$SP_WELCOME_SUBTITLE" \
        --radiolist "$SP_WELCOME_TEXT" 0 0 0 \
            01 "中文(简体)" off\
            02 "Čeština" off\
            03 "English" on\
            04 "Français" off\
            05 "Deutsch" off\
            06 "Italiano" off\
            07 "日本語" off\
            08 "한국어" off\
            09 "Española" off 3>&1 1>&2 2>&3 3>&-;)

    if [ $PIPESTATUS -eq 0 ]; then
        SP_CONFIG_LOCALE && SP_LICENSE_SHOW # Shows the user the license agreement.
    elif [ $PIPESTATUS -eq 1 ]; then
        SP_LOCALE=$(echo $LANG) && SP_WELCOME_EXIT # Displays a warning to the user whether the program should really be terminated.
    elif [ $PIPESTATUS -eq 255 ]; then
        echo "[ESC] key pressed." # Program has been terminated manually! <-- Replace with a GUI!
    else
        exit;
    fi
}

###############################################################################################################################################################

function SP_WELCOME_EXIT {
    dialog --backtitle "$SP_TITLE" \
        --yesno "$SP_WELCOME_LABEL_1" 0 0
        response=$?
        case $response in
            0) clear && exit;; # Program has been terminated manually!
            1) SP_WELCOME;; # Go back to the welcome window!
            255) echo "[ESC] key pressed.";; # Program has been terminated manually! <-- Replace with a GUI!
        esac
}

###############################################################################################################################################################

function SP_LICENSE_SHOW {
    SP_LICENSE_CHECK=$(dialog --backtitle "$SP_TITLE" \
        --title "$SP_LICENSE_SHOW_SUBTITLE" \
        --checklist "`cat $SP_LICENSE_FILE`" 0 0 0 \
            "$SP_LICENSE_SHOW_TEXT_1" "$SP_LICENSE_SHOW_TEXT_2" off 3>&1 1>&2 2>&3 3>&-;)
            
    if [ $PIPESTATUS -eq 0 ]; then
        SP_LICENSE_CHECK_STATUS
    elif [ $PIPESTATUS -eq 1 ]; then
        SP_WELCOME
    elif [ $PIPESTATUS -eq 255 ]; then
        echo "[ESC] key pressed." # Program has been terminated manually! <-- Replace with a GUI!
    else
        exit;
    fi
} 

###############################################################################################################################################################

function SP_SHOW_LICENSE_WARNING {
    dialog --backtitle "$SP_TITLE" \
        --yesno "$SP_LICENSE_WARNING_TEXT" 0 0
        response=$?
        case $response in
            0) SP_LICENSE_SHOW;; # Open the next dialog for accept the license.
            1) exit;; # Program has been terminated manually!
            255) echo "[ESC] key pressed.";; # Program has been terminated manually! <-- Replace with a GUI!
        esac
}

###############################################################################################################################################################

function SP_SELECT_OS_VERSION {
    SP_OS_VERSION=$(dialog --backtitle "$SP_TITLE" \
        --title "$SP_SELECT_OS_VERSION_SUBTITLE" \
        --radiolist "$SP_SELECT_OS_VERSION_TEXT" 0 0 0 \
            01 "Arch Linux" off\
            02 "Debian" off\
            03 "EndeavourOS" off\
            04 "Fedora" off\
            05 "Linux Mint" off\
            06 "Manjaro Linux" off\
            07 "openSUSE Leap & TW" off\
            08 "Red Hat Enterprise Linux" off\
            09 "Solus" off\
            10 "Ubuntu" off\
            11 "Void Linux" off\
            12 "Gentoo Linux" off 3>&1 1>&2 2>&3 3>&-)
            
    if [ $PIPESTATUS -eq 0 ]; then
        SP_CHECK_REQUIRED_WINE_VERSION
    elif [ $PIPESTATUS -eq 1 ]; then
        SP_LICENSE_SHOW
    elif [ $PIPESTATUS -eq 255 ]; then
        echo "[ESC] key pressed." # Program has been terminated manually! <-- Replace with a GUI!
    else
        exit;
    fi
}

###############################################################################################################################################################








###############################################################################################################################################################
# THE INSTALLATION PROGRAM IS STARTED HERE:                                                                                                                   #
###############################################################################################################################################################

# ...

#!/usr/bin/env bash

###########################################################
# This file is part of the project:                       #
# mictgl                                                  #
#                                                         #
# License: GPL-3.0+                                       #
# License URL: https://www.gnu.org/licenses/gpl-3.0.html  #
#                                                         #
# This program is free software: you can redistribute it  #
# and/or modify it under the terms of the GNU General     #
# Public License as published by the Free Software        #
# Foundation, either version 3 of the License, or (at     #
# your option) any later version.                         #
#                                                         #
# This program is distributed in the hope that it will be #
# useful, but WITHOUT ANY WARRANTY; without even the      #
# implied warranty of MERCHANTABILITY or FITNESS FOR A    #
# PARTICULAR PURPOSE. See the GNU General Public License  #
# for more details.                                       #
#                                                         #
# You should have received a copy of the GNU General      #
# Public License along with this program. If not, see     #
# <http://www.gnu.org/licenses/>.                         #
#---------------------------------------------------------#
# Project: mictgl - Version 0.1 (beta)                    #
# This file: mictgl.sh                                    #
#                                                         #
# Script for mute/unmute microphone using ALSA,           #
# PulseAudio and PipeWire                                 #
#                                                         #
# 1 - Open the terminal                                   #
# 2 - Go to directory of 'mictgl.sh'                      #
# 3 - Give 'mictgl.sh' execution permission:              #
# "chmod +x mictgl.sh"                                    #
# 4 - Execute 'mictgl.sh':                                #
# "./mictgl.sh"                                           #
# 5 - Optional: You can add an alias manually in your     #
# aliases files if you want. (recommended)*               #
# PS: If you used install.sh you can just use "mtgl"      #
# from anywhere of your system in your terminal.          #
# **For quick access, integrate this script into your     #
# desktop environment's hotkey or/and shortcut system.**  #
# This allows for easy and instant microphone toggling.   #
#                                                         #
# See README for more information about installation and  #
# use.                                                    #
#                                                         #
# What does this script do?                               #
#                                                         #
# **IT'S A LOW-INTERACT SCRIPT**                          #
# A minimalist Bash script designed to toggle the         #
# mute/unmute state of a specified microphone input using #
# ALSA (Advanced Linux Sound Architecture), PulseAudio    #
# and PipeWire. It provides visual feedback through       #
# desktop notifications (via notify-send), offering       #
# customizable messages, icons and alerts based on system #
# language and user-defined themes. This script is ideal  #
# for integration into *system hotkeys*, enabling quick   #
# and natural microphone control. It performs robust      #
# dependency checks and requires minimal user interaction #
# for daily use.                                          #
#                                                         #
# Dependencies:                                           #
# - Core utilities: bash (>= 2.0), cut, uname, grep, cat, #
#                   command, dirname, readlink, tr, awk   #
#                   sed                                   #
# - Audio control: amixer, aplay (from alsa-utils)        #
# - Notifications: notify-send                            #
#                  (from libnotify-bin/libnotify)         #
# *Optional:                                              #
# - Audio control: pactl, paplay                          #
#                  (from pulseaudio-utils /               #
#                  pulseaudio pulseaudio-alsa )           #
#                                                         #
#                  wpctl, pw-play                         #
#                  (from pipewire                         #
#                  pipewire-audio-client-libraries        #
#                  wireplumber /                          #
#                  pipewire-utils pipewire-pulseaudio /   #
#                  pipewire-pulse)                        #
#---------------------------------------------------------#
# Developer: Mozert M. Ramalho                            #
# Contact: https://github.com/mozertdev/                  #
#                                                         #
# Last Update: 2025/08/01                                 #
#                                                         #
###########################################################

### SYSTEM CHECK
#### [NOTICE] ####
# The dependencies bash, cut and uname need to be checked before the others
# dependencies, and need to be one by one because bash v2.0 or below can't use
# iteratebles and they are used to check bash version and the operational system
# before the others dependencies check.

MSG_DEPENDENCIES="$(cat << EOF
The software needs the following dependencies. Please make sure they're installed on your system.

--- Debian/Ubuntu-based distributions
sudo apt update && sudo apt install coreutils util-linux grep diffutils alsa-utils libnotify-bin

--- Fedora/RHEL-based distributions
sudo dnf install coreutils util-linux grep diffutils alsa-utils libnotify

--- Arch Linux-based distributions
sudo pacman -Sy coreutils util-linux grep diffutils alsa-utils libnotify

--- openSUSE-based distributions
sudo zypper install coreutils util-linux grep diffutils alsa-utils libnotify
EOF
)"

# Check if 'bash' command exists
command -v bash >/dev/null 2>&1
if [ ! "$?" = "0" ]; then
    echo "Error: The command 'bash' is not installed or not available in the PATH."
    echo -e "$MSG_DEPENDENCIES"
    exit 1
fi

# Check if 'cut' command exists
command -v cut >/dev/null 2>&1
if [ ! "$?" = "0" ]; then
    echo "Error: The command 'cut' is not installed or not available in the PATH."
    echo -e "$MSG_DEPENDENCIES"
    exit 1
fi

# Check if 'uname' command exists
command -v uname >/dev/null 2>&1
if [ ! "$?" = "0" ]; then
    echo "Error: The command 'uname' is not installed or not available in the PATH."
    echo -e "$MSG_DEPENDENCIES"
    exit 1
fi

# Check if the version of bash is greater than 2.0
MAJOR_BASH_VERSION="$(echo "$BASH_VERSION" | cut -d'.' -f1)"

if [ "$MAJOR_BASH_VERSION" -lt 2 ]; then
    echo "Your current Bash version is: $BASH_VERSION"
    echo "Error: This script requires Bash version 2.0 or higher."
    exit 1
fi

# Check if the system is Linux
if [ ! "$(uname -s)" = "Linux" ]; then
    echo "Error: This script only runs on Linux systems."
    exit 1
fi

### DEPENDENCIES
# List of dependencies the script needs
DEPENDENCIES=(
    "grep"
    "dirname"
    "readlink"
    "tr"
    "awk"
    "sed"
    "amixer"
    "aplay"
    "notify-send"
)

# Loop to check all dependencies
for dep in "${DEPENDENCIES[@]}"; do
    command -v "$dep" >/dev/null 2>&1
    if [ ! "$?" = "0" ]; then
        echo "Error: The command '$dep' is not installed or not available in the PATH."
        echo -e "$MSG_DEPENDENCIES"
        exit 1
    fi
done

# ---------------------------------------------------------------------------- #

#------------------------------------------------------------------------------
# WARNING: DO NOT MODIFY ANYTHING ABOVE THIS LINE
#------------------------------------------------------------------------------

# ==================== OPTIONS TO BE MODIFIED IF YOU'D LIKE ====================

### GENERAL OPTIONS
#------------------------------------------------------------------------------
# Script Language
#------------------------------------------------------------------------------
# Description: Defines the system's language setting, typically obtained
#              from the environment. This variable might be used for
#              localization purposes within the script.
# Default Value: "automatic" (Dynamically determined based on the system's
#                            locale settings)
# Example Values: "en_US", "pt_BR", "es_ES"
SYSTEM_LANG="automatic"

#------------------------------------------------------------------------------
# Sound Manager
#------------------------------------------------------------------------------
# Description: Specifies the sound server to interact with for microphone
#              control. Choose the option corresponding to your system's
#              audio setup. If the selected sound manager's utilities are
#              not installed, you may need to install them (e.g., PulseAudio
#              or PipeWire packages).
# Default Value: "alsa"
# Example Values: "alsa", "pulseaudio", "pipewire"
SOUND_MANAGER="alsa"

#------------------------------------------------------------------------------
# Microphone Name
#------------------------------------------------------------------------------
# Description: Specifies the name of the microphone control to be toggled.
#              You can find available control names using the following commands:
#              ALSA:
#                  amixer scontrols
#              PULSEAUDIO:
#                  pactl list sources short
#              PIPEWIRE:
#                  wpctl status
# Default Value: "default" (Try to get the default control name)
# Example Values: "Capture"
#                 "alsa_input.usb-Mic_Name_999999999999-00.mono-fallback"
#                 "Headset Microphone Name"
MICROPHONE_NAME="default"

#------------------------------------------------------------------------------
# Enable Desktop Notifications
#------------------------------------------------------------------------------
# Description: Toggles system desktop notifications for microphone state changes
#              and errors.
# Default Value: "true"
# Example Values: "true", "false", "yes", "no", "1", "0"
ENABLE_DESKTOP_NOTIFICATIONS="true"

#------------------------------------------------------------------------------
# Enable Sound Alerts
#------------------------------------------------------------------------------
# Description: Toggles sound alerts for microphone state changes and errors.
# Default Value: "false"
# Example Values: "true", "false", "yes", "no", "1", "0"
ENABLE_SOUND_ALERTS="false"

#------------------------------------------------------------------------------
# Theme
#------------------------------------------------------------------------------
# Description: Sets the visual theme for notifications.
#              Choosing "custom" allows the use of system default icons or
#              user-defined SVG icons via the UNMUTED_ICON, MUTED_ICON,
#              and ERROR_ICON variables.
# Default Value: "dark-nox"
# Example Values: "dark-nox", "light-lumen", "custom"
ICONS_THEME="dark-nox"

#------------------------------------------------------------------------------
# Icons Size
#------------------------------------------------------------------------------
# Description: Defines the size of the icons used in notifications.
#              This setting applies to built-in themes and influences the
#              expected size for custom SVG icons.
# Default Value: "standard"
# Example Values:
#   "small"    (32x32 pixels)
#   "standard" (48x48 pixels)
#   "large"    (64x64 pixels)
ICONS_SIZE="standard"

#------------------------------------------------------------------------------
# Unmuted Icon
#------------------------------------------------------------------------------
# Description: Specifies the icon to display when the microphone is unmuted.
#              Only active if ICONS_THEME is set to "custom".
#              Can be a system icon name (e.g., "audio-input-microphone") or
#              a full path to a custom SVG icon (e.g., "/path/to/my-active-mic.svg").
# Default Value: "" (System default icon name)
# Example Values: "audio-input-microphone", "/home/user/icons/48x48/mic-on.svg"
UNMUTED_ICON=""

#------------------------------------------------------------------------------
# Muted Icon
#------------------------------------------------------------------------------
# Description: Specifies the icon to display when the microphone is muted.
#              Only active if ICONS_THEME is set to "custom".
#              Can be a system icon name (e.g., "audio-input-microphone-muted") or
#              a full path to a custom SVG icon (e.g., "/path/to/my-muted-mic.svg").
# Default Value: "" (System default icon name)
# Example Values: "audio-input-microphone-muted", "/home/user/icons/48x48/mic-off.svg"
MUTED_ICON=""

#------------------------------------------------------------------------------
# Error Icon
#------------------------------------------------------------------------------
# Description: Specifies the icon to display when an error occurs.
#              Only active if ICONS_THEME is set to "custom".
#              Can be a system icon name (e.g., "error") or
#              a full path to a custom SVG icon (e.g., "/path/to/my-error.svg").
# Default Value: "" (System default icon name)
# Example Values: "error", "/home/user/icons/48x48/error-alert.svg"
ERROR_ICON=""

#------------------------------------------------------------------------------
# Sound Effects Theme
#------------------------------------------------------------------------------
# Description: Sets the sound theme for alerts.
#              Choosing "custom" allows the use of user-defined WAV sound files
#              via the UNMUTED_SOUND, MUTED_SOUND, and ERROR_SOUND variables.
# Default Value: "arcade-flash"
# Example Values: "arcade-flash", "arcade-signal", "custom"
SOUND_EFFECTS_THEME="arcade-flash"

#------------------------------------------------------------------------------
# Unmuted Sound
#------------------------------------------------------------------------------
# Description: Specifies the sound file to play when the microphone is unmuted.
#              Only active if SOUND_EFFECTS_THEME is set to "custom".
#              Must be a full path to a WAV file (e.g., "/path/to/my-unmuted-mic.wav").
# Default Value: "" (No custom sound)
# Example Values: "/home/user/sounds/mic-on.wav"
UNMUTED_SOUND=""

#------------------------------------------------------------------------------
# Muted Sound
#------------------------------------------------------------------------------
# Description: Specifies the sound file to play when the microphone is muted.
#              Only active if SOUND_EFFECTS_THEME is set to "custom".
#              Must be a full path to a WAV file (e.g., "/path/to/my-muted-mic.wav").
# Default Value: "" (No custom sound)
# Example Values: "/home/user/sounds/mic-off.wav"
MUTED_SOUND=""

#------------------------------------------------------------------------------
# Error Sound
#------------------------------------------------------------------------------
# Description: Specifies the sound file to play when an error occurs.
#              Only active if SOUND_EFFECTS_THEME is set to "custom".
#              Must be a full path to a WAV file (e.g., "/path/to/my-error-alert.wav").
# Default Value: "" (No custom sound)
# Example Values: "/home/user/sounds/error.wav"
ERROR_SOUND=""

# ======================= END OF OPTIONS TO BE MODIFIED ========================

#------------------------------------------------------------------------------
# WARNING: DO NOT MODIFY ANYTHING BELOW THIS LINE
#------------------------------------------------------------------------------

### CONSTANTS
# Script directory
SCRIPT_DIRECTORY="$(dirname "$(readlink -f "$0")")"

# Resources directory
RESOURCES_DIR="$SCRIPT_DIRECTORY/res"

# Themes directory
THEMES_DIR="$RESOURCES_DIR/themes"

# Icons themes directory
ICONS_THEMES_DIR="$THEMES_DIR/icons-themes"

# Sound effects themes directory
SOUND_EFFECTS_THEME_DIR="$THEMES_DIR/sfx-themes"

### VARIABLES FOR LOCALIZATION
# Default messages in English
MSG_MIC_UNMUTED_TITLE="Microphone Unmuted"
MSG_MIC_UNMUTED_CONTENT="Your microphone is now active."
MSG_MIC_MUTED_TITLE="Microphone Muted"
MSG_MIC_MUTED_CONTENT="Your microphone is now muted."
MSG_MIC_ERROR_TITLE="mictgl Error"
MSG_MIC_WARNING_TITLE="mictgl Warning"
MSG_MIC_ERROR_UNEXPECTED="An unexpected error occurred"
MSG_MIC_WARNING_ICON_FILE_NOT_FOUND="Icon file not found"
MSG_MIC_WARNING_ICON_FILE_FORMAT="Icon file format is not '.svg'. Use '.svg' files for better results"
MSG_MIC_ERROR_SOUND_FILE_NOT_FOUND="Sound file not found"
MSG_MIC_ERROR_SOUND_FILE_FORMAT="Invalid sound file format. Only '.wav' files are supported"
MSG_MIC_ERROR_SOUND_MANAGER="$(cat << EOF
Invalid sound manager.
Try edit the configuration variable SOUND_MANAGER using 'alsa', 'pulseaudio' or 'pipewire'.

Maybe you can fix it by changing the "SOUND_MANAGER" variable inside the mictgl script:
1 - Open the "mictgl.sh" file in your preferred code editor. Ex: nano, vi, vim, vscode

2 - Edit the "SOUND_MANAGER" variable using the name of the sound manager you want to use
Ex: SOUND_MANAGER="alsa", SOUND_MANAGER="pulseaudio", SOUND_MANAGER="pipewire"

4 - Save the changes to the script

5 - Run the script again
EOF
)"
MSG_MIC_ERROR_ALSA_MIC_NAME="$(cat << EOF
Maybe you can fix it by changing the "MICROPHONE_NAME" variable inside the mictgl script
1 - Type the following command in your Terminal:
amixer scontrols

2 - Open the "mictgl.sh" file in your preferred code editor. Ex: nano, vi, vim, vscode

3 - Edit the "MICROPHONE_NAME" variable using the name of the microphone you want to use
Ex: MICROPHONE_NAME="Microphone", MICROPHONE_NAME="Headset Mic"

4 - Save the changes to the script

5 - Run the script again
EOF
)"
MSG_MIC_ERROR_PULSEAUDIO_MIC_NAME="$(cat << EOF
Maybe you can fix it by changing the "MICROPHONE_NAME" variable inside the mictgl script
1 - Type the following command in your Terminal:
pactl list sources short

2 - Open the "mictgl.sh" file in your preferred code editor. Ex: nano, vi, vim, vscode

3 - Edit the "MICROPHONE_NAME" variable using the name of the microphone you want to use
Ex: MICROPHONE_NAME="alsa_input.usb-Mic_Name_999999999999-00.mono-fallback"

4 - Save the changes to the script

5 - Run the script again
EOF
)"
MSG_MIC_ERROR_PIPEWIRE_MIC_NAME="$(cat << EOF
Maybe you can fix it by changing the "MICROPHONE_NAME" variable inside the mictgl script
1 - Type the following command in your Terminal:
wpctl status

2 - Open the "mictgl.sh" file in your preferred code editor. Ex: nano, vi, vim, vscode

3 - Edit the "MICROPHONE_NAME" variable using the name of the microphone you want to use.
PS: It is inside the "Sources:" section
Ex: MICROPHONE_NAME="Headset Microphone Name"

4 - Save the changes to the script

5 - Run the script again
EOF
)"
MSG_PULSEAUDIO_DEPENDENCIES="$(cat << EOF
The software needs the following dependencies. Please make sure they're installed on your system.

--- Debian/Ubuntu-based distributions
sudo apt update && sudo apt install pulseaudio-utils

--- Fedora/RHEL-based distributions
sudo dnf install pulseaudio-utils

--- Arch Linux-based distributions
sudo pacman -S pulseaudio pulseaudio-alsa

--- openSUSE-based distributions
sudo zypper install pulseaudio-utils
EOF
)"
MSG_PIPEWIRE_DEPENDENCIES="$(cat << EOF
The software needs the following dependencies. Please make sure they're installed on your system.

--- Debian/Ubuntu-based distributions
sudo apt update && sudo apt install pipewire pipewire-audio-client-libraries wireplumber

--- Fedora/RHEL-based distributions
sudo dnf install pipewire pipewire-utils pipewire-pulseaudio wireplumber

--- Arch Linux-based distributions
sudo pacman -S pipewire pipewire-pulse wireplumber

--- openSUSE-based distributions
sudo zypper install pipewire pipewire-pulseaudio pipewire-utils wireplumber
EOF
)"

### FUNCTIONS
#------------------------------------------------------------------------------
# Function: set_language
# Description: Configures the script's messaging (titles and content for
#              notifications) based on the system's language setting. It supports
#              automatic detection via the 'LANG' environment variable or
#              explicit setting via 'SYSTEM_LANG'.
# Parameters: None
# Returns: None
# Side Effects: Modifies global variables: MSG_MIC_UNMUTED_TITLE,
#               MSG_MIC_UNMUTED_CONTENT, MSG_MIC_MUTED_TITLE,
#               MSG_MIC_MUTED_CONTENT, MSG_MIC_ERROR_TITLE,
#               MSG_MIC_ERROR_UNEXPECTED.
#------------------------------------------------------------------------------
set_language() {
    if [[ "$SYSTEM_LANG" = "automatic" ]]; then
        SYSTEM_LANG="$LANG"
    fi
    
    if [[ "$SYSTEM_LANG" =~ pt_BR ]]; then
        # Change messages to Portuguese if system is set to Brazilian Portuguese
        MSG_MIC_UNMUTED_TITLE="Microfone Ativado"
        MSG_MIC_UNMUTED_CONTENT="Seu microfone está ativo agora."
        MSG_MIC_MUTED_TITLE="Microfone Desativado"
        MSG_MIC_MUTED_CONTENT="Seu microfone está silenciado agora."
        MSG_MIC_ERROR_TITLE="Erro no mictgl"
        MSG_MIC_WARNING_TITLE="Aviso do mictgl"
        MSG_MIC_ERROR_UNEXPECTED="Ocorreu um erro inesperado."
        MSG_MIC_WARNING_ICON_FILE_NOT_FOUND="Arquivo de ícone não encontrado"
        MSG_MIC_WARNING_ICON_FILE_FORMAT="O formato do arquivo de ícone não é '.svg'. Use arquivos '.svg' para melhores resultados"
        MSG_MIC_ERROR_SOUND_FILE_NOT_FOUND="Arquivo de som não encontrado"
        MSG_MIC_ERROR_SOUND_FILE_FORMAT="Formato de arquivo de som inválido. Apenas arquivos '.wav' são suportados"
        MSG_MIC_ERROR_SOUND_MANAGER="$(cat << EOF
Gerenciador de som inválido.
Tente editar a variável de configuração SOUND_MANAGER usando 'alsa', 'pulseaudio' ou 'pipewire'.

Talvez você possa corrigir o problema alterando a variável "SOUND_MANAGER" dentro do script mictgl:
1 - Abra o arquivo "mictgl.sh" no seu editor de código preferido. Ex: nano, vi, vim, vscode

2 - Edite a variável "SOUND_MANAGER" usando o nome do gerenciador de som que deseja usar
Ex: SOUND_MANAGER="alsa", SOUND_MANAGER="pulseaudio", SOUND_MANAGER="pipewire"

4 - Salve as alterações no script

5 - Execute o script novamente
EOF
)"
        MSG_MIC_ERROR_ALSA_MIC_NAME="$(cat << EOF
Você pode tentar consertar isso alterando a variável "MICROPHONE_NAME" dentro do script mictgl:
1 - Digite o seguinte comando no seu Terminal:
amixer scontrols

2 - Abra o arquivo "mictgl.sh" no seu editor de código preferido. Ex: nano, vi, vim, vscode

3 - Edite a variável "MICROPHONE_NAME" usando o nome do microfone que você deseja usar
Ex: MICROPHONE_NAME="Microphone", MICROPHONE_NAME="Headset Mic"

4 - Salve as alterações no script

5 - Execute o script novamente
EOF
)"
        MSG_MIC_ERROR_PULSEAUDIO_MIC_NAME="$(cat << EOF
Você pode tentar consertar isso alterando a variável "MICROPHONE_NAME" dentro do script mictgl:
1 - Digite o seguinte comando no seu Terminal:
pactl list sources short

2 - Abra o arquivo "mictgl.sh" no seu editor de código preferido. Ex: nano, vi, vim, vscode

3 - Edite a variável "MICROPHONE_NAME" usando o nome do microfone que você deseja usar
Ex: MICROPHONE_NAME="alsa_input.usb-Mic_Name_999999999999-00.mono-fallback"

4 - Salve as alterações no script

5 - Execute o script novamente
EOF
)"
        MSG_MIC_ERROR_PIPEWIRE_MIC_NAME="$(cat << EOF
Você pode tentar consertar isso alterando a variável "MICROPHONE_NAME" dentro do script mictgl:
1 - Digite o seguinte comando no seu Terminal:
wpctl status

2 - Abra o arquivo "mictgl.sh" no seu editor de código preferido. Ex: nano, vi, vim, vscode

3 - Edite a variável "MICROPHONE_NAME" usando o nome do microfone que você deseja usar
PS: Está dentro da sessão "Sources:"
Ex: MICROPHONE_NAME="Headset Microphone Name"

4 - Salve as alterações no script

5 - Execute o script novamente
EOF
)"
        MSG_PULSEAUDIO_DEPENDENCIES="$(cat << EOF
O software precisa das seguintes dependências. Certifique-se de que elas estejam instaladas no seu sistema.

--- Debian/Ubuntu-based distributions
sudo apt update && sudo apt install pulseaudio-utils

--- Fedora/RHEL-based distributions
sudo dnf install pulseaudio-utils

--- Arch Linux-based distributions
sudo pacman -S pulseaudio pulseaudio-alsa

--- openSUSE-based distributions
sudo zypper install pulseaudio-utils
EOF
)"
        MSG_PIPEWIRE_DEPENDENCIES="$(cat << EOF
O software precisa das seguintes dependências. Certifique-se de que elas estejam instaladas no seu sistema.

--- Debian/Ubuntu-based distributions
sudo apt update && sudo apt install pipewire pipewire-audio-client-libraries wireplumber

--- Fedora/RHEL-based distributions
sudo dnf install pipewire pipewire-utils pipewire-pulseaudio wireplumber

--- Arch Linux-based distributions
sudo pacman -S pipewire pipewire-pulse wireplumber

--- openSUSE-based distributions
sudo zypper install pipewire pipewire-pulseaudio pipewire-utils wireplumber
EOF
)"
    elif [[ "$SYSTEM_LANG" =~ es_ES ]]; then
        # Change messages to Spanish if system is set to Spanish
        MSG_MIC_UNMUTED_TITLE="Micrófono Activado"
        MSG_MIC_UNMUTED_CONTENT="Su micrófono está activo ahora."
        MSG_MIC_MUTED_TITLE="Micrófono Desactivado"
        MSG_MIC_MUTED_CONTENT="Su micrófono está silenciado ahora."
        MSG_MIC_ERROR_TITLE="Error del mictgl"
        MSG_MIC_WARNING_TITLE="Advertencia del mictgl"
        MSG_MIC_ERROR_UNEXPECTED="Ha ocurrido un error inesperado."
        MSG_MIC_WARNING_ICON_FILE_NOT_FOUND="Archivo de icono no encontrado"
        MSG_MIC_WARNING_ICON_FILE_FORMAT="El formato del archivo de icono no es '.svg'. Use archivos '.svg' para mejores resultados"
        MSG_MIC_ERROR_SOUND_FILE_NOT_FOUND="Archivo de sonido no encontrado"
        MSG_MIC_ERROR_SOUND_FILE_FORMAT="Formato de archivo de sonido no válido. Solo se admiten archivos '.wav'"
        MSG_MIC_ERROR_SOUND_MANAGER="$(cat << EOF
Administrador de sonido no válido.
Intenta editar la variable de configuración SOUND_MANAGER con 'alsa', 'pulseaudio' o 'pipewire'.

Quizás puedas solucionarlo modificando la variable "SOUND_MANAGER" dentro del script mictgl:
1 - Abre el archivo "mictgl.sh" en tu editor de código preferido. Por ejemplo: nano, vi, vim, vscode.

2 - Edita la variable "SOUND_MANAGER" con el nombre del administrador de sonido que quieras usar.
Ej: SOUND_MANAGER="alsa", SOUND_MANAGER="pulseaudio", SOUND_MANAGER="pipewire".

4 - Guarda los cambios en el script.

5 - Ejecuta el script de nuevo.
EOF
)"
        MSG_MIC_ERROR_ALSA_MIC_NAME="$(cat << EOF
Puede que puedas solucionarlo cambiando la variable "MICROPHONE_NAME" dentro del script mictgl:
1 - Escribe el siguiente comando en tu Terminal:
amixer scontrols

2 - Abre el archivo "mictgl.sh" en tu editor de código preferido. Ej: nano, vi, vim, vscode

3 - Edita la variable "MICROPHONE_NAME" usando el nombre del micrófono que deseas usar
Ej: MICROPHONE_NAME="Microphone", MICROPHONE_NAME="Headset Mic"

4 - Guarda los cambios en el script

5 - Ejecuta el script de nuevo
EOF
)"
        MSG_MIC_ERROR_PULSEAUDIO_MIC_NAME="$(cat << EOF
Puede que puedas solucionarlo cambiando la variable "MICROPHONE_NAME" dentro del script mictgl:
1 - Escribe el siguiente comando en tu Terminal:
pactl list sources short

2 - Abre el archivo "mictgl.sh" en tu editor de código preferido. Ej: nano, vi, vim, vscode

3 - Edita la variable "MICROPHONE_NAME" usando el nombre del micrófono que deseas usar
Ej: MICROPHONE_NAME="alsa_input.usb-Mic_Name_999999999999-00.mono-fallback"

4 - Guarda los cambios en el script

5 - Ejecuta el script de nuevo
EOF
)"
        MSG_MIC_ERROR_PIPEWIRE_MIC_NAME="$(cat << EOF
Puede que puedas solucionarlo cambiando la variable "MICROPHONE_NAME" dentro del script mictgl:
1 - Escribe el siguiente comando en tu Terminal:
wpctl status

2 - Abre el archivo "mictgl.sh" en tu editor de código preferido. Ej: nano, vi, vim, vscode

3 - Edita la variable "MICROPHONE_NAME" usando el nombre del micrófono que deseas usar
PS: Está dentro de la sección “Sources:”
Ej: MICROPHONE_NAME="Headset Microphone Name"

4 - Guarda los cambios en el script

5 - Ejecuta el script de nuevo
EOF
)"
        MSG_PULSEAUDIO_DEPENDENCIES="$(cat << EOF
El software requiere las siguientes dependencias. Asegúrese de que estén instaladas en su sistema.

--- Debian/Ubuntu-based distributions
sudo apt update && sudo apt install pulseaudio-utils

--- Fedora/RHEL-based distributions
sudo dnf install pulseaudio-utils

--- Arch Linux-based distributions
sudo pacman -S pulseaudio pulseaudio-alsa

--- openSUSE-based distributions
sudo zypper install pulseaudio-utils
EOF
)"
        MSG_PIPEWIRE_DEPENDENCIES="$(cat << EOF
El software requiere las siguientes dependencias. Asegúrese de que estén instaladas en su sistema.

--- Debian/Ubuntu-based distributions
sudo apt update && sudo apt install pipewire pipewire-audio-client-libraries wireplumber

--- Fedora/RHEL-based distributions
sudo dnf install pipewire pipewire-utils pipewire-pulseaudio wireplumber

--- Arch Linux-based distributions
sudo pacman -S pipewire pipewire-pulse wireplumber

--- openSUSE-based distributions
sudo zypper install pipewire pipewire-pulseaudio pipewire-utils wireplumber
EOF
)"
    fi
}

#------------------------------------------------------------------------------
# Function: set_icons_theme
# Description: Determines the appropriate icon paths based on the selected
#              ICONS_THEME and ICONS_SIZE. If ICONS_THEME is "custom", it uses
#              user-defined icon paths specified in UNMUTED_ICON, MUTED_ICON,
#              and ERROR_ICON variables. Otherwise, it constructs paths to
#              theme-specific SVG icons.
# Parameters: None
# Returns: None
# Side Effects: Modifies global variables: ICONS_SIZE_PX, UNMUTED_ICON,
#              MUTED_ICON, ERROR_ICON.
#------------------------------------------------------------------------------
set_icons_theme() {
    if [[ "$ICONS_SIZE" = "standard" ]]; then
        ICONS_SIZE_PX="48x48"
    elif [[ "$ICONS_SIZE" = "small" ]]; then
        ICONS_SIZE_PX="32x32"
    elif [[ "$ICONS_SIZE" = "large" ]]; then
        ICONS_SIZE_PX="64x64"
    else
        ICONS_SIZE_PX="48x48"
    fi
    
    if [[ ! "$ICONS_THEME" = "custom" ]]; then
        UNMUTED_ICON="$ICONS_THEMES_DIR/$ICONS_THEME/$ICONS_SIZE_PX/microphone-active.svg"
        MUTED_ICON="$ICONS_THEMES_DIR/$ICONS_THEME/$ICONS_SIZE_PX/microphone-muted.svg"
        ERROR_ICON="$ICONS_THEMES_DIR/$ICONS_THEME/$ICONS_SIZE_PX/microphone-error.svg"
    fi
}

#------------------------------------------------------------------------------
# Function: set_sfx_theme
# Description: Determines the appropriate sound effect file paths based on the
#              selected SOUND_EFFECTS_THEME. If SOUND_EFFECTS_THEME is "custom",
#              it uses user-defined sound paths specified in UNMUTED_SOUND,
#              MUTED_SOUND, and ERROR_SOUND variables. Otherwise, it constructs
#              paths to theme-specific WAV sound files.
# Parameters: None
# Returns: None
# Side Effects: Modifies global variables: UNMUTED_SOUND, MUTED_SOUND,
#              ERROR_SOUND.
#------------------------------------------------------------------------------
set_sfx_theme() {
    if [[ ! "$SOUND_EFFECTS_THEME" = "custom" ]]; then
        UNMUTED_SOUND="$SOUND_EFFECTS_THEME_DIR/$SOUND_EFFECTS_THEME/microphone-active.wav"
        MUTED_SOUND="$SOUND_EFFECTS_THEME_DIR/$SOUND_EFFECTS_THEME/microphone-muted.wav"
        ERROR_SOUND="$SOUND_EFFECTS_THEME_DIR/$SOUND_EFFECTS_THEME/microphone-error.wav"
    fi
}

#------------------------------------------------------------------------------
# Function: send_notification
# Description: Sends a desktop notification if ENABLE_DESKTOP_NOTIFICATIONS is "true",
#              "yes" or "1".
# Parameters:
#    $1 (urgency_level): Urgency level for the notification (e.g., "critical",
#                        "normal", "low").
#    $2 (title): The title of the notification.
#    $3 (content): The content/body of the notification.
#    $4 (icon): The icon to display in the notification. Can be a system icon
#               name or a full path to an SVG file. Other image formats might
#               work but SVG is recommended for scalability.
# Returns: None
# Side Effects: Sends a desktop notification.
#------------------------------------------------------------------------------
send_notification() {
    local urgency_level="$1"
    local title="$2"
    local content="$3"
    local icon="$4"
    local file_extension="${icon##*.}"

    if [[ ! "$urgency_level" =~ ^("low"|"normal"|"critical")$ ]]; then
        urgency_level="normal"
    fi

    if [[ "$ENABLE_DESKTOP_NOTIFICATIONS" =~ ^("true"|"yes"|"1")$ ]]; then
        if [[ ! -f "$icon" ]]; then
            echo -e "$MSG_MIC_WARNING_TITLE\n$MSG_MIC_WARNING_ICON_FILE_NOT_FOUND: $icon" >&2
        fi
        
        if [[ ! "$file_extension" = "svg" ]]; then
            echo -e "$MSG_MIC_WARNING_TITLE\n$MSG_MIC_WARNING_ICON_FILE_FORMAT: $icon" >&2
        fi
        notify-send -u "$urgency_level" "$title" "$content" -i "$icon"
    fi
}

#------------------------------------------------------------------------------
# Function: alsa_play_sound
# Description: Plays a sound file if ENABLE_SOUND_ALERTS is "true", "yes" or "1".
#              It validates if the file exists and if it's a WAV format.
# Parameters:
#    $1 (sound_file_path): The full path to the sound file to play.
# Returns: None
# Side Effects: Reproduces a sound. Prints error messages if the
#              file is not found or is not a WAV format.
#------------------------------------------------------------------------------
alsa_play_sound() {
    local sound_file_path="$1"
    local file_extension="${sound_file_path##*.}"

    if [[ "$ENABLE_SOUND_ALERTS" =~ ^("true"|"yes"|"1")$ ]]; then
        if [[ -f "$sound_file_path" ]]; then
            if [[ "$file_extension" = "wav" ]]; then
                aplay "$sound_file_path" &>/dev/null &
            else
                echo -e "$MSG_MIC_ERROR_TITLE\n$MSG_MIC_ERROR_SOUND_FILE_FORMAT: $sound_file_path" >&2
            fi
        else
            echo -e "$MSG_MIC_ERROR_TITLE\n$MSG_MIC_ERROR_SOUND_FILE_NOT_FOUND: $sound_file_path" >&2
        fi
    fi
}

#------------------------------------------------------------------------------
# Function: pulseaudio_play_sound
# Description: Plays a sound file using `paplay` if ENABLE_SOUND_ALERTS is
#              "true", "yes", or "1". It validates if the file exists and
#              if it's a WAV format.
# Parameters:
#   $1 (sound_file_path): The full path to the sound file to play.
# Returns: None
# Side Effects: Reproduces a sound. Prints error messages if the
#               file is not found or is not a WAV format.
#------------------------------------------------------------------------------
pulseaudio_play_sound() {
    local sound_file_path="$1"
    local file_extension="${sound_file_path##*.}"

    if [[ "$ENABLE_SOUND_ALERTS" =~ ^("true"|"yes"|"1")$ ]]; then
        if [[ -f "$sound_file_path" ]]; then
            if [[ "$file_extension" = "wav" ]]; then
                paplay "$sound_file_path" &>/dev/null &
            else
                echo -e "$MSG_MIC_ERROR_TITLE\n$MSG_MIC_ERROR_SOUND_FILE_FORMAT: $sound_file_path" >&2
            fi
        else
            echo -e "$MSG_MIC_ERROR_TITLE\n$MSG_MIC_ERROR_SOUND_FILE_NOT_FOUND: $sound_file_path" >&2
        fi
    fi
}

#------------------------------------------------------------------------------
# Function: pipewire_play_sound
# Description: Plays a sound file using `pw-play` if ENABLE_SOUND_ALERTS is
#              "true", "yes", or "1". It validates if the file exists and
#              if it's a WAV format.
# Parameters:
#   $1 (sound_file_path): The full path to the sound file to play.
# Returns: None
# Side Effects: Reproduces a sound. Prints error messages if the
#               file is not found or is not a WAV format.
#------------------------------------------------------------------------------
pipewire_play_sound() {
    local sound_file_path="$1"
    local file_extension="${sound_file_path##*.}"

    if [[ "$ENABLE_SOUND_ALERTS" =~ ^("true"|"yes"|"1")$ ]]; then
        if [[ -f "$sound_file_path" ]]; then
            if [[ "$file_extension" = "wav" ]]; then
                pw-play "$sound_file_path" &>/dev/null &
            else
                echo -e "$MSG_MIC_ERROR_TITLE\n$MSG_MIC_ERROR_SOUND_FILE_FORMAT: $sound_file_path" >&2
            fi
        else
            echo -e "$MSG_MIC_ERROR_TITLE\n$MSG_MIC_ERROR_SOUND_FILE_NOT_FOUND: $sound_file_path" >&2
        fi
    fi
}

#------------------------------------------------------------------------------
# Function: error_handler
# Description: Handles script errors by printing an error message to the
#              terminal, sending a desktop notification, playing an error
#              sound, and exiting the script with a non-zero status if an
#              error code is provided.
# Parameters:
#   $1 (exit_code): The exit code from the last command.
#   $2 (error_message): A descriptive error message to display.
# Returns: None
# Side Effects: Prints to stderr, sends desktop notification, plays sound,
#              exits script if exit_code is not 0.
#------------------------------------------------------------------------------
error_handler() {
    local exit_code="$1"
    local error_message="$2"
    
    if [[ ! "$exit_code" = "0" ]]; then
        echo -e "$MSG_MIC_ERROR_TITLE\n$2" >&2
        send_notification "critical" "$MSG_MIC_ERROR_TITLE" "$2" "$ERROR_ICON"
        alsa_play_sound "$ERROR_SOUND"
        exit 1
    fi
}

#------------------------------------------------------------------------------
# Function: get_pipewire_mic_id_by_description
# Description: Retrieves the PipeWire source ID for a microphone based on its
#              description (MICROPHONE_NAME). This is necessary because PipeWire
#              commands often require the numerical ID instead of the descriptive name.
# Parameters: None
# Returns: The numerical ID of the PipeWire microphone source.
# Side Effects: None.
#------------------------------------------------------------------------------
get_pipewire_mic_id_by_description() {
    wpctl status | \
    grep -P "\b\Q$MICROPHONE_NAME\E\b" | \
    grep -oP '\s*\d+\.' | \
    awk '{print $1}' | \
    sed 's/\.$//'
}

#------------------------------------------------------------------------------
# Function: alsa_mic_toggle
# Description: Toggles the mute state of the microphone using ALSA's `amixer` utility.
#              It checks the current microphone status, toggles it, and provides
#              desktop notifications and sound alerts. Handles default microphone
#              naming for ALSA ("Capture").
# Parameters: None
# Returns: None
# Side Effects: Modifies ALSA microphone state (mute/unmute), prints status to stdout,
#               sends desktop notifications, plays sound alerts. Calls `error_handler`
#               on `amixer` command failure.
#------------------------------------------------------------------------------
alsa_mic_toggle() {
    if [[ "$MICROPHONE_NAME" = "default" ]]; then
        MICROPHONE_NAME="Capture"
    fi
    
    # Checks the current microphone status and switches
    #Forces amixer output to English locale and converts to uppercase
    if LC_ALL=C amixer get "$MICROPHONE_NAME" | tr '[:lower:]' '[:upper:]' | grep -q '\[OFF\]'; then
        # Microphone is muted, so unmute it
        amixer set "$MICROPHONE_NAME" toggle >/dev/null 2>&1
        error_handler "$?" "$MSG_MIC_ERROR_UNEXPECTED\n\n$MSG_MIC_ERROR_ALSA_MIC_NAME"
        echo -e "$MSG_MIC_UNMUTED_TITLE\n$MSG_MIC_UNMUTED_CONTENT"
        send_notification "normal" "$MSG_MIC_UNMUTED_TITLE" "$MSG_MIC_UNMUTED_CONTENT" "$UNMUTED_ICON"
        alsa_play_sound "$UNMUTED_SOUND"
    else
        # Microphone is not muted, so mute it
        amixer set "$MICROPHONE_NAME" toggle >/dev/null 2>&1
        error_handler "$?" "$MSG_MIC_ERROR_UNEXPECTED\n\n$MSG_MIC_ERROR_ALSA_MIC_NAME"
        echo -e "$MSG_MIC_MUTED_TITLE\n$MSG_MIC_MUTED_CONTENT"
        send_notification "normal" "$MSG_MIC_MUTED_TITLE" "$MSG_MIC_MUTED_CONTENT" "$MUTED_ICON"
        alsa_play_sound "$MUTED_SOUND"
    fi
}

#------------------------------------------------------------------------------
# Function: pulseaudio_mic_toggle
# Description: Toggles the mute state of the microphone using PulseAudio's
#              `pactl` utility. It checks the current microphone status,
#              toggles it, and provides desktop notifications and sound alerts.
#              Handles default microphone naming for PulseAudio ("@DEFAULT_SOURCE@").
# Parameters: None
# Returns: None
# Side Effects: Modifies PulseAudio microphone state (mute/unmute), prints status
#               to stdout, sends desktop notifications, plays sound alerts.
#               Performs dependency checks for `pactl` and `paplay`. Calls
#               `error_handler` on `pactl` command failure.
#------------------------------------------------------------------------------
pulseaudio_mic_toggle() {
    local dependencies=(
        "pactl"
        "paplay"
    )

    # Loop to check all dependencies
    for dep in "${dependencies[@]}"; do
        command -v "$dep" >/dev/null 2>&1
        if [[ ! "$?" = "0" ]]; then
            error_handler "1" "$MSG_MIC_ERROR_UNEXPECTED\n\n$MSG_PULSEAUDIO_DEPENDENCIES"
            exit 1
        fi
    done
    
    if [[ "$MICROPHONE_NAME" = "default" ]]; then
        MICROPHONE_NAME="@DEFAULT_SOURCE@"
    fi
    
    # Checks the current microphone status and switches
    # Forces pactl output to English locale and converts to uppercase
    if LC_ALL=C pactl get-source-mute "$MICROPHONE_NAME" | tr '[:lower:]' '[:upper:]' | grep -q 'MUTE: YES'; then
        # Microphone is muted, so unmute it
        pactl set-source-mute "$MICROPHONE_NAME" 0 >/dev/null 2>&1
        error_handler "$?" "$MSG_MIC_ERROR_UNEXPECTED\n\n$MSG_MIC_ERROR_PULSEAUDIO_MIC_NAME"
        echo -e "$MSG_MIC_UNMUTED_TITLE\n$MSG_MIC_UNMUTED_CONTENT"
        send_notification "normal" "$MSG_MIC_UNMUTED_TITLE" "$MSG_MIC_UNMUTED_CONTENT" "$UNMUTED_ICON"
        pulseaudio_play_sound "$UNMUTED_SOUND"
    else
        # Microphone is not muted, so mute it
        pactl set-source-mute "$MICROPHONE_NAME" 1 >/dev/null 2>&1
        error_handler "$?" "$MSG_MIC_ERROR_UNEXPECTED\n\n$MSG_MIC_ERROR_PULSEAUDIO_MIC_NAME"
        echo -e "$MSG_MIC_MUTED_TITLE\n$MSG_MIC_MUTED_CONTENT"
        send_notification "normal" "$MSG_MIC_MUTED_TITLE" "$MSG_MIC_MUTED_CONTENT" "$MUTED_ICON"
        pulseaudio_play_sound "$MUTED_SOUND"
    fi
}

#------------------------------------------------------------------------------
# Function: pipewire_mic_toggle
# Description: Toggles the mute state of the microphone using PipeWire's
#              `wpctl` utility. It checks the current microphone status,
#              toggles it, and provides desktop notifications and sound alerts.
#              Handles default microphone naming for PipeWire ("@DEFAULT_AUDIO_SOURCE@")
#              and retrieves the ID for custom microphone descriptions.
# Parameters: None
# Returns: None
# Side Effects: Modifies PipeWire microphone state (mute/unmute), prints status
#               to stdout, sends desktop notifications, plays sound alerts.
#               Performs dependency checks for `wpctl` and `pw-play`. Calls
#               `error_handler` on `wpctl` command failure.
#------------------------------------------------------------------------------
pipewire_mic_toggle() {
    local dependencies=(
        "wpctl"
        "pw-play"
    )

    # Loop to check all dependencies
    for dep in "${dependencies[@]}"; do
        command -v "$dep" >/dev/null 2>&1
        if [[ ! "$?" = "0" ]]; then
            error_handler "1" "$MSG_MIC_ERROR_UNEXPECTED\n\n$MSG_PIPEWIRE_DEPENDENCIES"
            exit 1
        fi
    done
    
    if [[ "$MICROPHONE_NAME" = "default" ]]; then
        MICROPHONE_NAME="@DEFAULT_AUDIO_SOURCE@"
    else
        MICROPHONE_NAME=$(get_pipewire_mic_id_by_description)
    fi
    
    # Checks the current microphone status and switches
    # Forces wpctl output to English locale and converts to uppercase
    if LC_ALL=C wpctl get-volume "$MICROPHONE_NAME" | tr '[:lower:]' '[:upper:]' | grep -q 'MUTED'; then
        # Microphone is muted, so unmute it
        wpctl set-mute "$MICROPHONE_NAME" 0 >/dev/null 2>&1
        error_handler "$?" "$MSG_MIC_ERROR_UNEXPECTED\n\n$MSG_MIC_ERROR_PIPEWIRE_MIC_NAME"
        echo -e "$MSG_MIC_UNMUTED_TITLE\n$MSG_MIC_UNMUTED_CONTENT"
        send_notification "normal" "$MSG_MIC_UNMUTED_TITLE" "$MSG_MIC_UNMUTED_CONTENT" "$UNMUTED_ICON"
        pipewire_play_sound "$UNMUTED_SOUND"
    else
        # Microphone is not muted, so mute it
        wpctl set-mute "$MICROPHONE_NAME" 1 >/dev/null 2>&1
        error_handler "$?" "$MSG_MIC_ERROR_UNEXPECTED\n\n$MSG_MIC_ERROR_PIPEWIRE_MIC_NAME"
        echo -e "$MSG_MIC_MUTED_TITLE\n$MSG_MIC_MUTED_CONTENT"
        send_notification "normal" "$MSG_MIC_MUTED_TITLE" "$MSG_MIC_MUTED_CONTENT" "$MUTED_ICON"
        pipewire_play_sound "$MUTED_SOUND"
    fi
}

#------------------------------------------------------------------------------
# Function: mic_toggle
# Description: Determines which sound manager (ALSA, PulseAudio, or PipeWire)
#              is configured via the SOUND_MANAGER variable and calls the
#              appropriate microphone toggle function. Provides an error
#              message and notification if an invalid sound manager is specified.
# Parameters: None
# Returns: None
# Side Effects: Calls specific mic toggle functions; prints error to stdout
#               and sends notification if SOUND_MANAGER is invalid.
#------------------------------------------------------------------------------
mic_toggle() {
    if [[ "$SOUND_MANAGER" = "alsa" ]]; then
        alsa_mic_toggle
    elif [[  "$SOUND_MANAGER" = "pulseaudio" ]]; then
        pulseaudio_mic_toggle
    elif [[  "$SOUND_MANAGER" = "pipewire" ]]; then
        pipewire_mic_toggle
    else
        echo -e "$MSG_MIC_ERROR_TITLE\n$MSG_MIC_ERROR_SOUND_MANAGER"
        send_notification "critical" "$MSG_MIC_ERROR_TITLE" "$MSG_MIC_ERROR_SOUND_MANAGER" "$ERROR_ICON"
    fi
}

### MAIN FUNCTION
#------------------------------------------------------------------------------
# Function: main
# Description: The main entry point of the script. It orchestrates the setup
#              of language, icon theme, and sound effects theme, and then
#              calls the primary function to toggle the microphone state.
# Parameters: None
# Returns: None
# Side Effects: Initializes script configurations and executes the microphone
#               toggle logic.
#------------------------------------------------------------------------------
main() {
    set_language
    set_icons_theme
    set_sfx_theme
    mic_toggle
}

### CALL THE MAIN FUNCTION
main

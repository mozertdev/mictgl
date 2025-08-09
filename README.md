# mictgl - Microphone Toggle Script 🎙️

**Version 0.1 (beta)**

Control your microphone effortlessly on Linux! 🐧 Mute and unmute with a single command, enhanced by customizable desktop notifications and sound alerts across ALSA, PulseAudio, and PipeWire. It's a blazingly fast and lightweight solution... take a look.

`mictgl` is a minimalist Bash script designed to give you quick and intuitive control over your microphone's mute/unmute state on Linux systems. It's incredibly lightweight, uses minimal system resources, and is ideal for integration into system hotkeys, enabling instant microphone toggling with ease! ✨

---

## Key Features

- **Universal Microphone Control:** Supports the most common Linux sound systems:
  
  - **ALSA** (Advanced Linux Sound Architecture) 🔊
  
  - **PulseAudio** 🎧
  
  - **PipeWire** 🎶

- **Instant Toggling:** Mute or unmute your microphone with a single command, perfect for quick access via hotkeys. ⚡

- **Extremely Lightweight & Fast:** Built for speed, this script uses minimal resources to give you a responsive and snappy experience. 🚀

- **Visual Feedback:** Provides clear desktop notifications (via `notify-send`) indicating the microphone's current state (muted/unmuted) and any errors. 🔔

- **Customizable Alerts:**
  
  - **Themable Icons:** Choose from built-in themes (`dark-nox`, `light-lumen`) or use **custom SVG icons** for notifications. 🎨
  
  - **Themable Sound Effects:** Select from built-in sound themes (`arcade-flash`, `arcade-signal`) or define **custom WAV sound files** for alerts. 🔊

- **Internationalization (i18n):** Built-in support for multiple languages:
  
  - English 🇺🇸
  
  - Portuguese (Brazil) 🇧🇷
  
  - Español 🇪🇸

- **Automatic Localization (l10n):**
  
  - Intelligently detects the system's language settings. 🤖
  
  - Offers the flexibility to manually set the language using the `SYSTEM_LANG` variable.
  
  - Supported locales:
    
    - `en_US` (English - Default)
    
    - `pt_BR` (Portuguese - Brazil)
    
    - `es_ES` (Español)

---

## Getting Started

You'll need **Bash version 2.0 or higher** to run `mictgl.sh` correctly. This script primarily interacts with system audio backends and requires specific utilities for each (e.g., `alsa-utils`, `pulseaudio-utils`, `pipewire-utils`).

---

## Compatibility

The script has been extensively tested on the following Linux distributions and desktop environments, with the results below.

| Distribution              | Desktop Environment (DE) | Status                          | Observations                                                                                                                                                                                                                            |
|:------------------------- |:------------------------ |:------------------------------- |:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Debian 12**             | GNOME                    | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | KDE Plasma               | ⚠️ Functional, with adjustments | The notification icon appears cropped. To fix this, edit the `ICONS_THEME` variable to `"custom"`, `UNMUTED_ICON` to `"mic-on"`, `MUTED_ICON` to `"mic-off"`, and `ERROR_ICON` to `"microphone"` in the script's configuration section. |
|                           | XFCE                     | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | Cinnamon                 | ✅ Functional                    | -                                                                                                                                                                                                                                       |
| **Ubuntu 24.04 LTS**      | GNOME                    | ✅ Functional                    | -                                                                                                                                                                                                                                       |
| **Linux Mint 22.1**       | Cinnamon                 | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | XFCE                     | ✅ Functional                    | -                                                                                                                                                                                                                                       |
| **Fedora Workstation 42** | GNOME                    | ✅ Functional                    | -                                                                                                                                                                                                                                       |
| **Arch Linux**            | GNOME                    | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | KDE Plasma               | ⚠️ Functional, with adjustments | The notification icon appears cropped. To fix this, edit the `ICONS_THEME` variable to `"custom"`, `UNMUTED_ICON` to `"mic-on"`, `MUTED_ICON` to `"mic-off"`, and `ERROR_ICON` to `"microphone"` in the script's configuration section. |
|                           | XFCE                     | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | Cinnamon                 | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | i3wm                     | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | Hyprland                 | ✅ Functional                    | -                                                                                                                                                                                                                                       |
| **openSUSE Tumbleweed**   | GNOME                    | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | KDE Plasma               | ⚠️ Functional, with adjustments | The notification icon appears cropped. To fix this, edit the `ICONS_THEME` variable to `"custom"`, `UNMUTED_ICON` to `"mic-on"`, `MUTED_ICON` to `"mic-off"`, and `ERROR_ICON` to `"microphone"` in the script's configuration section. |
|                           | XFCE                     | ✅ Functional                    | -                                                                                                                                                                                                                                       |
|                           | Cinnamon                 | ✅ Functional                    | -                                                                                                                                                                                                                                       |

✅ `Functional:` Tested and works as expected.
⚠️ `Functional, with adjustments:` Requires configuration adjustments to work correctly.

---

### Dependencies

Before running `mictgl`, ensure you have the following core utilities installed:

- **Core Utilities:** `bash` (>= 2.0), `cut`, `uname`, `grep`, `cat`, `command`, `dirname`, `readlink`, `tr`, `awk`, `sed`

- **Audio Control (ALSA):** `amixer`, `aplay` (from `alsa-utils`)

- **Notifications:** `notify-send` (from `libnotify-bin` or `libnotify`)

**Optional (depending on your `SOUND_MANAGER` setting):**

- **Audio Control (PulseAudio):** `pactl`, `paplay` (from `pulseaudio-utils` / `pulseaudio pulseaudio-alsa`)

- **Audio Control (PipeWire):** `wpctl`, `pw-play` (from `pipewire`, `pipewire-audio-client-libraries`, `wireplumber` / `pipewire-utils`, `pipewire-pulseaudio` / `pipewire-pulse`)

Below are common installation commands for major Linux distributions:

<details>
<summary><b>Debian/Ubuntu-based distributions</b></summary>

**Required***

```bash
sudo apt update && sudo apt install coreutils util-linux grep diffutils alsa-utils libnotify-bin
```

**Optional**

**PulseAudio**

```bash
sudo apt install pulseaudio-utils
```

**PipeWire**

```bash
sudo apt install pipewire pipewire-audio-client-libraries wireplumber
```

</details>

---

<details>
<summary><b>Fedora/RHEL-based distributions</b></summary>

**Required***

```bash
sudo dnf install coreutils util-linux grep diffutils alsa-utils libnotify
```

**Optional**

**PulseAudio**

```bash
sudo dnf install pulseaudio-utils
```

**PipeWire**

```bash
sudo dnf install pipewire pipewire-utils pipewire-pulseaudio wireplumber
```

</details>

---

<details>
<summary><b>Arch Linux-based distributions</b></summary>

**Required***

```bash
sudo pacman -Sy coreutils util-linux grep diffutils alsa-utils libnotify
```

**Optional**

**PulseAudio**

```bash
sudo pacman -S pulseaudio pulseaudio-alsa
```

**PipeWire**

```bash
sudo pacman -S pipewire pipewire-pulse wireplumber
```

</details>

---

<details>
<summary><b>openSUSE-based distributions</b></summary>

**Required***

```bash
sudo zypper install coreutils util-linux grep diffutils alsa-utils libnotify
```

**Optional**

**PulseAudio**

```bash
sudo zypper install pulseaudio-utils
```

**PipeWire**

```bash
sudo zypper install pipewire pipewire-pulseaudio pipewire-utils wireplumber
```

</details>

---

PS: You probably already have most of the dependencies mentioned above installed on your system.

### Installation

**Download the script:** Unpack and save the `mictgl` folder to a directory of your choice. A recommended location for scripts is `~/.local/share/scripts`.

**Give execution permission:** Navigate to the directory where you saved `mictgl.sh` in your terminal and make the script executable:

```bash
chmod +x mictgl.sh
```

**Run the script:** You can now run the script directly:

```bash
./mictgl.sh
```

Each execution will toggle your microphone's mute/unmute state.

**Optional: Add an alias (Recommended for terminal use)** For easier access from any directory, you can add an alias to your shell's configuration file (e.g., `~/.bashrc`, `~/.zshrc`).

**Bash**

```bash
echo 'alias mtgl="/path/to/your/mictgl.sh"' >> ~/.bashrc
```

**Zsh**

```bash
echo 'alias mtgl="/path/to/your/mictgl.sh"' >> ~/.zshrc
```

Replace `/path/to/your/mictgl.sh` with the actual path to your script. After adding the alias, restart your terminal or source your configuration file:

**Bash**

```bash
source ~/.bashrc
```

**Zsh**

```bash
source ~/.zshrc
```

Now you can simply type `mtgl` to toggle your microphone.

### Integrate with Desktop Environment Hotkeys (Highly Recommended!)

For the quickest and most seamless experience, integrate `mictgl.sh` into your desktop environment's custom hotkey or shortcut system. This allows you to toggle your microphone instantly with a single key combination (e.g., `Ctrl + Alt + M`). Refer to your desktop environment's documentation for instructions on setting custom shortcuts.

<details>
<summary><b>GNOME</b></summary>

1. Open **Settings**.

2. Navigate to the **Keyboard** section.

3. Go to **Custom Shortcuts**.

4. Click the **+** button to add a new shortcut.

5. Fill in the fields as follows:
   
   - **Name:** mictgl or Mic Toggler
   
   - **Command:** `/home/your_username/.local/share/scripts/mictgl/mictgl.sh` (replace `your_username` with your actual username).
   
   - **Shortcut:** Click on the field and press your desired key combination (e.g., `Ctrl + Alt + M`).

6. Click **Add**.

</details>

---

<details>
<summary><b>KDE Plasma</b></summary>

1. Open **System Settings**.

2. Go to the **Shortcuts** section.

3. Click on **Custom Shortcuts**.

4. Click **Edit** > **New** > **Global Shortcut** > **Command/URL**.

5. Give the shortcut a name, for example, "mictgl" or "Mic Toggler".

6. In the **Trigger** tab, click the button to set your shortcut. Press the desired key combination (e.g., `Ctrl + Alt + M`).

7. In the **Action** tab, in the command field, enter: `/home/your_username/.local/share/scripts/mictgl/mictgl.sh` (replace `your_username` with your actual username).

8. Click **Apply**.

</details>

---

<details>
<summary><b>XFCE</b></summary>

1. Open **Settings** and go to **Keyboard**.

2. Select the **Application Shortcuts** tab.

3. Click **Add**.

4. In the **Command** field, enter: `/home/your_username/.local/share/scripts/mictgl/mictgl.sh` (replace `your_username` with your actual username).

5. Click **OK**.

6. Press the desired key combination when prompted (e.g., `Ctrl + Alt + M`).

7. The shortcut will now appear in the list.

</details>

---

<details>
<summary><b>Cinnamon</b></summary>

1. Open **System Settings**.

2. Go to the **Hardware** section and click on **Keyboard**.

3. Select the **Shortcuts** tab.

4. In the left panel, choose **Custom Shortcuts**.

5. Click **Add Custom Shortcut**.

6. Fill in the fields:
   
   - **Name:** mictgl or Mic Toggler
   
   - **Command:** `/home/your_username/.local/share/scripts/mictgl/mictgl.sh` (replace `your_username` with your actual username).

7. Click **Add**.

8. Now, in the list of shortcuts, click on where it says "Unassigned" next to your new shortcut and press the desired key combination (e.g., `Ctrl + Alt + M`).

</details>

---

<details>
<summary><b>i3wm</b></summary>

1. Open your i3 configuration file. It's usually located at `~/.config/i3/config` or `~/.i3/config`.

2. Add the following line anywhere in the file (it's a good practice to add it with other program shortcuts): `bindsym $mod+m exec /home/your_username/.local/share/scripts/mictgl/mictgl.sh`
   
   - `$mod` refers to your modifier key (usually `Alt` or the `Super/Windows` key).
   
   - Replace `m` with the key you want to use.
   
   - Replace `your_username` with your actual username.

3. Save the file.

4. Reload i3. You can usually do this by pressing `$mod+Shift+r` or `$mod+r`, depending on your configuration.

</details>

---

<details>
<summary><b>Hyprland</b></summary>

1. Open your Hyprland configuration file, usually at `~/.config/hypr/hyprland.conf`.

2. Add the following line to the `binds` section: `bind = $mainMod, M, exec, /home/your_username/.local/share/scripts/mictgl/mictgl.sh`
   
   - `$mainMod` refers to your main modifier key (usually `Super/Windows`).
   
   - Replace `M` with the key you want to use.
   
   - Replace `your_username` with your actual username.

3. Save the file.

4. Reload Hyprland. You can do this with a `hyprctl reload` command in the terminal or by restarting the compositor.

</details>

---

## Configuration

The behavior of `mictgl` can be extensively customized by modifying variables directly within the `mictgl.sh` script, specifically in the section marked "OPTIONS TO BE MODIFIED IF YOU'D LIKE".

Here's a breakdown of the key variables:

- **`SYSTEM_LANG`**:
  
  - **Description**: Defines the script's language for notifications and messages.
  
  - **Default Value**: `"automatic"` (Dynamically determined based on system locale).
  
  - **Example Values**: `"en_US"`, `"pt_BR"`, `"es_ES"`.

- **`SOUND_MANAGER`**:
  
  - **Description**: Specifies the sound server to interact with (ALSA, PulseAudio, or PipeWire).
  
  - **Default Value**: `"alsa"`.
  
  - **Example Values**: `"alsa"`, `"pulseaudio"`, `"pipewire"`.
  
  - **Important**: Ensure the necessary utilities for the selected sound manager are installed (see Dependencies).

- **`MICROPHONE_NAME`**:
  
  - **Description**: The specific name or ID of the microphone control to toggle.
  
  - **Default Value**: `"default"` (Attempts to use the system's default microphone).
  
  - **How to find your microphone name**:
    
    - **ALSA**: Run `amixer scontrols`
    
    - **PulseAudio**: Run `pactl list sources short`
    
    - **PipeWire**: Run `wpctl status` (look under "Sources:")
  
  - **Example Values**: `"Capture"`, `"alsa_input.usb-Mic_Name_999999999999-00.mono-fallback"`, `"Headset Microphone Name"`.

- **`ENABLE_DESKTOP_NOTIFICATIONS`**:
  
  - **Description**: Toggles graphical notifications for microphone state changes and errors.
  
  - **Default Value**: `"true"`.
  
  - **Example Values**: `"true"`, `"false"`, `"yes"`, `"no"`, `"1"`, `"0"`.

- **`ENABLE_SOUND_ALERTS`**:
  
  - **Description**: Toggles sound effects for microphone state changes and errors.
  
  - **Default Value**: `"false"`.
  
  - **Example Values**: `"true"`, `"false"`, `"yes"`, `"no"`, `"1"`, `"0"`.

- **`ICONS_THEME`**:
  
  - **Description**: Sets the visual theme for notification icons. Choosing `"custom"` allows you to specify individual icon paths.
  
  - **Default Value**: `"dark-nox"`.
  
  - **Example Values**: `"dark-nox"`, `"light-lumen"`, `"custom"`.

- **`ICONS_SIZE`**:
  
  - **Description**: Defines the size of built-in icons. Applies to custom icons if you design them accordingly.
  
  - **Default Value**: `"standard"`.
  
  - **Example Values**: `"small"` (32x32px), `"standard"` (48x48px), `"large"` (64x64px).

- **`UNMUTED_ICON`**, **`MUTED_ICON`**, **`ERROR_ICON`**:
  
  - **Description**: Paths to custom SVG icons. Only active if `ICONS_THEME` is `"custom"`. Can be a system icon name or a full path to an SVG file.
  
  - **Default Value**: `""` (Uses system default or theme-specific icons).
  
  - **Example Values**: `"audio-input-microphone"`, `"/home/user/icons/48x48/mic-on.svg"`.

- **`SOUND_EFFECTS_THEME`**:
  
  - **Description**: Sets the sound theme for alerts. Choosing `"custom"` allows you to specify individual WAV sound file paths.
  
  - **Default Value**: `"arcade-flash"`.
  
  - **Example Values**: `"arcade-flash"`, `"arcade-signal"`, `"custom"`.

- **`UNMUTED_SOUND`**, **`MUTED_SOUND`**, **`ERROR_SOUND`**:
  
  - **Description**: Paths to custom WAV sound files. Only active if `SOUND_EFFECTS_THEME` is `"custom"`. Must be full paths to WAV files.
  
  - **Default Value**: `""` (No custom sound).
  
  - **Example Values**: `"/home/user/sounds/mic-on.wav"`.

**Example Configuration Section in `mictgl.sh`:**

```bash
# ==================== OPTIONS TO BE MODIFIED IF YOU'D LIKE ====================

### GENERAL OPTIONS
#------------------------------------------------------------------------------
# Script Language
#------------------------------------------------------------------------------
SYSTEM_LANG="pt_BR" # Force Portuguese (Brazil)

#------------------------------------------------------------------------------
# Sound Manager
#------------------------------------------------------------------------------
SOUND_MANAGER="pipewire" # Use PipeWire for microphone control

#------------------------------------------------------------------------------
# Microphone Name
#------------------------------------------------------------------------------
MICROPHONE_NAME="Headset Microphone Name" # Replace with your specific mic name

#------------------------------------------------------------------------------
# Enable Desktop Notifications
#------------------------------------------------------------------------------
ENABLE_DESKTOP_NOTIFICATIONS="true"

#------------------------------------------------------------------------------
# Enable Sound Alerts
#------------------------------------------------------------------------------
ENABLE_SOUND_ALERTS="true"

#------------------------------------------------------------------------------
# Theme
#------------------------------------------------------------------------------
ICONS_THEME="custom" # Use custom icons

#------------------------------------------------------------------------------
# Icons Size
#------------------------------------------------------------------------------
ICONS_SIZE="standard"

#------------------------------------------------------------------------------
# Unmuted Icon
#------------------------------------------------------------------------------
UNMUTED_ICON="/home/youruser/my-custom-icons/mic-on-48.svg"

#------------------------------------------------------------------------------
# Muted Icon
#------------------------------------------------------------------------------
MUTED_ICON="/home/youruser/my-custom-icons/mic-off-48.svg"

#------------------------------------------------------------------------------
# Error Icon
#------------------------------------------------------------------------------
ERROR_ICON="/home/youruser/my-custom-icons/alert-error-48.svg"

#------------------------------------------------------------------------------
# Sound Effects Theme
#------------------------------------------------------------------------------
SOUND_EFFECTS_THEME="custom" # Use custom sound effects

#------------------------------------------------------------------------------
# Unmuted Sound
#------------------------------------------------------------------------------
UNMUTED_SOUND="/home/youruser/my-custom-sounds/mic-unmute.wav"

#------------------------------------------------------------------------------
# Muted Sound
#------------------------------------------------------------------------------
MUTED_SOUND="/home/youruser/my-custom-sounds/mic-mute.wav"

#------------------------------------------------------------------------------
# Error Sound
#------------------------------------------------------------------------------
ERROR_SOUND="/home/youruser/my-custom-sounds/error-alert.wav"

# ======================= END OF OPTIONS TO BE MODIFIED ========================
```

## Version Information

This is version **0.1 (beta)**.

As a beta release, it may contain errors or bugs. Your feedback is highly appreciated. Please report any issues or suggestions through the project's issue tracker.

---

## Contributing

We welcome contributions! If you encounter any issues or have suggestions for improvements, please feel free to:

- Report bugs through the issue tracker.

- Suggest new features or enhancements.

- Create new icons themes and sound effects themes.

---

## License

`mictgl` is licensed under the **GPL-3.0+ License**. You can find the full license text [here](https://www.gnu.org/licenses/gpl-3.0.html).

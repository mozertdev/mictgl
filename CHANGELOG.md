# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1 (beta)] - 2025-08-01

### Added

- **Initial Release**: The first (beta) version of the `mictgl` script has been released.

- **Support for Multiple Sound Managers**: The ability to toggle microphone status using **ALSA**, **PulseAudio**, and **PipeWire**.

- **Desktop Notifications**: Integration with `notify-send` to display visual alerts when the microphone is muted or unmuted.

- **Sound Alerts**: Support for customizable alert sounds (using `.wav` files) for auditory feedback when the microphone state changes.

- **Customization Options**: Added configuration variables to allow users to customize the sound manager, microphone name, icon themes, and sound effects.

- **Localization (i18n)**: Support for notification messages in multiple languages, including **English**, **Brazilian Portuguese**, and **Spanish**.

- **Dependency Checks**: A robust check at the beginning of the script ensures all necessary tools (`amixer`, `notify-send`, `pactl`, `wpctl`, etc.) are installed.

- **Error Handling**: A centralized mechanism to catch and report errors, providing descriptive messages to help users troubleshoot configuration issues.

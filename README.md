# Service Health Checks

**Service Health Checks** is a collection of scripts and utilities designed to provide insight into the operational state of services running across different platforms—Linux, macOS, and Windows. This repository aims to simplify the process of determining if services are running, enabled, accessible, and performing correctly, regardless of your chosen operating system.

## Overview

Many organizations run services on multiple platforms, making it challenging to maintain a standardized approach to health and status checks. **Service Health Checks** seeks to bridge that gap by offering a unified set of tools or guidelines to:

- Check if a service is running and responding properly.
- Determine the service’s startup behavior (enabled or disabled at boot).
- Inspect recent logs or events related to the service.
- Identify dependencies and upstream/downstream relationships.
- Provide a consistent user experience across different operating systems.

## Features

- **Cross-Platform Focus:** Provides scripts and instructions for Linux, macOS, and Windows.
- **Comprehensive Status Checks:** Quickly see if a service is running, disabled, or experiencing errors.
- **Enablement and Startup Behavior:** Determine if a service starts automatically, or if it must be manually launched.
- **Dependency Insight:** Understand which other services or units a given service relies upon.
- **Log and Event Review:** Access recent logs, events, or error messages in a single step.
- **Extendable and Modular:** Add or modify scripts for new services or platforms easily.

## Usage and Structure

As this repository grows, you’ll find subdirectories organized by operating system:
- `linux/` for scripts and tools specific to Linux (systemd, SysVinit, etc.).
- `macos/` for scripts compatible with macOS (launchd).
- `windows/` for batch or PowerShell scripts targeting Windows services.

---

## Current Tools

### Linux (systemd-based)

#### Requirements

- A Linux distribution using `systemd`
- `bash` shell (usually installed by default on most Linux systems)
- `systemctl` and `journalctl` utilities (provided by `systemd`)
- Appropriate permissions to run system commands. For some checks, you may need `sudo` privileges.

#### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/<your-username>/service-checker.git
   ```
   
2. **Navigate into the Project Directory:**
   ```bash
   cd service-checker/linux
   ```
   
3. **Make the Script Executable:**
   ```bash
   chmod +x check_service.sh
   ```

#### Usage

Run the script with the name of the service you want to check:

```bash
./check_service.sh <service-name>
```

For example, to check the status of `sshd.service`:

```bash
./check_service.sh sshd.service
```

**Note:** Most systemd services end with `.service` but you can omit the suffix if you prefer.
For example, `./check_service.sh sshd` works the same as `./check_service.sh sshd.service` on many systems.

---

### macOS (launchd-based)

#### Requirements

- macOS with `launchctl` available (default on macOS).
- `bash` shell.
- Access to system logs using `log show`.

#### Installation

1. **Navigate to the macOS directory:**
   ```bash
   cd service-checker/macos
   ```

2. **Make the Script Executable:**
   ```bash
   chmod +x check_service.sh
   ```

#### Usage

Run the script with the service label you want to check:

```bash
./check_service.sh <service-label>
```

For example, to check the status of the `com.apple.screensharing` service:

```bash
./check_service.sh com.apple.screensharing
```

#### Features

- Checks if the service is running.
- Identifies if the service is enabled at startup.
- Displays service dependencies (if applicable).
- Fetches recent logs related to the service.

---

### Windows (PowerShell-based)

#### Requirements

- PowerShell environment (available by default on Windows).
- Permissions to query service states and read logs.

#### Installation

1. **Navigate to the Windows directory:**
   ```powershell
   cd service-checker\windows
   ```

2. **Ensure the script is accessible:**
   Confirm you can execute scripts in your PowerShell environment. If not, set the execution policy:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

#### Usage

Run the script with the service name you want to check:

```powershell
.\check_service.ps1 <ServiceName>
```

For example, to check the status of the `Spooler` service:

```powershell
.\check_service.ps1 Spooler
```

#### Features

- Checks if the service is running.
- Identifies the startup type (Automatic, Manual, or Disabled).
- Lists service dependencies.
- Fetches recent logs or events associated with the service.

---

## Contributing

Contributions are welcome! If you have a script or idea for improving cross-platform service checks:

1. Fork the repository.
2. Add your scripts or improvements in the appropriate directory.
3. Submit a pull request with a clear description of your changes.

---

## License

All scripts and code in this repository are released under the [MIT License](LICENSE), allowing you to freely use, modify, and distribute the tools as you see fit.
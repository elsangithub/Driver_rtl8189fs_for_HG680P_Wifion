<p align="right">
  <b>English</b> | <a href="README.id.md">Bahasa Indonesia</a>
</p>

# Realtek RTL8189FS SDIO Wi-Fi Driver for FiberHome HG680-P (Armbian)

[![Release](https://img.shields.io/badge/release-v1.0.3-blue.svg)](https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/releases)
[![Build & Release](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/actions)
[![DKMS Ready](https://img.shields.io/badge/DKMS-Automated_Build-brightgreen.svg)](https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)

A production-grade, out-of-tree Linux DKMS driver for the **Realtek RTL8189FS** (SDIO 802.11b/g/n) Wi-Fi chipset, specifically engineered and tuned for the **FiberHome HG680-P** (Amlogic S905X / Meson-GXL) TV box running Linux/Armbian.

---

## 🔍 Overview & Hardware Target

- **Target Device**: FiberHome HG680-P (Amlogic S905X / ARM64)
- **Wi-Fi Chipset**: Realtek RTL8189FS (SDIO)
- **Kernel Module**: `8189fs.ko`
- **Supported Architectures**: ARM64 / aarch64 (Armbian, Debian, Ubuntu)

### ⚠️ Device Tree (DTB) Prerequisite

Unlike standard USB Wi-Fi adapters, the onboard RTL8189FS chipset is connected via the internal **SDIO bus** (`mmc@70000`). It requires the Linux kernel to properly control the hardware reset GPIO pin (`sdio-pwrseq`) and supply the 32.768 kHz reference sleep clock (`wifi32k`) during boot.

To ensure the Wi-Fi hardware is powered on and recognized by the kernel, you **must use the HG680-P dedicated DTB**:
- **Target DTB**: `meson-gxl-s905x-hg680p.dtb`
- **Download DTB from Release**:
  ```bash
  sudo wget -O /boot/dtb/amlogic/meson-gxl-s905x-hg680p.dtb https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/releases/download/v1.0.3/meson-gxl-s905x-hg680p.dtb
  ```
- **Boot Configuration** (in `/boot/uEnv.txt`):
  ```text
  FDT=/dtb/amlogic/meson-gxl-s905x-hg680p.dtb
  ```
  *(or in `/boot/armbianEnv.txt`: `fdtfile=amlogic/meson-gxl-s905x-hg680p.dtb`)*

> [!WARNING]
> If you use a generic TV Box DTB (such as `meson-gxl-s905x-p212.dtb`), the Wi-Fi power sequence GPIOs will not be triggered. The chip will remain unpowered, `cat /sys/bus/sdio/devices/*/device` will return empty, and `wlan0` will never be initialized regardless of driver installation.

### How to Verify DTB & Wi-Fi Chipset Detection:
Run the following commands in your STB terminal before installing:
```bash
# 1. Verify that the HG680-P DTB model is active
cat /proc/device-tree/model
# Expected output: FiberHome HG680-P

# 2. Verify that the RTL8189FS SDIO hardware is powered on and detected
cat /sys/bus/sdio/devices/*/device 2>/dev/null
# Expected output: 0xf179 (Hardware ID for Realtek RTL8189FS)
```
If `0xf179` is returned, your hardware and DTB are properly configured, and this DKMS package (`rtl8189fs-dkms`) provides full driver automation and network stability.

---

## 🚀 Key Features

- **Automated DKMS Lifecycle**: Automatically compiles and links against installed Linux kernel headers on your system.
- **Power Save Tuning**: Disables aggressive sleep modes (`rtw_power_mgnt=0`, `rtw_ips_mode=0`) via modprobe to eliminate packet loss and random Wi-Fi drops.
- **Strict System Namespacing**: Completely avoids package ownership conflicts by utilizing `rtl8189fs-*` and `99-rtl8189fs-*` identifiers.
- **IRQ & RPS Optimization**: Dedicated script (`rtl8189fs-irq-tune.sh`) balances network packet steering across CPU cores for maximum throughput and low latency.
- **Turnkey Debian Packaging**: Single `.deb` package installs everything needed without manual driver compiling.

---

## 📦 Installation Guide

### Option 1: Quick Install via Pre-built `.deb` Package (Recommended)

Download and install the latest pre-built Debian package from GitHub Releases:

```bash
# 1. Ensure kernel headers and dkms are installed
sudo apt update
sudo apt install -y dkms build-essential linux-headers-$(uname -r)

# 2. Download the package
wget https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/releases/download/v1.0.3/rtl8189fs-dkms_1.0.3_all.deb

# 3. Install the package
sudo dpkg -i rtl8189fs-dkms_1.0.3_all.deb
```

### Option 2: Build Debian Package Locally

To build the package directly from source:

```bash
# Clone the repository
git clone https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion.git
cd Driver_rtl8189fs_for_HG680P_Wifion

# Build the .deb package
chmod +x build-deb.sh
./build-deb.sh

# Install the generated .deb package
sudo dpkg -i rtl8189fs-dkms_1.0.3_all.deb
```

---

## 🛠️ Verification & Troubleshooting

Check the driver registration status with DKMS:
```bash
dkms status -m rtl8189fs
```

Verify that the module is loaded:
```bash
lsmod | grep 8189fs
```

Inspect kernel log messages:
```bash
sudo dmesg | grep -i 8189fs
```

---

## 📄 License
This project is licensed under the GNU General Public License v2.0 (GPL-2.0).

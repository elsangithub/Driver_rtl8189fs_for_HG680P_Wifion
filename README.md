<p align="right">
  <b>English</b> | <a href="README.id.md">Bahasa Indonesia</a>
</p>

# Realtek RTL8189FS SDIO Wi-Fi Driver for FiberHome HG680-P (Armbian)

[![Release](https://img.shields.io/badge/release-v1.0.0-blue.svg)](https://github.com/elsangithub/hg680p-wifi-rtl8189fs/releases)
[![Build & Release](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/elsangithub/hg680p-wifi-rtl8189fs/actions)
[![DKMS Ready](https://img.shields.io/badge/DKMS-Automated_Build-brightgreen.svg)](https://github.com/elsangithub/hg680p-wifi-rtl8189fs)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)

A production-grade, out-of-tree Linux DKMS driver for the **Realtek RTL8189FS** (SDIO 802.11b/g/n) Wi-Fi chipset, specifically engineered and tuned for the **FiberHome HG680-P** (Amlogic S905X / Meson-GXL) TV box running Linux/Armbian.

---

## 🔍 Overview & Hardware Target

- **Target Device**: FiberHome HG680-P (Amlogic S905X / ARM64)
- **Wi-Fi Chipset**: Realtek RTL8189FS (SDIO)
- **Kernel Module**: `8189fs.ko`
- **Supported Architectures**: ARM64 / aarch64 (Armbian, Debian, Ubuntu)

### How to Check the Wi-Fi Chipset:
Execute the following in your terminal:
```bash
cat /sys/bus/sdio/devices/*/device 2>/dev/null || cat /sys/bus/sdio/devices/*/vendor 2>/dev/null
```
If your HG680-P contains the RTL8189FS SDIO Wi-Fi module, this DKMS package (`rtl8189fs-dkms`) provides full driver automation and network stability.

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
wget https://github.com/elsangithub/hg680p-wifi-rtl8189fs/releases/download/v1.0.0/rtl8189fs-dkms_1.0.0_all.deb

# 3. Install the package
sudo dpkg -i rtl8189fs-dkms_1.0.0_all.deb
```

### Option 2: Build Debian Package Locally

To build the package directly from source:

```bash
# Clone the repository
git clone https://github.com/elsangithub/hg680p-wifi-rtl8189fs.git
cd hg680p-wifi-rtl8189fs

# Build the .deb package
chmod +x build-deb.sh
./build-deb.sh

# Install the generated .deb package
sudo dpkg -i rtl8189fs-dkms_1.0.0_all.deb
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

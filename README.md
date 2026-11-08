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

- **Fully Supported & Tested Devices**:
  - **FiberHome HG680-P** (Amlogic S905X / ARM64)
  - **ZTE ZXV10 B860H V2** (Amlogic S905X / ARM64)
- **Wi-Fi Chipset**: Realtek RTL8189FS / RTL8189FTV (SDIO `0x024c:0xf179`)
  - *Note*: `RTL8189FS` is the official Realtek SDIO product family name, while `RTL8189FTV` is the physical IC part number package soldered on the ZTE B860H V2 board. Both share identical silicon architecture and bind to the same driver.
- **Kernel Module**: `8189fs.ko`
- **Supported Architectures**: ARM64 / aarch64 (Armbian, Debian, Ubuntu)

### ⚠️ Device Tree (DTB) Prerequisite

Unlike standard USB Wi-Fi adapters, the onboard Realtek RTL8189 series chipset is connected via the internal **SDIO bus** (`mmc@70000`). It requires the Linux kernel to properly control the hardware reset GPIO line (`sdio-pwrseq`) and supply the 32.768 kHz reference sleep clock (`wifi32k`) during boot.

> [!IMPORTANT]
> **DO NOT SWAP DTB FILES BETWEEN HG680-P AND B860H!**
> Although both TV boxes are powered by the Amlogic S905X SoC, the physical hardware reset GPIO lines on their motherboards are **routed to different pins**:
> - **FiberHome HG680-P**: Uses reset pin **offset `0x55`** $\rightarrow$ requires `meson-gxl-s905x-hg680p.dtb`.
> - **ZTE B860H V2**: Uses reset pin **offset `0x4c`** $\rightarrow$ requires `meson-gxl-s905x-b860h.dtb`.
>
> If you use the wrong DTB (e.g. using the HG680-P DTB on a B860H, or using a generic `meson-gxl-s905x-p212.dtb`), the Wi-Fi power sequence GPIOs will not trigger. The chipset will remain unpowered, `cat /sys/bus/sdio/devices/*/device` will return empty, and `wlan0` will never show up regardless of driver installation.

#### DTB Configuration by Device:

1. **For FiberHome HG680-P**:
   * **Target DTB**: `meson-gxl-s905x-hg680p.dtb`
   * **Download from Release**:
     ```bash
     sudo wget -O /boot/dtb/amlogic/meson-gxl-s905x-hg680p.dtb https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/releases/download/v1.0.3/meson-gxl-s905x-hg680p.dtb
     ```
   * **Boot Configuration** (in `/boot/uEnv.txt`):
     ```text
     FDT=/dtb/amlogic/meson-gxl-s905x-hg680p.dtb
     ```

2. **For ZTE ZXV10 B860H V2**:
   * **Target DTB**: `meson-gxl-s905x-b860h.dtb` *(standard in Armbian / available in `dtb/` folder)*
   * **Boot Configuration** (in `/boot/uEnv.txt`):
     ```text
     FDT=/dtb/amlogic/meson-gxl-s905x-b860h.dtb
     ```

### How to Verify DTB & Wi-Fi Chipset Detection:
Run the following commands in your STB terminal before installing:
```bash
# 1. Verify that the correct model is active
cat /proc/device-tree/model
# Output on HG680-P : FiberHome HG680-P
# Output on B860H   : ZTE B860H

# 2. Verify that the RTL8189 SDIO hardware is powered on and detected
cat /sys/bus/sdio/devices/*/device 2>/dev/null
# Expected output: 0xf179 (Official Device ID for Realtek RTL8189FS / RTL8189FTV)
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
# 1. Install prerequisites (DKMS, build tools & wget)
sudo apt update
sudo apt install -y dkms build-essential wget

# 2. Verify kernel headers are present
ls -d /usr/src/linux-headers-$(uname -r)

# 3. Download the package
wget https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/releases/download/v1.0.3/rtl8189fs-dkms_1.0.3_all.deb

# 4. Install the package
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

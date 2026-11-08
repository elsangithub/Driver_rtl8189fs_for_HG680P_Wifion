<p align="right">
  <a href="README.md">English</a> | <b>Bahasa Indonesia</b>
</p>

# Driver Wi-Fi Realtek RTL8189FS SDIO untuk FiberHome HG680-P (Armbian)

[![Release](https://img.shields.io/badge/release-v1.0.3-blue.svg)](https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/releases)
[![Build & Release](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/actions)
[![DKMS Ready](https://img.shields.io/badge/DKMS-Automated_Build-brightgreen.svg)](https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)

Driver out-of-tree Linux dengan integrasi DKMS untuk chipset Wi-Fi **Realtek RTL8189FS** (SDIO 802.11b/g/n), dirancang dan dioptimalkan secara khusus untuk STB **FiberHome HG680-P** (Amlogic S905X / Meson-GXL) yang menjalankan Linux/Armbian.

---

## 🔍 Ringkasan & Target Perangkat

- **Perangkat Target**: FiberHome HG680-P (Amlogic S905X / ARM64)
- **Chipset Wi-Fi**: Realtek RTL8189FS (SDIO)
- **Modul Kernel**: `8189fs.ko`
- **Arsitektur Didukung**: ARM64 / aarch64 (Armbian, Debian, Ubuntu)

### ⚠️ Prasyarat DTB (Device Tree Blob)

Berbeda dengan dongle USB Wi-Fi, chipset RTL8189FS pada HG680-P tersolder langsung pada motherboard dan terhubung melalui jalur **SDIO internal** (`mmc@70000`). Modul ini mewajibkan kernel Linux untuk mengontrol urutan kelistrikan GPIO reset/daya (`sdio-pwrseq`) dan sinyal clock referensi 32.768 kHz (`wifi32k`) saat proses *booting*.

Agar perangkat keras Wi-Fi diberi daya dan terdeteksi oleh kernel, Anda **wajib menggunakan berkas DTB khusus HG680-P**:
- **Berkas DTB Target**: `meson-gxl-s905x-hg680p.dtb`
- **Konfigurasi Boot** (pada berkas `/boot/uEnv.txt`):
  ```text
  FDT=/dtb/amlogic/meson-gxl-s905x-hg680p.dtb
  ```
  *(atau pada `/boot/armbianEnv.txt`: `fdtfile=amlogic/meson-gxl-s905x-hg680p.dtb`)*

> [!WARNING]
> Jika Anda menggunakan DTB generik S905X (seperti `meson-gxl-s905x-p212.dtb`), pin GPIO power/reset Wi-Fi tidak akan dipicu saat boot. Chipset akan tetap mati tanpa daya, `cat /sys/bus/sdio/devices/*/device` akan bernilai kosong, dan interface `wlan0` tidak akan pernah muncul meskipun driver terpasang.

### Cara Memeriksa DTB & Deteksi Chipset Wi-Fi di STB:
Jalankan perintah berikut di terminal STB Anda sebelum melakukan instalasi:
```bash
# 1. Pastikan model DTB HG680-P aktif
cat /proc/device-tree/model
# Output wajib: FiberHome HG680-P

# 2. Pastikan chipset RTL8189FS menerima daya dan terdeteksi di bus SDIO
cat /sys/bus/sdio/devices/*/device 2>/dev/null
# Output wajib: 0xf179 (Device ID resmi Realtek RTL8189FS)
```
Jika `0xf179` terdeteksi, konfigurasi hardware dan DTB Anda sudah benar, dan paket DKMS ini (`rtl8189fs-dkms`) akan langsung mengaktifkan antarmuka Wi-Fi secara optimal.

---

## 🚀 Fitur Utama

- **Siklus Hidup DKMS Otomatis**: Otomatis mengompilasi dan mengaitkan modul driver dengan header kernel Linux yang terpasang di sistem.
- **Tuning Manajemen Daya (Power Save)**: Menonaktifkan mode hemat daya agresif (`rtw_power_mgnt=0`, `rtw_ips_mode=0`) via modprobe untuk mencegah drop paket dan putus koneksi secara tiba-tiba.
- **Strict Namespacing**: Menghindari konflik kepemilikan paket di sistem global menggunakan identitas unik `rtl8189fs-*` dan `99-rtl8189fs-*`.
- **Optimasi IRQ & RPS**: Skrip udev khusus (`rtl8189fs-irq-tune.sh`) mendistribusikan beban paket jaringan antar core CPU untuk throughput maksimal dan latensi rendah.
- **Packaging Debian Turnkey**: Berkas tunggal `.deb` memasang seluruh kebutuhan tanpa kompilasi manual.

---

## 📦 Panduan Instalasi

### Opsi 1: Instalasi Cepat via Paket Biner `.deb` (Direkomendasikan)

Unduh dan pasang paket rilis terbaru dari GitHub Releases:

```bash
# 1. Pastikan kernel headers dan dkms terpasang
sudo apt update
sudo apt install -y dkms build-essential linux-headers-$(uname -r)

# 2. Unduh paket rilis
wget https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion/releases/download/v1.0.3/rtl8189fs-dkms_1.0.3_all.deb

# 3. Pasang paket ke sistem
sudo dpkg -i rtl8189fs-dkms_1.0.3_all.deb
```

### Opsi 2: Kompilasi dan Buat Paket Debian Lokal

Untuk membangun paket biner `.deb` langsung dari kode sumber:

```bash
# Clone repositori
git clone https://github.com/elsangithub/Driver_rtl8189fs_for_HG680P_Wifion.git
cd Driver_rtl8189fs_for_HG680P_Wifion

# Buat paket .deb
chmod +x build-deb.sh
./build-deb.sh

# Pasang paket hasil kompilasi
sudo dpkg -i rtl8189fs-dkms_1.0.3_all.deb
```

---

## 🛠️ Verifikasi & Diagnostik

Periksa status registrasi modul di DKMS:
```bash
dkms status -m rtl8189fs
```

Pastikan modul driver telah dimuat oleh kernel:
```bash
lsmod | grep 8189fs
```

Periksa log kernel terkait driver:
```bash
sudo dmesg | grep -i 8189fs
```

---

## 📄 Lisensi
Proyek ini dilisensikan di bawah GNU General Public License v2.0 (GPL-2.0).

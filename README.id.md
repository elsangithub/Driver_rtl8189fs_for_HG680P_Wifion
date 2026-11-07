<p align="right">
  <a href="README.md">English</a> | <b>Bahasa Indonesia</b>
</p>

# Driver Wi-Fi Realtek RTL8189FS SDIO untuk FiberHome HG680-P (Armbian)

[![Release](https://img.shields.io/badge/release-v1.0.0-blue.svg)](https://github.com/elsangithub/hg680p-wifi-rtl8189fs/releases)
[![Build & Release](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/elsangithub/hg680p-wifi-rtl8189fs/actions)
[![DKMS Ready](https://img.shields.io/badge/DKMS-Automated_Build-brightgreen.svg)](https://github.com/elsangithub/hg680p-wifi-rtl8189fs)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)

Driver out-of-tree Linux dengan integrasi DKMS untuk chipset Wi-Fi **Realtek RTL8189FS** (SDIO 802.11b/g/n), dirancang dan dioptimalkan secara khusus untuk STB **FiberHome HG680-P** (Amlogic S905X / Meson-GXL) yang menjalankan Linux/Armbian.

---

## 🔍 Ringkasan & Target Perangkat

- **Perangkat Target**: FiberHome HG680-P (Amlogic S905X / ARM64)
- **Chipset Wi-Fi**: Realtek RTL8189FS (SDIO)
- **Modul Kernel**: `8189fs.ko`
- **Arsitektur Didukung**: ARM64 / aarch64 (Armbian, Debian, Ubuntu)

### Cara Memeriksa Chipset Wi-Fi di STB:
Jalankan perintah berikut di terminal STB Anda:
```bash
cat /sys/bus/sdio/devices/*/device 2>/dev/null || cat /sys/bus/sdio/devices/*/vendor 2>/dev/null
```
Jika HG680-P Anda menggunakan modul Wi-Fi SDIO RTL8189FS, paket DKMS ini (`rtl8189fs-dkms`) menyediakan otomatisasi instalasi driver dan kestabilan jaringan.

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
wget https://github.com/elsangithub/hg680p-wifi-rtl8189fs/releases/download/v1.0.0/rtl8189fs-dkms_1.0.0_all.deb

# 3. Pasang paket ke sistem
sudo dpkg -i rtl8189fs-dkms_1.0.0_all.deb
```

### Opsi 2: Kompilasi dan Buat Paket Debian Lokal

Untuk membangun paket biner `.deb` langsung dari kode sumber:

```bash
# Clone repositori
git clone https://github.com/elsangithub/hg680p-wifi-rtl8189fs.git
cd hg680p-wifi-rtl8189fs

# Buat paket .deb
chmod +x build-deb.sh
./build-deb.sh

# Pasang paket hasil kompilasi
sudo dpkg -i rtl8189fs-dkms_1.0.0_all.deb
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

# Changelog

All notable changes to the **Realtek RTL8189FS Linux DKMS Driver** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-11-08

### 🚀 Initial Production DKMS Release
Initial modular DKMS and Debian packaging framework for Realtek RTL8189FS (SDIO) Wi-Fi driver, tailored for FiberHome HG680-P (Amlogic S905X) and general ARM64 Linux platforms.

### Added
- **DKMS Architecture & Build Automation**:
  - `dkms.conf` with dynamic kernel build support (`8189fs.ko`).
  - Automated Debian package builder `build-deb.sh` producing turnkey `rtl8189fs-dkms_1.0.0_all.deb`.
  - Single Source of Truth (SSOT) `sync-version.sh` for atomic version synchronization across metadata and documentation.
- **Strict System Namespacing & Performance Tuning**:
  - `99-rtl8189fs-throughput.conf`: Network socket buffer and TCP window scaling sysctl optimizations.
  - `99-rtl8189fs-performance.rules`: Udev rule triggering Wi-Fi optimization on interface activation.
  - `rtl8189fs-irq-tune.sh`: SDIO interrupt balancing and Receive Packet Steering (RPS) configuration.
  - `rtl8189fs.conf`: Modprobe configuration disabling aggressive power saving (`rtw_power_mgnt=0`, `rtw_ips_mode=0`) for rock-solid stability.
- **Debian Packaging Scripts**:
  - Turnkey `debian/control`, `debian/preinst`, `debian/postinst`, and `debian/prerm` scripts with kernel header detection and glibc host tool self-healing.
- **CI/CD & Documentation**:
  - GitHub Actions release pipeline (`.github/workflows/release.yml`) and changelog extraction helper (`.github/scripts/extract-changelog.py`).
  - Dual-language documentation (`README.md` and `README.id.md`).

# Changelog

All notable changes to the **Realtek RTL8189FS Linux DKMS Driver** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.2] - 2026-11-08

### 🚀 Throughput Acceleration, SGI 400ns & Anti-Bufferbloat
Pushed real-world throughput limits on FiberHome HG680-P by enabling Short Guard Interval (SGI 400ns) to raise the physical link rate to 72.2 Mbps, unlocking maximum A-MPDU (64K) and A-MSDU frame aggregation, eliminating Wi-Fi bufferbloat via FQ-CoDel and TCP BBR, and hardening kernel module teardown.

### Added
- **Short Guard Interval (SGI 400ns)**:
  - Enabled SGI capability injection (`IEEE80211_HT_CAP_SGI_20` and `IEEE80211_HT_CAP_SGI_40`) into `WIFI_ASSOCREQ` in `core/rtw_mlme_ext.c`, allowing the AP to transmit using 400ns symbols (72.2 Mbps PHY).
  - Unlocked SGI rate control adaptation in `OnAssocRsp()` to permit uplink transmission at 72.2 Mbps under Rate Adaptive (RA) engine.
  - Exposed runtime module parameter `rtw_short_gi` in `os_dep/linux/os_intfs.c`.
- **Maximum Frame Aggregation (A-MPDU 64K & A-MSDU)**:
  - Configured `rtw_rx_ampdu_amsdu = 1` by default to accept A-MSDU subframes inside A-MPDU bursts during ADDBA negotiation.
  - Added `rtw_rx_ampdu_factor` module parameter (default `3` = 64KB) in `os_dep/linux/os_intfs.c` and advertised 64K capability in Association Request.
  - Updated `/etc/modprobe.d/rtl8189fs.conf` with optimized aggregation options (`rtw_rx_ampdu_amsdu=1 rtw_tx_ampdu_amsdu=1 rtw_ampdu_enable=1 rtw_short_gi=15 rtw_rx_ampdu_factor=3`).
- **Bufferbloat Elimination & Latency Control**:
  - Configured `net.core.default_qdisc = fq_codel` and `net.ipv4.tcp_congestion_control = bbr` in `/etc/sysctl.d/99-rtl8189fs-throughput.conf`.
  - Applied active Fair Queueing (`fq_codel`) and `txqueuelen 1000` on `wlan0` via `/usr/lib/udev/rtl8189fs-irq-tune.sh`.

### Fixed
- **Kernel cfg80211 Warning Elimination (`net/wireless/scan.c:84`)**:
  - Bypassed manual `rtw_cfg80211_unlink_bss()` invocation on Linux kernel >= 6.0 in `os_dep/linux/ioctl_cfg80211.c`, preventing `WARN_ON(atomic_read(&bss->hold))` during module teardown and disconnection.

## [1.0.1] - 2026-11-08

### ⚡ Architecture & Compile-Time Optimization
Cleaned up legacy vendor build definitions to prune over 38 deadweight C translation units (>64,000 lines of inactive code) from the build process, reducing compiled files from 129 to 91, cutting DKMS compile time by nearly 2 minutes (from 6m 20s down to 4m 21s) and preventing STB thermal throttling during module building.

### Changed
- **Compiler Acceleration under Full `-O2`**:
  - Injected `-pipe -g0 -fno-var-tracking` flags into `ccflags-y`, eliminating redundant DWARF table generation and variable tracking compute passes while maintaining 100% full runtime `-O2` performance.
- **Vendor Debug Interface Cleanup**:
  - Disabled legacy vendor procfs debugging (`CONFIG_PROC_DEBUG = n`), completely eliminating over 11,200 lines of complex string formatting and register dumping code from `core/rtw_debug.c` and `os_dep/linux/rtw_proc.c`.
- **Wi-Fi Direct / P2P Pruning**:
  - Disabled unused Wi-Fi Direct screen-casting subsystem (`CONFIG_P2P`), pruning over 5,300 lines of P2P negotiation code from `core/rtw_p2p.c`.
- **Makefile Optimization**:
  - Wrapped inactive sub-features (`rtw_mesh`, `rtw_beamforming`, `rtw_tdls`, `rtw_rson`, `rtw_vht`, `rtw_iol`, `rtw_rm_fsm`, `custom_gpio_linux`, `rtw_rhashtable`, `hal_dm_acs`, `hal_btcoex_wifionly`) under conditional build flags.
  - Wrapped unused HAL interfaces (`hal_btcoex`, `hal_mp`, `hal_mcc`) and disconnected LED drivers (`hal_led`, `hal_sdio_led`, `rtl8189fs_led`) under corresponding configuration flags.
  - Removed empty ghost translation unit `core/rtw_ioctl_query.c`.
- **PHYDM Subsystem Pruning (`hal/phydm/phydm.mk`)**:
  - Pruned 17 unused MIMO/11ac PHYDM translation units from `_PHYDM_FILES` (Antenna Diversity, SOML MIMO stubs, Smart Antenna, Antenna Detection, Path Diversity, Beamforming TXBF, LNA saturation checks, ADC sampling, Power Training, PMAC TX settings, and MP tools) that are irrelevant for RTL8189FS (1T1R SISO 2.4GHz).
  - Retained essential stub symbols required by PHYDM core (`phydm_soml.o`, `phydm_dfs.o`, and `phydm_hal_txbf_api.o`), guaranteeing 0 modpost errors and 100% symbol integrity.

### Fixed
- **Linux 5.12+ RX Packet Delivery**:
  - Fixed silent packet drop / blackhole in `os_dep/linux/recv_linux.c` under `napi_recv()` for Linux kernel >= 5.12, ensuring incoming EAPOL and data frames are delivered reliably to the network stack.
  - Disabled redundant GRO (`CONFIG_RTW_GRO = n`) for SDIO 1T1R Wi-Fi, streamlining NAPI directly through `netif_receive_skb`.
- **Kernel cfg80211 Warning Elimination (`net/wireless/sme.c:845`)**:
  - Implemented `cfg80211_connect_bss` on Linux 6.0+ to pass authenticated BSS references directly to `cfg80211`, eliminating `WARN_ON(!bss)` kernel traces.
  - Guaranteed fallback to `cur_network` for `rtw_cfg80211_inform_bss` when `cur_network_scanned` is unpopulated.
- **Module Configuration Cleanup**:
  - Removed deprecated `rtw_drv_log_level=2` option from `/etc/modprobe.d/rtl8189fs.conf` to prevent kernel parameter warnings.

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
  - `rtl8189fs-irq-tune.sh`: SDIO interrupt balancing and Receive Packet Steering (RPS) configuration targeting controller physical register `d0070000`.
  - `rtl8189fs.conf`: Modprobe configuration disabling aggressive power saving (`rtw_power_mgnt=0`, `rtw_ips_mode=0`) for rock-solid stability.
- **Hardware Device Tree Integration**:
  - Dedicated Device Tree source and binary for FiberHome HG680-P (`dtb/meson-gxl-s905x-hg680p.dts`, `dtb/meson-gxl-s905x-hg680p.dtb`) fixing Wi-Fi SDIO power/reset line (GPIOX_6 / Pin 85) and eliminating phantom Broadcom Bluetooth timeouts.
  - Reference DTS and DTB files for Amlogic P212 and ZTE B860H.
- **Debian Packaging Scripts**:
  - Turnkey `debian/control`, `debian/preinst`, `debian/postinst`, and `debian/prerm` scripts with kernel header detection and glibc host tool self-healing.
- **CI/CD & Documentation**:
  - GitHub Actions release pipeline (`.github/workflows/release.yml`) and changelog extraction helper (`.github/scripts/extract-changelog.py`).
  - Dual-language documentation (`README.md` and `README.id.md`).

### Changed
- **Compiler & Build System Hardening**:
  - Elevated compiler optimization from `-O1` to `-O2` in `Makefile`.
  - Added `-fmin-function-alignment=%` compiler flag filtering for cross-toolchain header resilience.
  - Added Bare-metal libc include injection (`-isystem $(shell $(CC) -print-file-name=include)`) for Linux 6.12+ compatibility.
  - Added GCC 14 pointer error suppression flags (`-Wno-incompatible-pointer-types`, `-Wno-error=incompatible-pointer-types`, `-Wno-error=discarded-qualifiers`).
  - Streamlined driver build by disabling Mass Production factory calibration test code (`CONFIG_MP_INCLUDED = n`), verbose debug printk tracing (`CONFIG_RTW_DEBUG = n`), and concurrent dual-interface emulation (`CONFIG_CONCURRENT_MODE`), eliminating phantom `wlan1` adapter, reducing compile time significantly, and minimizing binary memory footprint on embedded ARM boards.
  - Enabled Linux network stack NAPI (`CONFIG_RTW_NAPI = y`) and Generic Receive Offload (`CONFIG_RTW_GRO = y`) for softirq RX packet processing and reduced CPU overhead.
  - Configured top-level module define `CONFIG_RTL8189FS ?= m` for robust out-of-tree kbuild integration.
- **DKMS Invocation & Packaging Architecture**:
  - Aligned DKMS build invocation syntax in `dkms.conf` with modern DKMS 3.x standards using `-C $kernel_source_dir M=$dkms_tree/...` (matching MediaTek `mt7663`/`mt7668` paradigm).
  - Switched autoload configuration in `debian/postinst` and `debian/prerm` to strict namespaced `/etc/modules-load.d/rtl8189fs.conf`.
  - Added proactive `cfg80211` module loading in `debian/postinst`.

### Fixed
- **Multi-Kernel Compatibility Guards (`ioctl_cfg80211.c` & `osdep_service_linux.h`)**:
  - Replaced legacy `from_timer()` callback with universal kernel primitive `container_of(in_timer, _timer, timer)` in `include/osdep_service_linux.h`, resolving compilation failure on Linux 6.15+ / 6.18 where `from_timer` was deprecated.
  - Implemented `#if (LINUX_VERSION_CODE >= KERNEL_VERSION(6, 14, 0))` guards for station ops (`add_station`, `del_station`, `change_station`, `dump_station`), key ops (`add_key`, `del_key`, `get_key`, `set_default_mgmt_key`), and power ops (`set_txpower`, `get_txpower`, `set_wiphy_params`), ensuring full out-of-the-box compatibility on Linux LTS kernels (5.x - 6.12) as well as newer kernels (6.14+).
  - Corrected `set_monitor_channel` net_device boundary to Linux 6.7+.

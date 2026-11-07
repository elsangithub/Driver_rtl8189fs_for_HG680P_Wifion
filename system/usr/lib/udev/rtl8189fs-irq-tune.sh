#!/bin/sh
# IRQ balancing and RPS tuning for RTL8189FS (HG680-P / S905X)
SDIO_IRQ=$(awk -F: '/c8835000|c8836000|meson-gx-mmc|8189fs/ {gsub(/ /, "", $1); print $1; exit}' /proc/interrupts 2>/dev/null)
if [ -z "$SDIO_IRQ" ]; then
    SDIO_IRQ=$(awk -F: '/mmc/ {gsub(/ /, "", $1); print $1; exit}' /proc/interrupts 2>/dev/null)
fi
if [ -n "$SDIO_IRQ" ] && [ -d "/proc/irq/$SDIO_IRQ" ]; then
    echo 2,3 > /proc/irq/$SDIO_IRQ/smp_affinity_list 2>/dev/null || true
fi
if [ -d /sys/class/net/wlan0/queues/rx-0 ]; then
    echo e > /sys/class/net/wlan0/queues/rx-0/rps_cpus 2>/dev/null || true
    echo 4096 > /sys/class/net/wlan0/queues/rx-0/rps_flow_cnt 2>/dev/null || true
fi

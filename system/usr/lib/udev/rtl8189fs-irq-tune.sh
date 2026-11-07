#!/bin/sh
# IRQ balancing and RPS tuning for RTL8189FS (HG680-P / S905X)
WIFI_IRQ=$(awk -F: '/d0070000/ {gsub(/ /, "", $1); print $1}' /proc/interrupts 2>/dev/null)
if [ -n "$WIFI_IRQ" ] && [ -d "/proc/irq/$WIFI_IRQ" ]; then
    echo 2,3 > /proc/irq/$WIFI_IRQ/smp_affinity_list 2>/dev/null || true
fi
if [ -d /sys/class/net/wlan0/queues/rx-0 ]; then
    echo e > /sys/class/net/wlan0/queues/rx-0/rps_cpus 2>/dev/null || true
    echo 4096 > /sys/class/net/wlan0/queues/rx-0/rps_flow_cnt 2>/dev/null || true
fi

# Anti-bufferbloat & active queue discipline tuning for wlan0
if [ -d /sys/class/net/wlan0 ]; then
    ip link set dev wlan0 txqueuelen 1000 2>/dev/null || true
    tc qdisc replace dev wlan0 root fq_codel 2>/dev/null || true
fi

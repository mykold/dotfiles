#!/bin/sh
set -eu

# default interface (usually eth0/enp*/eno*)
iface=$(ip route | awk '/^default/ {print $5; exit}')
[ -z "${iface:-}" ] && { echo "× OFF"; exit 0; }

rx1=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null) || { echo "× OFF"; exit 0; }
tx1=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null) || { echo "× OFF"; exit 0; }

sleep 1

rx2=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null) || { echo "× OFF"; exit 0; }
tx2=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null) || { echo "× OFF"; exit 0; }

rx=$((rx2 - rx1))
tx=$((tx2 - tx1))

fmt() {
  v=$1
  if [ "$v" -ge 1073741824 ]; then
    awk "BEGIN {printf \"%.1fG\", $v/1073741824}"
  elif [ "$v" -ge 1048576 ]; then
    awk "BEGIN {printf \"%.1fM\", $v/1048576}"
  elif [ "$v" -ge 1024 ]; then
    awk "BEGIN {printf \"%.0fK\", $v/1024}"
  else
    printf "%dB" "$v"
  fi
}

echo "↓$(fmt "$rx") ↑$(fmt "$tx")"


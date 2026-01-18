#!/usr/bin/env bash
set -euo pipefail

# Check WireGuard VPN status
# Count interfaces that have UP in their flags

active_count=$(ip link show 2>/dev/null | grep -E '^[0-9]+: .*(wg|vpn)' | grep -c 'UP' || echo 0)

if [ "$active_count" -gt 0 ]; then
  echo "$active_count"
else
  echo ""
fi

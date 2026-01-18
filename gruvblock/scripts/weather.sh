#!/usr/bin/env bash
set -euo pipefail

# Resolve location: env overrides; else geolocate via IP; fallback to London
LAT="${WEATHER_LAT:-}"
LON="${WEATHER_LON:-}"

if [ -z "$LAT" ] || [ -z "$LON" ]; then
  geo=$(curl -s --max-time 2 "http://ip-api.com/json" 2>/dev/null || true)
  if command -v jq >/dev/null 2>&1; then
    LAT=${LAT:-$(printf '%s' "$geo" | jq -r '.lat // empty')}
    LON=${LON:-$(printf '%s' "$geo" | jq -r '.lon // empty')}
  else
    LAT=${LAT:-$(printf '%s' "$geo" | grep -o '"lat":[0-9.+-]*' | head -1 | cut -d: -f2)}
    LON=${LON:-$(printf '%s' "$geo" | grep -o '"lon":[0-9.+-]*' | head -1 | cut -d: -f2)}
  fi
fi

[ -z "$LAT" ] && LAT="51.5074"
[ -z "$LON" ] && LON="-0.1278"

response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code&temperature_unit=celsius&timezone=auto" 2>/dev/null)

if [ -z "$response" ]; then
  echo "N/A"
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  temp=$(printf '%s' "$response" | jq -r '.current.temperature_2m // empty')
else
  # Fallback: take the first numeric temperature_2m (skip the unit field)
  temp=$(printf '%s' "$response" | grep -o '"temperature_2m":[0-9.+-]*' | head -1 | cut -d: -f2)
fi

temp_int="${temp%.*}"
[ -z "$temp_int" ] && temp_int="N/A"

echo "$temp_int"

#!/usr/bin/env bash

gitkraken &>/dev/null &

config_file="$HOME/.gitkraken/config"

if [ -n "${1:-}" ]; then
  config_file="$HOME/.gitkraken/profiles/$1/profile"
fi

# Wait until the config file exists (GitKraken may create it on first run)
until [[ -f "$config_file" ]]; do
  sleep 0.3
done

current_config=$(jq -r '.' "$config_file")

inotifywait -r -m -e modify "$config_file" | while read -r; do
  next_config=$(jq -r '.' "$config_file")
  deep-json-diff <(echo "$current_config") <(echo "$next_config")
  current_config=$next_config
done

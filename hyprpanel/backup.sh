#!/bin/sh
set -euo pipefail
IFS=$'\n\t'

BKP_PATH="${HOME}/.config/hyprpanel"
CONFIG_PATH="${HOME}/.cache/ags/hyprpanel"
CONFIG_FILENAME="options.json"

cd "${CONFIG_PATH}"

jq --sort-keys "." "${CONFIG_FILENAME}" > "${BKP_PATH}/${CONFIG_FILENAME}"

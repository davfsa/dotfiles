#!/bin/sh
set -euo pipefail
IFS=$'\n\t'

BKP_PATH="${HOME}/.config/hyprpanel"
CONFIG_PATH="${HOME}/.cache/ags/hyprpanel"
CONFIG_FILENAME="options.json"

mkdir -p "${CONFIG_PATH}"
cd "${CONFIG_PATH}"

if [ -e "${CONFIG_FILENAME}" ]; then
  echo "AGS file already exists, storing it in a backup..."
  mv "${CONFIG_FILENAME}" "${CONFIG_FILENAME}.bkp"
fi

pkill agsv1
cp "${BKP_PATH}/${CONFIG_FILENAME}" "${CONFIG_FILENAME}"
hyprctl --instance 0 'dispatch exec agsv1'

#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Uso: $0 <uuid> <email> <senha> <validade> <limite>"
    exit 1
fi

uuid="$1"
email="$2"
senha="$3"
validade="$4"
limite="$5"

config_v2ray="/etc/v2ray/config.json"
config_xray="/usr/local/etc/xray/config.json"

new_client=$(jq -n \
  --arg id "$uuid" \
  --arg email "$email" \
  '{id: $id, email: $email, level: 0}')

adicionar_cliente() {
  local config="$1"
  if grep -q "\"id\": \"$uuid\"" "$config"; then
    echo "⚠️ UUID já existe em $config"
  else
    tmpfile=$(mktemp)
    jq --argjson client "$new_client" '
      (.inbounds[] | select(.protocol == "vless") | .settings.clients) += [$client]
    ' "$config" > "$tmpfile" && mv "$tmpfile" "$config"

    chmod 644 "$config"
    chown root:root "$config"

    echo "✅ UUID adicionado em $config"
  fi
}

# Aplica nos dois sistemas
adicionar_cliente "$config_v2ray"
adicionar_cliente "$config_xray"

systemctl restart v2ray 2>/dev/null
systemctl restart xray 2>/dev/null

bash atlascreate.sh "$email" "$senha" "$validade" "$limite"

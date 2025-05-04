#!/bin/bash

# Verificar se o número correto de argumentos foi fornecido
if [ "$#" -ne 5 ]; then
    echo "Uso: $0 <uuid> <email> <senha> <validade_em_dias> <limite>"
    exit 1
fi

uuid="$1"
email="$2"
senha="$3"
validade="$4"
limite="$5"

v2ray_config="/etc/v2ray/config.json"
xray_config="/usr/local/etc/xray/config.json"

add_to_config() {
    local config_file="$1"
    local service_name="$2"

    if [ ! -f "$config_file" ]; then
        echo "❌ Arquivo $config_file não encontrado. Pulando $service_name."
        return
    fi

    if grep -q "\"id\": \"$uuid\"" "$config_file"; then
        echo "⚠️ UUID $uuid já existe em $service_name"
    else
        tmpfile=$(mktemp)
        jq --arg uuid "$uuid" --arg email "$email" '
          (.inbounds[] | select(.protocol == "vless") | .settings.clients) +=
          [{"id": $uuid, "email": $email, "level": 0}]
        ' "$config_file" > "$tmpfile" && mv "$tmpfile" "$config_file"
        chmod 644 "$config_file"
        echo "✅ UUID $uuid adicionado ao $service_name"
        systemctl restart "$service_name"
    fi
}

add_to_config "$v2ray_config" "v2ray"
add_to_config "$xray_config" "xray"

# Executar o script atlascreate
bash atlascreate.sh "$email" "$senha" "$validade" "$limite"

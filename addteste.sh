#!/bin/bash

# Verifica número de argumentos
if [ "$#" -ne 5 ]; then
    echo "Uso: $0 <uuid> <email> <senha> <validade> <limite>"
    exit 1
fi

uuid="$1"
email="$2"
senha="$3"
validade="$4"
limite="$5"

add_uuid() {
    local config_path="$1"
    local service="$2"

    # Verifica se o UUID já existe
    if grep -q "\"id\": \"$uuid\"" "$config_path"; then
        echo "⚠️ UUID já existe em $config_path"
        return
    fi

    # Adiciona o cliente no formato correto (ordem dos campos)
    tmpfile=$(mktemp)
    if jq --arg uuid "$uuid" --arg email "$email" '
        (.inbounds[] | select(.protocol == "vless") | .settings.clients) +=
        [{"id": $uuid, "email": $email, "level": 0}]
    ' "$config_path" > "$tmpfile"; then
        mv "$tmpfile" "$config_path"
        chmod 644 "$config_path"
        chown root:root "$config_path"
        echo "✅ UUID adicionado em $config_path"
        systemctl restart "$service"
    else
        echo "❌ Erro ao processar $config_path"
        rm "$tmpfile"
    fi
}

# Adiciona no V2Ray
add_uuid "/etc/v2ray/config.json" "v2ray"

# Adiciona no Xray
add_uuid "/usr/local/etc/xray/config.json" "xray"

# Criação no painel Atlas
bash atlasteste.sh "$email" "$senha" "$validade" "$limite"

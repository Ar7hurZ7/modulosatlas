#!/bin/bash

delete_id() {
    if [ "$#" -ne 2 ]; then
        echo "Uso: $0 <uuid> <login>"
        exit 1
    fi

    uuidel="$1"
    login="$2"

    remove_uuid() {
        local config_path="$1"
        local service_name="$2"

        if grep -q "$uuidel" "$config_path"; then
            tmpfile=$(mktemp)
            if jq --arg uuid "$uuidel" '
                (.inbounds[] | select(.protocol == "vless") | .settings.clients) |=
                map(select(.id != $uuid))
            ' "$config_path" > "$tmpfile"; then
                mv "$tmpfile" "$config_path"
                chmod 644 "$config_path"
                chown root:root "$config_path"
                echo "🧹 UUID $uuidel removido de $config_path"
                systemctl restart "$service_name"
            else
                echo "❌ Erro ao processar $config_path"
                rm "$tmpfile"
            fi
        fi
    }

    remove_uuid "/etc/v2ray/config.json" "v2ray"
    remove_uuid "/usr/local/etc/xray/config.json" "xray"

    bash atlasremove.sh "$login"
}

delete_id "$1" "$2"

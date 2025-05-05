#!/bin/bash

# Verifica se os argumentos foram fornecidos corretamente
if [ "$#" -ne 5 ]; then
    echo "Uso: $0 <uuid> <email> <senha> <validade_min> <limite>"
    exit 1
fi

# Atribuição de variáveis
uuid="$1"
username="$2"
password="$3"
dias="$4"
sshlimiter="$5"

# Cria o usuário SSH com validade
final=$(date "+%Y-%m-%d" -d "+$dias minutes")
pass=$(perl -e 'print crypt($ARGV[0], "password")' "$password")
useradd -e "$final" -M -s /bin/false -p "$pass" "$username"
echo "$password" > "/etc/SSHPlus/senha/$username"
echo "$username $sshlimiter" >> /root/usuarios.db

# Cria script para deletar o usuário após expiração
cat <<EOF > "/etc/SSHPlus/userteste/$username.sh"
#!/bin/bash
pkill -f "$username"
userdel --force "$username"
grep -v ^$username[[:space:]] /root/usuarios.db > /tmp/ph && cat /tmp/ph > /root/usuarios.db
rm /etc/SSHPlus/senha/$username > /dev/null 2>&1
rm -rf /etc/SSHPlus/userteste/$username.sh
exit
EOF
chmod +x "/etc/SSHPlus/userteste/$username.sh"
at -f "/etc/SSHPlus/userteste/$username.sh" now + "$dias" min > /dev/null 2>&1

# Adiciona UUID ao V2Ray e Xray
config_v2ray="/etc/v2ray/config.json"
config_xray="/usr/local/etc/xray/config.json"

new_client="{\"id\": \"$uuid\", \"email\": \"$username\", \"level\": 0}"

adicionar_uuid() {
  local config="$1"
  if [ -f "$config" ]; then
    if grep -q "$uuid" "$config"; then
      echo "⚠️ UUID $uuid já existe em $config"
    else
      tmpfile=$(mktemp)
      jq --arg client "$new_client" '(.inbounds[] | select(.protocol == "vless") | .settings.clients) += [($client | fromjson)]' "$config" > "$tmpfile" && mv "$tmpfile" "$config"
      chmod 644 "$config"
      chown root:root "$config"
      echo "✅ UUID $uuid adicionado em $config"
    fi
  fi
}

adicionar_uuid "$config_v2ray"
adicionar_uuid "$config_xray"

systemctl restart v2ray 2>/dev/null
systemctl restart xray 2>/dev/null

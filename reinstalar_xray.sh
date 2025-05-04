#!/bin/bash

# Spinner para mostrar animação durante processos em background
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Solicita a porta ao usuário
read -p "Digite a porta desejada para o Xray: " PORTA

echo "🧹 Removendo instalação anterior do Xray..."
(
    sudo systemctl stop xray
    sudo systemctl disable xray
    sudo rm -f /usr/local/bin/xray
    sudo rm -rf /usr/local/etc/xray
    sudo rm -f /etc/systemd/system/xray.service
    sudo rm -f /etc/systemd/system/xray.service.d/10-donot_touch_single_conf.conf
) & spinner

echo "📥 Instalando nova versão do Xray..."
(bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install) & spinner

echo "📁 Criando diretório de configuração alternativo..."
sudo mkdir -p /etc/v2ray

echo "⚙️ Salvando novo config.json..."
cat <<EOF | sudo tee /etc/v2ray/config.json > /dev/null
{
  "api": {
    "services": ["HandlerService", "LoggerService", "StatsService"],
    "tag": "api"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 1085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "port": $PORTA,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "4c4326a8-830d-4496-aad8-392fd624ff47",
            "email": "xxx9",
            "level": 0
          }
        ],
        "decryption": "none",
        "fallbacks": []
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "none",
        "xhttpSettings": {
          "headers": {},
          "host": "",
          "mode": "auto",
          "path": "/",
          "scMaxBufferedPosts": 30,
          "scMaxEachPostBytes": "1000000",
          "scStreamUpServerSecs": "20-80",
          "xPaddingBytes": "100-1000"
        }
      },
      "sniffing": {
        "enabled": false,
        "destOverride": ["http", "tls", "quic", "fakedns"]
      },
      "tag": "inbound-sshplus"
    }
  ],
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "info"
  },
  "outbounds": [
    {"protocol": "freedom", "settings": {}, "tag": "direct"},
    {"protocol": "blackhole", "settings": {}, "tag": "blocked"}
  ],
  "policy": {
    "levels": {"0": {"statsUserDownlink": true, "statsUserUplink": true}},
    "system": {"statsInboundDownlink": true, "statsInboundUplink": true}
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {"inboundTag": ["api"], "outboundTag": "api", "type": "field"},
      {"ip": ["geoip:private"], "outboundTag": "blocked", "type": "field"},
      {"outboundTag": "blocked", "protocol": ["bittorrent"], "type": "field"}
    ]
  },
  "stats": {}
}
EOF

echo "🔧 Atualizando serviço systemd..."
cat <<EOF | sudo tee /etc/systemd/system/xray.service > /dev/null
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/v2ray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

echo "🔐 Corrigindo permissões do config.json..."
chmod 644 /etc/v2ray/config.json

echo "🔁 Reiniciando Xray..."
sudo systemctl daemon-reload
sudo systemctl enable xray
sudo systemctl restart xray

echo "✅ Xray reinstalado e configurado com sucesso!"

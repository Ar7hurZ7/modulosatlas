#!/bin/bash

clear
echo -e "\e[1;36m🔁 Iniciando instalação do Xray...\e[0m"
sleep 1

# Função de animação de carregamento
loading_animation() {
    local message=$1
    local duration=$2
    local i=0
    local spin='-\|/'

    echo -ne "$message "
    while [ $i -lt $duration ]; do
        for j in $(seq 0 3); do
            echo -ne "\b${spin:$j:1}"
            sleep 0.1
        done
        i=$((i + 1))
    done
    echo -ne "\b✔️"
    echo
}

# Etapas de limpeza
loading_animation "⏹️ Parando serviço Xray" 10
sudo systemctl stop xray &>/dev/null

loading_animation "🧹 Limpando instalação anterior" 15
sudo systemctl disable xray &>/dev/null
sudo rm -f /usr/local/bin/xray
sudo rm -rf /usr/local/etc/xray
sudo rm -f /etc/systemd/system/xray.service
sudo rm -f /etc/systemd/system/xray.service.d/10-donot_touch_single_conf.conf

# Reinstalação
loading_animation "⬇️ Instalando Xray" 20
bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install &>/dev/null

# Configuração personalizada
loading_animation "📁 Criando diretório " 5
sudo mkdir -p /etc/v2ray

read -p "🛠️ Digite a porta que deseja usar para o Xray (ex: 8002): " PORTA

cat <<EOF | sudo tee /etc/v2ray/config.json > /dev/null
{
  "api": {
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ],
    "tag": "api"
  },
  "burstObservatory": null,
  "dns": null,
  "fakedns": null,
  "inbounds": [
    {
      "allocate": null,
      "listen": "127.0.0.1",
      "port": 1085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "sniffing": null,
      "streamSettings": null,
      "tag": "api"
    },
    {
      "allocate": {
        "concurrency": 3,
        "refresh": 5,
        "strategy": "always"
      },
      "listen": null,
      "port": $PORTA,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "email": "xxx9",
            "id": "4c4326a8-830d-4496-aad8-392fd624ff47",
            "level": 0
          }
        ],
        "decryption": "none",
        "fallbacks": []
      },
      "sniffing": {
        "destOverride": [
          "http",
          "tls",
          "quic",
          "fakedns"
        ],
        "enabled": false,
        "metadataOnly": false,
        "routeOnly": false
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "none",
        "xhttpSettings": {
          "headers": {},
          "host": "",
          "mode": "auto",
          "noSSEHeader": false,
          "path": "/",
          "scMaxBufferedPosts": 30,
          "scMaxEachPostBytes": "1000000",
          "scStreamUpServerSecs": "20-80",
          "xPaddingBytes": "100-1000"
        }
      },
      "tag": "inbound-sshplus"
    }
  ],
  "log": {
    "access": "/var/log/v2ray/access.log",
    "dnsLog": false,
    "error": "/var/log/v2ray/error.log",
    "loglevel": "info",
    "maskAddress": ""
  },
  "observatory": null,
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true,
      "statsOutboundDownlink": false,
      "statsOutboundUplink": false
    }
  },
  "reverse": null,
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked",
        "type": "field"
      },
      {
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ],
        "type": "field"
      }
    ]
  },
  "stats": {},
  "transport": null
}
EOF

# Serviço systemd
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

# Permissões
chmod 644 /etc/v2ray/config.json

# Ativação
loading_animation "🔁 Reiniciando serviço Xray" 10
sudo systemctl daemon-reload
sudo systemctl enable xray
sudo systemctl restart xray

# Mensagem final
echo -e "\n✅ \e[1;32mXray instalado com sucesso!\e[0m"

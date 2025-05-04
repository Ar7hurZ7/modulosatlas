#!/bin/bash

# 🛑 Remover instalação atual do Xray
echo "🧹 Removendo instalação atual do Xray..."
sudo systemctl stop xray
sudo systemctl disable xray
sudo rm -f /usr/local/bin/xray
sudo rm -rf /usr/local/etc/xray
sudo rm -f /etc/systemd/system/xray.service
sudo rm -f /etc/systemd/system/xray.service.d/10-donot_touch_single_conf.conf
sudo systemctl daemon-reload

# 🔄 Instalar Xray novamente
echo "⬇️ Instalando Xray..."
bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install

# 🛠 Solicitar porta personalizada
read -p "🔢 Digite a porta desejada para o Xray: " PORTA

# 📁 Recriar diretório original
sudo mkdir -p /usr/local/etc/xray

# 📝 Gerar config.json no caminho original
echo "⚙️ Gerando /usr/local/etc/xray/config.json..."
cat <<EOF | sudo tee /usr/local/etc/xray/config.json > /dev/null
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

# ✅ Corrigir permissões
sudo chmod 644 /usr/local/etc/xray/config.json

# 🔁 Reiniciar Xray
echo "🚀 Reiniciando Xray..."
sudo systemctl daemon-reload
sudo systemctl enable xray
sudo systemctl restart xray

# ✅ Finalizado
echo "✅ Xray reinstalado com config em /usr/local/etc/xray/config.json usando a porta $PORTA"


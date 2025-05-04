#!/bin/bash

clear

echo -e "\e[1;36m🚧 Iniciando instalação do Xray...\e[0m"

# Função de animação
progress_bar() {
  pid=$!
  spin='-\|/'
  i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r⏳ Instalando... ${spin:$i:1}"
    sleep 0.2
  done
}

# Função de limpeza
limpar_instalacao_antiga() {
  echo -e "\n🔄 Removendo Xray anterior (se existir)..."
  sudo systemctl stop xray >/dev/null 2>&1
  sudo systemctl disable xray >/dev/null 2>&1
  sudo rm -f /usr/local/bin/xray
  sudo rm -rf /usr/local/etc/xray
  sudo rm -f /etc/systemd/system/xray.service
  sudo rm -f /etc/systemd/system/xray.service.d/10-donot_touch_single_conf.conf
}

# Função de instalação
instalar_xray() {
  bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install >/dev/null 2>&1 &
  progress_bar
}

# Criar diretório e solicitar porta
preparar_configuracao() {
  echo -e "\n📦 Preparando configuração personalizada..."
  sudo mkdir -p /usr/local/etc/xray

  read -p "🔢 Digite a porta que deseja usar para o VLESS (ex: 8002): " porta
  porta=${porta:-8002}

  cat <<EOF | sudo tee /usr/local/etc/xray/config.json >/dev/null
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
      "settings": { "address": "127.0.0.1" },
      "tag": "api"
    },
    {
      "port": $porta,
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
    { "protocol": "freedom", "settings": {}, "tag": "direct" },
    { "protocol": "blackhole", "settings": {}, "tag": "blocked" }
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
      "statsInboundUplink": true
    }
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      { "inboundTag": ["api"], "outboundTag": "api", "type": "field" },
      { "ip": ["geoip:private"], "outboundTag": "blocked", "type": "field" },
      { "protocol": ["bittorrent"], "outboundTag": "blocked", "type": "field" }
    ]
  }
}
EOF

  sudo chmod 644 /usr/local/etc/xray/config.json
}

# Iniciar serviço
reiniciar_servico() {
  echo -e "\n🚀 Reiniciando Xray..."
  sudo systemctl daemon-reload
  sudo systemctl enable xray
  sudo systemctl restart xray
}

# Execução
limpar_instalacao_antiga
instalar_xray
preparar_configuracao
reiniciar_servico

echo -e "\n✅ \e[1;32mXray instalado com sucesso na porta $porta!\e[0m"

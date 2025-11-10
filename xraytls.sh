{
  "api": {
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ],
    "tag": "api"
  },
  "inbounds": [
    {
      "tag": "api",
      "port": 1080,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "listen": "127.0.0.1"
    },
    {
      "tag": "inbound-sshorizon",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "email": "ids",
            "id": "ba258996-cc84-4a01-b658-06217949826e",
            "level": 0
          },
          {
            "id": "f8250f90-4b56-4f56-82d2-51ac52f1ae73",
            "email": "ne770",
            "level": 0
          },
          {
            "id": "6e49427f-6e8c-4f96-8957-8795a2be1169",
            "email": "rn039",
            "level": 0
          }
        ],
        "decryption": "none",
        "fallbacks": []
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/opt/sshorizon/ssl/fullchain.pem",
              "keyFile": "/opt/sshorizon/ssl/privkey.pem"
            }
          ],
          "alpn": [
            "http/1.1"
          ]
        },
        "xhttpSettings": {
          "headers": null,
          "host": "",
          "mode": "",
          "noSSEHeader": false,
          "path": "/",
          "scMaxBufferedPosts": 30,
          "scMaxEachPostBytes": "1000000",
          "scStreamUpServerSecs": "20-80",
          "xPaddingBytes": "100-1000"
        }
      }
    }
  ],
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "info"
  },
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
      "statsInboundUplink": true
    }
  },
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
  }
}

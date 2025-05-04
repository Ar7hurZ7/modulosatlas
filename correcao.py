import json
import os

# Caminho do config do Xray
config_path = '/usr/local/etc/xray/config.json'

# Carregar configuração existente do Xray
with open(config_path, 'r') as f:
    config = json.load(f)

# Adicionar seção de log se ainda não existir
if 'log' not in config:
    new_config = {
        'log': {
            'access': '/var/log/v2ray/access.log',
            'error': '/var/log/v2ray/error.log',
            'loglevel': 'info'
        }
    }
    new_config.update(config)
    config = new_config
    print('✅ Configuração de log adicionada ao Xray (salvando como v2ray)')
else:
    print('ℹ️ Log já configurado.')

# Garantir que diretório de log existe
os.makedirs('/var/log/v2ray', exist_ok=True)
os.chmod('/var/log/v2ray', 0o755)

# Salvar de volta a configuração
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

# Reiniciar o serviço Xray
os.system('systemctl restart xray')

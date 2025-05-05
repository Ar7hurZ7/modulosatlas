#!/bin/bash
rm -f atlasdata.sh atlascreate.sh atlasteste.sh atlasremove.sh delete.py sincronizar.py add.sh rem.sh addteste.sh addsinc.sh remsinc.sh atlastestev2.sh
wget -O atlascreate.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/atlascreate.sh"
wget -O add.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/add.sh"
wget -O remsinc.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/remsinc.sh"
wget -O addsinc.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/addsinc.sh"
wget -O rem.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/rem.sh"
wget -O atlasteste.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/atlasteste.sh"
wget -O addteste.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/addteste.sh"
wget -O atlasremove.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/atlasremove.sh"
wget -O delete.py "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/delete.py"
wget -O atlasdata.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/atlasdata.sh"
wget -O sincronizar.py "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/sincronizar.py"
wget -O atlastestev2.sh "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/atlastestev2.sh"
chmod 777 atlascreate.sh add.sh remsinc.sh addsinc.sh rem.sh atlasteste.sh addteste.sh atlasremove.sh delete.py atlasdata.sh sincronizar.py atlastestev2.sh
apt install dos2unix
dos2unix rem.sh
wget "https://raw.githubusercontent.com/Ar7hurZ7/modulosatlas/refs/heads/main/verificador.py" -O verificador.py 
python3 verificador.py

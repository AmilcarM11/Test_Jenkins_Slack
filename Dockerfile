FROM nginx:alpine

# Copiar los archivos HTML al directorio raíz de Nginx
COPY html/ /usr/share/nginx/html/

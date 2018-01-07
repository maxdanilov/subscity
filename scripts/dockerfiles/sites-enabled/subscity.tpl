server {
    listen          80;
    listen          [::]:80;
    server_name     *.${SC_DOMAIN_NAME} ${SC_DOMAIN_NAME};
    return          301 https://${DOLLAR}host${DOLLAR}request_uri;
}

server {
    listen                  443 ssl;
    listen                  [::]:443 ssl;
    server_name             ${SC_DOMAIN_NAME};
    ssl_certificate         /etc/ssl/certs/nginx.crt;
    ssl_trusted_certificate /etc/ssl/certs/nginx.crt;
    ssl_certificate_key     /etc/ssl/certs/nginx.key;
    return              301 https://msk.${DOLLAR}host${DOLLAR}request_uri;
}

server {
    listen          443 ssl;
    listen          [::]:443 ssl;
    server_name     *.${SC_DOMAIN_NAME};
    access_log      off;

    ssl_session_cache           shared:SSL:10m;
    ssl_session_timeout         5m;
    ssl_prefer_server_ciphers   on;
    ssl_stapling                on;

    keepalive_timeout                       60;
    ssl_certificate                         /etc/ssl/certs/nginx.crt;
    ssl_trusted_certificate                 /etc/ssl/certs/nginx.crt;
    ssl_certificate_key                     /etc/ssl/certs/nginx.key;
    ssl_protocols                           SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers                             "RC4:HIGH:!aNULL:!MD5:!kEDH";
    add_header Strict-Transport-Security    'max-age=604800';

    location ~ ^/(images|fonts)/  {
        root    /usr/share/nginx/html/subscity/;
        expires 2d;
    }

    location / {
        proxy_pass          http://${SC_DB_HOST}:3000;
        proxy_set_header    Host             ${DOLLAR}host;
        proxy_set_header    X-Real-IP        ${DOLLAR}remote_addr;
    }
}
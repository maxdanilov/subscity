server {
    listen          80;
    listen          [::]:80;
    server_name     *.${SC_DOMAIN_NAME} ${SC_DOMAIN_NAME};
    return          301 https://${DOLLAR}host${DOLLAR}request_uri;
}

server {
    listen                                  443 ssl;
    listen                                  [::]:443 ssl;
    server_name                             ${SC_DOMAIN_NAME};
    ssl_certificate                         /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key                     /etc/ssl/certs/privkey.pem;
    return                                  301 https://msk.${DOLLAR}host${DOLLAR}request_uri;
}

server {
    listen                      443 ssl;
    listen                      [::]:443 ssl;
    server_name                 *.${SC_DOMAIN_NAME};
    access_log                  /var/log/nginx/access.log;
    proxy_max_temp_file_size    0;

    gzip            on;
    gzip_disable    "msie6";
    gzip_types      text/html application/javascript text/css application/octet-stream;

    ssl_session_cache           shared:SSL:10m;
    ssl_session_timeout         5m;
    ssl_prefer_server_ciphers   on;
    ssl_stapling                on;

    keepalive_timeout                       60;
    ssl_certificate                         /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key                     /etc/ssl/certs/privkey.pem;
    ssl_protocols                           SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers                             "RC4:HIGH:!aNULL:!MD5:!kEDH";
    add_header Strict-Transport-Security    'max-age=604800';

    root    /usr/share/nginx/html/subscity/;

    error_page 502 /maintenance.html;
    location = /maintenance.html {
        internal;
    }

    location = /policy/android {
        rewrite /(.*) https://vittt2008.github.io/subscity/privacy_policy;
    }

    location /robots.txt {
        return 200 "User-agent: *\nDisallow:\n";
    }

    location ~ ^/(images|fonts)/  {
        expires 2d;
    }

    location / {
        proxy_pass          http://${SC_DB_HOST}:3000;
        proxy_set_header    Host             ${DOLLAR}host;
        proxy_set_header    X-Real-IP        ${DOLLAR}remote_addr;
    }
}
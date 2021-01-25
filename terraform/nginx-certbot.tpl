upstream app {
    # Path to Unicorn SOCK file, as defined https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-unicorn-and-nginx-on-ubuntu-14-04
    server unix:/home/ubuntu/run/puma.sock fail_timeout=0;
}

server {
  root /home/ubuntu/contra/public;
%{ if domain_name == "" ~}
  server_name "";
%{ else ~}
  server_name ${domain_name} www.${domain_name};
%{ endif ~}
  index index.html;

  if ($host = www.${domain_name}) {
      return 301 https://${domain_name}$request_uri;
  }

  location / {
    try_files $uri/index.html $uri.html $uri @app;
  }

  location ~ ^/assets/ {
    expires 1y;
    add_header Cache-Control public;

    add_header ETag "";
    break;
  }

  location ~* ^.+\.(jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|mid|midi|wav|bmp|rtf|mp3|flv|mpeg|avi)$ {
    try_files $uri @app;
  }

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://app;
  }

%{ if domain_name == "" ~}
  listen 80 default_server;
%{ else ~}
  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/${domain_name}/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/${domain_name}/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
%{ endif ~}
}


%{ if domain_name != "" ~}
server {
  if ($host = ${domain_name}) {
      return 301 https://$host$request_uri;
  } # managed by Certbot


  listen   80;
  server_name ${domain_name} www.${domain_name};
    return 404; # managed by Certbot
}
%{ endif ~}

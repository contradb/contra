upstream app {
    # Path to Unicorn SOCK file, as defined https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-unicorn-and-nginx-on-ubuntu-14-04
    server unix:/home/ubuntu/run/puma.sock fail_timeout=0;
}

# from https://www.digitalocean.com/community/tutorials/how-to-redirect-www-to-non-www-with-nginx-on-ubuntu-14-04
%{ if domain_name != null ~}
server {
    server_name www.${domain_name};
    return 301 $scheme://${domain_name}$request_uri;
}
%{ endif ~}

server {
  listen 80 default_server;
  root /home/ubuntu/contra/public;
  server_name ${domain_name == null ? "" : domain_name};
  index index.htm index.html;

  location / {
    try_files $uri/index.html $uri.html $uri @app;
  }

  # doesn't appear to serve the fingerprinted assets the way I want it to - Dave Morse contradb
  # see https://github.com/dcmorse/contra/issues/24
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
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://app;
  }
}

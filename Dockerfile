FROM debian:jessie

MAINTAINER Victor Hahn Castell <victor@hahncastell.de>

ENV NGINX_VERSION 1.9.5

RUN apt-get update
RUN apt-get install -y wget git

WORKDIR /usr/src
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN tar -xf nginx-${NGINX_VERSION}.tar.gz

RUN git clone https://github.com/victorhahncastell/nginx-auth-ldap.git

WORKDIR /usr/src/nginx-${NGINX_VERSION}
RUN apt-get install -y build-essential
RUN apt-get install -y zlib1g-dev libpcre3 libpcre3-dev unzip curl libcurl4-openssl-dev libossp-uuid-dev libldap2-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev
RUN ./configure --conf-path=/etc/nginx/nginx.conf --add-module=/usr/src/nginx-auth-ldap/ --with-file-aio --with-ipv6 --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_geoip_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-http_perl_module --with-mail --with-mail_ssl_module --with-pcre --with-google_perftools_module --with-debug
RUN make install

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log
RUN ln -sf /dev/stderr /usr/local/nginx/logs/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]

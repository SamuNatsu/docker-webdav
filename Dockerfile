# Base image
FROM alpine:latest
EXPOSE 80

# Arguments
ARG NGINX_VERSION=1.26.0

# Install build dependencies
RUN apk update && apk add --no-cache git build-base pcre-dev zlib-dev openssl-dev libxml2-dev libxslt-dev

# Clone source code from github
RUN git clone https://github.com/atomx/nginx-http-auth-digest
RUN git clone https://github.com/mid1221213/nginx-dav-ext-module

# Get nginx source code
RUN wget "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
RUN tar -zxf "nginx-$NGINX_VERSION.tar.gz" && rm "nginx-$NGINX_VERSION.tar.gz"

# Compile nginx
RUN cd "nginx-$NGINX_VERSION" \
  && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
    --with-compat \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-Os -fstack-clash-protection -Wformat -Werror=format-security -fno-plt -g' \
    --with-ld-opt='-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs' \
    --add-module=../nginx-http-auth-digest \
    --add-module=../nginx-dav-ext-module \
  && make -j && make install

# Clean up build dependencies
RUN apk del git build-base pcre-dev zlib-dev openssl-dev libxml2-dev libxslt-dev
RUN rm -rf nginx-http-auth-digest nginx-dav-ext-module "nginx-$NGINX_VERSION"

# Install dependencies
RUN apk add --no-cache pcre zlib openssl libxml2 libxslt

# Copy files
COPY default.conf /etc/nginx/cond.d/default.conf
COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

# Start up command
CMD /entrypoint.sh

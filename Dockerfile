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
    --with-threads \
    --with-http_dav_module \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_v2_module \
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
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

# Redirect stdout and stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# Start up command
CMD /entrypoint.sh

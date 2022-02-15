FROM nginx:1.21-alpine AS builder

ENV SUBS_VERSION 1.1.15
ENV FONTS_HOST 'http://localhost'

RUN apk add --no-cache --virtual .build-deps \
        git \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre2-dev \
        zlib-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        perl-dev \
        libedit-dev \
        bash \
        alpine-sdk \
        findutils

RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz
RUN mkdir /tmp/src && CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') tar -zxC /tmp/src -f nginx.tar.gz

RUN git clone git://github.com/yaoweibin/ngx_http_substitutions_filter_module.git

RUN SUBSDIR="$(pwd)/ngx_http_substitutions_filter_module" && \
    cd /tmp/src/nginx-$NGINX_VERSION && \
    ./configure --with-compat $CONFARGS --add-dynamic-module=$SUBSDIR && \
    make && \
    make install

FROM nginx:1.21-alpine

# Extract the dynamic module NCHAN from the builder image
COPY --from=builder /usr/local/nginx/modules/ngx_http_subs_filter_module.so /usr/local/nginx/modules/ngx_http_subs_filter_module.so

COPY ./conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY ./docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]

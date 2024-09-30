FROM alpine:3.20

LABEL version="1.0"
LABEL alpine_version="3.20"
LABEL nginx_version="1.24.0"
LABEL openssl_version="1.1.1w"
LABEL description="Docker image nginx alpine build"

ENV NGINX_VERSION=1.24.0
ENV OPENSSL_VERSION=1.1.1w

RUN  addgroup nginx -g 1000 \
&& adduser -D -H -s /sbin/nologin -G nginx -u 1000 nginx \
&& apk add --no-cache --virtual .build-deps \
	gcc \
	libc-dev \
	make \
	openssl-dev \
	pcre-dev \
	zlib-dev \
	linux-headers \
	curl \
	gnupg \
	libxslt-dev \
	gd-dev \
	geoip-dev \
	perl-dev \
	git \
        bash \
	tzdata

RUN cat /usr/share/zoneinfo/Asia/Jakarta > /etc/localtime \
&& mkdir -p /usr/local/src \
&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
&& curl -fSL https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz -o openssl.tar.gz \
&& git clone https://github.com/openresty/headers-more-nginx-module.git /usr/local/src/headers-more-nginx-module \
&& tar -zxC /usr/local/src -f nginx.tar.gz \
&& tar -zxC /usr/local/src -f openssl.tar.gz \
&& cd /usr/local/src/nginx-$NGINX_VERSION \
&& sed -i -e 's/\#define NGINX\_VERSION      \"'$NGINX_VERSION'\"/\#define NGINX\_VERSION      \"'dtx'\"/g' src/core/nginx.h
RUN cd /usr/local/src/nginx-$NGINX_VERSION \
&& ./configure --prefix=/opt/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --with-openssl=/usr/local/src/openssl-$OPENSSL_VERSION \
        --with-http_v2_module --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-file-aio \
        --with-threads \
		--with-http_realip_module \
        --with-http_geoip_module \
        --with-stream \
	--with-http_dav_module \
        --with-stream_geoip_module=dynamic \
        --with-http_perl_module=dynamic \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --add-module=/usr/local/src/headers-more-nginx-module \
&& make -j$(getconf _NPROCESSORS_ONLN) \
&& make install \
&& strip /opt/nginx/sbin/nginx* \
&& strip /usr/lib/nginx/modules/*.so \
&& rm -rf /usr/local/src/nginx-$NGINX_VERSION \
&& apk add --no-cache --virtual .gettext gettext \
&& mv /usr/bin/envsubst /tmp/ \
&& runDeps="$( \
	scanelf --needed --nobanner /opt/nginx/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
	| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
	| sort -u \
	| xargs -r apk info --installed \
	| sort -u \
)" \
&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
&& apk del .build-deps \
&& apk del .gettext \
&& apk add --no-cache curl bash \
&& mv /tmp/envsubst /usr/local/bin/ \
&& rm -rf /usr/local/src \
&& rm -rf /nginx.tar.gz \
&& rm -rf /openssl.tar.gz \
&& mkdir -p /var/log/nginx/ \
&& chown nginx. -R /var/log/nginx/

RUN chown nginx. -R /opt/nginx/

FROM alpine:latest AS build

ENV NGINX_VERSION=1.19.2

RUN apk add --no-cache g++ pcre-dev openssl-dev zlib-dev make git

# nginx
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar xzvf nginx-${NGINX_VERSION}.tar.gz && rm -rf *.tar.gz

# nginx-push-stream-module latest
RUN git clone https://github.com/slact/nchan.git

WORKDIR /nginx-${NGINX_VERSION}

# configure and build

RUN ./configure --add-module=../nchan --with-http_auth_request_module --with-http_ssl_module --with-http_v2_module && make && make install

FROM alpine:latest

ENV PUBSUB_SECRET=${PUBSUB_SECRET:-""}

COPY --from=build /usr/local/nginx /usr/local/nginx
COPY nginx.conf.template /usr/local/nginx/conf/
COPY set-env-in-nginx-config.sh /
RUN chmod +x /set-env-in-nginx-config.sh
COPY sysctl.conf /etc/sysctl.conf
COPY limits.conf /etc/security/


RUN apk update && \
  apk add zlib pcre gettext

CMD ["/bin/sh", "-c", "/set-env-in-nginx-config.sh && /usr/local/nginx/sbin/nginx"]


EXPOSE 80/tcp 443/tcp
FROM alpine:latest AS build

ENV NGINX_VERSION=1.19.2

RUN apk add --no-cache g++ pcre-dev zlib-dev make git

# nginx
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar xzvf nginx-${NGINX_VERSION}.tar.gz && rm -rf *.tar.gz

# nginx-push-stream-module latest
RUN git clone https://github.com/wandenberg/nginx-push-stream-module.git

WORKDIR /nginx-${NGINX_VERSION}

# configure and build

RUN ./configure --add-module=../nginx-push-stream-module --with-http_auth_request_module && make && make install

FROM alpine:latest
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/
COPY sysctl.conf /etc/sysctl.conf


RUN apk update && \
  apk add zlib pcre

CMD ["/bin/sh", "-c", "/usr/local/nginx/sbin/nginx"]


EXPOSE 80/tcp 443/tcp 1935/tcp
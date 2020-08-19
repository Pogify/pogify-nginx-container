FROM alpine:latest AS build

RUN apk add --no-cache g++ && \
  apk add --no-cache pcre-dev && \
  apk add --no-cache zlib-dev && \
  apk add --no-cache make && \
  apk add --no-cache git

# nginx version 1.18.0
RUN wget http://nginx.org/download/nginx-1.18.0.tar.gz && tar xzvf nginx-1.18.0.tar.gz

# nginx-push-stream-module lastest
RUN git clone https://github.com/wandenberg/nginx-push-stream-module.git

RUN ls
# remove *.tar.gz
RUN rm -rf *.tar.gz

WORKDIR /nginx-1.18.0

# configure 

RUN ./configure --add-module=../nginx-push-stream-module
RUN make
RUN make install && \
  make clean && \
  rm -rf /nginx-1.18.0 /var/cache/apk/ /nginx-push-stream-module && \
  apk del g++ make git

FROM alpine:latest
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/

RUN apk update && \
  apk add zlib pcre

CMD ["/bin/sh", "-c", "/usr/local/nginx/sbin/nginx"]




EXPOSE 80/tcp 443/tcp 1935/tcp
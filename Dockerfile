FROM ubuntu:latest AS build

RUN apt-get update && apt-get install build-essential wget git libpcre3 libpcre3-dev zlib1g openssl -y
RUN apt-get install zlib1g-dev -y

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
RUN make install

# CMD ["nginx", "-g", "daemon off;"]

FROM alpine:latest
COPY --from=build /usr/local/nginx/ /nginx/
RUN ls /nginx/
WORKDIR /


ENTRYPOINT ["/nginx/sbin/nginx", "-g", "daemon off;"]




EXPOSE 80/tcp 443/tcp 1935/tcp
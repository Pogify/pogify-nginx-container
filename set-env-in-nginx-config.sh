#!/bin/sh

defined_envs=$(printf '${%s} ' $(env | cut -d= -f1))
envsubst "$defined_envs" < "/usr/local/nginx/conf/nginx.conf.template" > "/usr/local/nginx/conf/nginx.conf"

echo "Generated Nginx config from env"
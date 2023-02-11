docker run -d \
-p $2:5000 \
--restart=always \
--name $1 \
-v "$(pwd)"/auth:/auth \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-v "$(pwd)"/certs:/certs \
-v "$(pwd)"/registry:/var/lib/registry/ \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
registry:2

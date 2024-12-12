#! /bin/sh

DIRNAME=$(cd `dirname $0`; pwd)

echo Dirname = $DIRNAME
echo USER=$USER
mkdir -p ${DIRNAME}/certs

. ${DIRNAME}/config.txt

# Files specific to Synology, don't modify these.
SSL_TARGET_DIR=/usr/syno/etc/www/certificate/letsencrypt

docker rm synology-letsencrypt; \
docker build -t synology-letsencrypt:latest . && \
docker run --name synology-letsencrypt \
       -v ${DIRNAME}/certs:/root \
       --env-file config.txt \
       synology-letsencrypt

SSL_SRC_DIR=${DIRNAME}/certs/.acme.sh/${HOST}_ecc
echo Looking at files in $SSL_SRC_DIR
ls -alF $SSL_SRC_DIR

if [ -f $SSL_TARGET_DIR/fullchain.pem -a \
        -f $SSL_TARGET_DIR/privkey.pem -a \
        -z "$(diff $SSL_SRC_DIR/fullchain.cer $SSL_TARGET_DIR/fullchain.pem)" -a \
        -z "$(diff $SSL_SRC_DIR/$HOST.key $SSL_TARGET_DIR/privkey.pem)" \
   ]; then
    echo SSL certificates are the same, skipping.
else
    echo Certificate files were regenerated, copying to $SSL_TARGET_DIR

    # On Synology the /etc/nginx/nginx.conf file has a line that reads:
    #
    # include conf.d/ssl.*.conf
    #
    # We generate our own configuration file to include the
    # LetsEncrypt certificate just created. The certificate statements
    # will override any others that are set earlier in the nginx.conf
    # file for the server.
    (
    cat <<EOF
ssl_certificate_key $SSL_SRC_DIR/$HOST.key;
ssl_certificate     $SSL_SRC_DIR/fullchain.cer;
EOF
    )> /etc/nginx/conf.d/ssl.letsencrypt.conf

    echo Copying Lets Encrypt certificates to $SSL_TARGET_DIR
    cp $SSL_SRC_DIR/fullchain.cer $SSL_TARGET_DIR/fullchain.pem
    cp $SSL_SRC_DIR/$HOST.key $SSL_TARGET_DIR/privkey.pem

    echo Restarting nginx...
    synosystemctl restart nginx
    echo done
fi
